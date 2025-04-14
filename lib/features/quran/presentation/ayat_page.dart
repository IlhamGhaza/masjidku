import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/datasource/db_local_datasource.dart';
import '../../../data/model/bookmark_model.dart';
import '../widget/ayat_widget.dart';

class AyatPage extends StatefulWidget {
  final Surah? surah;
  final Juz? juz;
  final QuranPage? page;
  final bool? lastReading;
  BookmarkModel? bookmarkModel;
  AyatPage({
    super.key,
    this.surah,
    this.juz,
    this.page,
    this.lastReading = false,
    this.bookmarkModel,
  });
  factory AyatPage.ofSurah(
    Surah surah, {
    bool lastReading = false,
    BookmarkModel? bookmark,
  }) =>
      AyatPage(surah: surah, lastReading: lastReading, bookmarkModel: bookmark);

  @override
  State<AyatPage> createState() => _AyatPageState();
}

class _AyatPageState extends State<AyatPage>
    with SingleTickerProviderStateMixin {
  String getSurahType(String type) {
    return type.toLowerCase() == 'meccan' ? 'Mekah' : 'Madinah';
  }

  Surah? surah;
  Surah? previousSurah;
  Surah? nextSurah;
  Juz? juz;
  QuranPage? page;
  final List<dynamic> surahVerseList = [];
  QuranLanguage translationLanguage = QuranLanguage.indonesian;
  Map<int, Map<int, Verse>> translatedVerses = {};
  int lastReadIndex = 0;
  ItemScrollController itemScrollController = ItemScrollController();
  late AnimationController _animationController;
  bool _showNavigation = true;

  Future<void> scrollToLastRead() async {
    lastReadIndex =
        widget.bookmarkModel != null ? widget.bookmarkModel!.ayatNumber : 0;
    if (itemScrollController.isAttached) {
      itemScrollController.scrollTo(
        duration: const Duration(seconds: 2),
        index: (widget.lastReading ?? false) ? lastReadIndex : 0,
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _toggleNavigation() {
    setState(() {
      _showNavigation = !_showNavigation;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToLastRead();
    });

    surah = widget.surah;
    juz = widget.juz;
    page = widget.page;
    translatedVerses = Quran.getQuranVerses(language: translationLanguage);
    surahVerseList.add(widget.surah);
    surahVerseList.addAll(Quran.getSurahVersesAsList(widget.surah!.number));

    if (surah != null) {
      // Get previous surah if current surah is not the first one
      if (surah!.number > 1) {
        previousSurah = Quran.getSurah(surah!.number - 1);
      }

      // Get next surah if current surah is not the last one (Quran has 114 surahs)
      if (surah!.number < 114) {
        nextSurah = Quran.getSurah(surah!.number + 1);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'Surah ${surah!.nameEnglish}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: colorScheme.primary.withOpacity(0.9),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Implement search functionality
                },
              ).animate().fadeIn(duration: 400.ms),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Implement settings functionality
                },
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ],
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels > 10 && _showNavigation) {
                setState(() {
                  _showNavigation = false;
                });
              } else if (scrollInfo.metrics.pixels <= 10 && !_showNavigation) {
                setState(() {
                  _showNavigation = true;
                });
              }
              return false;
            },
            child: Stack(
              children: [
                // Main content
                ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  itemCount: surahVerseList.length,
                  padding: const EdgeInsets.only(bottom: 140),
                  itemBuilder: (context, index) {
                    dynamic item = surahVerseList[index];
                    if (item is Surah) {
                      return _buildSurahHeader(item, colorScheme, screenSize);
                    } else if (item is Verse) {
                      return AyatWidget(
                        verse: item,
                        translationLanguage: translationLanguage,
                        translatedVerses: translatedVerses,
                        bookmarkModel: widget.bookmarkModel,
                        onBookmarkPressed: (verse) async {
                          _showBookmarkDialog(verse, colorScheme);
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),

                // Navigation buttons
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  bottom: _showNavigation ? 30 : -100,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavigationButton(
                        screenSize,
                        colorScheme,
                        previousSurah,
                        'Surah Sebelumnya',
                        Icons.arrow_back_ios,
                        Alignment.centerLeft,
                        () {
                          if (previousSurah != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AyatPage.ofSurah(previousSurah!),
                              ),
                            );
                          }
                        },
                      ),
                      _buildNavigationButton(
                        screenSize,
                        colorScheme,
                        nextSurah,
                        'Surah Berikutnya',
                        Icons.arrow_forward_ios,
                        Alignment.centerRight,
                        () {
                          if (nextSurah != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AyatPage.ofSurah(nextSurah!),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                ),

                // Floating action button to toggle navigation
                Positioned(
                  bottom: 20,
                  right: screenSize.width / 2 - 25,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: colorScheme.primary,
                    onPressed: _toggleNavigation,
                    child: Icon(
                      _showNavigation
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeader(
    Surah surah,
    ColorScheme colorScheme,
    Size screenSize,
  ) {
    return SingleChildScrollView(
      child: Container(
        color: colorScheme.background,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Surah header with gradient
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              width: screenSize.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                    colorScheme.primary.withOpacity(0.6),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                            surah.name,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: "Uthmanic",
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(
                            begin: -0.2,
                            end: 0,
                            duration: 600.ms,
                            curve: Curves.easeOutQuart,
                          ),

                      const SizedBox(height: 8),

                      Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                surah.nameEnglish,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '(${surah.meaning})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(
                            begin: -0.2,
                            end: 0,
                            duration: 600.ms,
                            delay: 200.ms,
                            curve: Curves.easeOutQuart,
                          ),

                      const SizedBox(height: 16),

                      _buildSurahDetail(
                            '${surah.number}',
                            '${surah.verseCount}',
                            getSurahType(surah.type.toString()),
                          )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: 600.ms,
                            delay: 400.ms,
                            curve: Curves.easeOutQuart,
                          ),
                    ],
                  ),
                ),
              ),
            ),

            // Bismillah container
            Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      Quran.bismillah,
                      style: TextStyle(
                        fontSize: 28,
                        color: colorScheme.primary,
                        fontFamily: "Uthmanic",
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 800.ms,
                  delay: 600.ms,
                ),

            // Play all button
            Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Putar Semua'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 2,
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, delay: 800.ms)
                .slideX(begin: -0.2, end: 0, duration: 600.ms, delay: 800.ms),

            const Divider(height: 32, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahDetail(String urutan, String ayat, String tempat) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetailItem(urutan, 'Urutan'),
          const SizedBox(width: 20),
          _buildDetailItem(ayat, 'Ayat'),
          const SizedBox(width: 20),
          _buildDetailItem(tempat, 'Tempat'),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  Widget _buildNavigationButton(
    Size screenSize,
    ColorScheme colorScheme,
    Surah? targetSurah,
    String title,
    IconData icon,
    Alignment alignment,
    VoidCallback? onTap,
  ) {
    final bool isEnabled = targetSurah != null;

    return Container(
      width: screenSize.width * 0.43,
      height: 90,
      decoration: BoxDecoration(
        color:
            isEnabled
                ? colorScheme.primary.withOpacity(0.9)
                : colorScheme.primary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        boxShadow:
            isEnabled
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
                : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  alignment == Alignment.centerLeft
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment:
                      alignment == Alignment.centerLeft
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                  children: [
                    if (alignment == Alignment.centerLeft)
                      Icon(icon, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (alignment == Alignment.centerRight)
                      Icon(icon, color: Colors.white, size: 16),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  targetSurah?.nameEnglish ?? 'Tidak Ada',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (targetSurah != null)
                  Text(
                    'Ayat 1-${targetSurah.verseCount}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBookmarkDialog(Verse verse, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: colorScheme.primary,
                      size: 48,
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Simpan Bacaan Terakhir",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Apakah Anda ingin menyimpan bacaan terakhir di Surah ${surah!.nameEnglish}, Ayat ${verse.verseNumber}?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurface.withOpacity(
                              0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            context.tr("cancel"),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            BookmarkModel model = BookmarkModel(
                              surah!.nameEnglish,
                              surah!.number,
                              verse.verseNumber,
                            );
                            await DbLocalDatasource().saveBookmark(model);
                            setState(() {
                              widget.bookmarkModel = model;
                            });
                            Navigator.pop(context);

                            if (mounted) {
                              SnackbarUtils(
                                backgroundColor: Colors.green,
                                text: "save_last_read".tr(),
                                // icon: Icons.check_circle,
                              ).showSuccessSnackBar(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            context.tr("save"),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 300.ms,
              ),
        );
      },
    );
  }
}
