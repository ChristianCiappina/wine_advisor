import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wine_advisor/models/wine_recommendation.dart';
import 'package:wine_advisor/screens/calculator_screen.dart';
import 'package:wine_advisor/screens/cellar_screen.dart';
import 'package:wine_advisor/screens/food_screen.dart';
import 'package:wine_advisor/screens/login_screen.dart';
import 'package:wine_advisor/screens/mood_screen.dart';
import 'package:wine_advisor/screens/profile_screen.dart';
import 'package:wine_advisor/screens/quiz_screen.dart';
import 'package:wine_advisor/screens/result_screen.dart';
import 'package:wine_advisor/screens/reverse_pairing_screen.dart';
import 'package:wine_advisor/screens/scanner_screen.dart';
import 'package:wine_advisor/screens/service_guide_screen.dart';
import 'package:wine_advisor/screens/sommelier_chat_screen.dart';
import 'package:wine_advisor/screens/tasting_lab_screen.dart';
import 'package:wine_advisor/screens/wine_detail_screen.dart';
import 'package:wine_advisor/widgets/language_pill.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _FeaturedWineData {
  final String title;
  final String winery;
  final String vintage;
  final String denomination;
  final String region;
  final String score;
  final String reviews;
  final String reviewsEn;
  final String price;
  final List<String> notesIt;
  final List<String> notesEn;
  final int catId;
  final String categoryNameIt;
  final String categoryNameEn;
  final String exampleWines;
  final String explanationIt;
  final String explanationEn;
  final String servingTemperature;
  final List<Color> gradientColors;
  final Color accentColor;
  final IconData icon;
  final String imageUrl;

  const _FeaturedWineData({
    required this.title,
    required this.winery,
    required this.vintage,
    required this.denomination,
    required this.region,
    required this.score,
    required this.reviews,
    required this.reviewsEn,
    required this.price,
    required this.notesIt,
    required this.notesEn,
    required this.catId,
    required this.categoryNameIt,
    required this.categoryNameEn,
    required this.exampleWines,
    required this.explanationIt,
    required this.explanationEn,
    required this.servingTemperature,
    required this.gradientColors,
    required this.accentColor,
    required this.icon,
    required this.imageUrl,
  });
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _bookmarkedBottles = {};

  static const Map<String, _FeaturedWineData> _featuredWinesByFilter = {
    'all': _FeaturedWineData(
      title: 'Amarone della Valpolicella Classico',
      winery: 'Cantina Bertani · 2018',
      vintage: '2018',
      denomination: 'DOCG',
      region: 'Veneto, Italia',
      score: '4.9',
      reviews: '(1.420 recensioni)',
      reviewsEn: '(1,420 reviews)',
      price: '€68',
      notesIt: ['Ciliegia matura', 'Vaniglia nobile', 'Spezie tostate'],
      notesEn: ['Ripe Cherry', 'Noble Vanilla', 'Toasted Spices'],
      catId: 3,
      categoryNameIt: 'Rosso Strutturato',
      categoryNameEn: 'Full-bodied Red',
      exampleWines: 'Amarone della Valpolicella, Barolo, Brunello',
      explanationIt: 'Vino potente, dai tannini vellutati e dal corpo sontuoso.',
      explanationEn: 'Powerful wine with velvety tannins and a sumptuous body.',
      servingTemperature: '16-18°C',
      gradientColors: [Color(0xFF4A0E17), Color(0xFF1E0408)],
      accentColor: Color(0xFFFDCC85),
      icon: Icons.wine_bar,
      imageUrl: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=800&auto=format&fit=crop&q=80',
    ),
    'rossi': _FeaturedWineData(
      title: 'Barolo Riserva Monfortino',
      winery: 'Giacomo Conterno · 2015',
      vintage: '2015',
      denomination: 'DOCG',
      region: 'Piemonte, Italia',
      score: '5.0',
      reviews: '(980 recensioni)',
      reviewsEn: '(980 reviews)',
      price: '€185',
      notesIt: ['Goudron & Tartufo', 'Rosa appassita', 'Cacao puro'],
      notesEn: ['Tar & Truffle', 'Dried Rose', 'Pure Cocoa'],
      catId: 3,
      categoryNameIt: 'Rosso Strutturato',
      categoryNameEn: 'Full-bodied Red',
      exampleWines: 'Barolo Monfortino, Sassicaia, Solaia',
      explanationIt: 'Il Re dei vini: austerità nobile, tannini scolpiti e longevità leggendaria.',
      explanationEn: 'The King of wines: noble austerity, sculpted tannins and legendary longevity.',
      servingTemperature: '18-20°C',
      gradientColors: [Color(0xFF5A1420), Color(0xFF24070D)],
      accentColor: Color(0xFFFDCC85),
      icon: Icons.wine_bar_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=800&auto=format&fit=crop&q=80',
    ),
    'bollicine': _FeaturedWineData(
      title: 'Franciacorta Riserva Cuvée Annamaria Clementi',
      winery: "Ca' del Bosco · 2015",
      vintage: '2015',
      denomination: 'DOCG',
      region: 'Lombardia, Italia',
      score: '4.9',
      reviews: '(1.150 recensioni)',
      reviewsEn: '(1,150 reviews)',
      price: '€95',
      notesIt: ['Agrumi canditi', 'Crosta di pane', 'Miele di tiglio'],
      notesEn: ['Candied Citrus', 'Brioche Crust', 'Linden Honey'],
      catId: 2,
      categoryNameIt: 'Bollicina Strutturata',
      categoryNameEn: 'Structured Sparkling',
      exampleWines: 'Franciacorta Riserva, Trento DOC, Champagne',
      explanationIt: 'Metodo Classico maestoso: perlage cremoso, dorata complessità e freschezza minerale.',
      explanationEn: 'Majestic Classic Method: creamy perlage, golden complexity and crisp salinity.',
      servingTemperature: '8-10°C',
      gradientColors: [Color(0xFF5A4418), Color(0xFF241A06)],
      accentColor: Color(0xFFFFD54F),
      icon: Icons.auto_awesome,
      imageUrl: 'https://images.unsplash.com/photo-1569919659476-f0852f6834b7?w=800&auto=format&fit=crop&q=80',
    ),
    'bianchi': _FeaturedWineData(
      title: 'Cervaro della Sala',
      winery: 'Marchesi Antinori · 2021',
      vintage: '2021',
      denomination: 'IGT',
      region: 'Umbria, Italia',
      score: '4.8',
      reviews: '(890 recensioni)',
      reviewsEn: '(890 reviews)',
      price: '€54',
      notesIt: ['Burro fuso', 'Pietra focaia', 'Pesca bianca'],
      notesEn: ['Melted Butter', 'Flint Minerality', 'White Peach'],
      catId: 4,
      categoryNameIt: 'Bianco Strutturato o Bollicina',
      categoryNameEn: 'Full-bodied White or Sparkling',
      exampleWines: 'Cervaro della Sala, Rossj-Bass, Vintage Tunina',
      explanationIt: 'Chardonnay di classe mondiale: avvolgente, minerale e dal finale sapido interminabile.',
      explanationEn: 'World-class Chardonnay: rich, mineral and with an endless savory finish.',
      servingTemperature: '10-12°C',
      gradientColors: [Color(0xFF4A441E), Color(0xFF1B1808)],
      accentColor: Color(0xFFFFE082),
      icon: Icons.wine_bar,
      imageUrl: 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=800&auto=format&fit=crop&q=80',
    ),
    'bio': _FeaturedWineData(
      title: 'Brunello di Montalcino Biodinamico',
      winery: 'Podere Le Ripi · 2017',
      vintage: '2017',
      denomination: 'DOCG',
      region: 'Toscana, Italia',
      score: '4.9',
      reviews: '(640 recensioni)',
      reviewsEn: '(640 reviews)',
      price: '€78',
      notesIt: ['Sottobosco', 'Violetta selvatica', 'Erbe officinali'],
      notesEn: ['Forest Floor', 'Wild Violet', 'Medicinal Herbs'],
      catId: 3,
      categoryNameIt: 'Rosso Strutturato',
      categoryNameEn: 'Full-bodied Red',
      exampleWines: 'Podere Le Ripi Brunello, Foradori Teroldego, Emidio Pepe',
      explanationIt: 'Pura espressione biodinamica: armonia naturale tra frutto vibrante, terra e tannino vellutato.',
      explanationEn: 'Pure biodynamic expression: natural harmony between vibrant fruit, earth and velvety tannins.',
      servingTemperature: '16-18°C',
      gradientColors: [Color(0xFF332014), Color(0xFF140C07)],
      accentColor: Color(0xFF81C784),
      icon: Icons.eco_rounded,
      imageUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=800&auto=format&fit=crop&q=80',
    ),
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDisplayName(String? email) {
    if (email == null || email.isEmpty) return t('guest_title');
    final namePart = email.split('@')[0];
    final cleanName = namePart.replaceAll(RegExp(r'[0-9_\.]'), ' ').trim();
    if (cleanName.isEmpty) return namePart;
    return cleanName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return t('good_morning');
    } else if (hour < 18) {
      return t('good_afternoon');
    } else {
      return t('good_evening');
    }
  }

  void _showNotificationDialog() {
    final isIt = appLang.value == 'it';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF4EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_active, color: Color(0xFF7B581C), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isIt ? 'Notifiche Sommelier' : 'Sommelier Notifications',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF581825).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wine_bar, color: Color(0xFF581825), size: 20),
              ),
              title: Text(
                isIt ? 'Selezione del Mese Aggiornata' : 'Selection of the Month Updated',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                isIt
                    ? 'Scopri l\'Amarone Classico Bertani 2018 consigliato dallo Chef.'
                    : 'Discover the Amarone Classico Bertani 2018 recommended by our Chef.',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B581C).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF7B581C), size: 20),
              ),
              title: Text(
                isIt ? 'Trucco del Ghiaccio & Sale' : 'Ice & Salt Master Trick',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                isIt
                    ? 'Come raffreddare il vino in 10 minuti: consulta la Guida al Servizio.'
                    : 'How to chill wine in 10 minutes: check the Service Guide.',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF581825),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child: Text(isIt ? 'Chiudi' : 'Close'),
          ),
        ],
      ),
    );
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
        final displayName = user != null ? _formatDisplayName(user.email) : t('guest_title');

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F6),
          body: _buildBody(context, displayName, user),
          bottomNavigationBar: _buildLuxuryBottomNav(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, String displayName, User? user) {
    switch (_selectedTabIndex) {
      case 1:
        return const FoodScreen();
      case 2:
        return const ScannerScreen();
      case 3:
        return CellarScreen(
          onNavigateToScanner: () => setState(() => _selectedTabIndex = 2),
        );
      case 4:
        return const SommelierChatScreen();
      case 0:
      default:
        return _buildLuxuryHomeView(context, displayName, user);
    }
  }

  // 1. HOME VIEW
  Widget _buildLuxuryHomeView(
    BuildContext context,
    String displayName,
    User? user,
  ) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Bar
                _buildTopHeader(context, user),
                const SizedBox(height: 16),

                // Hero & Greeting Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('private_experience').toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF7B581C),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_getGreeting()}, $displayName',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF3C0311),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t('what_to_uncork'),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Bar
                      _buildSearchBar(context),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Horizontal Filter Pills
                _buildFilterPills(),
                const SizedBox(height: 24),

                // Sommelier Selection Card (Mese Corrente)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSommelierSelectionCard(context),
                ),
                const SizedBox(height: 28),

                // Pairing of the Day (Gourmet)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPairingOfTheDayCard(context),
                ),
                const SizedBox(height: 28),

                // Community Favorites Carousel
                _buildCommunityFavoritesSection(context),
                const SizedBox(height: 24),

                // Scan Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildScanBanner(context),
                ),
                const SizedBox(height: 32),

                // Exclusive Paths Hub
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPathsHub(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TOP HEADER
  Widget _buildTopHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F6).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF2C2224).withValues(alpha: 0.05)),
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
                    t('nav_home').toUpperCase(),
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

  // SEARCH BAR
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (val) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FoodScreen(initialQuery: val)),
          );
        },
        decoration: InputDecoration(
          hintText: t('home_search_hint'),
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF7B581C), size: 22),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: Colors.grey, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodScreen(initialQuery: _searchController.text),
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // FILTER PILLS
  Widget _buildFilterPills() {
    final filters = [
      {'id': 'all', 'label': t('filter_all')},
      {'id': 'rossi', 'label': t('filter_reds')},
      {'id': 'bollicine', 'label': t('filter_bubbles')},
      {'id': 'bianchi', 'label': t('filter_whites')},
      {'id': 'bio', 'label': t('filter_bio')},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedFilter = f['id']!),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF581825) : const Color(0xFFF6F3F0),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF581825) : const Color(0xFFE8DFD8),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF581825).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    f['label']!,
                    softWrap: false,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF3C0311),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // SOMMELIER SELECTION CARD
  Widget _buildSommelierSelectionCard(BuildContext context) {
    final wineData = _featuredWinesByFilter[_selectedFilter] ?? _featuredWinesByFilter['all']!;
    final isIt = appLang.value == 'it';
    final notes = isIt ? wineData.notesIt : wineData.notesEn;
    final reviewsText = isIt ? wineData.reviews : wineData.reviewsEn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Color(0xFF7B581C), size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t('sommelier_month_selection'),
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
            ),
            const SizedBox(width: 8),
            Text(
              t('current_month').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF7B581C),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF2C2224).withValues(alpha: 0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 92,
                      height: 134,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Realistic Glass Bottle Photo
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              wineData.imageUrl,
                              width: 92,
                              height: 134,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: wineData.gradientColors,
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    wineData.icon,
                                    size: 38,
                                    color: wineData.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Subtle Luxury Dark Scrim for Corner Badges
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.75),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Star Rating Pill
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: wineData.accentColor.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, size: 9, color: wineData.accentColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    wineData.score,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: wineData.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Vintage Year Pill
                          Positioned(
                            bottom: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: wineData.accentColor.withValues(alpha: 0.6),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                wineData.vintage,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: wineData.accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDCC85),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  wineData.denomination,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF291800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '• ${wineData.region}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            wineData.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3C0311),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wineData.winery,
                            style: const TextStyle(
                              color: Color(0xFF7B581C),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDCC85).withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, size: 12, color: Color(0xFF785519)),
                                    const SizedBox(width: 3),
                                    Text(
                                      wineData.score,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF785519),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reviewsText,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                t('indicative_price'),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                wineData.price,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3C0311),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Olfactory Tags
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F3F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_florist, size: 13, color: Color(0xFF7B581C)),
                          const SizedBox(width: 4),
                          Text(
                            t('olfactory_notes_structure').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: Color(0xFF534344),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: notes.map((note) => _TagPill(label: note)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WineDetailScreen(
                                customTitle: wineData.title,
                                customWinery: wineData.winery,
                                customPrice: wineData.price,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.wine_bar, size: 16),
                        label: Text(
                          t('detail_title'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF581825),
                          side: const BorderSide(color: Color(0xFF581825), width: 1.2),
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                recommendation: WineRecommendation(
                                  id: wineData.catId,
                                  categoryName: isIt ? wineData.categoryNameIt : wineData.categoryNameEn,
                                  exampleWines: wineData.exampleWines,
                                  explanation: isIt ? wineData.explanationIt : wineData.explanationEn,
                                  servingTemperature: wineData.servingTemperature,
                                ),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant_menu, size: 16),
                        label: Text(
                          t('discover_pairings_btn'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF581825),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
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

  // PAIRING OF THE DAY
  Widget _buildPairingOfTheDayCard(BuildContext context) {
    final isIt = appLang.value == 'it';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.wine_bar, color: Color(0xFF7B581C), size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      t('pairing_of_the_day'),
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
            ),
            const SizedBox(width: 8),
            const Text(
              'Gourmet',
              style: TextStyle(
                color: Color(0xFF7B581C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: const Color(0xFF2C2224).withValues(alpha: 0.08)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C2224).withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Top Banner with gradient
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3C0311), Color(0xFF581825)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDCC85),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t('chef_advice_badge'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF291800),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${t('tannic_balance')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Filetto al Pepe Verde & Barolo Monfortino 2016',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cantina Giacomo Conterno',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isIt
                                  ? 'Intenso, persistente, tannini vellutati'
                                  : 'Intense, lingering, velvety tannins',
                              style: const TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultScreen(
                                recommendation: WineRecommendation(
                                  id: 3,
                                  categoryName: isIt ? 'Rosso Strutturato' : 'Full-bodied Red',
                                  exampleWines: 'Barolo, Brunello, Amarone',
                                  explanation: isIt
                                      ? 'Abbinamento principe con la carne rossa al pepe verde.'
                                      : 'Master pairing for green peppercorn red meat.',
                                  servingTemperature: '16-18°C',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // COMMUNITY FAVORITES CAROUSEL
  Widget _buildCommunityFavoritesSection(BuildContext context) {
    final communityWines = [
      {
        'id': 'brunello',
        'catId': 3,
        'region': 'Toscana DOCG',
        'title': 'Brunello di Montalcino Riserva 2017',
        'winery': 'Biondi Santi',
        'rating': '4.8',
        'price': '€140',
        'gradient': [const Color(0xFF4A0E17), const Color(0xFF20050A)],
        'icon': Icons.wine_bar,
        'imageUrl': 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'franciacorta',
        'catId': 2,
        'region': 'Lombardia DOCG',
        'title': 'Franciacorta Cuvée Prestige Edizione',
        'winery': "Ca' del Bosco",
        'rating': '4.7',
        'price': '€42',
        'gradient': [const Color(0xFF5A4418), const Color(0xFF281E08)],
        'icon': Icons.auto_awesome,
        'imageUrl': 'https://images.unsplash.com/photo-1569919659476-f0852f6834b7?w=600&auto=format&fit=crop&q=80',
      },
      {
        'id': 'cervaro',
        'catId': 4,
        'region': 'Umbria IGT',
        'title': 'Cervaro della Sala 2021',
        'winery': 'Marchesi Antinori',
        'rating': '4.8',
        'price': '€55',
        'gradient': [const Color(0xFF4A441E), const Color(0xFF1E1C0A)],
        'icon': Icons.wine_bar_rounded,
        'imageUrl': 'https://images.unsplash.com/photo-1584916201218-f4242ceb4809?w=600&auto=format&fit=crop&q=80',
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFF7B581C), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t('community_favorites'),
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
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FoodScreen()),
                  );
                },
                child: Text(
                  t('see_all'),
                  style: const TextStyle(
                    color: Color(0xFF7B581C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: communityWines.length,
            itemBuilder: (ctx, index) {
              final wine = communityWines[index];
              final isBookmarked = _bookmarkedBottles.contains(wine['id']);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WineDetailScreen(
                        customTitle: wine['title'] as String?,
                        customWinery: wine['winery'] as String?,
                        customPrice: wine['price'] as String?,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 210,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2C2224).withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 76,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  wine['imageUrl'] as String,
                                  height: 76,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, err, stack) => Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: wine['gradient'] as List<Color>,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        wine['icon'] as IconData,
                                        size: 26,
                                        color: const Color(0xFFFDCC85),
                                      ),
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
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDCC85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          size: 10, color: Color(0xFF785519)),
                                      const SizedBox(width: 2),
                                      Text(
                                        wine['rating'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF785519),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (wine['region'] as String).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B581C),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wine['title'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF3C0311),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wine['winery'] as String,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          wine['price'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(4),
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
                            size: 20,
                            color: const Color(0xFF581825),
                          ),
                          onPressed: () {
                            setState(() {
                              if (isBookmarked) {
                                _bookmarkedBottles.remove(wine['id']);
                              } else {
                                _bookmarkedBottles.add(wine['id'] as String);
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isBookmarked
                                    ? t('result_removed')
                                    : t('result_saved')),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          ),
        ),
      ],
    );
  }

  // SCAN BANNER
  Widget _buildScanBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3C0311), Color(0xFF581825), Color(0xFF3C0311)],
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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFDCC85),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.center_focus_strong,
              color: Color(0xFF785519),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('scan_banner_title'),
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t('scan_banner_sub'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => setState(() => _selectedTabIndex = 2),
            icon: const Icon(Icons.photo_camera, size: 16),
            label: Text(t('scan_btn')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3C0311),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // EXCLUSIVE PATHS HUB
  Widget _buildPathsHub(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('hub_title'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3C0311),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          t('hub_sub'),
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 16),

        _buildPathCard(
          context,
          title: t('food_title'),
          subtitle: t('food_sub'),
          icon: Icons.restaurant_menu,
          accentColor: const Color(0xFFB57C1E),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const FoodScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('mood_title'),
          subtitle: t('mood_sub'),
          icon: Icons.nightlife,
          accentColor: const Color(0xFF7A4069),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const MoodScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: appLang.value == 'it'
              ? 'Concierge & Chat Sommelier AI'
              : 'Concierge & AI Sommelier Chat',
          subtitle: appLang.value == 'it'
              ? 'Consigli istantanei in chat per cene, regali e abbinamenti.'
              : 'Instant chat advice for dinners, gifts, and pairings.',
          badge: '✨ Gemini AI',
          icon: Icons.chat_bubble_outline,
          accentColor: const Color(0xFF8C6D23),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SommelierChatScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('quiz_card_title'),
          subtitle: t('quiz_card_sub'),
          badge: t('quiz_card_badge'),
          icon: Icons.auto_awesome,
          accentColor: const Color(0xFFC07F00),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const QuizScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('reverse_card_title'),
          subtitle: t('reverse_card_sub'),
          icon: Icons.dinner_dining,
          accentColor: const Color(0xFFC86D3B),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ReversePairingScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('calc_card_title'),
          subtitle: t('calc_card_sub'),
          badge: t('calc_card_badge'),
          icon: Icons.calculate_outlined,
          accentColor: const Color(0xFF2C6B74),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CalculatorScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('service_card_title'),
          subtitle: t('service_card_sub'),
          badge: t('service_card_badge'),
          icon: Icons.wine_bar_outlined,
          accentColor: const Color(0xFF581825),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ServiceGuideScreen())),
        ),
        const SizedBox(height: 12),

        _buildPathCard(
          context,
          title: t('lab_card_title'),
          subtitle: t('lab_card_sub'),
          badge: t('lab_card_badge'),
          icon: Icons.psychology_outlined,
          accentColor: const Color(0xFF385A75),
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const TastingLabScreen())),
        ),
      ],
    );
  }

  Widget _buildPathCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color accentColor = const Color(0xFF581825),
    String? badge,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDCC85).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF785519),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C0311),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF6F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF7B581C),
                  size: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION BAR
  Widget _buildLuxuryBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F6).withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C2224).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.explore_outlined,
                selectedIcon: Icons.explore,
                label: t('nav_home'),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.restaurant_menu_outlined,
                selectedIcon: Icons.restaurant_menu,
                label: t('nav_wines'),
              ),
              // Floating Center Scan Button
              Transform.translate(
                offset: const Offset(0, -10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 2),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _selectedTabIndex == 2
                          ? const LinearGradient(
                              colors: [Color(0xFF7B581C), Color(0xFFFDCC85)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF3C0311), Color(0xFF581825)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedTabIndex == 2
                                  ? const Color(0xFF7B581C)
                                  : const Color(0xFF581825))
                              .withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.document_scanner,
                      color: _selectedTabIndex == 2
                          ? const Color(0xFF291800)
                          : Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.shelves,
                selectedIcon: Icons.shelves,
                label: t('nav_cellar'),
                badgeCount: _bookmarkedBottles.length,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.psychology_outlined,
                selectedIcon: Icons.psychology,
                label: t('nav_sommelier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedTabIndex == index;
    final color = isSelected ? const Color(0xFF581825) : Colors.grey[600];

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: color,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B581C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
