import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/activity_page.dart';
import 'features/home_page.dart';
import 'features/quran_page.dart';
import 'features/finance_report_page.dart'; 
import 'features/profile_page.dart';


class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const QuranPage(),
    const FinanceReportPage(), 
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              height: 65,
              elevation: 0,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              backgroundColor: colorScheme.surface,
              indicatorColor: colorScheme.primaryContainer,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 500),
              destinations: [
                NavigationDestination(
                  icon: Icon(
                    Icons.home_outlined,
                    color:
                        _selectedIndex == 0
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.home_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Beranda',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.menu_book_outlined,
                    color:
                        _selectedIndex == 2
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.menu_book_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Quran',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons
                        .account_balance_outlined,
                    color:
                        _selectedIndex == 1
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.account_balance_rounded, 
                    color: colorScheme.primary,
                  ),
                  label: 'Keuangan', 
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.calendar_today_outlined,
                    color:
                        _selectedIndex == 3
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.calendar_today_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Kegiatan',
                ),
                NavigationDestination(
                  icon: Icon(
                    Icons.person_outline_rounded,
                    color:
                        _selectedIndex == 4
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
