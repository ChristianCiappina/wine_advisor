import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wine_advisor/screens/login_screen.dart';
import 'package:wine_advisor/screens/profile_screen.dart';
import 'package:wine_advisor/screens/wine_detail_screen.dart';
import 'package:wine_advisor/services/cellar_service.dart';
import 'package:wine_advisor/widgets/language_pill.dart';
import '../main.dart';

class CellarScreen extends StatefulWidget {
  final VoidCallback? onNavigateToScanner;

  const CellarScreen({super.key, this.onNavigateToScanner});

  @override
  State<CellarScreen> createState() => _CellarScreenState();
}

class _CellarBottle {
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
  final Color statusColor;
  final String windowRange;
  final int startYear;
  final int endYear;
  final String centerStatusKey;
  final double progress;
  bool isFav;
  final String priceEstimate;
  final String emoji;

  _CellarBottle({
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
    required this.statusColor,
    required this.windowRange,
    required this.startYear,
    required this.endYear,
    required this.centerStatusKey,
    required this.progress,
    this.isFav = false,
    required this.priceEstimate,
    this.emoji = '🍷',
  });
}

class _CellarScreenState extends State<CellarScreen> {
  String _activeFilter = 'all'; // 'all', 'ready', 'aging', 'fav'
  String _sortBy = 'vintage'; // 'vintage', 'score', 'value'
  final TextEditingController _searchController = TextEditingController();

  late List<_CellarBottle> _bottles;

  @override
  void initState() {
    super.initState();
    CellarService.instance.init();
    _bottles = _toViewBottles(CellarService.instance.bottlesNotifier.value);
  }

