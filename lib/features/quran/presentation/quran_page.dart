import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjidku/data/datasource/db_local_datasource.dart';
import 'package:masjidku/data/model/bookmark_model.dart';
import 'package:quran_flutter/quran_flutter.dart';
import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import 'ayat_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  QuranLanguage selectedLanguage = QuranLanguage.indonesian;
  List<Surah> surahs = [];
  List<String> surahNames = [];
  List<String> surahNamesArabic = [];
  List<String> surahNamesLatin = [];
  List<String> surahmeaning = [];
  Map<int, Map<int, Verse>> quranVerses = {};

  BookmarkModel? bookmarkModel;

  void loadData() async {
    final bookmark = await DbLocalDatasource().getBookmark();
    if (mounted) {
      setState(() {
        bookmarkModel = bookmark;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
    // _tabController = TabController(length: 3, vsync: this);

    surahs = Quran.getSurahAsList();
    surahNames = surahs.map((surah) => surah.name).toList();
    surahNamesArabic = surahs.map((surah) => surah.name).toList();
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode = themeMode == ThemeMode.dark;
        final theme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

        final colorScheme = theme.colorScheme;
        // final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: colorScheme.background,
          appBar: AppBar(
            backgroundColor: colorScheme.primary,
            title: const Text('Al-Quran'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 0.1),
                  //header last read
                  bookmarkModel == null
                      ? const SizedBox()
                      : Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 20.0,
                          ),
                          child: Column(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${bookmarkModel?.suratName}',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${bookmarkModel?.suratNumber} : ${bookmarkModel?.ayatNumber}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    //icon read
                                    Icons.book,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ],
                              ),
                              InkWell(
                               onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AyatPage.ofSurah(
                                            Quran.getSurah(
                                              bookmarkModel!.suratNumber,
                                            ),
                                            lastReading: true,
                                            bookmark: bookmarkModel,
                                          ),
                                    ),
                                  );
                                  loadData();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        spacing: 6,
                                        children: [
                                          Text(
                                            "Lanjutkan Membaca",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  _buildListTitle(colorScheme, "Ayat Tersimpan"),
                  // ListView.builder(
                  //   itemCount: 2,
                  //   itemBuilder: (context, index) {
                  //     return AyatCard(
                  //       ayat: ayat[index],
                  //     );
                  //   },
                  // ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 2,
                      itemBuilder: (context, index) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: colorScheme.surface,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'surah',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'disimpan 3 hari yang lalu',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "ayat",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "terjemahan",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _rowSavedQuran(
                                      colorScheme,
                                      () {},
                                      'Putar',
                                      Icons.volume_up,
                                    ),
                                    _rowSavedQuran(
                                      colorScheme,
                                      () {},
                                      'Catatan',
                                      Icons.notes,
                                    ),
                                    _rowSavedQuran(
                                      colorScheme,
                                      () {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text('Hapus Ayat'),
                                                content: Text(
                                                  'Apakah kamu ingin menghapus ayat ini?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text('Batal'),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Hapus'),
                                                    onPressed: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      'Hapus',
                                      Icons.delete,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _buildListTitle(colorScheme, 'Jelajahi Al-Qur\'an'),
                  _buildSurahTab(colorScheme),

                  // Tab Bar for Surah and Juz
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: colorScheme.background,
                  //     borderRadius: BorderRadius.circular(15),
                  //   ),
                  //   child: TabBar(
                  //     dividerColor: colorScheme.surface,
                  //     controller: _tabController,
                  //     indicatorColor: colorScheme.primary,
                  //     labelColor: colorScheme.primary,
                  //     unselectedLabelColor: colorScheme.onSurface,
                  //     tabs: const [
                  //       Tab(text: 'Surah'),
                  //       Tab(text: 'Juz'),
                  //       Tab(text: 'Halaman'),
                  //     ],
                  //   ),
                  // ),
                  // // Tab Bar View
                  // SizedBox(
                  //   height: 300,
                  //   child: TabBarView(
                  //     controller: _tabController,
                  //     children: [
                  //       _buildSurahTab(colorScheme),
                  //       _buildJuzTab(colorScheme),
                  //       _buildPageTab(colorScheme),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahTab(ColorScheme colorScheme) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Surah ${surah.nameEnglish}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                '${surah.meaning} • ${surah.verseCount} Ayat',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              trailing: Text(
                '${surah.name}',
                style: TextStyle(
                  fontSize: 18,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AyatPage.ofSurah(surah),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Widget _buildJuzTab(ColorScheme colorScheme) {
  //   return ListView.builder(
  //     itemCount: juzs.length,
  //     itemBuilder: (context, index) {
  //       final juz = juzs[index];
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 8),
  //         decoration: BoxDecoration(
  //           color: colorScheme.surface,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: ListTile(
  //           leading: Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: colorScheme.primary.withValues(alpha: 0.1),
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 '${index + 1}',
  //                 style: TextStyle(
  //                   color: colorScheme.primary,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           title: Text(
  //             'Juz ${juz.number}',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: colorScheme.onSurface,
  //             ),
  //           ),
  //           subtitle: Text(
  //             'Page ${juz.verseCount}',
  //             style: TextStyle(
  //               color: colorScheme.onSurface.withValues(alpha: 0.7),
  //             ),
  //           ),
  //           onTap: () {
  //             // Handle juz tap
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildPageTab(ColorScheme colorScheme) {
  //   return ListView.builder(
  //     itemCount: 30,
  //     itemBuilder: (context, index) {
  //       return Container(
  //         margin: const EdgeInsets.only(bottom: 8),
  //         decoration: BoxDecoration(
  //           color: colorScheme.surface,
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: ListTile(
  //           leading: Container(
  //             width: 40,
  //             height: 40,
  //             decoration: BoxDecoration(
  //               color: colorScheme.primary.withValues(alpha: 0.1),
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 '${index + 1}',
  //                 style: TextStyle(
  //                   color: colorScheme.primary,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           title: Text(
  //             'Juz ${index + 1}',
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: colorScheme.onSurface,
  //             ),
  //           ),
  //           subtitle: Text(
  //             'Page ${index + 1}',
  //             style: TextStyle(
  //               color: colorScheme.onSurface.withValues(alpha: 0.7),
  //             ),
  //           ),
  //           onTap: () {
  //             // Handle juz tap
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildListTitle(ColorScheme colorScheme, String title) {
    return Text(
      title,
      style: TextStyle(
        color: colorScheme.onBackground,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _rowSavedQuran(
    ColorScheme colorScheme,
    VoidCallback onTap,
    String text,
    IconData icon,
  ) {
    return InkWell(
      onTap: onTap,
      child: Row(
        spacing: 5,
        children: [
          //icon speaker
          Icon(icon, size: 20),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: colorScheme.onBackground),
          ),
        ],
      ),
    );
  }
}
