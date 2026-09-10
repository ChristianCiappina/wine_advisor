import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wine_advisor/screens/login_screen.dart';
import 'package:wine_advisor/screens/profile_screen.dart';
import 'package:wine_advisor/screens/wine_detail_screen.dart';
import 'package:wine_advisor/services/cellar_service.dart';
import 'package:wine_advisor/services/gemini_service.dart';
import 'package:wine_advisor/widgets/language_pill.dart';
import '../main.dart';

class ScannerScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ScannerScreen({super.key, this.onBackToHome});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _flashActive = false;
  bool _cellarMode = false;
  bool _isBookmarked = false;
  bool _isAddedToCellar = false;
  bool _hasScannedResult = true;
  double _zoomLevel = 1.0;
  String _scanMode = 'front'; // 'front', 'back', 'wine_list'

  // Real Camera & Image Recognition State
  final ImagePicker _picker = ImagePicker();
  Uint8List? _capturedImageBytes;
  bool _isAnalyzing = false;
  RecognizedWine? _scannedWine;

  // Recognized Wine Key
  String _selectedWineKey = 'tignanello';

  final Map<String, Map<String, dynamic>> _winesDatabase = {
    'tignanello': {
      'title': 'Tignanello',
      'appellation': 'Toscana IGT • Annata 2019',
      'winery': 'Tenuta Tignanello, Marchesi Antinori',
      'points': '97',
      'rating': '4.9',
      'reviews': '3.850',
      'avgPrice': '€135',
      'marketRange': '€125-145',
      'maturation': 'Ottimale',
      'maturationUntil': '2038',
      'quote':
          '“Vellutato ed armonico. Trama tannica cesellata con profumi suadenti di mora selvatica, spezie nobili e tabacco tostato.”',
      'quoteEn':
          '“Velvety and harmonious. Chiseled tannic texture with alluring scents of wild blackberry, noble spices, and toasted tobacco.”',
      'catId': 3,
      'catName': 'Rosso Strutturato',
      'examples': 'Tignanello, Sassicaia, Barolo, Brunello',
      'explanation':
          'Vino iconico toscano di grande struttura, tannini vellutati e superba persistenza.',
      'temp': '16-18°C',
    },
    'sassicaia': {
      'title': 'Sassicaia',
      'appellation': 'Bolgheri Sassicaia DOC • 2018',
      'winery': 'Tenuta San Guido',
      'points': '98',
      'rating': '4.9',
      'reviews': '4.200',
      'avgPrice': '€290',
      'marketRange': '€270-320',
      'maturation': 'Eccellente',
      'maturationUntil': '2045',
      'quote':
          '“Icona mondiale assoluta. Aristocratico, trama cesellata con sentori di ribes nero, macchia mediterranea e legno nobile.”',
      'quoteEn':
          '“Absolute world icon. Aristocratic, chiseled texture with scents of black currant, Mediterranean scrub, and noble oak.”',
      'catId': 3,
      'catName': 'Rosso Strutturato',
      'examples': 'Sassicaia, Ornellaia, Barolo, Amarone',
      'explanation':
          'Il re dei Supertuscan. Vino di leggendaria eleganza e straordinaria longevità.',
      'temp': '16-18°C',
    },
    'cervaro': {
      'title': 'Cervaro della Sala',
      'appellation': 'Umbria IGT • Annata 2021',
      'winery': 'Marchesi Antinori',
      'points': '95',
      'rating': '4.8',
      'reviews': '2.400',
      'avgPrice': '€55',
      'marketRange': '€50-60',
      'maturation': 'Perfetta',
      'maturationUntil': '2030',
      'quote':
          '“Grande bianco da lungo invecchiamento. Note avvolgenti di burro vanigliato, agrumi canditi e pietra focaia minerale.”',
      'quoteEn':
          '“Great white built for cellaring. Enveloping notes of vanilla butter, candied citrus, and mineral flint.”',
      'catId': 4,
      'catName': 'Bianco Strutturato o Bollicina',
      'examples': 'Cervaro della Sala, Chardonnay barricato, Meursault',
      'explanation':
          'Chardonnay e Grechetto fermentati in barrique per una ricchezza aromatica inebriante.',
      'temp': '10-12°C',
    },
    'franciacorta': {
      'title': 'Cuvée Prestige Edizione',
      'appellation': 'Franciacorta DOCG • Brut',
      'winery': "Ca' del Bosco",
      'points': '94',
      'rating': '4.7',
      'reviews': '3.100',
      'avgPrice': '€42',
      'marketRange': '€38-46',
      'maturation': 'Pronto da bere',
      'maturationUntil': '2027',
      'quote':
          '“Bollicine finissime e persistenti. Sentori fragranti di crosta di pane dorata, pesca bianca e vibrante freschezza.”',
      'quoteEn':
          '“Ultra-fine, persistent perlage. Fragrant notes of golden brioche, white peach, and vibrant freshness.”',
      'catId': 2,
      'catName': 'Bollicina Strutturata',
      'examples': 'Franciacorta, Champagne Brut, Trento DOC',
      'explanation':
          'Metodo Classico prestigioso, perfetto per brindisi memorabili e cene raffinate.',
      'temp': '6-8°C',
    },
  };

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      _laserController.repeat(reverse: true);
    } else {
      _laserController.value = 0.5;
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentWine {
    if (_scannedWine != null) {
      return {
        'title': _scannedWine!.title,
        'appellation': _scannedWine!.appellation,
        'winery': _scannedWine!.winery,
        'points': _scannedWine!.points,
        'rating': _scannedWine!.rating,
        'reviews': '1.240',
        'avgPrice': _scannedWine!.avgPrice,
        'marketRange': _scannedWine!.marketRange,
        'maturation': _scannedWine!.maturation,
        'maturationUntil': _scannedWine!.maturationUntil,
        'quote': _scannedWine!.quote,
        'quoteEn': _scannedWine!.quoteEn,
        'catId': _scannedWine!.catId,
        'catName': _scannedWine!.catName,
        'examples': _scannedWine!.title,
        'explanation': _scannedWine!.quote,
        'temp': _scannedWine!.servingTemp,
        'vintage': _scannedWine!.vintage,
      };
    }
    return _winesDatabase[_selectedWineKey] ?? _winesDatabase['tignanello']!;
  }

  Future<void> _pickAndAnalyzeImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (file == null) return;

      final bytes = await file.readAsBytes();

      setState(() {
        _capturedImageBytes = bytes;
        _isAnalyzing = true;
      });

      final result = await GeminiService.instance.analyzeWineLabel(bytes);

      if (mounted) {
        setState(() {
          _scannedWine = result;
          _isAnalyzing = false;
          _isAddedToCellar = false;
          _isBookmarked = false;
          _hasScannedResult = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${t('scanner_match_confirmed')}: ${result.title}',
            ),
            backgroundColor: const Color(0xFF581825),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error capturing/analyzing image: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appLang.value == 'it'
                  ? 'Impossibile completare la scansione della foto. Riprova.'
                  : 'Unable to complete photo scan. Please try again.',
            ),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  void _showManualWineSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                  const Icon(Icons.edit_square, color: Color(0xFF7B581C)),
                  const SizedBox(width: 8),
                  Text(
                    t('scanner_manual_title'),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3C0311),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ..._winesDatabase.entries.map((entry) {
                final wine = entry.value;
                final isSelected = entry.key == _selectedWineKey;

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isSelected
                        ? const Color(0xFF581825)
                        : const Color(0xFFF6F3F0),
                    child: Text(
                      wine['catId'] == 2 ? '🍾' : (wine['catId'] == 4 ? '🥂' : '🍷'),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  title: Text(
                    wine['title'] as String,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF3C0311)
                          : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    '${wine['winery']} • ${wine['points']} Punti WA',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF7B581C))
                      : const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    setState(() {
                      _selectedWineKey = entry.key;
                      _isAddedToCellar = false;
                      _isBookmarked = false;
                      _hasScannedResult = true;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${t('scanner_match_confirmed')}: ${wine['title']}',
                        ),
                        backgroundColor: const Color(0xFF581825),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
    );
  }

  void _shareWineDetails() {
    final wine = _currentWine;
    final text =
        '${t('scanner_share_text_1')}*${wine['title']}* (${wine['appellation']})\n${wine['winery']}${t('scanner_share_text_2')}${appLang.value == 'en' ? wine['quoteEn'] : wine['quote']}\n\n🍇 Wine Advisor App';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('scanner_share_copied')),
        backgroundColor: const Color(0xFF581825),
        duration: const Duration(seconds: 2),
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

        final wine = _currentWine;
        final sommelierQuote =
            lang == 'en' ? (wine['quoteEn'] as String) : (wine['quote'] as String);

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F6),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top Header
                      _buildHeader(context, user),

                      // Camera Canvas Container
                      _buildScannerCanvas(context),

                      // Recognition Result Bottom Drawer or Interactive Camera Launcher
                      if (_hasScannedResult)
                        _buildResultCard(context, wine, sommelierQuote)
                      else
                        _buildCameraLauncherCard(context),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 1. TOP HEADER
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
                    t('scanner_nav_title').toUpperCase(),
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
              const SizedBox(width: 6),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                    color: Colors.grey[800],
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t('scanner_match_confirmed')),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
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
                    color: const Color(0xFF581825),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDCC85), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. SCANNER SIMULATION CANVAS
  Widget _buildScannerCanvas(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 440),
      decoration: BoxDecoration(
        color: _cellarMode ? const Color(0xFF140F11) : const Color(0xFF221B1C),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Cellar Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    _cellarMode
                        ? const Color(0xFF38151D).withValues(alpha: 0.4)
                        : const Color(0xFF4A1E26).withValues(alpha: 0.5),
                    const Color(0xFF140E10),
                  ],
                ),
              ),
            ),
          ),

          // Vintage Dimming Scrim
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.75),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),

          // Ambient Flash Spotlight Glow (illuminates viewfinder when flash is active)
          if (_flashActive)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(32)),
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.05),
                      radius: 0.75,
                      colors: [
                        const Color(0xFFFFF7D6).withValues(alpha: 0.28),
                        const Color(0xFFFDCC85).withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Main Column with HUD, Viewfinder, and Manual Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top HUD Bar: Active Status & Flash/Cellar Toggles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Scanner Active Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFDCC85).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDCC85),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t('scanner_active_badge'),
                            style: const TextStyle(
                              color: Color(0xFFFDCC85),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls (Flash & Cellar Mode)
                    Row(
                      children: [
                        // Flash Button
                        IconButton.filled(
                          onPressed: () {
                            setState(() => _flashActive = !_flashActive);
                          },
                          icon: Icon(
                            _flashActive ? Icons.flash_on : Icons.flash_off,
                            size: 18,
                            color: _flashActive
                                ? const Color(0xFF291800)
                                : Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: _flashActive
                                ? const Color(0xFFFDCC85)
                                : Colors.black.withValues(alpha: 0.5),
                            padding: const EdgeInsets.all(8),
                          ),
                          tooltip: _flashActive
                              ? t('scanner_flash_off')
                              : t('scanner_flash_on'),
                        ),
                        const SizedBox(width: 8),

                        // Cellar Night Mode Button
                        InkWell(
                          onTap: () {
                            setState(() => _cellarMode = !_cellarMode);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _cellarMode
                                  ? const Color(0xFFFDCC85)
                                  : Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _cellarMode
                                    ? Colors.transparent
                                    : Colors.white24,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.wine_bar,
                                  size: 16,
                                  color: _cellarMode
                                      ? const Color(0xFF291800)
                                      : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t('scanner_cellar_mode'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _cellarMode
                                        ? const Color(0xFF291800)
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Scan Mode Selector (Etichetta Fronte / Retro / Carta Vini)
                _buildScanModeSelector(),

                const SizedBox(height: 10),

                // Center Viewfinder with Reticle Corners & Laser
                _buildViewfinderReticle(),

                // Optical Zoom Selector Pills (0.5x, 1x, 2x, 3x)
                _buildOpticalZoomControls(),

                const SizedBox(height: 12),

                // Real Camera & Gallery Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickAndAnalyzeImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: Text(
                        appLang.value == 'it' ? 'Scatta Foto' : 'Take Photo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDCC85),
                        foregroundColor: const Color(0xFF3C0311),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickAndAnalyzeImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: Text(
                        appLang.value == 'it' ? 'Carica Foto' : 'Upload',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFFDCC85)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Dynamic Instruction Prompt Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 15, color: Color(0xFFFDCC85)),
                      const SizedBox(width: 8),
                      Text(
                        _getScanPrompt(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Manual Action Button
                TextButton.icon(
                  onPressed: _showManualWineSelector,
                  icon: const Icon(Icons.edit_square,
                      size: 16, color: Color(0xFFFDCC85)),
                  label: Text(
                    t('scanner_manual_entry'),
                    style: const TextStyle(
                      color: Color(0xFFFDCC85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFFDCC85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScanPrompt() {
    switch (_scanMode) {
      case 'back':
        return t('scanner_prompt_back');
      case 'wine_list':
        return t('scanner_prompt_list');
      case 'front':
      default:
        return t('scanner_frame_prompt');
    }
  }

  Widget _buildScanModeSelector() {
    final modes = [
      {'id': 'front', 'label': t('scanner_mode_front'), 'icon': Icons.crop_portrait_rounded},
      {'id': 'back', 'label': t('scanner_mode_back'), 'icon': Icons.flip_rounded},
      {'id': 'wine_list', 'label': t('scanner_mode_list'), 'icon': Icons.receipt_long_rounded},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((m) {
          final isSelected = _scanMode == m['id'];
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _scanMode = m['id'] as String);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDCC85) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFDCC85).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    m['icon'] as IconData,
                    size: 13,
                    color: isSelected ? const Color(0xFF291800) : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    m['label'] as String,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF291800) : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOpticalZoomControls() {
    final zoomLevels = [0.5, 1.0, 2.0, 3.0];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDCC85).withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: zoomLevels.map((lvl) {
          final isSelected = (_zoomLevel - lvl).abs() < 0.01;
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _zoomLevel = lvl);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDCC85) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${lvl == 0.5 ? '0.5' : lvl.toInt()}x',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF291800) : Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // VIEWFINDER RETICLE WITH ANIMATED LASER
  Widget _buildViewfinderReticle() {
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corner 1: Top-Left
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFFDCC85), width: 4),
                  left: BorderSide(color: Color(0xFFFDCC85), width: 4),
                ),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
              ),
            ),
          ),

          // Corner 2: Top-Right
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFFDCC85), width: 4),
                  right: BorderSide(color: Color(0xFFFDCC85), width: 4),
                ),
                borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
              ),
            ),
          ),

          // Corner 3: Bottom-Left
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFDCC85), width: 4),
                  left: BorderSide(color: Color(0xFFFDCC85), width: 4),
                ),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(12)),
              ),
            ),
          ),

          // Corner 4: Bottom-Right
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFDCC85), width: 4),
                  right: BorderSide(color: Color(0xFFFDCC85), width: 4),
                ),
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(12)),
              ),
            ),
          ),

          // Captured Image Preview (if present) with Optical Zoom
          if (_capturedImageBytes != null)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Transform.scale(
                    scale: _zoomLevel,
                    child: Image.memory(
                      _capturedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

          // Wine Glass Silhouette Watermark (if no image) with Optical Zoom
          if (_capturedImageBytes == null)
            Center(
              child: Transform.scale(
                scale: _zoomLevel,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wine_bar,
                      size: 58,
                      color: Color(0x3DFDCC85),
                    ),
                  ),
                ),
              ),
            ),

          // Analyzing Loading Overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Color(0xFFFDCC85),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      appLang.value == 'it'
                          ? 'Analisi Sommelier AI...'
                          : 'AI Sommelier Analyzing...',
                      style: const TextStyle(
                        color: Color(0xFFFDCC85),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Animated Laser Scan Line
          AnimatedBuilder(
            animation: _laserController,
            builder: (context, child) {
              return Positioned(
                top: 10 + (_laserController.value * 220),
                left: 14,
                right: 14,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFFFDCC85),
                        Color(0xFFFFDF9E),
                        Color(0xFFFDCC85),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFDCC85).withValues(alpha: 0.8),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 3. RECOGNITION RESULT BOTTOM DRAWER CARD
  Widget _buildResultCard(
    BuildContext context,
    Map<String, dynamic> wine,
    String sommelierQuote,
  ) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C2224).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF2C2224).withValues(alpha: 0.06),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Handle Pill & Match Confirmation
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Match 99% Badge & Bookmark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFDCC85).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified,
                            size: 15, color: Color(0xFF7B581C)),
                        const SizedBox(width: 6),
                        Text(
                          t('scanner_match_confirmed'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: t('scanner_close_result'),
                        icon: const Icon(Icons.close_fullscreen_rounded,
                            size: 18, color: Colors.grey),
                        onPressed: () {
                          setState(() => _hasScannedResult = false);
                        },
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 22,
                          color: _isBookmarked
                              ? const Color(0xFF7B581C)
                              : Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() => _isBookmarked = !_isBookmarked);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isBookmarked
                                  ? t('result_saved')
                                  : t('result_removed')),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // AI Enological Precision Confidence Meter (99.4%)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF9F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFDCC85).withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 13, color: Color(0xFF7B581C)),
                            const SizedBox(width: 6),
                            Text(
                              t('scanner_precision_sub'),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7B581C),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '99.4%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.994,
                        minHeight: 4,
                        backgroundColor: Color(0xFFEDE8E3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7B581C)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Wine Title, Estate and Vintage Badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (wine['appellation'] as String).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B581C),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wine['title'] as String,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF3C0311),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wine['winery'] as String,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Sommelier Score Stamp
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDCC85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF7B581C).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          wine['points'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF291800),
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t('scanner_score_stamp').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF614004),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Snapshot Grid (3 columns)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Col 1: Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('scanner_rating_label').toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Color(0xFF785519)),
                              const SizedBox(width: 3),
                              Text(
                                wine['rating'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF291800),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${wine['reviews']} ${t('scanner_reviews_count')}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Col 2: Avg Value
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('scanner_avg_value').toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wine['avgPrice'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3C0311),
                            ),
                          ),
                          Text(
                            '${t('scanner_market_range')} ${wine['marketRange']}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    // Col 3: Maturation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('scanner_maturation_label').toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wine['maturation'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B581C),
                            ),
                          ),
                          Text(
                            '${t('scanner_maturation_until')} ${wine['maturationUntil']}',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Curated Sommelier Tasting Note Sensory Quote
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDEA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote,
                        size: 20, color: Color(0xFF581825)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sommelierQuote,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12.5,
                          height: 1.4,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WineDetailScreen(
                        customTitle: wine['title'] as String?,
                        customWinery: wine['winery'] as String?,
                        customPrice: wine['avgPrice'] as String?,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(
                  t('scanner_open_sheet'),
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF581825),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        setState(() => _isAddedToCellar = true);
                        final vintageYear = (wine['vintage'] as num?)?.toInt() ?? 2020;
                        final untilYear = int.tryParse(wine['maturationUntil']?.toString() ?? '2032') ?? 2032;

                        await CellarService.instance.addBottle(
                          CellarBottleItem(
                            id: 'scanned-${DateTime.now().millisecondsSinceEpoch}',
                            title: wine['title'] as String,
                            winery: wine['winery'] as String,
                            region: (wine['appellation'] as String?) ?? 'Italia',
                            vintage: vintageYear,
                            quantity: 1,
                            score: '${wine['points']} pt',
                            statusCategory: 'ready',
                            statusKey: 'cellar_status_ready',
                            statusColorValue: 0xFF059669,
                            windowRange: '$vintageYear-$untilYear',
                            startYear: vintageYear,
                            endYear: untilYear,
                            centerStatusKey: 'cellar_harmonious_ready',
                            progress: 0.8,
                            isFav: false,
                            priceEstimate: wine['avgPrice'] as String,
                            emoji: (wine['catId'] == 2) ? '🍾' : ((wine['catId'] == 4) ? '🥂' : '🍷'),
                          ),
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${wine['title']}: ${t('scanner_added_cellar')}'),
                              backgroundColor: const Color(0xFF581825),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        _isAddedToCellar
                            ? Icons.check_circle
                            : Icons.shelves,
                        size: 18,
                        color: _isAddedToCellar
                            ? const Color(0xFF7B581C)
                            : const Color(0xFF581825),
                      ),
                      label: Text(
                        _isAddedToCellar
                            ? t('scanner_added_cellar')
                            : t('scanner_add_cellar'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _isAddedToCellar
                              ? const Color(0xFF7B581C)
                              : const Color(0xFF581825),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD9C1C2)),
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareWineDetails,
                      icon: const Icon(Icons.share,
                          size: 18, color: Color(0xFF581825)),
                      label: Text(
                        t('scanner_share_btn'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF581825),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD9C1C2)),
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
    );
  }

  // 4. INTERACTIVE VIEW FINDER LAUNCHER CARD
  Widget _buildCameraLauncherCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C2224).withValues(alpha: 0.12),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF2C2224).withValues(alpha: 0.06),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF581825).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.document_scanner,
                        color: Color(0xFF581825), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t('scanner_scan_ready_title'),
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF3C0311),
                          ),
                        ),
                        Text(
                          t('scanner_scan_ready_sub'),
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickAndAnalyzeImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera, size: 18),
                      label: Text(t('scanner_take_photo')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF581825),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickAndAnalyzeImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: Text(t('scanner_upload_photo')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3C0311),
                        side: const BorderSide(color: Color(0xFF7B581C)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('scanner_sample_labels'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B581C),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showManualWineSelector,
                    icon: const Icon(Icons.tune,
                        size: 14, color: Color(0xFF7B581C)),
                    label: Text(
                      t('all'),
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF7B581C)),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _winesDatabase.keys.map((key) {
                  final item = _winesDatabase[key]!;
                  return ActionChip(
                    avatar: Text(item['catId'] == 2
                        ? '🍾'
                        : (item['catId'] == 4 ? '🥂' : '🍷')),
                    label: Text(item['title'] as String),
                    labelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    onPressed: () {
                      setState(() {
                        _selectedWineKey = key;
                        _hasScannedResult = true;
                        _isAddedToCellar = false;
                        _isBookmarked = false;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
