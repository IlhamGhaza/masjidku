import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';

import '../../../core/components/buttons.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../event/upcoming_event_page.dart';
import '../../prayer/prayer_page.dart';
import '../../profile_page.dart';
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

  final List<Map<String, dynamic>> prayerTimes = [
    {'name': 'Fajr', 'time': '5:30 AM', 'status': 'Started'},
    {'name': 'Dhuhr', 'time': '1:15 PM', 'status': ''},
    {'name': 'Asr', 'time': '4:45 PM', 'status': ''},
    {'name': 'Maghrib', 'time': '7:20 PM', 'status': ''},
    {'name': 'Isha', 'time': '8:45 PM', 'status': ''},
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

  @override
  void initState() {
    super.initState();
    // Pilih warna secara acak saat widget diinisialisasi
    final random = Random();
    _selectedColor = _iconColors[random.nextInt(_iconColors.length)];
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
          backgroundColor: colorScheme.background,
          body: SafeArea(
            child: SingleChildScrollView(
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
                                    Text(
                                      'MasjidKu',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Bogor, Jawa Barat',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  //notification
                                  _buildGlassmorphicIcon(
                                    Icons.notifications,
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => NotificationPage(),
                                        ),
                                      );
                                    },
                                  ),
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
                          _buildDateCard("01/01/2023", "01/01/1444"),
                        ],
                      ),
                    ),
                  ),
                  _seeAll(colorScheme, context, 'Today Prayer', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrayerPage()),
                    );
                  }),

                  // prayer time,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var prayer in prayerTimes)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // Reset all statuses
                              for (var p in prayerTimes) {
                                p['status'] = '';
                              }
                              // Set status for the tapped prayer
                              prayer['status'] = 'Started';
                            });
                          },
                          child: Container(
                            width: 70,
                            height: 120,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  prayer['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  prayer['time'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (prayer['status'].isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      prayer['status'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // next prayer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: colorScheme.secondary.withValues(alpha: 0.15),
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            child: Icon(
                              Icons.access_time_filled,
                              color: colorScheme.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Next Prayer : ',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      'Fajr ',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      'in - ',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      '20 min',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 3,
                                  children: [
                                    Text(
                                      '1:30 AM',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white.withValues(
                                                  alpha: 0.5,
                                                )
                                                : Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                      ),
                                    ),
                                    Text(
                                      '| iqomah :',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white.withValues(
                                                  alpha: 0.5,
                                                )
                                                : Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                      ),
                                    ),
                                    Text(
                                      '10:30 PM',
                                      style: TextStyle(
                                        color:
                                            isDarkMode
                                                ? Colors.white.withValues(
                                                  alpha: 0.5,
                                                )
                                                : Colors.black.withValues(
                                                  alpha: 0.5,
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
                  //icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        spacing: 40,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconHomeWidget(
                            iconName: Icons.wb_sunny,
                            iconDescription: 'Sunrise',
                            onTap: () {},
                          ),
                          IconHomeWidget(
                            iconName: Icons.wb_sunny,
                            iconDescription: 'Sunrise',
                            onTap: () {},
                          ),
                          IconHomeWidget(
                            iconName: Icons.wb_sunny,
                            iconDescription: 'Sunrise',
                            onTap: () {},
                          ),
                          IconHomeWidget(
                            iconName: Icons.wb_sunny,
                            iconDescription: 'Sunrise',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  //
                  _seeAll(colorScheme, context, 'Upcoming Events', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UpcomingEventPage()),
                    );
                  }),
                  //event section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),

                    child: SizedBox(
                      height: 138,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          final itemColor =
                              _iconColors[index % _iconColors.length];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: itemColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                        _events[index]['month'].substring(0, 3),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _events[index]['name'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black.withValues(
                                                  alpha: 0.7,
                                                ),
                                      ),
                                    ),
                                    Text(
                                      _events[index]['desc'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isDarkMode
                                                ? Colors.white
                                                : Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black.withValues(
                                                    alpha: 0.5,
                                                  ),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          _events[index]['time'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black.withValues(
                                                      alpha: 0.5,
                                                    ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  //donate
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),

                    child: Column(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Campaigns',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : Colors.black.withValues(alpha: 0.7),
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
                            color:
                                isDarkMode
                                    ? Colors.white
                                    : Colors.black.withValues(alpha: 0.7),
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
                            'Donate Now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.black : Colors.white,
                            ),
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
              "See all",
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
            color: Colors.white.withOpacity(0.2),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
            color: Colors.white.withOpacity(0.15),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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
                    'Hijri',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
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
