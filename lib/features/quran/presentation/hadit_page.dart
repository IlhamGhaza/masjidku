import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:ui';

import '../../../core/theme/theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/model/hadith_model.dart';

class HadithPage extends StatefulWidget {
  const HadithPage({Key? key}) : super(key: key);

  @override
  State<HadithPage> createState() => _HadithPageState();
}

class _HadithPageState extends State<HadithPage>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();

  final List<HadithModel> _allHadiths = [
    HadithModel(
      narrator: "Abu Hurairah",
      source: "Bukhari & Muslim",
      arabText:
          "إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
      translation:
          "Sesungguhnya setiap amalan tergantung pada niatnya. Dan sesungguhnya setiap orang akan mendapatkan apa yang ia niatkan.",
      reference: "HR. Bukhari no. 1 dan Muslim no. 1907",
      category: "Niat",
    ),
    HadithModel(
      narrator: "Abdullah bin Umar",
      source: "Bukhari",
      arabText:
          "بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاَةِ، وَإِيتَاءِ الزَّكَاةِ، وَالْحَجِّ، وَصَوْمِ رَمَضَانَ",
      translation:
          "Islam dibangun di atas lima perkara: bersaksi bahwa tiada Tuhan yang berhak disembah selain Allah dan Muhammad adalah utusan Allah, mendirikan shalat, menunaikan zakat, haji, dan puasa Ramadhan.",
      reference: "HR. Bukhari no. 8 dan Muslim no. 16",
      category: "Rukun Islam",
    ),
    HadithModel(
      narrator: "Anas bin Malik",
      source: "Muslim",
      arabText:
          "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
      translation:
          "Tidak beriman salah seorang di antara kalian hingga ia mencintai untuk saudaranya apa yang ia cintai untuk dirinya sendiri.",
      reference: "HR. Bukhari no. 13 dan Muslim no. 45",
      category: "Iman",
    ),
    HadithModel(
      narrator: "Abu Hurairah",
      source: "Muslim",
      arabText:
          "مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ جَارَهُ، وَمَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيُكْرِمْ ضَيْفَهُ",
      translation:
          "Barangsiapa yang beriman kepada Allah dan hari akhir, hendaklah ia berkata baik atau diam. Barangsiapa yang beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tetangganya. Dan barangsiapa yang beriman kepada Allah dan hari akhir, hendaklah ia memuliakan tamunya.",
      reference: "HR. Bukhari no. 6018 dan Muslim no. 47",
      category: "Akhlak",
    ),
    HadithModel(
      narrator: "Abu Hurairah",
      source: "Tirmidzi",
      arabText:
          "الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنَ الْمُؤْمِنِ الضَّعِيفِ، وَفِي كُلٍّ خَيْرٌ",
      translation:
          "Mukmin yang kuat lebih baik dan lebih dicintai Allah daripada mukmin yang lemah, dan pada keduanya ada kebaikan.",
      reference: "HR. Muslim no. 2664",
      category: "Kekuatan",
    ),
  ];

  List<HadithModel> _filteredHadiths = [];
  List<String> _collections = [
    "Semua",
    "Bukhari",
    "Muslim",
    "Abu Daud",
    "Tirmidzi",
    "Ibnu Majah",
    "Nasai",
  ];
  List<String> _categories = [
    "Semua",
    "Niat",
    "Rukun Islam",
    "Iman",
    "Akhlak",
    "Kekuatan",
  ];

  int _selectedCollectionIndex = 0;
  int _selectedCategoryIndex = 0;
  bool _showArabic = true;
  bool _showTranslation = true;
  double _fontSize = 18.0;
  String _searchQuery = '';
  bool _isSearching = false;

  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredHadiths = List.from(_allHadiths);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.forward();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {}
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterHadiths() {
    setState(() {
      _filteredHadiths =
          _allHadiths.where((hadith) {
            // Filter by collection
            bool matchesCollection =
                _selectedCollectionIndex == 0 ||
                hadith.source.toLowerCase().contains(
                  _collections[_selectedCollectionIndex].toLowerCase(),
                );

            // Filter by category
            bool matchesCategory =
                _selectedCategoryIndex == 0 ||
                hadith.category == _categories[_selectedCategoryIndex];

            // Filter by search query
            bool matchesSearch =
                _searchQuery.isEmpty ||
                hadith.translation.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                hadith.narrator.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                hadith.reference.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );

            return matchesCollection && matchesCategory && matchesSearch;
          }).toList();
    });
  }

  void _toggleBookmark(int index) {
    setState(() {
      final hadith = _filteredHadiths[index];
      _filteredHadiths[index] = hadith.copyWith(
        isBookmarked: !hadith.isBookmarked,
      );

      // Find and update the hadith in the original list
      final originalIndex = _allHadiths.indexWhere(
        (h) => h.arabText == hadith.arabText && h.narrator == hadith.narrator,
      );

      if (originalIndex != -1) {
        _allHadiths[originalIndex] = _allHadiths[originalIndex].copyWith(
          isBookmarked: !_allHadiths[originalIndex].isBookmarked,
        );
      }

      // Show snackbar
      if (_filteredHadiths[index].isBookmarked) {
        SnackbarUtils(
          backgroundColor: Colors.green,
          text: "Hadits berhasil disimpan",
        ).showSuccessSnackBar(context);
      }
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pengaturan Tampilan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Tampilkan Teks Arab'),
                    value: _showArabic,
                    onChanged: (bool value) {
                      setState(() {
                        _showArabic = value;
                      });
                      this.setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Tampilkan Terjemahan'),
                    value: _showTranslation,
                    onChanged: (bool value) {
                      setState(() {
                        _showTranslation = value;
                      });
                      this.setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Ukuran Font'),
                  Slider(
                    value: _fontSize,
                    min: 14.0,
                    max: 30.0,
                    divisions: 8,
                    label: _fontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _fontSize = value;
                      });
                      this.setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Tutup'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
            title:
                _isSearching
                    ? TextField(
                      autofocus: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Cari hadits...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterHadiths();
                      },
                    )
                    : Text(
                      'Hadits',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            centerTitle: true,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.9),
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchQuery = '';
                      _filterHadiths();
                    }
                  });
                },
              ).animate().fadeIn(duration: 400.ms),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _showSettingsDialog,
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            ],
          ),
          body: Column(
            children: [
              // Header gradient background
              Container(
                height: 150,
                width: screenSize.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.primary.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
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
                        // Collection selector
                        SizedBox(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _collections.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(_collections[index]),
                                  selected: _selectedCollectionIndex == index,
                                  selectedColor: Colors.white.withValues(
                                    alpha: 0.3,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight:
                                        _selectedCollectionIndex == index
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedCollectionIndex = index;
                                      _filterHadiths();
                                    });
                                  },
                                ),
                              ).animate().fadeIn(
                                duration: 400.ms,
                                delay: Duration(milliseconds: 100 * index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Category selector
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(colorScheme, 'Kategori'),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ActionChip(
                              label: Text(_categories[index]),
                              backgroundColor:
                                  _selectedCategoryIndex == index
                                      ? colorScheme.primary
                                      : colorScheme.surface,
                              labelStyle: TextStyle(
                                color:
                                    _selectedCategoryIndex == index
                                        ? Colors.white
                                        : colorScheme.onSurface,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                  _filterHadiths();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Hadith list
              Expanded(
                child:
                    _filteredHadiths.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: colorScheme.onBackground.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada hadits yang ditemukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onBackground.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredHadiths.length,
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: Duration(
                                milliseconds: 500 + (index * 50),
                              ),
                              curve: Curves.easeOutQuint,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: _buildHadithCard(
                                _filteredHadiths[index],
                                index,
                                colorScheme,
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: colorScheme.primary,
            child: Icon(Icons.bookmark, color: Colors.white),
            onPressed: () {
              // Show bookmarked hadiths
              setState(() {
                _filteredHadiths =
                    _allHadiths.where((h) => h.isBookmarked).toList();
                if (_filteredHadiths.isEmpty) {
                  SnackbarUtils(
                    backgroundColor: colorScheme.primary,
                    text: "Belum ada hadits yang disimpan",
                  ).showSuccessSnackBar(context);
                  _filteredHadiths = List.from(_allHadiths);
                }
              });
            },
          ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
        );
      },
    );
  }

  Widget _buildSectionHeader(ColorScheme colorScheme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHadithCard(
    HadithModel hadith,
    int index,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border:
              hadith.isBookmarked
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: colorScheme.surface,
            child: InkWell(
              onTap: () {
                // Show detailed view or expand card
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with narrator and source
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.person,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hadith.narrator,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                hadith.source,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hadith.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    Divider(height: 24),

                    // Arabic text
                    if (_showArabic)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          hadith.arabText,
                          style: TextStyle(
                            fontSize: _fontSize + 2,
                            height: 1.8,
                            fontFamily: 'Uthmanic',
                            color: colorScheme.onSurface,
                          ),
                          // textDirection: TextDirection.RTL,
                          textAlign: TextAlign.right,
                        ),
                      ),

                    if (_showArabic && _showTranslation) SizedBox(height: 16),

                    // Translation
                    if (_showTranslation)
                      Text(
                        hadith.translation,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: 1.5,
                          color: colorScheme.onSurface,
                        ),
                      ),

                    SizedBox(height: 16),

                    // Reference
                    Text(
                      hadith.reference,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),

                    SizedBox(height: 8),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            hadith.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color:
                                hadith.isBookmarked
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                          ),
                          onPressed: () => _toggleBookmark(index),
                          tooltip: 'Simpan',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.share_outlined,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            // Implement share functionality
                            SnackbarUtils(
                              backgroundColor: colorScheme.primary,
                              text: "Hadits berhasil dibagikan",
                            ).showSuccessSnackBar(context);
                          },
                          tooltip: 'Bagikan',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.copy_outlined,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            // Implement copy functionality
                            SnackbarUtils(
                              backgroundColor: colorScheme.primary,
                              text: "Hadits berhasil disalin",
                            ).showSuccessSnackBar(context);
                          },
                          tooltip: 'Salin',
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.volume_up_outlined,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            // Implement audio playback
                            SnackbarUtils(
                              backgroundColor: colorScheme.primary,
                              text: "Memutar audio hadits",
                            ).showSuccessSnackBar(context);
                          },
                          tooltip: 'Putar',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to help with color alpha values, consistent with the rest of the codebase
extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromRGBO(
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
      alpha ?? this.opacity,
    );
  }
}
