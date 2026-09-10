import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WineUserMeta {
  final int categoryId;
  final int rating; // 0 (non votato) a 5
  final String note;
  final DateTime? updatedAt;

  const WineUserMeta({
    required this.categoryId,
    this.rating = 0,
    this.note = '',
    this.updatedAt,
  });

  bool get hasRating => rating > 0;
  bool get hasNote => note.trim().isNotEmpty;
}

class WineNotesService {
  WineNotesService._();
  static final WineNotesService instance = WineNotesService._();

  String _userKey(int categoryId) {
    String userId;
    try {
      userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    } catch (_) {
      userId = 'guest';
    }
    return 'wine_meta_${userId}_$categoryId';
  }

  /// Recupera le note e la valutazione dell'utente per una determinata categoria di vino
  Future<WineUserMeta> getMeta(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey(categoryId));
    if (raw == null) {
      return WineUserMeta(categoryId: categoryId);
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WineUserMeta(
        categoryId: categoryId,
        rating: (map['rating'] as num?)?.toInt() ?? 0,
        note: (map['note'] ?? '').toString(),
        updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'].toString())
            : null,
      );
    } catch (_) {
      return WineUserMeta(categoryId: categoryId);
    }
  }

  /// Salva la sola valutazione a stelle (1-5)
  Future<void> saveRating(int categoryId, int rating) async {
    final current = await getMeta(categoryId);
    await _save(
      WineUserMeta(
        categoryId: categoryId,
        rating: rating.clamp(0, 5),
        note: current.note,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Salva la sola nota di degustazione
  Future<void> saveNote(int categoryId, String note) async {
    final current = await getMeta(categoryId);
    await _save(
      WineUserMeta(
        categoryId: categoryId,
        rating: current.rating,
        note: note.trim(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Salva contemporaneamente rating e nota
  Future<void> saveMeta(int categoryId, {int? rating, String? note}) async {
    final current = await getMeta(categoryId);
    await _save(
      WineUserMeta(
        categoryId: categoryId,
        rating: rating != null ? rating.clamp(0, 5) : current.rating,
        note: note != null ? note.trim() : current.note,
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Cancella la nota mantenendo l'eventuale rating
  Future<void> deleteNote(int categoryId) async {
    final current = await getMeta(categoryId);
    await _save(
      WineUserMeta(
        categoryId: categoryId,
        rating: current.rating,
        note: '',
        updatedAt: DateTime.now(),
      ),
    );
  }

  /// Cancella completamente i metadati locali per la categoria
  Future<void> clearMeta(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey(categoryId));
  }

  Future<void> _save(WineUserMeta meta) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'category_id': meta.categoryId,
      'rating': meta.rating,
      'note': meta.note,
      'updated_at': meta.updatedAt?.toIso8601String(),
    };
    await prefs.setString(_userKey(meta.categoryId), jsonEncode(map));
  }
}
