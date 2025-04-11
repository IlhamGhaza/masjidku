import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijriyah_indonesia/hijriyah_indonesia.dart';
import 'package:intl/intl.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';

class PrayerPage extends StatefulWidget {
  const PrayerPage({super.key});

  @override
  State<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends State<PrayerPage> {
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
            title: Text(context.tr('prayer_times')),
            centerTitle: true,
            actions: [
              //calender
              IconButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: const Locale('id', 'ID'),
                  );
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Container(
                  //   width: screenSize.width,
                  //   height: screenSize.height * 0.24,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         colorScheme.onPrimaryContainer,
                  //         colorScheme.primary,
                  //       ],
                  //     ),
                  //   ),
                  // child:
                  // ),
                  //widget

                  // Transform.translate(
                  //   offset: const Offset(0, -50),
                  //   child: Container(
                  //     width: screenSize.width * 0.9,
                  //     padding: const EdgeInsets.symmetric(
                  //       vertical: 16,
                  //       horizontal: 20,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: isDarkMode ? colorScheme.surface : Colors.white,
                  //       borderRadius: BorderRadius.circular(15),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withValues(alpha: 0.1),
                  //           blurRadius: 10,
                  //           offset: const Offset(0, 3),
                  //         ),
                  //       ],
                  //     ),
                  //     child: Column(
                  //       spacing: 3,
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           DateFormat('dd MMMM yyyy').format(DateTime.now()),
                  //           style: TextStyle(
                  //             fontSize: 16,
                  //             color: isDarkMode ? Colors.white : Colors.black,
                  //           ),
                  //         ),
                  //         Text(
                  //           Hijriyah.fromDate(
                  //             DateTime.now().toLocal(),
                  //           ).toFormat("dd MMMM yyyy"),
                  //           style: TextStyle(
                  //             fontSize: 14,
                  //             color: isDarkMode ? Colors.white : Colors.black,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 5.0),
                  //         Row(
                  //           spacing: 5,
                  //           children: [
                  //             CircleAvatar(
                  //               backgroundColor: colorScheme.primary,
                  //               radius: 8,
                  //             ),
                  //             Text(
                  //               'Bogor, Indonesia',
                  //               style: TextStyle(
                  //                 fontSize: 14,
                  //                 color:
                  //                     isDarkMode ? Colors.white : Colors.black,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      spacing: 20,
                      children: [
                        const SizedBox(height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              context.tr("today"),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onBackground,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: colorScheme.onBackground,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: colorScheme.onBackground,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          height: 600,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                offset: Offset(0, 3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  color: colorScheme.primary,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "hari ini",
                                        style: TextStyle(
                                          color: colorScheme.onBackground,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "hij",
                                        style: TextStyle(
                                          color: colorScheme.onBackground,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _rowjadwalSholat(
                                        'imsak',
                                        '04:00',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Shubuh',
                                        '04:45',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Terbit',
                                        '06:00',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Zuhur',
                                        '04:00',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Asrar',
                                        '04:00',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Maghrib',
                                        '04:00',
                                        colorScheme,
                                      ),
                                      _rowjadwalSholat(
                                        'Isya',
                                        '19:00',
                                        colorScheme,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _rowjadwalSholat(
    String textjadwal,
    String textJam,
    dynamic colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              textjadwal,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              textJam,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.alarm, color: colorScheme.onBackground, size: 20),
          ),
        ],
      ),
    );
  }
}
