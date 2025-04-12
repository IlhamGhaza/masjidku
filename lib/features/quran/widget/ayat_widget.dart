import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_flutter/enums/quran_language.dart';
import 'package:quran_flutter/quran_flutter.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';

class AyatWidget extends StatefulWidget {
  final Verse verse;
  final QuranLanguage translationLanguage;
  final Map<int, Map<int, Verse>> translatedVerses;
  const AyatWidget({
    super.key,
    required this.verse,
    required this.translationLanguage,
    required this.translatedVerses,
  });

  @override
  State<AyatWidget> createState() => _AyatWidgetState();
}

class _AyatWidgetState extends State<AyatWidget> {
 void _copyAllText() {
    String textToCopy =
        '${widget.verse.text}\n\n${widget.translatedVerses[widget.verse.surahNumber]![widget.verse.verseNumber]!.text}\n(Qs. ${widget.verse.surahNumber}: ${widget.verse.verseNumber})';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ayat copied to clipboard'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareAyat() {
    // String textToShare =
    //     '${widget.verse.text}\n\n${widget.translatedVerses[widget.verse.surahNumber]![widget.verse.verseNumber]!.text}\n(Qs. ${widget.verse.surahNumber}: ${widget.verse.verseNumber})';

    // // Replace 'your_app_package' with your actual app package name
    // String deepLink =
    //     'quran://your_app_package/surah/${widget.verse.surahNumber}/ayat/${widget.verse.verseNumber}';

    // Share.share('$textToShare\n\nOpen in app: $deepLink');

    //snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Oops something went wrong'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primary,
                child: Text(
                  widget.verse.verseNumber.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.verse.text,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onBackground,
                    fontFamily: 'Uthmanic',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment:
                    widget.translationLanguage.isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                child: Text(
                  widget
                      .translatedVerses[widget.verse.surahNumber]![widget
                          .verse
                          .verseNumber]!
                      .text,
                  textAlign:
                      widget.translationLanguage.isRTL
                          ? TextAlign.right
                          : TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRowSection(
                    colorScheme,
                    'Play',
                    Icons.play_arrow,
                    () {},
                  ),
                  //ulangi
                  _buildRowSection(colorScheme, 'Ulangi', Icons.repeat, () {}),
                  // _buildRowSection(colorScheme, 'Catatan', Icons.note, () {}),
                  _buildRowSection(
                    colorScheme,
                    'Bookmark',
                    Icons.bookmark,
                    () {},
                  ),
                  _buildRowSection(colorScheme, 'Share', Icons.share,_shareAyat),
                  _buildRowSection(
                    colorScheme,
                    'Copy',
                    Icons.copy,
                    _copyAllText,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRowSection(
    ColorScheme colorScheme,
    String title,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 16),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onBackground),
          ),
        ],
      ),
    );
  }
}
