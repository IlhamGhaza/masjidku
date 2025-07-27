import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjidku/l10n/app_localizations.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/theme/theme.dart';
import '../widget/hadit_card.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({Key? key}) : super(key: key);

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                title: Text(
                  AppLocalizations.of(context)!.hadith,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // Implement search functionality
                    },
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return HadithCard(
                        colorScheme: colorScheme,
                        narrator: 'Abu Hurairah',
                        source: 'Bukhari & Muslim',
                        translation: 'Actions are judged by intentions...',
                        isBookmarked: index % 2 == 0, // Example logic
                      );
                    },
                    childCount: 10, // Replace with actual hadith count
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
