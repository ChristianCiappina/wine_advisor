import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wine_recommendation.dart';
import '../services/wine_service.dart';
import '../services/wine_notes_service.dart';
import '../widgets/language_pill.dart';
import '../widgets/star_rating_bar.dart';
import '../widgets/wine_notes_sheet.dart';
import '../main.dart';

class ResultScreen extends StatefulWidget {
  final WineRecommendation recommendation;

  const ResultScreen({super.key, required this.recommendation});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSaving = false;
  bool _isFavorite = false;
  WineUserMeta _meta = const WineUserMeta(categoryId: 0);

  @override
  void initState() {
    super.initState();
    _meta = WineUserMeta(categoryId: widget.recommendation.id);
    _checkFavoriteStatus();
    _loadUserMeta();
  }

  Future<void> _loadUserMeta() async {
    try {
      final meta = await WineNotesService.instance.getMeta(widget.recommendation.id);
      if (mounted) {
        setState(() => _meta = meta);
      }
    } catch (_) {}
  }

  Future<void> _openNotesSheet() async {
    final updated = await WineNotesSheet.show(
      context,
      categoryId: widget.recommendation.id,
      categoryTitle: widget.recommendation.localizedCategoryName,
      initialRating: _meta.rating,
      initialNote: _meta.note,
    );
    if (updated != null && mounted) {
      setState(() {
        _meta = updated;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final fav = await WineService.instance.isFavorite(widget.recommendation.id);
      if (mounted) {
        setState(() {
          _isFavorite = fav;
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('must_login_to_save')),
          backgroundColor: const Color(0xFF6D213C),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final nowFav = await WineService.instance.toggleFavorite(widget.recommendation.id);

      if (mounted) {
        setState(() {
          _isFavorite = nowFav;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(nowFav ? t('result_saved') : t('result_removed')),
            backgroundColor: nowFav ? Colors.green : Colors.blueGrey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${t('error_prefix')}: $error'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              t('result_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.grey),
                tooltip: t('share_tooltip'),
                onPressed: () async {
                  final shareText =
                      '${t('share_text_1')}${widget.recommendation.localizedCategoryName}${t('share_text_2')}${widget.recommendation.exampleWines}${t('share_text_3')}${widget.recommendation.servingTemperature}\n';
                  try {
                    final box = context.findRenderObject() as RenderBox?;
                    final position = box != null
                        ? box.localToGlobal(Offset.zero) & box.size
                        : null;
                    await SharePlus.instance.share(
                      ShareParams(
                        text: shareText,
                        sharePositionOrigin: position,
                      ),
                    );
                  } catch (e) {
                    await Clipboard.setData(ClipboardData(text: shareText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t('share_copied')),
                          backgroundColor: Colors.blueGrey,
                        ),
                      );
                    }
                  }
                },
              ),
              const LanguagePill(),
              SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.recommendation.imageUrl != null)
                      Hero(
                        tag: 'wine_image_${widget.recommendation.id}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.recommendation.imageUrl!,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 280,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Center(
                                    child: Icon(
                                      Icons.wine_bar,
                                      size: 80,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3C0311), Color(0xFF581825)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C0311).withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFDCC85).withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.wine_bar,
                                size: 54,
                                color: Color(0xFFFDCC85),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                    Text(
                      t('result_recommended'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.recommendation.localizedCategoryName,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C0311),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${t('result_examples')} ${widget.recommendation.exampleWines}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      t('result_why'),
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF3C0311),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.recommendation.localizedExplanation,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.thermostat, color: Color(0xFF6D213C)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${t('result_temp')} ${widget.recommendation.servingTemperature}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sezione Degustazione Personale & Rating
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: const Color(0xFFD6C5B3).withValues(alpha: 0.6),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD6C5B3).withValues(alpha: 0.35),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.rate_review_outlined,
                                        color: Theme.of(context).colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      t('my_tasting'),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                  tooltip: t('edit_notes'),
                                  onPressed: _openNotesSheet,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                StarRatingBar(
                                  rating: _meta.rating,
                                  size: 26,
                                  spacing: 4,
                                  onRatingChanged: (newRating) async {
                                    setState(() {
                                      _meta = WineUserMeta(
                                        categoryId: widget.recommendation.id,
                                        rating: newRating,
                                        note: _meta.note,
                                        updatedAt: DateTime.now(),
                                      );
                                    });
                                    await WineNotesService.instance.saveRating(
                                      widget.recommendation.id,
                                      newRating,
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _meta.rating > 0
                                      ? '${_meta.rating} ${t('stars_count')}'
                                      : t('not_rated'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _meta.rating > 0
                                        ? const Color(0xFF6D213C)
                                        : Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _openNotesSheet,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF8F5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD6C5B3).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: _meta.hasNote
                                    ? Text(
                                        _meta.note,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[800],
                                          height: 1.4,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Icon(
                                            Icons.add_comment_outlined,
                                            size: 18,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              t('add_notes'),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isSaving ? null : _toggleFavorite,
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
            label: Text(
              _isFavorite ? t('result_saved_btn') : t('result_save'),
            ),
          ),
        );
      },
    );
  }
}
