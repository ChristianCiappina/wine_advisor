import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wine_recommendation.dart';
import '../services/wine_service.dart';
import '../utils/debouncer.dart';
import '../widgets/language_pill.dart';
import 'result_screen.dart';
import '../main.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(milliseconds: 300));
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;

  final List<Map<String, String>> _suggestedChips = [
    {'key': 'mood_chip_all', 'query': ''},
    {'key': 'mood_chip_romantic', 'query': 'romantica'},
    {'key': 'mood_chip_relax', 'query': 'relax'},
    {'key': 'mood_chip_party', 'query': 'festa'},
    {'key': 'mood_chip_couch', 'query': 'divano'},
    {'key': 'mood_chip_family', 'query': 'famiglia'},
  ];

  @override
  void initState() {
    super.initState();
    _searchMoods('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  IconData _getMoodIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('romant') || lower.contains('love') || lower.contains('cuore') || lower.contains('cena a due')) {
      return Icons.favorite_rounded;
    }
    if (lower.contains('relax') || lower.contains('camino') || lower.contains('spa') || lower.contains('quiete') || lower.contains('lettura')) {
      return Icons.spa_rounded;
    }
    if (lower.contains('festa') || lower.contains('party') || lower.contains('amici') || lower.contains('aperitiv') || lower.contains('compleanno')) {
      return Icons.celebration_rounded;
    }
    if (lower.contains('divano') || lower.contains('couch') || lower.contains('film') || lower.contains('serie') || lower.contains('tv')) {
      return Icons.weekend_rounded;
    }
    if (lower.contains('famigli') || lower.contains('family') || lower.contains('pranzo') || lower.contains('domenica')) {
      return Icons.groups_rounded;
    }
    return Icons.nightlife_rounded;
  }

  Color _getMoodAccentColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('romant') || lower.contains('love')) return const Color(0xFF9E2A2B);
    if (lower.contains('relax') || lower.contains('camino')) return const Color(0xFF2C6B74);
    if (lower.contains('festa') || lower.contains('party') || lower.contains('aperitiv')) return const Color(0xFFC86D3B);
    if (lower.contains('divano') || lower.contains('couch')) return const Color(0xFF675D50);
    if (lower.contains('famigli') || lower.contains('family')) return const Color(0xFF8D5B4C);
    return const Color(0xFF7B581C);
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() => _searchMoods(query));
  }

  Future<void> _searchMoods(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await WineService.instance.searchMoods(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${t('error_prefix')}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyChipSuggestion(Map<String, String> chip) {
    final query = chip['query'] ?? '';
    if (query.isEmpty) {
      _searchController.clear();
      _searchMoods('');
    } else {
      _searchController.text = t(chip['key']!);
      _searchMoods(query);
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
              t('mood_appbar'),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: t('mood_hint'),
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchMoods('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _suggestedChips.map((chip) {
                          final label = t(chip['key']!);
                          final isAll = chip['query']!.isEmpty;
                          final isSelected = (_searchController.text.toLowerCase() == label.toLowerCase()) ||
                              (isAll && _searchController.text.isEmpty);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(label),
                              showCheckmark: false,
                              selected: isSelected,
                              selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              onSelected: (_) => _applyChipSuggestion(chip),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_emotions_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    t('mood_empty_title'),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchMoods('');
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: Text(t('mood_show_all')),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final mood = _searchResults[index];
                                final category = mood['wine_categories'];
                                final rawName = mood['title'] != null && mood['title'].toString().isNotEmpty
                                    ? mood['title'].toString()
                                    : _capitalize(mood['food_type'] ?? '');
                                final displayName = t(rawName);

                                final catId = category?['id'];
                                final catName = category != null
                                    ? (catId != null ? t('cat_name_$catId') : t(category['category_name'] ?? ''))
                                    : '';

                                final icon = _getMoodIcon(rawName);
                                final accentColor = _getMoodAccentColor(rawName);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFEFE8DE)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2C2224).withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        if (category == null) return;
                                        final recommendation =
                                            WineRecommendation.fromJson(category);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResultScreen(
                                              recommendation: recommendation,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: accentColor.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(icon, color: accentColor, size: 24),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    displayName,
                                                    style: GoogleFonts.playfairDisplay(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: const Color(0xFF2C2224),
                                                    ),
                                                  ),
                                                  if (catName.isNotEmpty) ...[
                                                    const SizedBox(height: 6),
                                                    Wrap(
                                                      crossAxisAlignment: WrapCrossAlignment.center,
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFF6EEDB),
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(
                                                              color: const Color(0xFFE2D1B3),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.wine_bar,
                                                                size: 13,
                                                                color: Color(0xFF7B581C),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  catName,
                                                                  style: const TextStyle(
                                                                    fontSize: 12,
                                                                    fontWeight: FontWeight.w600,
                                                                    color: Color(0xFF7B581C),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFAF6F0),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: 13,
                                                color: Color(0xFF7B581C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
