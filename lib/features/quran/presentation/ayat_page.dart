import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_flutter/quran_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../data/datasource/db_local_datasource.dart';
import '../../../data/model/bookmark_model.dart';
import '../widget/ayat_widget.dart';

class AyatPage extends StatefulWidget {
  final Surah? surah;
  final Juz? juz;
  final QuranPage? page;
  final bool? lastReading;
  final BookmarkModel? bookmarkModel;
  const AyatPage({
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

class _AyatPageState extends State<AyatPage> {
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

  Future<void> scrollToLastRead() async {
    // final lastRead = await DBLocalDatasource().getLastRead();
    lastReadIndex =
        widget.bookmarkModel != null ? widget.bookmarkModel!.ayatNumber : 0;
    itemScrollController.scrollTo(
      duration: Duration(seconds: 2),
      index: (widget.lastReading ?? false) ? lastReadIndex : 0,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToLastRead();
    });
    // TODO: implement initState
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

    super.initState();
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
          appBar: AppBar(
            title: Text('Surah ${surah!.nameEnglish}'),
            centerTitle: true,
            backgroundColor: colorScheme.primary,
          ),
          body: Stack(
            children: [
              ScrollablePositionedList.builder(
                itemScrollController: itemScrollController,
                itemCount: surahVerseList.length,
                padding: const EdgeInsets.only(bottom: 140),
                itemBuilder: (context, index) {
                  dynamic item = surahVerseList[index];
                  if (item is Surah) {
                    return Container(
                      color: colorScheme.background,
                      child: Column(
                        children: [
                          Container(
                            height: 180,
                            width: screenSize.width,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.onPrimaryContainer,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Text(
                                    widget.surah!.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.surah!.nameEnglish,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '(' + widget.surah!.meaning + ')',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildSurahDetail(
                                    '${widget.surah!.number}',
                                    '${widget.surah!.verseCount}',
                                    getSurahType(widget.surah!.type.toString()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorScheme.surface,
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
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Container(
                                  height: 40,
                                  width: screenSize.width * 0.3,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: colorScheme.secondary,
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.volume_up,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          'Putar Semua',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (item is Verse) {
                    return Column(
                      children: [
                        AyatWidget(
                          verse: item,
                          translationLanguage: translationLanguage,
                          translatedVerses: translatedVerses,
                          bookmarkModel: widget.bookmarkModel,
                          onBookmarkPressed: (verse) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Simpan Bacaan Terakhir"),
                                  content: Text(
                                    "Apakah Anda ingin menyimpan bacaan terakhir di Surah ${surah!.nameEnglish} , Ayat ${verse.verseNumber}?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Batal"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        BookmarkModel model = BookmarkModel(
                                          surah!.nameEnglish,
                                          surah!.number,
                                          verse.verseNumber,
                                        );
                                        await DbLocalDatasource().saveBookmark(
                                          model,
                                        );
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Bacaan terakhir disimpan!",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: Text("Simpan"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),

              //

              //
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Replace the existing previous surah container with this:
                    Container(
                      width: screenSize.width * 0.45,
                      height: 90,
                      decoration: BoxDecoration(
                        color:
                            previousSurah != null
                                ? colorScheme.primary.withValues(alpha: 0.9)
                                : colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ), // Dimmed when disabled
                        borderRadius: BorderRadius.circular(15),
                        boxShadow:
                            previousSurah != null
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                : [],
                      ),
                      child: InkWell(
                        onTap:
                            previousSurah != null
                                ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AyatPage.ofSurah(previousSurah!),
                                    ),
                                  );
                                }
                                : null, // Disable tap when no previous surah
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Surah Sebelumnya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                previousSurah?.nameEnglish ?? 'Tidak Ada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (previousSurah != null)
                                Text(
                                  'Ayat 1-${previousSurah!.verseCount}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Replace the existing next surah container with this:
                    Container(
                      width: screenSize.width * 0.45,
                      height: 90,
                      decoration: BoxDecoration(
                        color:
                            nextSurah != null
                                ? colorScheme.primary.withValues(alpha: 0.9)
                                : colorScheme.primary.withValues(
                                  alpha: 0.4,
                                ), // Dimmed when disabled
                        borderRadius: BorderRadius.circular(15),
                        boxShadow:
                            nextSurah != null
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                                : [],
                      ),
                      child: InkWell(
                        onTap:
                            nextSurah != null
                                ? () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              AyatPage.ofSurah(nextSurah!),
                                    ),
                                  );
                                }
                                : null, // Disable tap when no next surah
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Surah Berikutnya',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                nextSurah?.nameEnglish ?? 'Tidak Ada',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (nextSurah != null)
                                Text(
                                  'Ayat 1-${nextSurah!.verseCount}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSurahDetail(String urutan, String ayat, String tempat) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 20,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              urutan,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Urutan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              ayat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Ayat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tempat,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Tempat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
