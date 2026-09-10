import '../main.dart';

class WineRecommendation {
  final int id;
  final String categoryName;
  final String exampleWines;
  final String explanation;
  final String servingTemperature;
  final String? imageUrl; // <-- NUOVA VARIABILE (può essere nulla)

  WineRecommendation({
    required this.id,
    required this.categoryName,
    required this.exampleWines,
    required this.explanation,
    required this.servingTemperature,
    this.imageUrl,
  });

  String get localizedCategoryName {
    final byId = t('cat_name_$id');
    if (byId != 'cat_name_$id') return byId;
    return t(categoryName);
  }

  String get localizedExplanation {
    final byId = t('cat_expl_$id');
    if (byId != 'cat_expl_$id') return byId;
    return t(explanation);
  }

  static String _cleanText(String? text) {
    if (text == null) return '';
    return text
        .replaceAll('Gew\uFFFDrztraminer', 'Gewürztraminer')
        .replaceAll('Gewrztraminer', 'Gewürztraminer')
        .replaceAll('acidit\uFFFD', 'acidità')
        .replaceAll('gi\uFFFD', 'già')
        .replaceAll('met\uFFFD', 'metà')
        .replaceAll('\uFFFDC', '°C')
        .replaceAll('\uFFFD C', '°C')
        .replaceAll('\uFFFD', '°');
  }

  factory WineRecommendation.fromJson(Map<String, dynamic> json) {
    return WineRecommendation(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      categoryName: _cleanText(json['category_name']?.toString()),
      exampleWines: _cleanText(json['example_wines']?.toString()),
      explanation: _cleanText(json['explanation']?.toString()),
      servingTemperature: _cleanText(json['serving_temperature']?.toString()),
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_name': categoryName,
      'example_wines': exampleWines,
      'explanation': explanation,
      'serving_temperature': servingTemperature,
      'image_url': imageUrl,
    };
  }
}
