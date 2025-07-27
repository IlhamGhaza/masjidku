import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_flutter/quran_flutter.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../data/model/bookmark_model.dart';

class AyatWidget extends StatefulWidget {
  final Verse verse;
  final QuranLanguage translationLanguage;
  final Map<int, Map<int, Verse>> translatedVerses;
  final Function(Verse verse)? onBookmarkPressed;
  final BookmarkModel? bookmarkModel;
  const AyatWidget({
    super.key,
    required this.verse,
    required this.translationLanguage,
    required this.translatedVerses,
    this.onBookmarkPressed,
    this.bookmarkModel,
  });

  @override
  State<AyatWidget> createState() => _AyatWidgetState();
}

class _AyatWidgetState extends State<AyatWidget> {
  bool _isExpanded = false;

  void _copyAllText() {
    String textToCopy =
        '${widget.verse.text}\n\n${widget.translatedVerses[widget.verse.surahNumber]![widget.verse.verseNumber]!.text}\n(Qs. ${widget.verse.surahNumber}: ${widget.verse.verseNumber})';
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayat copied to clipboard'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareAyat() {
    // Implement sharing functionality here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Oops something went wrong'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
        final colorScheme = theme.colorScheme;

        return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with verse number and bookmark button
                    Row(
                      children: [
                        CircleAvatar(
                              radius: 20,
                              backgroundColor: colorScheme.primary,
                              child: Text(
                                widget.verse.verseNumber.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: -0.2,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            ),

                        const Spacer(),

                        IconButton(
                              onPressed: () {
                                if (widget.onBookmarkPressed != null) {
                                  widget.onBookmarkPressed!(widget.verse);
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                Icons.done_all,
                                color:
                                    (widget.bookmarkModel != null &&
                                            widget.bookmarkModel!.suratNumber ==
                                                widget.verse.surahNumber &&
                                            widget.bookmarkModel!.ayatNumber ==
                                                widget.verse.verseNumber)
                                        ? colorScheme.primary
                                        : Colors.grey.withValues(alpha: 0.5),
                                size: 28,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 300.ms)
                            .slideX(
                              begin: 0.2,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Arabic text
                    Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            widget.verse.text,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                              fontFamily: 'Uthmanic',
                              height: 1.5,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: 100.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 20),

                    // Translation text
                    Align(
                          alignment:
                              widget.translationLanguage.isRTL
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Text(
                            widget
                                .translatedVerses[widget
                                    .verse
                                    .surahNumber]![widget.verse.verseNumber]!
                                .text,
                            textAlign:
                                widget.translationLanguage.isRTL
                                    ? TextAlign.right
                                    : TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: 200.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 16),

                    // Action buttons
                    AnimatedCrossFade(
                      firstChild: Center(
                        child: TextButton.icon(
                          onPressed: _toggleExpand,
                          icon: const Icon(Icons.more_horiz),
                          label: const Text('Show Actions'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ),
                      secondChild: Wrap(
                        alignment: WrapAlignment.spaceEvenly,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildActionButton(
                            colorScheme,
                            'Play',
                            Icons.play_arrow,
                            () {},
                          ),
                          _buildActionButton(
                            colorScheme,
                            'Repeat',
                            Icons.repeat,
                            () {},
                          ),
                          _buildActionButton(
                            colorScheme,
                            'Bookmark',
                            Icons.bookmark,
                            () {
                              if (widget.onBookmarkPressed != null) {
                                widget.onBookmarkPressed!(widget.verse);
                              }
                            },
                          ),
                          _buildActionButton(
                            colorScheme,
                            'Share',
                            Icons.share,
                            _shareAyat,
                          ),
                          _buildActionButton(
                            colorScheme,
                            'Copy',
                            Icons.copy,
                            _copyAllText,
                          ),
                          _buildActionButton(
                            colorScheme,
                            'Hide',
                            Icons.keyboard_arrow_up,
                            _toggleExpand,
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                      crossFadeState:
                          _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.95, 0.95),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildActionButton(
    ColorScheme colorScheme,
    String title,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
