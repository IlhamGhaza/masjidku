import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/number_symbols_data.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'dart:ui';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/permisson_utils.dart';
import '../../../core/utils/prayertimeinfo.dart';
import '../../../data/datasource/db_local_datasource.dart';
import '../../event/announcement_page.dart';
import '../../event/upcoming_event_page.dart';
import '../../prayer/prayer_page.dart';
import '../../account/presentation/profile_page.dart';
import '../widget/icon_home_widget.dart';
import 'notification_page.dart';

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

  late final Color _selectedColor;
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

  @override
  void initState() {
    super.initState();
    final random = Random();
    _selectedColor = _iconColors[random.nextInt(_iconColors.length)];
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
          body: SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                //header
                Container(
                  height: 180,
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
                                _buildGlassmorphicIcon(Icons.notifications, () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotificationPage(),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 8.0),
                                _buildGlassmorphicIcon(
                                  Icons.person,
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfilePage(),
                                      ),
                                    );
                                  },
                                  // IconButton(
                                  //   onPressed: () {},
                                  //   icon: Icon(
                                  //     isDarkMode
                                  //         ? Icons.light_mode
                                  //         : Icons.dark_mode,
                                  //     color: colorScheme.onPrimary,
                                  //   ),
                                  // ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    color: Colors.black.withValues(alpha: 0.2),
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
                                        'Bogor, Jawa Barat',
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
                                    color: Colors.black.withValues(alpha: 0.2),
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
                                    _nextPrayer(),
                                    // See all button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const PrayerPage(),
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
                                      child: Text(context.tr('see_all')),
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
                                      Icons.notifications_active,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      'Notif On',
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

                      // _seeAll(colorScheme, context, 'Today Prayer', () {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(builder: (context) => PrayerPage()),
                      //   );
                      // }),
                      // // prayer time,
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     for (var prayer in prayerTimes)
                      //       GestureDetector(
                      //         onTap: () {
                      //           setState(() {
                      //             // Reset all statuses
                      //             for (var p in prayerTimes) {
                      //               p['status'] = '';
                      //             }
                      //             // Set status for the tapped prayer
                      //             prayer['status'] = 'Started';
                      //           });
                      //         },
                      //         child: Container(
                      //           width: 70,
                      //           height: 120,
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 8,
                      //             horizontal: 4,
                      //           ),
                      //           decoration: BoxDecoration(
                      //             color: colorScheme.surface,
                      //             borderRadius: BorderRadius.circular(10),
                      //             boxShadow: [
                      //               BoxShadow(
                      //                 color: Colors.black.withValues(alpha: 0.05),
                      //                 blurRadius: 5,
                      //                 spreadRadius: 1,
                      //               ),
                      //             ],
                      //           ),
                      //           child: Column(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Text(
                      //                 prayer['name'],
                      //                 style: TextStyle(
                      //                   fontSize: 12,
                      //                   color: colorScheme.onSurface.withValues(
                      //                     alpha: 0.7,
                      //                   ),
                      //                 ),
                      //               ),
                      //               const SizedBox(height: 4),
                      //               Text(
                      //                 prayer['time'],
                      //                 style: TextStyle(
                      //                   fontSize: 14,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: colorScheme.onSurface,
                      //                 ),
                      //               ),
                      //               if (prayer['status'].isNotEmpty)
                      //                 Container(
                      //                   margin: const EdgeInsets.only(top: 4),
                      //                   padding: const EdgeInsets.symmetric(
                      //                     horizontal: 6,
                      //                     vertical: 2,
                      //                   ),
                      //                   decoration: BoxDecoration(
                      //                     color: AppTheme.successColor.withValues(
                      //                       alpha: 0.2,
                      //                     ),
                      //                     borderRadius: BorderRadius.circular(10),
                      //                   ),
                      //                   child: Text(
                      //                     prayer['status'],
                      //                     style: TextStyle(
                      //                       fontSize: 10,
                      //                       color: AppTheme.successColor,
                      //                     ),
                      //                   ),
                      //                 ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //   ],
                      // ),
                      // // next prayer
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //   child: Container(
                      //     height: 55,
                      //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10),
                      //       color: colorScheme.secondary.withValues(alpha: 0.15),
                      //     ),
                      //     child: Row(
                      //       spacing: 5,
                      //       children: [
                      //         Container(
                      //           height: 30,
                      //           width: 30,
                      //           decoration: BoxDecoration(
                      //             color: colorScheme.secondary.withValues(
                      //               alpha: 0.2,
                      //             ),
                      //           ),
                      //           child: Icon(
                      //             Icons.access_time_filled,
                      //             color: colorScheme.primary,
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //             vertical: 6.0,
                      //             horizontal: 8.0,
                      //           ),
                      //           child: Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               Row(
                      //                 children: [
                      //                   Text(
                      //                     'Next Prayer : ',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white
                      //                               : Colors.black,
                      //                     ),
                      //                   ),
                      //                   Text(
                      //                     'Fajr ',
                      //                     style: TextStyle(
                      //                       color: colorScheme.primary,
                      //                     ),
                      //                   ),
                      //                   Text(
                      //                     'in - ',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white
                      //                               : Colors.black,
                      //                     ),
                      //                   ),
                      //                   Text(
                      //                     '20 min',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white
                      //                               : Colors.black,
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //               Row(
                      //                 spacing: 3,
                      //                 children: [
                      //                   Text(
                      //                     '1:30 AM',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white.withValues(
                      //                                 alpha: 0.5,
                      //                               )
                      //                               : Colors.black.withValues(
                      //                                 alpha: 0.5,
                      //                               ),
                      //                     ),
                      //                   ),
                      //                   Text(
                      //                     '| iqomah :',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white.withValues(
                      //                                 alpha: 0.5,
                      //                               )
                      //                               : Colors.black.withValues(
                      //                                 alpha: 0.5,
                      //                               ),
                      //                     ),
                      //                   ),
                      //                   Text(
                      //                     '10:30 PM',
                      //                     style: TextStyle(
                      //                       color:
                      //                           isDarkMode
                      //                               ? Colors.white.withValues(
                      //                                 alpha: 0.5,
                      //                               )
                      //                               : Colors.black.withValues(
                      //                                 alpha: 0.5,
                      //                               ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      //icon
                      _gridIcon(),
                      //announcement
                      _seeAll(colorScheme, context, 'announcement'.tr(), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnouncementPage(),
                          ),
                        );
                      }),
                      //announcement section
                      SizedBox(
                        height: 175,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final itemColor =
                                _iconColors[index % _iconColors.length];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
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
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _announcements[index]['title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onBackground,
                                            ),
                                          ),
                                          Text(
                                            _announcements[index]['desc'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onBackground,
                                            ),
                                          ),
                                          Text(
                                            _announcements[index]['date'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onBackground,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      //event
                      _seeAll(colorScheme, context, 'upcoming_events'.tr(), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpcomingEventPage(),
                          ),
                        );
                      }),
                      //event section
                      SizedBox(
                        height: 175,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            final itemColor =
                                _iconColors[index % _iconColors.length];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
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
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
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
                                              _events[index]['month'].substring(
                                                0,
                                                3,
                                              ),
                                              style: TextStyle(
                                                color: itemColor,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _events[index]['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onBackground,
                                            ),
                                          ),
                                          Text(
                                            _events[index]['desc'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onBackground,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                size: 12,
                                                color: colorScheme.onBackground,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                _events[index]['time'],
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      colorScheme.onBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      //donate
                      Column(
                        spacing: 5,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('current_campaign'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),

                              child: Image.network(
                                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Text(
                            'Mosque Renovation Project',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onBackground,
                            ),
                          ),
                          Text(
                            'Help us renovate our mosque to accommodate more worshippers and improve facilities.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDarkMode
                                      ? Colors.white
                                      : Colors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 8),
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
                              minimumSize: Size(double.infinity, 60),
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  isDarkMode ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              context.tr('donate_now'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _nextPrayer() {
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
    return Row(
      spacing: 4,
      children: [
        Icon(Icons.timer_outlined, color: Colors.white, size: 18),
        Text(
          "$nextPrayer: $nextTime",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text('to', style: TextStyle(color: Colors.white, fontSize: 16)),
        Text(
          timeRemaining,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _gridIcon() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen =
            constraints.maxWidth > 600; // Threshold for wide screen

        if (isWideScreen) {
          // Single row for wider screens
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 40,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconHomeWidget(
                  iconName: Icons.menu_book,
                  iconDescription: 'quran'.tr(),
                  onTap: () {},
                ),
                IconHomeWidget(
                  iconName: Icons.calendar_month,
                  iconDescription: 'calendar'.tr(),
                  onTap: () {},
                ),
                IconHomeWidget(
                  iconName: Icons.volunteer_activism,
                  iconDescription: 'donate'.tr(),
                  onTap: () {},
                ),
                IconHomeWidget(
                  iconName: Icons.explore,
                  iconDescription: 'community'.tr(),
                  onTap: () {},
                ),
                IconHomeWidget(
                  iconName: Icons.mic,
                  iconDescription: 'lectures'.tr(),
                  onTap: () {},
                ),
                IconHomeWidget(
                  iconName: Icons.more_horiz,
                  iconDescription: 'more'.tr(),
                  onTap: () {},
                ),
              ],
            ),
          );
        } else {
          // Two rows for phone screens
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconHomeWidget(
                    iconName: Icons.menu_book,
                    iconDescription: 'quran'.tr(),
                    onTap: () {},
                  ),

                  IconHomeWidget(
                    iconName: Icons.calendar_month,
                    iconDescription: 'calender'.tr(),
                    onTap: () {},
                  ),
                  IconHomeWidget(
                    iconName: Icons.volunteer_activism,
                    iconDescription: 'donate'.tr(),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconHomeWidget(
                    iconName: Icons.volunteer_activism,
                    iconDescription: 'donate'.tr(),
                    onTap: () {},
                  ),
                  IconHomeWidget(
                    iconName: Icons.mic,
                    iconDescription: 'lecture'.tr(),
                    onTap: () {},
                  ),
                  IconHomeWidget(
                    iconName: Icons.more_horiz,
                    iconDescription: 'more'.tr(),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  //
  Widget _seeAll(
    ColorScheme colorScheme,
    BuildContext contex,
    String text,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(width: 8.0),
          InkWell(
            onTap: onTap,
            child: Text(
              context.tr("see_all"),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //
  Widget _buildGlassmorphicIcon(IconData icon, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

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
                    context.tr('today'),
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
                    context.tr('hijri'),
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
