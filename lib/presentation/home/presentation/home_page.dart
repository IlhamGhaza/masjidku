import 'dart:math';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import '../../../core/services/prayer_notification_service.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/permisson_utils.dart';
import '../../../core/utils/prayertimeinfo.dart';
import '../../../data/datasource/db_local_datasource.dart';
import '../../event/upcoming_event_page.dart';
import '../../prayer/prayer_page.dart';
import '../../account/presentation/profile_page.dart';
import '../widget/glassmorphic_icon_widget.dart';
import '../widget/grid_icon_widget.dart';
import '../widget/next_prayer_widget.dart';
import '../widget/see_all_widget.dart';
import 'notification_page.dart';
import 'package:masjidku/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //list event (tanggal dan bulan, nama, desc, waktu)
  final List<Map<String, dynamic>> _events = [
    {
      'date': '1',
      'month': 'Januari',
      'name': 'Friday Khutbah',
      'desc': 'Topic: The Importance of Charity',
      'time': '1:30 PM - 2:30 PM',
    },
    {
      'date': '2',
      'month': 'Januari',
      'name': 'Khatib',
      'desc': 'Khatib Masjid',
      'time': '08:00',
    },
  ];
  //annoucement (icon, title, desc, date)
  final List<Map<String, dynamic>> _announcements = [
    {
      'icon': Icons.announcement,
      'title': 'Announcement 1',
      'desc': 'This is the first announcement.',
      'date': '2023-01-01',
    },
    {
      'icon': Icons.announcement,
      'title': 'Announcement 2',
      'desc': 'This is the second announcement.',
      'date': '2023-01-02',
    },
  ];

  final List<Color> _iconColors = [
    AppTheme.lightTheme.colorScheme.primary,
    AppTheme.lightTheme.colorScheme.error,
    AppTheme.successColor,
    AppTheme.warningColor,
    AppTheme.lightTheme.colorScheme.secondary,
    AppTheme.infoColor,
    AppTheme.lightTheme.colorScheme.primaryContainer,
    AppTheme.lightTheme.colorScheme.onPrimaryContainer,
  ];

  // late final Color _selectedColor;
  var myCoordinates = Coordinates(-6.537132990026773, 106.79284326451504);
  final params = CalculationMethod.singapore.getParameters();
  String? imsak;
  String? fajr;
  String? sunrise;
  String? dhuhr;
  String? asr;
  String? maghrib;
  String? isha;

  bool _isLoading = true;
  bool _isAnyAlarmOn = false;
  final List<String> _prayerNames = [
    'Imsak',
    'Shubuh',
    'Terbit',
    'Zuhur',
    'Ashar',
    'Maghrib',
    'Isya',
  ];

  @override
  void initState() {
    super.initState();
    final notificationService = PrayerNotificationService();
    notificationService.setNotificationResponseCallback((response) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PrayerPage()),
        );
      }
    });
    _checkAlarmStatus();
    _schedulePrayerNotifications();
    final random = Random();
    // _selectedColor = _iconColors[random.nextInt(_iconColors.length)];
    loadLocation().then((_) {
      setState(() {
        _isLoading = false;
      });
    });

    params.madhab = Madhab.shafi;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _schedulePrayerNotifications() {
    if (imsak != null &&
        fajr != null &&
        sunrise != null &&
        dhuhr != null &&
        asr != null &&
        maghrib != null &&
        isha != null) {
      final notificationService = PrayerNotificationService();
      notificationService.scheduleAllPrayerNotifications(
        imsak: imsak,
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha,
        selectedDate: DateTime.now(),
        context: context,
        latitude: myCoordinates.latitude,
        longitude: myCoordinates.longitude,
      );
    }
  }

  void calculatePrayerTimes(DateTime date) {
    setState(() {
      _isLoading = true;
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
        }
        await DbLocalDatasource().saveLatLng(
          location.latitude,
          location.longitude,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        // Show snackbar when permission is denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.loc_per_denied),
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
    }
  }

  Future<void> loadLocation() async {
    try {
      final permissionStatus = await requestLocationPermission();
      final latLng = await DbLocalDatasource().getLatLng();

      if (latLng.isEmpty) {
        if (permissionStatus) {
          await refreshLocation();
        } else {
          // Show snackbar when permission is denied
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.loc_per_denied_2,
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
          // Use default coordinates
          final prayerTimes = PrayerTimes.today(myCoordinates, params);
          _updatePrayerTimes(prayerTimes);
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
            _updatePrayerTimes(prayerTimes);
          }
        } catch (e) {
          // If geocoding fails, still calculate prayer times with saved coordinates
          myCoordinates = Coordinates(lat, lng);
          final prayerTimes = PrayerTimes.today(myCoordinates, params);
          _updatePrayerTimes(prayerTimes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
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
    }
  }

  void _updatePrayerTimes(PrayerTimes prayerTimes) {
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
      _schedulePrayerNotifications();
    });
  }

  DateTime selectedDate = DateTime.now();
  String locationNow = 'Kab Bogor, Indonesia';

  Future<void> _handleRefresh() async {
    await refreshLocation();
    _checkAlarmStatus;

    setState(() {});
  }

  Future<void> _checkAlarmStatus() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      bool anyOn = false;
      for (String prayerName in _prayerNames) {
        // Check the boolean flag for each prayer alarm key
        if (prefs.getBool('alarm_$prayerName') ?? false) {
          anyOn = true;
          break; // If one is found, no need to check further
        }
      }
      // Update the state with the result
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isAnyAlarmOn = anyOn;
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      // Handle potential errors reading SharedPreferences
      print("Error reading alarm status: $e");
      if (mounted) {
        setState(() {
          _isAnyAlarmOn = false; // Default to off on error
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  //header
                  Container(
                    height: 210,
                    width: screenSize.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.onPrimaryContainer,
                          colorScheme.primary,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Column(
                                  spacing: 4,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MasjidKu',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Text(
                                    //   'Bogor, Jawa Barat',
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.bold,
                                    //     color: Colors.white,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  //notification
                                  GlassmorphicIconWidget(
                                    icon: Icons.notifications,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationPage(),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8.0),
                                  GlassmorphicIconWidget(
                                    icon: Icons.notifications,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfilePage(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDateCard(
                            DateFormat('dd MMMM yyyy').format(DateTime.now()),
                            Hijriyah.fromDate(
                              DateTime.now().toLocal(),
                            ).toFormat("dd MMMM yyyy"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //main content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        //card prayer
                        Container(
                          padding: EdgeInsets.all(20.0),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16.0),
                            image: DecorationImage(
                              image: AssetImage(
                                DateTime.now().hour >= 6 &&
                                        DateTime.now().hour < 17
                                    ? 'assets/images/duhur.png'
                                    : 'assets/images/banner.png',
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.3),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Current location and prayer time info
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Current location
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          locationNow,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Current time
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Current Time: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'HH:mm',
                                          ).format(DateTime.now()),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Current prayer time
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.4,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.mosque_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Current Prayer: ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          PrayerTimeUtils.getCurrentPrayer(
                                            imsak: imsak,
                                            fajr: fajr,
                                            sunrise: sunrise,
                                            dhuhr: dhuhr,
                                            asr: asr,
                                            maghrib: maghrib,
                                            isha: isha,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              // Next prayer time info at the bottom
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Time to next prayer
                                      NextPrayerWidget(
                                        imsak: imsak.toString(),
                                        fajr: fajr.toString(),
                                        sunrise: sunrise.toString(),
                                        dhuhr: dhuhr.toString(),
                                        asr: asr.toString(),
                                        maghrib: maghrib.toString(),
                                        isha: isha.toString(),
                                      ),
                                      // See all button
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PrayerPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.see_all,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Prayer time indicator
                              Positioned(
                                top: 70,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        // Conditional Icon
                                        _isAnyAlarmOn
                                            ? Icons.notifications_active
                                            : Icons.notifications_off_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4), // Adjusted spacing
                                      Text(
                                        // Conditional Text
                                        _isAnyAlarmOn
                                            ? 'Notif On'
                                            : 'Notif Off',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        //icon
                        const GridIconWidget(),
                        const SizedBox(height: 16),
                        //announcement
                        SeeAllWidget(
                          colorScheme: colorScheme,
                          context: context,
                          text: AppLocalizations.of(context)!.announcement,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpcomingEventPage(),
                              ),
                            );
                          },
                        ),
                        //announcement section
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: _announcements.length,
                            itemBuilder: (context, index) {
                              final itemColor =
                                  _iconColors[index % _iconColors.length];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        offset: Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: itemColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            _announcements[index]['icon'],
                                            color: itemColor,
                                            size: 28,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _announcements[index]['title'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                _announcements[index]['desc'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.8),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _announcements[index]['date'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                        //event
                        SeeAllWidget(
                          colorScheme: colorScheme,
                          context: context,
                          text: AppLocalizations.of(context)!.upcoming_events,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpcomingEventPage(),
                              ),
                            );
                          },
                        ),
                        //event section
                        SizedBox(
                          height: 180,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: _events.length,
                            itemBuilder: (context, index) {
                              final itemColor =
                                  _iconColors[(index + 2) %
                                      _iconColors
                                          .length]; // Use different colors
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        offset: Offset(0, 1),
                                        blurRadius: 3,
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.06,
                                        ),
                                        offset: Offset(0, 3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            color: itemColor.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                _events[index]['date'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: itemColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                _events[index]['month']
                                                    .substring(0, 3),
                                                style: TextStyle(
                                                  color: itemColor,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _events[index]['name'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              Text(
                                                _events[index]['desc'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: colorScheme.onSurface
                                                      .withValues(alpha: 0.8),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: colorScheme.onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    _events[index]['time'],
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: colorScheme
                                                          .onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        //donate
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.current_campaign,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Mosque Renovation Project',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Help us renovate our mosque to accommodate more worshippers and improve facilities.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDarkMode
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : Colors.black.withValues(alpha: 0.7),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Donation successful!',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                backgroundColor: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.donate_now,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //

  //
  Widget _buildDateCard(String gregorianDate, String hijriDate) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.today,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gregorianDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppLocalizations.of(context)!.hijri,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hijriDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
}
