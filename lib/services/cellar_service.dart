import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CellarBottleItem {
  final String id;
  final String title;
  final String winery;
  final String region;
  final int vintage;
  int quantity;
  final String score;
  final bool isHighlight;
  final String statusCategory; // 'aging', 'ready'
  final String statusKey;
  final int statusColorValue; // Color value as int
  final String windowRange;
  final int startYear;
  final int endYear;
  final String centerStatusKey;
  final double progress;
  bool isFav;
  final String priceEstimate;
  final String emoji;
  final String? imageBase64;
  final String? tastingNotes;

  CellarBottleItem({
    required this.id,
    required this.title,
    required this.winery,
    required this.region,
    required this.vintage,
    required this.quantity,
    required this.score,
    this.isHighlight = false,
    required this.statusCategory,
    required this.statusKey,
    required this.statusColorValue,
    required this.windowRange,
    required this.startYear,
    required this.endYear,
    required this.centerStatusKey,
    required this.progress,
    this.isFav = false,
    required this.priceEstimate,
    this.emoji = '🍷',
    this.imageBase64,
    this.tastingNotes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'winery': winery,
        'region': region,
        'vintage': vintage,
        'quantity': quantity,
        'score': score,
        'isHighlight': isHighlight,
        'statusCategory': statusCategory,
        'statusKey': statusKey,
        'statusColorValue': statusColorValue,
        'windowRange': windowRange,
        'startYear': startYear,
        'endYear': endYear,
        'centerStatusKey': centerStatusKey,
        'progress': progress,
        'isFav': isFav,
        'priceEstimate': priceEstimate,
        'emoji': emoji,
        'imageBase64': imageBase64,
        'tastingNotes': tastingNotes,
      };

  factory CellarBottleItem.fromJson(Map<String, dynamic> json) =>
      CellarBottleItem(
        id: json['id'] as String,
        title: json['title'] as String,
        winery: json['winery'] as String,
        region: json['region'] as String? ?? 'Italia',
        vintage: (json['vintage'] as num?)?.toInt() ?? 2020,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        score: json['score'] as String? ?? '95 pt',
        isHighlight: json['isHighlight'] as bool? ?? false,
        statusCategory: json['statusCategory'] as String? ?? 'ready',
        statusKey: json['statusKey'] as String? ?? 'cellar_status_ready',
        statusColorValue:
            (json['statusColorValue'] as num?)?.toInt() ?? 0xFF059669,
        windowRange: json['windowRange'] as String? ?? '2024-2030',
        startYear: (json['startYear'] as num?)?.toInt() ?? 2020,
        endYear: (json['endYear'] as num?)?.toInt() ?? 2030,
        centerStatusKey:
            json['centerStatusKey'] as String? ?? 'cellar_harmonious_ready',
        progress: (json['progress'] as num?)?.toDouble() ?? 0.8,
        isFav: json['isFav'] as bool? ?? false,
        priceEstimate: json['priceEstimate'] as String? ?? '€45',
        emoji: json['emoji'] as String? ?? '🍷',
        imageBase64: json['imageBase64'] as String?,
        tastingNotes: json['tastingNotes'] as String?,
      );

  CellarBottleItem copyWith({
    int? quantity,
    bool? isFav,
    String? tastingNotes,
  }) {
    return CellarBottleItem(
      id: id,
      title: title,
      winery: winery,
      region: region,
      vintage: vintage,
      quantity: quantity ?? this.quantity,
      score: score,
      isHighlight: isHighlight,
      statusCategory: statusCategory,
      statusKey: statusKey,
      statusColorValue: statusColorValue,
      windowRange: windowRange,
      startYear: startYear,
      endYear: endYear,
      centerStatusKey: centerStatusKey,
      progress: progress,
      isFav: isFav ?? this.isFav,
      priceEstimate: priceEstimate,
      emoji: emoji,
      imageBase64: imageBase64,
      tastingNotes: tastingNotes ?? this.tastingNotes,
    );
  }
}

class CellarService {
  CellarService._();
  static final CellarService instance = CellarService._();

  final ValueNotifier<List<CellarBottleItem>> bottlesNotifier =
      ValueNotifier<List<CellarBottleItem>>(_defaultBottles);

  bool _initialized = false;

  static List<CellarBottleItem> get _defaultBottles => [
        CellarBottleItem(
          id: 'brunello-2015',
          title: 'Brunello di Montalcino 2015',
          winery: 'Biondi-Santi, Tenuta Greppo',
          region: 'Toscana, Montalcino',
          vintage: 2015,
          quantity: 1,
          score: '98 pt',
          statusCategory: 'aging',
          statusKey: 'cellar_status_aging',
          statusColorValue: 0xFFD97706,
          windowRange: '2024-2035',
          startYear: 2015,
          endYear: 2035,
          centerStatusKey: 'cellar_peak_in_years',
          progress: 0.58,
          isFav: true,
          priceEstimate: '€220',
          emoji: '🍷',
        ),
        CellarBottleItem(
          id: 'sassicaia-2018',
          title: 'Sassicaia 2018',
          winery: 'Tenuta San Guido',
          region: 'Bolgheri Sassicaia DOC',
          vintage: 2018,
          quantity: 2,
          score: '99 pt',
          statusCategory: 'aging',
          statusKey: 'cellar_status_rest',
          statusColorValue: 0xFFD97706,
          windowRange: '2026-2040',
          startYear: 2018,
          endYear: 2040,
          centerStatusKey: 'cellar_wait_years',
          progress: 0.38,
          isFav: true,
          priceEstimate: '€290',
          emoji: '🍷',
        ),
        CellarBottleItem(
          id: 'franciacorta-2019',
          title: 'Franciacorta Satèn 2019',
          winery: 'Bellavista',
          region: 'Franciacorta DOCG',
          vintage: 2019,
          quantity: 1,
          score: 'Ideale stasera!',
          isHighlight: true,
          statusCategory: 'ready',
          statusKey: 'cellar_status_ready',
          statusColorValue: 0xFF059669,
          windowRange: 'Ora - 2025',
          startYear: 2019,
          endYear: 2025,
          centerStatusKey: 'cellar_peak_reached',
          progress: 0.88,
          isFav: false,
          priceEstimate: '€48',
          emoji: '🍾',
        ),
        CellarBottleItem(
          id: 'chianti-2018',
          title: 'Chianti Classico Gran Selezione 2018',
          winery: 'Castello di Fonterutoli',
          region: 'Castellina in Chianti',
          vintage: 2018,
          quantity: 3,
          score: '95 pt',
          statusCategory: 'ready',
          statusKey: 'cellar_status_drink_start',
          statusColorValue: 0xFF059669,
          windowRange: '2023-2030',
          startYear: 2018,
          endYear: 2030,
          centerStatusKey: 'cellar_harmonious_ready',
          progress: 0.50,
          isFav: false,
          priceEstimate: '€55',
          emoji: '🍷',
        ),
      ];

  String _storageKey() {
    String userId;
    try {
      userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      userId = 'guest';
    }
    return 'user_cellar_bottles_$userId';
  }

  /// Inizializza e carica le bottiglie dal local storage
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey());
      if (raw != null && raw.isNotEmpty) {
        final list = (jsonDecode(raw) as List)
            .map((item) =>
                CellarBottleItem.fromJson(item as Map<String, dynamic>))
            .toList();
        bottlesNotifier.value = list;
      } else {
        bottlesNotifier.value = _defaultBottles;
        await _persist();
      }
    } catch (e) {
      debugPrint('CellarService init error: $e');
      bottlesNotifier.value = _defaultBottles;
    } finally {
      _initialized = true;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw =
          jsonEncode(bottlesNotifier.value.map((b) => b.toJson()).toList());
      await prefs.setString(_storageKey(), raw);
    } catch (e) {
      debugPrint('CellarService persist error: $e');
    }
  }

  /// Aggiunge una bottiglia alla cantina personale
  Future<void> addBottle(CellarBottleItem bottle) async {
    await init();
    final current = List<CellarBottleItem>.from(bottlesNotifier.value);
    final existingIdx = current.indexWhere((b) =>
        b.title.toLowerCase() == bottle.title.toLowerCase() &&
        b.vintage == bottle.vintage);

    if (existingIdx != -1) {
      current[existingIdx].quantity += bottle.quantity;
    } else {
      current.insert(0, bottle);
    }
    bottlesNotifier.value = current;
    await _persist();
  }

  /// Rimuove una bottiglia dalla cantina
  Future<void> removeBottle(String id) async {
    await init();
    final current = List<CellarBottleItem>.from(bottlesNotifier.value);
    current.removeWhere((b) => b.id == id);
    bottlesNotifier.value = current;
    await _persist();
  }

  /// Modifica la quantità di una bottiglia
  Future<void> updateQuantity(String id, int delta) async {
    await init();
    final current = List<CellarBottleItem>.from(bottlesNotifier.value);
    final idx = current.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final newQty = current[idx].quantity + delta;
      if (newQty <= 0) {
        current.removeAt(idx);
      } else {
        current[idx].quantity = newQty;
      }
      bottlesNotifier.value = current;
      await _persist();
    }
  }

  /// Alterna il preferito
  Future<void> toggleFav(String id) async {
    await init();
    final current = List<CellarBottleItem>.from(bottlesNotifier.value);
    final idx = current.indexWhere((b) => b.id == id);
    if (idx != -1) {
      current[idx].isFav = !current[idx].isFav;
      bottlesNotifier.value = current;
      await _persist();
    }
  }

  /// Verifica se una bottiglia è presente in cantina
  bool isBottleInCellar(String title, [int? vintage]) {
    final lower = title.toLowerCase().trim();
    return bottlesNotifier.value.any((b) =>
        b.title.toLowerCase().trim() == lower &&
        (vintage == null || b.vintage == vintage));
  }

  /// Stappa una bottiglia (decrementa la quantità o rimuove)
  Future<bool> corkBottle(String id) async {
    await init();
    final current = List<CellarBottleItem>.from(bottlesNotifier.value);
    final idx = current.indexWhere((b) => b.id == id);
    if (idx != -1) {
      if (current[idx].quantity > 1) {
        current[idx].quantity -= 1;
        bottlesNotifier.value = current;
        await _persist();
        return false; // ancora disponibile
      } else {
        current.removeAt(idx);
        bottlesNotifier.value = current;
        await _persist();
        return true; // terminata
      }
    }
    return false;
  }

  /// Genera un riassunto testuale formattato della cantina da condividere
  String exportCellarSummary(String lang) {
    final list = bottlesNotifier.value;
    final totalBottles = list.fold<int>(0, (sum, b) => sum + b.quantity);
    final isIt = lang == 'it';

    final buffer = StringBuffer();
    buffer.writeln(isIt
        ? '🍷 *La Mia Cantina Personale — Wine Advisor*'
        : '🍷 *My Personal Cellar — Wine Advisor*');
    buffer.writeln(isIt
        ? 'Totale: $totalBottles bottiglie (${list.length} etichette)\n'
        : 'Total: $totalBottles bottles (${list.length} labels)\n');

    for (final b in list) {
      final status = b.statusCategory == 'ready'
          ? (isIt ? '🟢 Pronta' : '🟢 Ready')
          : (isIt ? '⏳ Invecchiamento' : '⏳ Aging');
      buffer.writeln('• ${b.emoji} *${b.title}* (${b.vintage})');
      buffer.writeln('  ${b.winery} — ${b.region}');
      buffer.writeln('  ${isIt ? "Quantità" : "Quantity"}: ${b.quantity}x | ${isIt ? "Finestra" : "Window"}: ${b.windowRange} | $status');
      buffer.writeln('');
    }

    buffer.writeln(isIt
        ? 'Creato con Wine Advisor 🍾'
        : 'Created with Wine Advisor 🍾');
    return buffer.toString();
  }

  /// Ricarica se l'utente effettua login/logout
  Future<void> reload() async {
    _initialized = false;
    await init();
  }

  @visibleForTesting
  void resetForTesting() {
    _initialized = false;
    bottlesNotifier.value = List<CellarBottleItem>.from(_defaultBottles);
  }
}
