import 'package:flutter/material.dart';
import '../services/wine_notes_service.dart';
import '../main.dart';
import 'star_rating_bar.dart';

class WineNotesSheet extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;
  final int initialRating;
  final String initialNote;

  const WineNotesSheet({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    this.initialRating = 0,
    this.initialNote = '',
  });

  static Future<WineUserMeta?> show(
    BuildContext context, {
    required int categoryId,
    required String categoryTitle,
    int initialRating = 0,
    String initialNote = '',
  }) {
    return showModalBottomSheet<WineUserMeta>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WineNotesSheet(
          categoryId: categoryId,
          categoryTitle: categoryTitle,
          initialRating: initialRating,
          initialNote: initialNote,
        ),
      ),
    );
  }

  @override
  State<WineNotesSheet> createState() => _WineNotesSheetState();
}

class _WineNotesSheetState extends State<WineNotesSheet> {
  late int _rating;
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final noteText = _controller.text.trim();

    try {
      await WineNotesService.instance.saveMeta(
        widget.categoryId,
        rating: _rating,
        note: noteText,
      );

      final updatedMeta = WineUserMeta(
        categoryId: widget.categoryId,
        rating: _rating,
        note: noteText,
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.pop(context, updatedMeta);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('notes_saved')),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleDeleteNote() async {
    setState(() => _isSaving = true);
    try {
      await WineNotesService.instance.deleteNote(widget.categoryId);
      _controller.clear();

      final updatedMeta = WineUserMeta(
        categoryId: widget.categoryId,
        rating: _rating,
        note: '',
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.pop(context, updatedMeta);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6C5B3).withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('tasting_notes'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      widget.categoryTitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Rating section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD6C5B3).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Text(
                  t('rate_wine'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                StarRatingBar(
                  rating: _rating,
                  size: 36,
                  spacing: 8,
                  onRatingChanged: (val) {
                    setState(() => _rating = val);
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  _rating > 0
                      ? '$_rating ${t('stars_count')}'
                      : t('not_rated'),
                  style: TextStyle(
                    fontSize: 12,
                    color: _rating > 0 ? const Color(0xFF6D213C) : Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Note text field
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: t('notes_hint'),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFFD6C5B3).withValues(alpha: 0.7),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFFD6C5B3).withValues(alpha: 0.7),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              if (widget.initialNote.isNotEmpty) ...[
                TextButton.icon(
                  onPressed: _isSaving ? null : _handleDeleteNote,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  label: Text(
                    t('delete_notes'),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
                const Spacer(),
              ] else ...[
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: Text(t('cancel'), style: TextStyle(color: Colors.grey[600])),
                ),
                const Spacer(),
              ],
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check, size: 20),
                label: Text(t('save_notes')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
