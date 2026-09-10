import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wine_recommendation.dart';
import '../services/wine_service.dart';
import '../services/wine_notes_service.dart';
import '../widgets/language_pill.dart';
import '../widgets/star_rating_bar.dart';
import '../widgets/wine_notes_sheet.dart';
import 'result_screen.dart';
import 'login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> _favorites = [];
  Map<int, WineUserMeta> _userMeta = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final results = await WineService.instance.getFavorites();
      final metaMap = <int, WineUserMeta>{};
      for (final fav in results) {
        final categoryData = fav['wine_categories'];
        if (categoryData != null && categoryData['id'] != null) {
          final catId = categoryData['id'] as int;
          metaMap[catId] = await WineNotesService.instance.getMeta(catId);
        }
      }
      if (mounted) {
        setState(() {
          _favorites = results;
          _userMeta = metaMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error_prefix')}: $e')),
        );
      }
    }
  }

  Future<void> _openNotesSheet(int categoryId, String categoryTitle) async {
    final currentMeta = _userMeta[categoryId] ?? WineUserMeta(categoryId: categoryId);
    final updated = await WineNotesSheet.show(
      context,
      categoryId: categoryId,
      categoryTitle: categoryTitle,
      initialRating: currentMeta.rating,
      initialNote: currentMeta.note,
    );
    if (updated != null && mounted) {
      setState(() {
        _userMeta[categoryId] = updated;
      });
    }
  }

  Future<void> _deleteFavorite(int categoryId, int index) async {
    final removedItem = _favorites[index];

    // Rimozione ottimistica locale
    setState(() {
      _favorites.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t('profile_deleted')),
          backgroundColor: Colors.blueGrey,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      await WineService.instance.deleteFavorite(categoryId);
    } catch (e) {
      // Rollback in caso di fallimento rete
      if (mounted) {
        setState(() {
          _favorites.insert(index, removedItem);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('error_prefix')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, child) {
        User? user;
        try {
          user = Supabase.instance.client.auth.currentUser;
        } catch (_) {
          user = null;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              t('profile_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: const [
              LanguagePill(),
              SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: user == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wine_bar_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              t('profile_title'),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              t('guest_profile_msg'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.login),
                              label: Text(t('guest_login_btn')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wine_bar_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('profile_empty_title'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('profile_empty_sub'),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _fetchFavorites,
                            icon: const Icon(Icons.refresh),
                            label: Text(t('refresh')),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchFavorites,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favorites.length,
                        itemBuilder: (context, index) {
                          final fav = _favorites[index];
                          final categoryData = fav['wine_categories'];

                          if (categoryData == null) return const SizedBox.shrink();

                          final catId = categoryData['id'] as int? ?? 0;
                          final meta = _userMeta[catId] ?? WineUserMeta(categoryId: catId);
                          final localizedCatTitle = catId > 0
                              ? t('cat_name_$catId')
                              : t(categoryData['category_name'] ?? '');

                          return Dismissible(
                            key: Key('${catId}_$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            onDismissed: (direction) =>
                                _deleteFavorite(catId, index),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        final result =
                                            WineRecommendation.fromJson(categoryData);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ResultScreen(recommendation: result),
                                          ),
                                        ).then((_) {
                                          if (catId > 0) {
                                            WineNotesService.instance.getMeta(catId).then((m) {
                                              if (mounted) setState(() => _userMeta[catId] = m);
                                            });
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFD6C5B3,
                                              ).withValues(alpha: 0.35),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.wine_bar,
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
                                                  localizedCatTitle,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  categoryData['example_wines'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1, thickness: 0.7),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        StarRatingBar(
                                          rating: meta.rating,
                                          size: 20,
                                          spacing: 2,
                                          onRatingChanged: (newRating) async {
                                            setState(() {
                                              _userMeta[catId] = WineUserMeta(
                                                categoryId: catId,
                                                rating: newRating,
                                                note: meta.note,
                                                updatedAt: DateTime.now(),
                                              );
                                            });
                                            await WineNotesService.instance.saveRating(catId, newRating);
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          meta.rating > 0
                                              ? '${meta.rating}⭐'
                                              : t('not_rated'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: meta.rating > 0
                                                ? const Color(0xFF6D213C)
                                                : Colors.grey[400],
                                          ),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () => _openNotesSheet(catId, localizedCatTitle),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  meta.hasNote ? Icons.edit_note : Icons.add_comment_outlined,
                                                  size: 17,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  meta.hasNote ? t('edit_notes') : t('add_notes'),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (meta.hasNote) ...[
                                      const SizedBox(height: 8),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () => _openNotesSheet(catId, localizedCatTitle),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAF8F5),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: const Color(0xFFD6C5B3).withValues(alpha: 0.5),
                                            ),
                                          ),
                                          child: Text(
                                            meta.note,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey[800],
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
