import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/activity_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/quran/quran_page.dart';
import 'features/financial/finance_report_page.dart';
import 'features/account/presentation/profile_page.dart';
import 'package:easy_localization/easy_localization.dart'; // Sesuaikan dengan package lokalisasi yang Anda gunakan

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const QuranPage(),
    const FinanceReportPage(),
    const ActivityPage(), //event
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // Dipanggil ketika locale berubah
    if (mounted) {
      setState(() {
        // Force rebuild
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale; // for easy_localization

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isTabletOrLaptop = constraints.maxWidth > 600;

            if (isTabletOrLaptop) {
              // Tablet or Laptop Layout with Sidebar
              return Scaffold(
                body: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(2, 0),
                          ),
                        ],
                      ),
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onItemTapped,
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: colorScheme.surface,
                        indicatorColor: colorScheme.primaryContainer,
                        selectedIconTheme: IconThemeData(
                          color: colorScheme.primary,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.home_outlined),
                            selectedIcon: const Icon(Icons.home_rounded),
                            label: Text('home'.tr()),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.menu_book_outlined),
                            selectedIcon: const Icon(Icons.menu_book_rounded),
                            label: Text('quran'.tr()),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.account_balance_outlined),
                            selectedIcon: const Icon(
                              Icons.account_balance_rounded,
                            ),
                            label: Text('finance'.tr()),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.calendar_today_outlined),
                            selectedIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            label: Text('activity'.tr()),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.person_outline_rounded),
                            selectedIcon: const Icon(Icons.person_rounded),
                            label: Text('profile'.tr()),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: IndexedStack(
                          key: ValueKey(_selectedIndex),
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Mobile Layout with BottomNavigationBar
              return Scaffold(
                body: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: IndexedStack(
                    key: ValueKey(_selectedIndex),
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
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
                    key: ValueKey('navbar_${currentLocale.languageCode}'),
                    height: 65,
                    elevation: 0,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onItemTapped,
                    backgroundColor: colorScheme.surface,
                    indicatorColor: colorScheme.primaryContainer,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
                    animationDuration: const Duration(milliseconds: 300),
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
                        label: 'home'.tr(),
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.menu_book_outlined,
                          color:
                              _selectedIndex == 1
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        selectedIcon: Icon(
                          Icons.menu_book_rounded,
                          color: colorScheme.primary,
                        ),
                        label: 'quran'.tr(),
                      ),
                      NavigationDestination(
                        icon: Icon(
                          Icons.account_balance_outlined,
                          color:
                              _selectedIndex == 2
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                        ),
                        selectedIcon: Icon(
                          Icons.account_balance_rounded,
                          color: colorScheme.primary,
                        ),
                        label: 'finance'.tr(),
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
                        label: 'activity'.tr(),
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
                        label: 'profile'.tr(),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
