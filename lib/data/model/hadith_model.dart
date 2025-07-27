class HadithBook {
  final int id;
  final String name;
  final String arabicName;
  final String englishName;
  final String urduName;

  HadithBook({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.englishName,
    required this.urduName,
  });

  factory HadithBook.fromJson(Map<String, dynamic> json) {
    return HadithBook(
      id: json['id'],
      name: json['bookName'] ?? '',
      arabicName: json['bookSlug'] ?? '',
      englishName: json['writerName'] ?? '',
      urduName: (json['hadiths_count']?.toString() ?? ''),
    );
  }
}

class HadithChapter {
  final int id;
  final int? bookId;
  final String name;
  final String arabicName;
  final String englishName;
  final String urduName;

  HadithChapter({
    required this.id,
    required this.bookId,
    required this.name,
    required this.arabicName,
    required this.englishName,
    required this.urduName,
  });

  factory HadithChapter.fromJson(Map<String, dynamic> json) {
    return HadithChapter(
      id: json['id'],
      bookId: null, // Tidak ada di response
      name: json['chapterNumber']?.toString() ?? '',
      arabicName: json['chapterArabic'] ?? '',
      englishName: json['chapterEnglish'] ?? '',
      urduName: json['chapterUrdu'] ?? '',
    );
  }
}

class Hadith {
  final int id;
  final int bookId;
  final int chapterId;
  final String arabicText;
  final String englishText;
  final String urduText;
  final String narrator;
  final String grade;
  final String reference;

  Hadith({
    required this.id,
    required this.bookId,
    required this.chapterId,
    required this.arabicText,
    required this.englishText,
    required this.urduText,
    required this.narrator,
    required this.grade,
    required this.reference,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      bookId: json['book_id'],
      chapterId: json['chapter_id'],
      arabicText: json['arabic_text'] ?? '',
      englishText: json['english_text'] ?? '',
      urduText: json['urdu_text'] ?? '',
      narrator: json['narrator'] ?? '',
      grade: json['grade'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}

class HadithBookmark {
  final int id;
  final int hadithId;
  final int bookId;
  final int chapterId;
  final String hadithText;
  final String narrator;
  final String reference;
  final DateTime createdAt;

  HadithBookmark({
    required this.id,
    required this.hadithId,
    required this.bookId,
    required this.chapterId,
    required this.hadithText,
    required this.narrator,
    required this.reference,
    required this.createdAt,
  });

  factory HadithBookmark.fromJson(Map<String, dynamic> json) {
    return HadithBookmark(
      id: json['id'],
      hadithId: json['hadith_id'],
      bookId: json['book_id'],
      chapterId: json['chapter_id'],
      hadithText: json['hadith_text'],
      narrator: json['narrator'],
      reference: json['reference'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadith_id': hadithId,
      'book_id': bookId,
      'chapter_id': chapterId,
      'hadith_text': hadithText,
      'narrator': narrator,
      'reference': reference,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
