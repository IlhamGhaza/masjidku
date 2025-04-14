import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/utils/permisson_utils.dart';
import '../../core/utils/prayertimeinfo.dart';
import '../../data/datasource/db_local_datasource.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage>
    with SingleTickerProviderStateMixin {
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
  bool _isLoading = true;

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

    loadLocation().then((_) {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    });

    params.madhab = Madhab.shafi;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    // Reset animation and play it again
    _animationController.reset();
    _animationController.forward();
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

          // Reset animation and play it again
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
        // Show snackbar when permission is denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('location permission denied')),
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
            content: Text(e.toString()),
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
                  context.tr('location permission denied, please enable it'),
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
          // If geocoding fails, still calculate prayer times with saved coordinates
          myCoordinates = Coordinates(lat, lng);
          final prayerTimes = PrayerTimes.today(myCoordinates, params);
          updatePrayerTimes(prayerTimes);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
                                  colorScheme.primary.withOpacity(0.8),
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
                                          color: Colors.black.withOpacity(0.05),
                                          offset: const Offset(0, 1),
                                          blurRadius: 3,
                                          spreadRadius: 0,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
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
                                                colorScheme.primary.withOpacity(
                                                  0.8,
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
                                                          .withOpacity(0.2),
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

                                        // Prayer times list
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

                                // Next prayer indicator
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

  // Add this import at the top of the file

  // Then modify the _buildPrayerTimeCard method
  Widget _buildPrayerTimeCard(
    String name,
    String time,
    ColorScheme colorScheme,
    int index,
  ) {
    // Get the current prayer
    final currentPrayer = PrayerTimeUtils.getCurrentPrayer(
      imsak: imsak,
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    // Check if this is the current prayer
    final isCurrentPrayer = (name == currentPrayer);

    return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isCurrentPrayer
                      ? colorScheme.primaryContainer.withOpacity(0.3)
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isCurrentPrayer
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.2),
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
                            'Now',
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
                          // Show a dialog to set alarm
                          _showSetAlarmDialog(context, name, time);
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          color:
                              isCurrentPrayer
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isCurrentPrayer
                                  ? colorScheme.primaryContainer.withOpacity(
                                    0.5,
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

  // bool _isNextPrayer(String prayerName) {
  //   // Logic to determine if this is the next prayer time
  //   // This is a placeholder - you would implement actual logic based on current time
  //   DateTime now = DateTime.now();

  //   // Example implementation (simplified)
  //   if (prayerName == 'Shubuh' && now.hour < 5) return true;
  //   if (prayerName == 'Zuhur' && now.hour >= 5 && now.hour < 12) return true;
  //   if (prayerName == 'Ashar' && now.hour >= 12 && now.hour < 15) return true;
  //   if (prayerName == 'Maghrib' && now.hour >= 15 && now.hour < 18) return true;
  //   if (prayerName == 'Isya' && now.hour >= 18) return true;

  //   return false;
  // }

  void _showSetAlarmDialog(
    BuildContext context,
    String prayerName,
    String time,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Alarm for $prayerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Would you like to set an alarm for $prayerName at $time?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 8),
                  Text('Prayer time: $time'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement alarm setting functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Alarm set for $prayerName at $time'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: Text('Set Alarm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextPrayerIndicator(ColorScheme colorScheme) {
    // Get the next prayer time using our utility class
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('next_prayer'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimaryContainer,
            ),
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
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
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
        ],
      ),
    );
  }
}

// Extension method to add spacing between widgets in a column or row
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

// Extension method to add withValues to Color for opacity
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
