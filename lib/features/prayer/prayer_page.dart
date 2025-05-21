import 'package:adhan/adhan.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/utils/permisson_utils.dart';
import '../../core/utils/prayertimeinfo.dart';
import '../../data/datasource/db_local_datasource.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage>
    with SingleTickerProviderStateMixin {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool notificationsInitialized = false;
  var myCoordinates = Coordinates(-6.537132990026773, 106.79284326451504);
  final params = CalculationMethod.singapore.getParameters();
  String? imsak;
  String? fajr;
  String? sunrise;
  String? dhuhr;
  String? asr;
  String? maghrib;
  String? isha;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late tz.Location local;
  bool _isLocalTimeZoneResolved = true;
  bool _isLoading = true;

  Map<String, int> alarmIds = {};

  Map<String, bool> alarmsSet = {};

  Future<void> _initializeNotifications() async {
    if (notificationsInitialized) return;
    debugPrint('[PrayerPage] Initializing local notifications...');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    notificationsInitialized = true;
    debugPrint('[PrayerPage] Local notifications initialized successfully.');
  }


  /// Schedules a persistent local notification for the given prayer name at the given
  /// prayer time. The notification will have a unique ID based on the prayer name and
  /// will be scheduled using the local timezone. If the prayer time is in the past, the
  /// notification will not be scheduled.
  Future<void> _schedulePersistentNotification(
    String prayerName,
    DateTime prayerTime,
  ) async {
    await _initializeNotifications();
    debugPrint(
      '[PrayerPage] Attempting to schedule persistent notification for $prayerName at $prayerTime',
    );

    final int notificationId = alarmIds[prayerName] ?? 0;
    debugPrint('[PrayerPage] Notification ID for $prayerName: $notificationId');

    // Only schedule if the prayer time is in the future
    if (prayerTime.isAfter(DateTime.now())) {
      debugPrint(
        '[PrayerPage] Prayer time for $prayerName is in the future. Proceeding with scheduling.',
      );
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true, // Makes notification persistent
            autoCancel: false, // Prevents user from dismissing
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      try {
        debugPrint(
          '[PrayerPage] Scheduling notification for $prayerName with ID $notificationId at $prayerTime using timezone $local',
        );
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          '${context.tr('prayer_time_for')} $prayerName',
          '${context.tr('its_time_for')} $prayerName ${context.tr('prayer_at')} ${DateFormat.jm().format(prayerTime)}',
          tz.TZDateTime.from(prayerTime, local),
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'prayer_page_notification', // Tambahkan payload ini
        );
        debugPrint(
          '[PrayerPage] Successfully scheduled notification for $prayerName (ID: $notificationId).',
        );
      } catch (e) {
        debugPrint(
          '[PrayerPage] ERROR scheduling notification for $prayerName (ID: $notificationId): $e',
        );
      }
    } else {
      debugPrint(
        '[PrayerPage] Prayer time for $prayerName ($prayerTime) is in the past. Notification not scheduled.',
      );
    }
  }

  /// Called when a notification is tapped.
  ///
  /// If the notification's payload is 'prayer_page_notification',
  /// navigates to [PrayerPage].
  ///
  /// Note that this will push a new instance of [PrayerPage] onto the
  /// navigation stack. If [PrayerPage] is already open, this will
  /// open another one on top of it. Consider using a more sophisticated
  /// navigation logic if needed (e.g. using [Navigator.pushReplacement]
  /// or checking if already on [PrayerPage]).
  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null && payload == 'prayer_page_notification') {
      debugPrint(
        '[PrayerPage] Notification tapped with payload: $payload. Navigating to PrayerPage.',
      );
      if (mounted) {
        // Navigasi ke PrayerPage.
        // Ini akan mendorong instance baru PrayerPage ke atas stack navigasi.
        // Jika PrayerPage sudah terbuka, ini akan membuka satu lagi di atasnya.
        // Pertimbangkan logika navigasi yang lebih canggih jika perlu
        // (misalnya, menggunakan Navigator.pushReplacement atau memeriksa apakah sudah di PrayerPage).
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PrayerPage(),
        ));
      }
    }
  }

  /// Jadwalkan notifikasi untuk semua waktu sholat di tanggal yang
  /// saat ini dipilih. Notifikasi akan dijadwalkan berdasarkan waktu
  /// lokal jika zona waktu lokal berhasil diresolusi. Jika tidak, maka
  /// notifikasi akan dijadwalkan berdasarkan waktu UTC.
  Future<void> _scheduleAllPrayerNotifications() async {
    debugPrint('[PrayerPage] _scheduleAllPrayerNotifications called.');
    if (!_isLocalTimeZoneResolved) {
      debugPrint(
        '[PrayerPage] WARNING: Local timezone was not resolved. Notifications might be scheduled based on UTC.',
      );
    }
    if (imsak != null) {
      final imsakTime = _parseTimeString(imsak!, selectedDate);
      await _schedulePersistentNotification('Imsak', imsakTime);
    }
    if (fajr != null) {
      final fajrTime = _parseTimeString(fajr!, selectedDate);
      await _schedulePersistentNotification('Shubuh', fajrTime);
    }
    if (sunrise != null) {
      final sunriseTime = _parseTimeString(sunrise!, selectedDate);
      await _schedulePersistentNotification('Terbit', sunriseTime);
    }

    if (dhuhr != null) {
      final dhuhrTime = _parseTimeString(dhuhr!, selectedDate);
      await _schedulePersistentNotification('Zuhur', dhuhrTime);
    }
    if (asr != null) {
      final asrTime = _parseTimeString(asr!, selectedDate);
      await _schedulePersistentNotification('Ashar', asrTime);
    }
    if (maghrib != null) {
      final maghribTime = _parseTimeString(maghrib!, selectedDate);
      await _schedulePersistentNotification('Maghrib', maghribTime);
    }
    if (isha != null) {
      final ishaTime = _parseTimeString(isha!, selectedDate);
      await _schedulePersistentNotification('Isya', ishaTime);
    }
    debugPrint(
      '[PrayerPage] Finished scheduling all prayer notifications for date: $selectedDate',
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Initialize timezone data
    tz_data.initializeTimeZones();
    debugPrint('[PrayerPage] Timezone data initialized.');
    try {
      local = tz.local;
      _isLocalTimeZoneResolved = true;
      debugPrint('[PrayerPage] Local timezone resolved: $local');
    } catch (e) {
      debugPrint(
        "Error initializing local timezone: $e. Falling back to UTC for notifications.",
      );
      // Fallback to UTC to prevent LateInitializationError.
      // Notifications might be scheduled based on UTC if local timezone is not found.
      local = tz.UTC;
      _isLocalTimeZoneResolved = false;
    }

    Alarm.init();
    _loadAlarmStates();

    loadLocation().then((_) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();

      debugPrint(
        '[PrayerPage] initState: Calling _scheduleAllPrayerNotifications after loadLocation.',
      );
      _scheduleAllPrayerNotifications();
    });

    params.madhab = Madhab.shafi;
  }

  Future<void> _loadAlarmStates() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint(
      '[PrayerPage] Loading alarm states and IDs from SharedPreferences.',
    );
    setState(() {
      alarmsSet = {
        'Imsak': prefs.getBool('alarm_Imsak') ?? false,
        'Shubuh': prefs.getBool('alarm_Shubuh') ?? false,
        'Terbit': prefs.getBool('alarm_Terbit') ?? false,
        'Zuhur': prefs.getBool('alarm_Zuhur') ?? false,
        'Ashar': prefs.getBool('alarm_Ashar') ?? false,
        'Maghrib': prefs.getBool('alarm_Maghrib') ?? false,
        'Isya': prefs.getBool('alarm_Isya') ?? false,
      };

      alarmIds = {
        'Imsak': prefs.getInt('alarmId_Imsak') ?? 0,
        'Shubuh': prefs.getInt('alarmId_Shubuh') ?? 1,
        'Terbit': prefs.getInt('alarmId_Terbit') ?? 2,
        'Zuhur': prefs.getInt('alarmId_Zuhur') ?? 3,
        'Ashar': prefs.getInt('alarmId_Ashar') ?? 4,
        'Maghrib': prefs.getInt('alarmId_Maghrib') ?? 5,
        'Isya': prefs.getInt('alarmId_Isya') ?? 6,
      };
      debugPrint('[PrayerPage] Loaded alarmIds: $alarmIds');
    });
  }

  Future<void> _saveAlarmState(String prayerName, bool isSet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_$prayerName', isSet);
  }

  Future<void> _saveAlarmId(String prayerName, int alarmId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('alarmId_$prayerName', alarmId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Calculates prayer times for the given date and updates the UI.
  ///
  /// This function will also schedule all prayer notifications for the given
  /// date.
  void calculatePrayerTimes(DateTime date) {
    setState(() {
      _isLoading = true;
      debugPrint('[PrayerPage] calculatePrayerTimes called for date: $date');
    });

    DateComponents dateComponents = DateComponents(
      date.year,
      date.month,
      date.day,
    );
    final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

    setState(() {
      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      selectedDate = date;
      _isLoading = false;
    });

    _animationController.reset();
    _animationController.forward();
    debugPrint(
      '[PrayerPage] calculatePrayerTimes: Calling _scheduleAllPrayerNotifications.',
    );
    _scheduleAllPrayerNotifications();
  }


  void onChangeDate(int days) {
    DateTime newDate = selectedDate.add(Duration(days: days));
    calculatePrayerTimes(newDate);
  }

  refreshLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final permissionStatus = await requestLocationPermission();
      if (permissionStatus) {
        final location = await determinePosition();
        myCoordinates = Coordinates(location.latitude, location.longitude);
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          locationNow = "${place.subAdministrativeArea}, ${place.country}";
          final prayerTimes = PrayerTimes.today(myCoordinates, params);

          imsak = DateFormat.jm().format(
            prayerTimes.fajr.subtract(Duration(minutes: 10)),
          );
          fajr = DateFormat.jm().format(prayerTimes.fajr);
          sunrise = DateFormat.jm().format(prayerTimes.sunrise);
          dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
          asr = DateFormat.jm().format(prayerTimes.asr);
          maghrib = DateFormat.jm().format(prayerTimes.maghrib);
          isha = DateFormat.jm().format(prayerTimes.isha);
          setState(() {
            _isLoading = false;
          });

          _animationController.reset();
          _animationController.forward();
        }
        await DbLocalDatasource().saveLatLng(
          location.latitude,
          location.longitude,
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr('loc_per_denied'),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Loads the current location and updates the prayer times accordingly.
  ///
  /// If location permission is granted, it will use the saved coordinates from
  /// the database. If not, it will show a snackbar to request permission.
  ///
  /// If saved coordinates are not available, it will use the default coordinates.
  /// If the geocoding fails, it will use the default coordinates.
  Future<void> loadLocation() async {
    try {
      final permissionStatus = await requestLocationPermission();
      final latLng = await DbLocalDatasource().getLatLng();

      if (latLng.isEmpty) {
        if (permissionStatus) {
          await refreshLocation();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.tr('loc_per_denied_2'),
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          final prayerTimes = PrayerTimes.today(myCoordinates, params);
          updatePrayerTimes(prayerTimes);
        }
      } else {
        double lat = latLng[0];
        double lng = latLng[1];
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

          if (placemarks.isNotEmpty) {
            myCoordinates = Coordinates(lat, lng);
            Placemark place = placemarks[0];
            locationNow = "${place.subAdministrativeArea}, ${place.country}";
            final prayerTimes = PrayerTimes.today(myCoordinates, params);
            updatePrayerTimes(prayerTimes);
          }
        } catch (e) {
          myCoordinates = Coordinates(lat, lng);
          final prayerTimes = PrayerTimes.today(myCoordinates, params);
          updatePrayerTimes(prayerTimes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Updates the prayer times and schedules all prayer notifications.
  ///
  /// This function takes a [PrayerTimes] object as a parameter and updates
  /// the prayer times displayed on the prayer page. It also schedules all
  /// prayer notifications for the given date.
  ///
  /// The prayer times are updated by subtracting 10 minutes from the fajr time
  /// and formatting the times using the [DateFormat.jm] format. The
  /// [_isLoading] flag is set to false and the [_scheduleAllPrayerNotifications]
  /// function is called to schedule all prayer notifications.
  void updatePrayerTimes(PrayerTimes prayerTimes) {
    setState(() {
      imsak = DateFormat.jm().format(
        prayerTimes.fajr.subtract(Duration(minutes: 10)),
      );
      fajr = DateFormat.jm().format(prayerTimes.fajr);
      sunrise = DateFormat.jm().format(prayerTimes.sunrise);
      dhuhr = DateFormat.jm().format(prayerTimes.dhuhr);
      asr = DateFormat.jm().format(prayerTimes.asr);
      maghrib = DateFormat.jm().format(prayerTimes.maghrib);
      isha = DateFormat.jm().format(prayerTimes.isha);
      _isLoading = false;
    });
    debugPrint(
      '[PrayerPage] updatePrayerTimes: Calling _scheduleAllPrayerNotifications.',
    );
    _scheduleAllPrayerNotifications();
  }

  DateTime selectedDate = DateTime.now();
  String locationNow = 'Kab Bogor, Indonesia';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        final screenSize = MediaQuery.of(context).size;

        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            elevation: 0,
            title: Text(
              context.tr('prayer_times'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('id', 'ID'),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: colorScheme.primary,
                            onPrimary: Colors.white,
                            surface: colorScheme.surface,
                            onSurface: colorScheme.onSurface,
                          ),
                          dialogBackgroundColor: colorScheme.background,
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    selectedDate = pickedDate;
                    calculatePrayerTimes(pickedDate);
                  }
                },
                icon: const Icon(Icons.calendar_month),
                tooltip: context.tr('select_date'),
              ),
              IconButton(
                onPressed: () {
                  refreshLocation();
                },
                icon: const Icon(Icons.refresh),
                tooltip: context.tr('refresh_location'),
              ),
            ],
          ),
          body: SafeArea(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: screenSize.width,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      locationNow,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 16.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.tr("today"),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onBackground,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            onChangeDate(-1);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.primaryContainer,
                                            foregroundColor:
                                                colorScheme.onPrimaryContainer,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(8),
                                            minimumSize: Size.zero,
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            onChangeDate(1);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                colorScheme.primaryContainer,
                                            foregroundColor:
                                                colorScheme.onPrimaryContainer,
                                            shape: const CircleBorder(),
                                            padding: const EdgeInsets.all(8),
                                            minimumSize: Size.zero,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ).animate().fadeIn(
                                  duration: 600.ms,
                                  delay: 100.ms,
                                ),

                                const SizedBox(height: 16),

                                AnimatedBuilder(
                                  animation: _fadeAnimation,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _fadeAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: colorScheme.surface,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.06,
                                          ),
                                          offset: const Offset(0, 3),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight: Radius.circular(20),
                                                ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                colorScheme.primary,
                                                colorScheme.primary.withValues(
                                                  alpha: 0.8,
                                                ),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        DateFormat(
                                                          'dd MMMM yyyy',
                                                        ).format(selectedDate),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        Hijriyah.fromDate(
                                                          selectedDate
                                                              .toLocal(),
                                                        ).toFormat(
                                                          "dd MMMM yyyy",
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.mosque_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              _buildPrayerTimeCard(
                                                'Imsak',
                                                imsak ?? "-",
                                                colorScheme,
                                                0,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Shubuh',
                                                fajr ?? "-",
                                                colorScheme,
                                                1,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Terbit',
                                                sunrise ?? "-",
                                                colorScheme,
                                                2,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Zuhur',
                                                dhuhr ?? "-",
                                                colorScheme,
                                                3,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Ashar',
                                                asr ?? "-",
                                                colorScheme,
                                                4,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Maghrib',
                                                maghrib ?? "-",
                                                colorScheme,
                                                5,
                                              ),
                                              _buildPrayerTimeCard(
                                                'Isya',
                                                isha ?? "-",
                                                colorScheme,
                                                6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                _buildNextPrayerIndicator(colorScheme)
                                    .animate()
                                    .fadeIn(duration: 800.ms, delay: 300.ms)
                                    .slideY(begin: 0.2, end: 0),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }

  /// Parse a time string in the format of "HH:mm" and return the corresponding
  /// DateTime object with the given [date].
  ///
  /// The [timeString] will be parsed with the [DateFormat.jm()] format, and the
  /// resulting [DateTime] object will be constructed with the year, month, day,
  /// hour, and minute from the parsed time and the given [date].
  ///
  /// The returned [DateTime] object will have the same year, month, and day as
  /// the given [date], and the hour and minute will be taken from the parsed
  /// time.
  ///
  /// If the [timeString] is null or empty, or if the [date] is null, the
  /// function will throw an exception.
  ///
  /// Example:
  ///
  ///     final date = DateTime(2022, 1, 1);
  ///     final timeString = '12:34';
  ///     final parsedDateTime = _parseTimeString(timeString, date);
  ///     // parsedDateTime is DateTime(2022, 1, 1, 12, 34)
  DateTime _parseTimeString(String? timeString, DateTime date) {
    if (timeString == null || timeString.isEmpty) {
      debugPrint(
        '[PrayerPage] _parseTimeString: timeString is null or empty for date $date. Returning date as is.',
      );
      return date; // Or throw an error, depending on desired behavior
    }
    final format = DateFormat.jm();
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Sets an alarm for the given [prayerName] at the given [timeString].
  ///
  /// The alarm will be set for the given [timeString] on the current date,
  /// and will play the audio file at "assets/audios/mecca.mp3".
  ///
  /// If the [timeString] is in the past, a snackbar will be shown with an
  /// orange background and a message indicating that the time has passed.
  ///
  /// If the alarm is set successfully, a snackbar will be shown with a green
  /// background and a message indicating that the alarm has been set.
  ///
  /// If an error occurs when setting the alarm, a snackbar will be shown with
  /// a red background and a message indicating the error.
  Future<void> _setAlarm(String prayerName, String timeString) async {
    try {
      final prayerDateTime = _parseTimeString(timeString, selectedDate);

      // if (prayerDateTime.isBefore(DateTime.now())) {
      //   if (selectedDate.day == DateTime.now().day) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //           '${context.tr('time_pass')} $prayerName',
      //           style: TextStyle(color: Colors.white),
      //         ),
      //         backgroundColor: Colors.orange,
      //         behavior: SnackBarBehavior.floating,
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(10),
      //         ),
      //       ),
      //     );
      //     return;
      //   }
      // }

      final alarmId = alarmIds[prayerName] ?? 0;

      final alarmSettings = AlarmSettings(
        id: alarmId,
        dateTime: prayerDateTime,
        assetAudioPath: 'assets/audios/mecca.mp3',
        loopAudio: false,
        vibrate: true,
        volumeSettings: VolumeSettings.fade(
          volume: 0.3,
          fadeDuration: Duration(seconds: 5),
          volumeEnforced: true,
        ),
        notificationSettings: NotificationSettings(
          title: '${context.tr('prayer_time_for')} $prayerName',
          body:
              '${context.tr('its_time_for')} $prayerName ${context.tr('prayer_at')} $timeString',
          stopButton: context.tr('stop'),
          icon: '@mipmap/ic_launcher', 
          iconColor: Color(0xff862778),
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);

      setState(() {
        alarmsSet[prayerName] = true;
      });

      await _saveAlarmState(prayerName, true);
      await _saveAlarmId(prayerName, alarmId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('alarm_set')} $prayerName at $timeString',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('alarm_error')}: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  /// Cancels an alarm for the given [prayerName].
  ///
  /// If the alarm is not set, a snackbar will be shown with a red background
  /// and a message indicating the error.
  ///
  /// If the alarm is set successfully, a snackbar will be shown with a blue
  /// background and a message indicating that the alarm has been canceled.
  ///
  /// If an error occurs when canceling the alarm, a snackbar will be shown with
  /// a red background and a message indicating the error.
  Future<void> _cancelAlarm(String prayerName) async {
    try {
      final alarmId = alarmIds[prayerName] ?? 0;

      await Alarm.stop(alarmId);

      setState(() {
        alarmsSet[prayerName] = false;
      });

      await _saveAlarmState(prayerName, false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('alarm_canceled')} $prayerName',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('cancel_error')}: $e',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }


  /// Shows an alert dialog to set or cancel an alarm for the given [prayerName] at the given [time].
  ///
  /// If an alarm is already set for the given [prayerName], the dialog will ask the user if they want to cancel the alarm.
  /// If no alarm is set, the dialog will ask the user if they want to set an alarm.
  ///
  /// The dialog will also show the [time] of the prayer.
  ///
  /// The [colorScheme] parameter is used to style the buttons in the dialog.
  void _showSetAlarmDialog(
    BuildContext context,
    String prayerName,
    String time,
    ColorScheme colorScheme,
  ) {
    final bool isAlarmSet = alarmsSet[prayerName] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isAlarmSet
                ? '${context.tr('manage_alarm_for')} $prayerName'
                : '${context.tr('set_alarm_for')} $prayerName',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isAlarmSet)
                Text(
                  '${context.tr('would_you_like_to_set_alarm')} $prayerName at $time?',
                ),
              if (isAlarmSet)
                Text('${context.tr('alarm_already_set')} $prayerName at $time'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('${context.tr('prayer_time ')}$time'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('cancel')),
            ),
            if (!isAlarmSet)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _setAlarm(prayerName, time);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('set_alarm')),
              ),
            if (isAlarmSet)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _cancelAlarm(prayerName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.tr('cancel_alarm')),
              ),
          ],
        );
      },
    );
  }

  /// Builds a card to display a single prayer time.
  ///
  /// The card will highlight the current prayer time and show an alarm icon if
  /// the alarm is set for that prayer time.
  ///
  /// The [name] parameter specifies the name of the prayer time (e.g. "Imsak").
  ///
  /// The [time] parameter specifies the time of the prayer in the format "HH:mm".
  ///
  /// The [colorScheme] parameter specifies the color scheme to use for the card.
  ///
  /// The [index] parameter specifies the index of the card in the list of prayer
  /// times. This is used to animate the card into view with a staggered animation.
  Widget _buildPrayerTimeCard(
    String name,
    String time,
    ColorScheme colorScheme,
    int index,
  ) {
    final currentPrayer = PrayerTimeUtils.getCurrentPrayer(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    final isCurrentPrayer = (name == currentPrayer);

    final isAlarmSet = alarmsSet[name] ?? false;

    return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isCurrentPrayer
                      ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isCurrentPrayer
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.2),
                width: isCurrentPrayer ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isCurrentPrayer
                                  ? colorScheme.primary
                                  : colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getPrayerIcon(name),
                          color:
                              isCurrentPrayer
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCurrentPrayer
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      if (isCurrentPrayer)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            context.tr('now'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCurrentPrayer
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                          color:
                              isCurrentPrayer
                                  ? colorScheme.primary
                                  : colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          _showSetAlarmDialog(context, name, time, colorScheme);
                        },
                        icon: Icon(
                          isAlarmSet
                              ? Icons.notifications_active
                              : Icons.notifications_outlined,
                          color:
                              isAlarmSet
                                  ? Colors.orange
                                  : isCurrentPrayer
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isAlarmSet
                                  ? Colors.orange.withValues(alpha: 0.2)
                                  : isCurrentPrayer
                                  ? colorScheme.primaryContainer.withValues(
                                    alpha: 0.5,
                                  )
                                  : Colors.transparent,
                          padding: EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
        .slideX(begin: 0.1, end: 0);
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'imsak':
        return Icons.nightlight_round;
      case 'shubuh':
        return Icons.wb_twilight;
      case 'terbit':
        return Icons.wb_sunny_outlined;
      case 'zuhur':
        return Icons.sunny;
      case 'ashar':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isya':
        return Icons.dark_mode_outlined;
      default:
        return Icons.access_time;
    }
  }

  /// Builds a widget that displays the next prayer information, including the
  /// name of the prayer, the time it will occur, and the remaining time until
  /// the prayer. The widget also displays an alarm indicator if the alarm is
  /// set for the next prayer, and an "Set Alarm" or "Cancel Alarm" button to
  /// toggle the alarm state.
  Widget _buildNextPrayerIndicator(ColorScheme colorScheme) {
    final nextPrayerInfo = PrayerTimeUtils.getNextPrayer(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    final nextPrayer = nextPrayerInfo.name;
    final nextTime = DateFormat.jm().format(nextPrayerInfo.time);
    final timeRemaining = nextPrayerInfo.timeRemaining;

    final isAlarmSet = alarmsSet[nextPrayer] ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('next_prayer'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              if (isAlarmSet)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 14,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('alarm_set'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPrayerIcon(nextPrayer),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextPrayer,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        nextTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      timeRemaining,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (isAlarmSet) {
                _cancelAlarm(nextPrayer);
              } else {
                _setAlarm(nextPrayer, nextTime);
              }
            },
            icon: Icon(
              isAlarmSet ? Icons.notifications_off : Icons.notifications_active,
              size: 18,
            ),
            label: Text(
              isAlarmSet
                  ? context.tr('cancel_next_prayer_alarm')
                  : context.tr('set_next_prayer_alarm'),
              style: TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAlarmSet ? Colors.red : colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension SpacingExtension on List<Widget> {
  List<Widget> get spacing {
    if (isEmpty) return this;

    return expand((widget) sync* {
        yield widget;
        yield SizedBox(height: 10, width: 10);
      }).toList()
      ..removeLast();
  }
}

extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.opacity,
    );
  }
}