  List<_CellarBottle> _toViewBottles(List<CellarBottleItem> items) {
    return items
        .map((b) => _CellarBottle(
              id: b.id,
              title: b.title,
              winery: b.winery,
              region: b.region,
              vintage: b.vintage,
              quantity: b.quantity,
              score: b.score,
              isHighlight: b.isHighlight,
              statusCategory: b.statusCategory,
              statusKey: b.statusKey,
              statusColor: Color(b.statusColorValue),
              windowRange: b.windowRange,
              startYear: b.startYear,
              endYear: b.endYear,
              centerStatusKey: b.centerStatusKey,
              progress: b.progress,
              isFav: b.isFav,
              priceEstimate: b.priceEstimate,
              emoji: b.emoji,
            ))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddBottleDialog() {
    final titleCtrl = TextEditingController();
    final wineryCtrl = TextEditingController();
    final vintageCtrl = TextEditingController(text: '2020');
    final regionCtrl = TextEditingController(text: 'Piemonte, Italia');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.add_circle, color: Color(0xFF581825)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('cellar_added_manual_dialog'),
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nome Vino (es. Barolo Monfortino)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: wineryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cantina / Produttore (es. Giacomo Conterno)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vintageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Annata',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: regionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Regione',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                final v = int.tryParse(vintageCtrl.text.trim()) ?? 2020;
                await CellarService.instance.addBottle(
                  CellarBottleItem(
                    id: 'bottle-${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.trim(),
                    winery: wineryCtrl.text.trim().isEmpty
                        ? 'Cantina Selezionata'
                        : wineryCtrl.text.trim(),
                    region: regionCtrl.text.trim(),
                    vintage: v,
                    quantity: 1,
                    score: '96 pt',
                    statusCategory: 'aging',
                    statusKey: 'cellar_status_aging',
                    statusColorValue: 0xFFD97706,
                    windowRange: '$v-${v + 15}',
                    startYear: v,
                    endYear: v + 15,
                    centerStatusKey: 'cellar_peak_in_years',
                    progress: 0.35,
                    priceEstimate: '€110',
                    emoji: '🍷',
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t('cellar_add_success')),
                      backgroundColor: const Color(0xFF581825),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581825),
              foregroundColor: Colors.white,
            ),
            child: Text(t('cellar_add_btn')),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF7B581C)),
            const SizedBox(width: 8),
            Text(
              'Notifiche Caveau',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFDCC85),
                child: Text('🍾'),
              ),
              title: const Text('Franciacorta Satèn al culmine',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text(
                  'Raggiunta la finestra ideale di beva. Consigliata la stappatura stasera.',
                  style: TextStyle(fontSize: 12)),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFDCC85),
                child: Text('🌡️'),
              ),
              title: const Text('Condizioni Caveau Ottimali',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text(
                  'Temperatura costante a 14.2°C con 68% di umidità relativa.',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Chiudi', style: TextStyle(color: Color(0xFF581825))),
          ),
        ],
      ),
    );
  }

  List<_CellarBottle> _getFilteredBottles() {
    final query = _searchController.text.trim().toLowerCase();
    return _bottles.where((b) {
      // Filter tab
      if (_activeFilter == 'ready' && b.statusCategory != 'ready') return false;
      if (_activeFilter == 'aging' && b.statusCategory != 'aging') return false;
      if (_activeFilter == 'fav' && !b.isFav) return false;

      // Search query
      if (query.isNotEmpty) {
        final matches = b.title.toLowerCase().contains(query) ||
            b.winery.toLowerCase().contains(query) ||
            b.region.toLowerCase().contains(query) ||
            b.vintage.toString().contains(query);
        if (!matches) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (_sortBy == 'score') {
          return b.score.compareTo(a.score);
        } else if (_sortBy == 'value') {
          return b.priceEstimate.compareTo(a.priceEstimate);
        } else {
          // vintage
          return b.vintage.compareTo(a.vintage);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<CellarBottleItem>>(
      valueListenable: CellarService.instance.bottlesNotifier,
      builder: (context, cellarItems, _) {
        _bottles = _toViewBottles(cellarItems);
        return ValueListenableBuilder<String>(
          valueListenable: appLang,
          builder: (context, lang, child) {
        User? user;
        try {
          user = Supabase.instance.client.auth.currentUser;
        } catch (_) {
          user = null;
        }

        final filtered = _getFilteredBottles();
        final readyCount = _bottles.where((b) => b.statusCategory == 'ready').length;
        final agingCount = _bottles.where((b) => b.statusCategory == 'aging').length;
        final favCount = _bottles.where((b) => b.isFav).length;
        final totalBottlesCount = 24; // Master inventory count from design

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F6),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header Superiore
                      _buildHeader(context, user),
                      const SizedBox(height: 16),

                      // 2. Cellar Overview & Hero Stat Capsule
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildHeadlineSection(),
                      ),
                      const SizedBox(height: 18),

                      // 3. Quick Vital Cards (Bento 3 columns)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBentoVitals(totalBottlesCount, readyCount),
                      ),
                      const SizedBox(height: 18),

                      // 4. Interactive Sommelier Nudge Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSommelierNudge(),
                      ),
                      const SizedBox(height: 20),

                      // 5. Filter Pills Strip
                      _buildFilterStrip(
                        totalCount: _bottles.length,
                        readyCount: readyCount,
                        agingCount: agingCount,
                        favCount: favCount,
                        shownCount: filtered.length,
                      ),
                      const SizedBox(height: 16),

                      // 6. Search & Sort Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSearchAndSortBar(),
                      ),
                      const SizedBox(height: 18),

                      // 7. Add Bottle Call To Action
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildAddBottleCta(),
                      ),
                      const SizedBox(height: 24),

                      // 8. Wine Bottles Master List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBottlesList(filtered),
                      ),
                      const SizedBox(height: 28),

                      // 9. Statistiche del Bevitore & Wine Radar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildDrinkerAnalytics(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  },
);
}

  // 1. HEADER
  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF2C2224).withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF581825), Color(0xFF3C0311)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF581825).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wine Advisor',
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: const Color(0xFF3C0311),
                    ),
                  ),
                  Text(
                    t('cellar_header_subtitle').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFF7B581C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const LanguagePill(),
              const SizedBox(width: 4),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                    color: Colors.grey[800],
                    onPressed: _showNotificationDialog,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDCC85),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF581825).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF581825), width: 1.2),
                  ),
                  child: Center(
                    child: Icon(
                      user != null ? Icons.person : Icons.login,
                      size: 18,
                      color: const Color(0xFF581825),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. HEADLINE & HERO STAT CAPSULE
  Widget _buildHeadlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('cellar_private_collection').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7B581C),
                fontWeight: FontWeight.w700,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    final summary = CellarService.instance.exportCellarSummary(appLang.value);
                    Clipboard.setData(ClipboardData(text: summary));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t('cellar_export_copied')),
                        backgroundColor: const Color(0xFF581825),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF581825).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF581825).withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.share, size: 12, color: Color(0xFF581825)),
                        const SizedBox(width: 4),
                        Text(
                          t('cellar_export_btn'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF581825),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDDB0),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF7B581C),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t('cellar_active_vault'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF291800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          t('cellar_title'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3C0311),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('cellar_subtitle'),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13.5,
          ),
        ),
      ],
    );
  }

  // 3. BENTO QUICK VITALS
  Widget _buildBentoVitals(int totalCount, int readyCount) {
    return Row(
      children: [
        // Card 1: Bottiglie
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDEA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('cellar_bottles_stat').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalCount',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3C0311),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('cellar_denominations_sub'),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7B581C),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 2: Stima Totale
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDEA),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('cellar_total_value_stat').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '€1.840',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7B581C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('cellar_value_trend_sub'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Card 3: Da Bere (Watermark)
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFDCC85),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B581C).withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Opacity(
                    opacity: 0.20,
                    child: const Icon(
                      Icons.wine_bar,
                      size: 54,
                      color: Color(0xFF291800),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('cellar_to_drink_stat').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: Color(0xFF614004),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$readyCount',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF291800),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t('cellar_active_window_sub'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF291800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. INTERACTIVE SOMMELIER NUDGE
  Widget _buildSommelierNudge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF581825),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF581825).withValues(alpha: 0.2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('cellar_sommelier_nudge_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF3C0311),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('cellar_sommelier_nudge_body'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WineDetailScreen(
                    customTitle: 'Franciacorta Satèn 2019',
                    customWinery: 'Bellavista',
                    customPrice: '€48',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF581825),
              elevation: 1,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              t('cellar_nudge_open_btn'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 5. FILTER PILLS STRIP
  Widget _buildFilterStrip({
    required int totalCount,
    required int readyCount,
    required int agingCount,
    required int favCount,
    required int shownCount,
  }) {
    final filters = [
      {'id': 'all', 'label': '${t('cellar_filter_all')} ($totalCount)'},
      {'id': 'ready', 'label': '${t('cellar_filter_ready')} ($readyCount)'},
      {'id': 'aging', 'label': '${t('cellar_filter_aging')} ($agingCount)'},
      {'id': 'fav', 'label': '${t('cellar_filter_fav')} ($favCount)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t('cellar_filter_selection').toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '$shownCount di $totalCount ${t('cellar_shown_counter')}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B581C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: filters.map((f) {
              final isSelected = _activeFilter == f['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f['label']!),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[800],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12,
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFF3C0311),
                  backgroundColor: const Color(0xFFF0EDEA),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (_) => setState(() => _activeFilter = f['id']!),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // 6. SEARCH & SORT BAR
  Widget _buildSearchAndSortBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C2224).withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: t('cellar_search_hint'),
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7B581C), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          onSelected: (val) => setState(() => _sortBy = val),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'vintage', child: Text(t('cellar_sort_vintage'))),
            PopupMenuItem(value: 'score', child: Text(t('cellar_sort_score'))),
            PopupMenuItem(value: 'value', child: Text(t('cellar_sort_value'))),
          ],
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EDEA),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.sort, size: 18, color: Color(0xFF3C0311)),
                const SizedBox(width: 4),
                Text(
                  _sortBy == 'score'
                      ? t('cellar_sort_score')
                      : (_sortBy == 'value' ? t('cellar_sort_value') : t('cellar_sort_vintage')),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3C0311),
                  ),
                ),
                const Icon(Icons.expand_more, size: 16, color: Color(0xFF3C0311)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 7. ADD BOTTLE CTA
  Widget _buildAddBottleCta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3C0311),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C0311).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.add_circle, color: Color(0xFFFFD9DC), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('cellar_new_entry_title'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t('cellar_new_entry_subtitle'),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              if (widget.onNavigateToScanner != null) {
                widget.onNavigateToScanner!();
              } else {
                _showAddBottleDialog();
              }
            },
            icon: const Icon(Icons.qr_code_scanner, size: 16),
            label: Text(
              t('cellar_add_btn'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFDCC85),
              foregroundColor: const Color(0xFF291800),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // 8. MASTER BOTTLE LIST
  Widget _buildBottlesList(List<_CellarBottle> bottles) {
    if (bottles.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('cellar_custody_title'),
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3C0311),
              ),
            ),
            Text(
              '${bottles.length} ${t('cellar_guide_samples')}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...bottles.map((b) => _buildBottleCard(b)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDEA)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF581825), Color(0xFF3C0311)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF581825).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t('cellar_empty_filter_title'),
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3C0311),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t('cellar_empty_filter_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _activeFilter = 'all';
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.filter_alt_off, size: 16),
            label: Text(t('cellar_reset_filters')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581825),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  String _getBottlePhoto(String title) {
    final t = title.toLowerCase();
    if (t.contains('franciacorta') || t.contains('satèn') || t.contains('bollicine')) {
      return 'https://images.unsplash.com/photo-1569919659476-f0852f6834b7?w=600&auto=format&fit=crop&q=80';
    }
    if (t.contains('barolo') || t.contains('conterno') || t.contains('bricco')) {
      return 'https://images.unsplash.com/photo-1558001373-7b93ee48ffa0?w=600&auto=format&fit=crop&q=80';
    }
    if (t.contains('sassicaia') || t.contains('bolgheri') || t.contains('san guido')) {
      return 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=600&auto=format&fit=crop&q=80';
    }
    if (t.contains('amarone') || t.contains('bertani') || t.contains('valpolicella')) {
      return 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=600&auto=format&fit=crop&q=80';
    }
    if (t.contains('bianco') || t.contains('cervaro') || t.contains('chardonnay')) {
      return 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=600&auto=format&fit=crop&q=80';
  }

  Widget _buildBottleCard(_CellarBottle b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F0),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Bottle image mockup + Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottle Thumbnail with Quantity Tag
              Container(
                width: 72,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        _getBottlePhoto(b.title),
                        width: 72,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF581825),
                          child: const Center(
                            child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 30),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '${b.quantity}x',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Wine Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            b.region.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: Color(0xFF7B581C),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: b.isHighlight
                                ? const Color(0xFFD1FAE5) // emerald-100
                                : const Color(0xFFFFDDB0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            b.score,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: b.isHighlight
                                  ? const Color(0xFF065F46) // emerald-900
                                  : const Color(0xFF291800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WineDetailScreen(
                              customTitle: b.title,
                              customWinery: b.winery,
                              customPrice: b.priceEstimate,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        b.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3C0311),
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      b.winery,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),

                    // Status Pill & Window
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: b.statusColor == const Color(0xFF059669)
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: b.statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                t(b.statusKey),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: b.statusColor == const Color(0xFF059669)
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${t('cellar_window_label')} ${b.windowRange}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Aging Window Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${b.startYear} ${b.startYear == 2015 ? t('cellar_harvest_label') : ''}',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                  ),
                  Text(
                    t(b.centerStatusKey),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: b.progress > 0.8
                          ? const Color(0xFF059669)
                          : const Color(0xFF7B581C),
                    ),
                  ),
                  Text(
                    '${b.endYear}',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: b.progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E2DF),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    b.progress > 0.8
                        ? const Color(0xFF059669)
                        : const Color(0xFF7B581C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Bar: Quantity stepper + Fav heart + Cork button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity stepper
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E2DF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        CellarService.instance.updateQuantity(b.id, -1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F3F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, size: 13, color: Color(0xFF581825)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${b.quantity} bott.',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C0311),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        CellarService.instance.updateQuantity(b.id, 1);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF581825),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 13, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite Heart
                  IconButton(
                    icon: Icon(
                      b.isFav ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: b.isFav ? const Color(0xFFB91C1C) : Colors.grey[500],
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      CellarService.instance.toggleFav(b.id);
                    },
                    tooltip: b.isFav ? t('cellar_fav_removed') : t('cellar_fav_added'),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 4),

                  // Stappa button
                  ElevatedButton.icon(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      await CellarService.instance.corkBottle(b.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t('cellar_corked_toast')),
                            backgroundColor: const Color(0xFF581825),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.wine_bar, size: 14),
                    label: Text(t('cellar_cork_btn'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF581825),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. STATISTICHE DEL BEVITORE & WINE RADAR
  Widget _buildDrinkerAnalytics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDEA),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('cellar_analytics_subtitle').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF7B581C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t('cellar_drinker_stats_title'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3C0311),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.pie_chart, color: Color(0xFF7B581C), size: 24),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            t('cellar_geo_split_subtitle'),
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),

          // Segmented Colored Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: 50,
                    child: Container(color: const Color(0xFF3C0311)),
                  ),
                  Expanded(
                    flex: 30,
                    child: Container(color: const Color(0xFF7B581C)),
                  ),
                  Expanded(
                    flex: 20,
                    child: Container(color: const Color(0xFFFDCC85)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRegionLegendItem(
                color: const Color(0xFF3C0311),
                percentage: '50%',
                label: 'Toscana (12)',
              ),
              _buildRegionLegendItem(
                color: const Color(0xFF7B581C),
                percentage: '30%',
                label: 'Piemonte (7)',
              ),
              _buildRegionLegendItem(
                color: const Color(0xFFFDCC85),
                percentage: '20%',
                label: 'Lombardia (5)',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Cellar Climate Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.thermostat, color: Color(0xFF7B581C), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('cellar_conditions_note'),
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      Text(
                        t('cellar_conditions_val'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3C0311),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFE2DDD9)),
          const SizedBox(height: 14),

          // Aging Horizon Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (appLang.value == 'it' ? 'Evoluzione & Longevità' : 'Aging & Longevity').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: Color(0xFF7B581C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appLang.value == 'it' ? 'Orizzonte di Beva (2024 - 2035+)' : 'Drinking Window (2024 - 2035+)',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3C0311),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.timeline_rounded, color: Color(0xFF7B581C), size: 22),
            ],
          ),
          const SizedBox(height: 10),

          // 3-Stage Longevity Curve Bars
          _buildLongevityStage(
            label: appLang.value == 'it' ? 'Al Culmine / Ideali Ora (2024-2026)' : 'At Peak / Drink Now (2024-2026)',
            bottlesCount: '2 btg (8%)',
            sampleWine: 'Franciacorta Satèn Millesimato',
            color: const Color(0xFF059669),
            fraction: 0.25,
          ),
          const SizedBox(height: 8),
          _buildLongevityStage(
            label: appLang.value == 'it' ? 'In Affinamento Ottimale (2027-2030)' : 'Optimal Cellaring (2027-2030)',
            bottlesCount: '14 btg (58%)',
            sampleWine: 'Amarone Bertani 2018 · Cervaro 2021',
            color: const Color(0xFFD97706),
            fraction: 0.65,
          ),
          const SizedBox(height: 8),
          _buildLongevityStage(
            label: appLang.value == 'it' ? 'Riserva da Collezione (> 2030)' : 'Collection Reserve (> 2030)',
            bottlesCount: '8 btg (34%)',
            sampleWine: 'Barolo Bricco Rocche 2017 · Sassicaia',
            color: const Color(0xFF7C3AED),
            fraction: 0.85,
          ),
        ],
      ),
    );
  }

  Widget _buildLongevityStage({
    required String label,
    required String bottlesCount,
    required String sampleWine,
    required Color color,
    required double fraction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2C2224)),
                ),
              ),
              Text(
                bottlesCount,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: const Color(0xFFE5E2DF),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            sampleWine,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionLegendItem({
    required Color color,
    required String percentage,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3C0311),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
