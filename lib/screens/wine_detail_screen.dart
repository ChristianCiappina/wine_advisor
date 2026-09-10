import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wine_advisor/screens/login_screen.dart';
import 'package:wine_advisor/screens/profile_screen.dart';
import 'package:wine_advisor/services/cellar_service.dart';
import 'package:wine_advisor/widgets/language_pill.dart';
import '../main.dart';

class WineDetailScreen extends StatefulWidget {
  final String? wineKey;
  final String? customTitle;
  final String? customWinery;
  final String? customPrice;

  const WineDetailScreen({
    super.key,
    this.wineKey,
    this.customTitle,
    this.customWinery,
    this.customPrice,
  });

  @override
  State<WineDetailScreen> createState() => _WineDetailScreenState();
}

class _WineDetailScreenState extends State<WineDetailScreen> {
  bool _isInWishlist = false;
  bool _isInCellar = false;
  bool _isBookmarked = false;
  bool _storyExpanded = false;

  @override
  void initState() {
    super.initState();
    final title = widget.customTitle ?? 'Barolo Bricco Rocche';
    _isInCellar = CellarService.instance.isBottleInCellar(title);
  }

  void _toggleWishlist() {
    HapticFeedback.selectionClick();
    setState(() => _isInWishlist = !_isInWishlist);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isInWishlist
              ? t('added_to_wishlist')
              : t('removed_from_wishlist'),
        ),
        backgroundColor: const Color(0xFF581825),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleCellar() async {
    HapticFeedback.mediumImpact();
    final title = widget.customTitle ?? 'Barolo Bricco Rocche';
    final winery = widget.customWinery ?? 'Ceretto · 2017';
    final price = widget.customPrice ?? '€185';
    final bottleId = 'detail-${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-')}';

    setState(() => _isInCellar = !_isInCellar);

    if (_isInCellar) {
      await CellarService.instance.addBottle(
        CellarBottleItem(
          id: bottleId,
          title: title,
          winery: winery,
          region: 'Piemonte, Italia',
          vintage: 2017,
          quantity: 1,
          score: '98 pt',
          statusCategory: 'aging',
          statusKey: 'cellar_status_aging',
          statusColorValue: 0xFFD97706,
          windowRange: '2024-2038',
          startYear: 2017,
          endYear: 2038,
          centerStatusKey: 'cellar_peak_in_years',
          progress: 0.45,
          priceEstimate: price,
          emoji: '🍷',
        ),
      );
    } else {
      await CellarService.instance.removeBottle(bottleId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isInCellar
                ? t('cellared_toast')
                : t('removed_cellar_toast'),
          ),
          backgroundColor: _isInCellar ? const Color(0xFF7B581C) : Colors.blueGrey,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showMarketModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.shopping_bag, color: Color(0xFF7B581C)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t('market_modal_title'),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C0311),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('market_modal_desc'),
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              _buildMerchantTile(
                name: 'Tannico Premium',
                delivery: 'Consegna in 24h · €185',
                rating: '4.9 ★',
              ),
              const Divider(),
              _buildMerchantTile(
                name: 'Callmewine Privé',
                delivery: 'Spedizione refrigerata · €182',
                rating: '4.8 ★',
              ),
              const Divider(),
              _buildMerchantTile(
                name: 'Enoteca Falletto Store',
                delivery: 'Ritiro diretto in cantina · €180',
                rating: '5.0 ★',
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
    );
  }

  Widget _buildMerchantTile({
    required String name,
    required String delivery,
    required String rating,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.storefront_rounded, color: Color(0xFF581825), size: 20),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(delivery, style: const TextStyle(fontSize: 12)),
      trailing: ElevatedButton(
        onPressed: () {
          final messenger = ScaffoldMessenger.of(context);
          final isIt = appLang.value == 'it';
          Navigator.pop(context);
          messenger.showSnackBar(
            SnackBar(
              content: Text(isIt ? 'Reindirizzamento verso $name...' : 'Redirecting to $name...'),
              backgroundColor: const Color(0xFF581825),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF581825),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text('Acquista', style: TextStyle(fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) {
        User? user;
        try {
          user = Supabase.instance.client.auth.currentUser;
        } catch (_) {
          user = null;
        }

        final title = widget.customTitle ?? 'Barolo Bricco Rocche';
        final winery = widget.customWinery ?? 'Ceretto · 2017';
        final price = widget.customPrice ?? '€185';

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F6),
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Top Bar
                          _buildTopBar(context, user),

                          // 2. Hero Showcase Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: _buildHeroShowcase(title, winery, price),
                          ),

                          // 3. Spettro Organolettico (Sensory Analysis)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: _buildSensoryAnalysisSection(),
                          ),

                          // 4. Bouquet Aromatico
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: _buildBouquetSection(),
                          ),

                          // 5. Servizio & Decantazione
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: _buildServiceSection(),
                          ),

                          // 6. Abbinamenti Gastronomici Consigliati
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: _buildPairingsSection(),
                          ),

                          // 7. La Cantina & Il Terroir
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: _buildWinerySection(),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),

                // 8. Floating Bottom Interaction Dock
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildFloatingDock(price),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 1. TOP BAR
  Widget _buildTopBar(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: const Color(0xFF3C0311),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF581825), Color(0xFF3C0311)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF581825).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 18),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                t('detail_title'),
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3C0311),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const LanguagePill(),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  size: 22,
                  color: _isBookmarked ? const Color(0xFF7B581C) : Colors.grey[800],
                ),
                onPressed: () {
                  setState(() => _isBookmarked = !_isBookmarked);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isBookmarked ? t('result_saved') : t('result_removed')),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF581825),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDCC85), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. HERO SHOWCASE CARD
  Widget _buildHeroShowcase(String title, String winery, String price) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3F0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Row & Heart Wishlist Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 6,
                children: [
                  _buildBadgePill('DOCG', isPrimary: true),
                  _buildBadgePill('Annata 2017'),
                  _buildBadgePill('14.5% vol'),
                ],
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                icon: Icon(
                  _isInWishlist ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: _isInWishlist ? const Color(0xFF581825) : Colors.grey[700],
                ),
                onPressed: _toggleWishlist,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bottle & Identity Split
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Bottle Mockup Container
              Container(
                width: 110,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1558001373-7b93ee48ffa0?w=600&auto=format&fit=crop&q=80',
                        width: 110,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF581825), Color(0xFF3C0311)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 54),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF581825).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFDCC85).withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            t('cru_historic').toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFFFDCC85),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Title, Location, Winery & Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF7B581C)),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Castiglione Falletto, Piemonte',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7B581C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C0311),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      winery,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3C0311),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t('est_avg_price'),
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating Badges Shelf (3 columns)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildScoreShelfItem(
                  score: '4.9 / 5',
                  hasStar: true,
                  source: 'Wine Advisor',
                ),
                Container(width: 1, height: 32, color: Colors.grey[200]),
                _buildScoreShelfItem(
                  score: '98 / 100',
                  source: 'Robert Parker',
                  isPrimary: true,
                ),
                Container(width: 1, height: 32, color: Colors.grey[200]),
                _buildScoreShelfItem(
                  score: '3 Bicchieri',
                  source: 'Gambero Rosso',
                  isGold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(String text, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isPrimary ? const Color(0xFF3C0311) : Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildScoreShelfItem({
    required String score,
    required String source,
    bool hasStar = false,
    bool isPrimary = false,
    bool isGold = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasStar) ...[
                const Icon(Icons.star, size: 14, color: Color(0xFF7B581C)),
                const SizedBox(width: 2),
              ],
              Text(
                score,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isPrimary
                      ? const Color(0xFF3C0311)
                      : (isGold ? const Color(0xFF7B581C) : Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            source.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // 3. SPETTRO ORGANOLETTICO (SENSORY ANALYSIS)
  Widget _buildSensoryAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('sensory_analysis').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF7B581C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('organoleptic_spectrum'),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3C0311),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t('vintage_excellent'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3C0311),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3F0),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSpectrogramRow(
                label: t('body_label'),
                description: t('body_desc_barolo'),
                progress: 0.85,
                barColor: const Color(0xFF581825),
              ),
              const SizedBox(height: 14),
              _buildSpectrogramRow(
                label: t('tannin_label'),
                description: t('tannin_desc_barolo'),
                progress: 0.90,
                barColor: const Color(0xFF581825),
              ),
              const SizedBox(height: 14),
              _buildSpectrogramRow(
                label: t('acidity_label'),
                description: t('acidity_desc_barolo'),
                progress: 0.75,
                barColor: const Color(0xFF7B581C),
              ),
              const SizedBox(height: 14),
              _buildSpectrogramRow(
                label: t('sweetness_label'),
                description: t('sweetness_desc_barolo'),
                progress: 0.10,
                barColor: const Color(0xFF867274),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpectrogramRow({
    required String label,
    required String description,
    required double progress,
    required Color barColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1B1C1A),
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E2DF),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  // 4. BOUQUET OLFATTIVO
  Widget _buildBouquetSection() {
    final aromas = [
      {
        'icon': Icons.local_florist,
        'title': t('aroma_rose_dried'),
        'subtitle': t('aroma_rose_dried_sub'),
        'color': const Color(0xFF581825),
        'bg': const Color(0xFFFFD9DC),
      },
      {
        'icon': Icons.nature,
        'title': t('aroma_truffle_tar'),
        'subtitle': t('aroma_truffle_tar_sub'),
        'color': const Color(0xFF7B581C),
        'bg': const Color(0xFFFFDDB0),
      },
      {
        'icon': Icons.restaurant,
        'title': t('aroma_cherry_liqueur'),
        'subtitle': t('aroma_cherry_liqueur_sub'),
        'color': const Color(0xFF581825),
        'bg': const Color(0xFFFFD9DC),
      },
      {
        'icon': Icons.spa,
        'title': t('aroma_dark_spices'),
        'subtitle': t('aroma_dark_spices_sub'),
        'color': const Color(0xFF7B581C),
        'bg': const Color(0xFFFFDDB0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('bouquet_title').toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF7B581C),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          t('primary_tertiary_aromas'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3C0311),
          ),
        ),
        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: aromas.map((aroma) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3F0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: aroma['bg'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      aroma['icon'] as IconData,
                      size: 18,
                      color: aroma['color'] as Color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aroma['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                        Text(
                          aroma['subtitle'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 5. SERVIZIO & DECANTAZIONE
  Widget _buildServiceSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EDEA),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.thermostat, color: Color(0xFF581825), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('service_temp_label').toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B581C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t('service_temp_desc'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                t('decant_time_label').toUpperCase(),
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                t('decant_time_desc'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF581825),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. ABBINAMENTI GASTRONOMICI
  Widget _buildPairingsSection() {
    final pairings = [
      {
        'title': t('pairing_dish_1_title'),
        'desc': t('pairing_dish_1_desc'),
        'badge': t('pairing_perfect_badge'),
        'emoji': '🥩',
        'badgeColor': const Color(0xFF581825),
      },
      {
        'title': t('pairing_dish_2_title'),
        'desc': t('pairing_dish_2_desc'),
        'badge': t('pairing_territory_badge'),
        'emoji': '🍄',
        'badgeColor': const Color(0xFF7B581C),
      },
      {
        'title': t('pairing_dish_3_title'),
        'desc': t('pairing_dish_3_desc'),
        'badge': t('pairing_cheese_badge'),
        'emoji': '🧀',
        'badgeColor': const Color(0xFF3C0311),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('table_art').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF7B581C),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t('choice_pairings'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3C0311),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.restaurant, color: Color(0xFF7B581C), size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 165,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: pairings.length,
            itemBuilder: (ctx, index) {
              final dish = pairings[index];

              return Container(
                width: 210,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F0),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: (dish['badgeColor'] as Color),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dish['badge'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(dish['emoji'] as String, style: const TextStyle(fontSize: 22)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish['title'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF3C0311),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dish['desc'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey[700], height: 1.3),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. LA CANTINA & IL TERROIR
  Widget _buildWinerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('winery_terroir_title').toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF7B581C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('winery_name_ceretto'),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3C0311),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => setState(() => _storyExpanded = !_storyExpanded),
              child: Text(
                _storyExpanded ? t('collapse_btn') : t('expand_btn'),
                style: const TextStyle(
                  color: Color(0xFF7B581C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F3F0),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E2DF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('🏰', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bricco Rocche · Cru Singolare',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          t('winery_soil_ceretto'),
                          style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t('winery_story_ceretto'),
                maxLines: _storyExpanded ? null : 3,
                overflow: _storyExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.eco, size: 14, color: Color(0xFF7B581C)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            t('organic_certified'),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t('founded_in'),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF581825),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 8. FLOATING BOTTOM DOCK
  Widget _buildFloatingDock(String price) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F6).withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // In Cantina Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _toggleCellar,
              icon: Icon(
                _isInCellar ? Icons.check : Icons.wine_bar,
                size: 18,
                color: _isInCellar ? const Color(0xFF291800) : const Color(0xFF581825),
              ),
              label: Text(
                _isInCellar ? t('cellared_btn') : t('in_cellar_btn'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: _isInCellar ? const Color(0xFF291800) : const Color(0xFF581825),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isInCellar
                    ? const Color(0xFFFDCC85)
                    : const Color(0xFFF0EDEA),
                elevation: 0,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Purchase Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showMarketModal,
              icon: const Icon(Icons.shopping_bag, size: 18, color: Colors.white),
              label: Text(
                '${t('buy_at_price')} · $price',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF581825),
                elevation: 2,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
