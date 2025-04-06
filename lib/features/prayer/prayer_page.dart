import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: screenSize.width,
                    height: screenSize.height * 0.24,
                    decoration: BoxDecoration(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //icon back
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Jadwal Sholat',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ),
                  //widget
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: Container(
                      width: screenSize.width * 0.9,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: 3,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal Masehi',
                            style: TextStyle(
                              fontSize: 16,

                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),

                          Text(
                            'Tanggal Hijriah',
                            style: TextStyle(
                              fontSize: 14,

                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Row(
                            spacing: 5,
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.primary,
                                radius: 8,
                              ),
                              Text(
                                'Bogor, Indonesia',
                                style: TextStyle(
                                  fontSize: 14,

                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
