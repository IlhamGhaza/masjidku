class HadithModel {
  final String narrator;
  final String source;
  final String arabText;
  final String translation;
  final String reference;
  final String category;
  final bool isBookmarked;

  HadithModel({
    required this.narrator,
    required this.source,
    required this.arabText,
    required this.translation,
    required this.reference,
    this.category = '',
    this.isBookmarked = false,
  });

  HadithModel copyWith({
    String? narrator,
    String? source,
    String? arabText,
    String? translation,
    String? reference,
    String? category,
    bool? isBookmarked,
  }) {
    return HadithModel(
      narrator: narrator ?? this.narrator,
      source: source ?? this.source,
      arabText: arabText ?? this.arabText,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
