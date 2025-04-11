import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/theme_cubit.dart';

class UpcomingEventPage extends StatefulWidget {
  const UpcomingEventPage({super.key});

  @override
  State<UpcomingEventPage> createState() => _UpcomingEventPageState();
}

class _UpcomingEventPageState extends State<UpcomingEventPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Upcoming Events'),
            centerTitle: true,
            backgroundColor: colorScheme.primary,
          ),
          body: const Center(child: Text('Upcoming Events')),
        );
      },
    );
  }
}
