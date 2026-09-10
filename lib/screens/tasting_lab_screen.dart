import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../main.dart';
import '../widgets/language_pill.dart';

class TastingLabScreen extends StatefulWidget {
  const TastingLabScreen({super.key});

  @override
  State<TastingLabScreen> createState() => _TastingLabScreenState();
}

class _TastingLabScreenState extends State<TastingLabScreen> {
  int _currentStep = 0; // 0: Visual, 1: Olfactory, 2: Taste, 3: Result

  // Visual
  String _selectedColor = 'straw_green';
  String _selectedTears = 'light';

  // Olfactory (up to 5)
  final Set<String> _selectedAromas = {};

  // Taste
  String _selectedBody = 'med';
  String _selectedAcidity = 'fresh';
  String _selectedTannins = 'silky';

  final List<Map<String, dynamic>> _colorOptions = [
    {
      'id': 'straw_green',
      'labelKey': 'lab_color_straw_green',
      'color': Color(0xFFE2E088),
      'isWhite': true,
    },
    {
      'id': 'straw_gold',
      'labelKey': 'lab_color_straw_gold',
      'color': Color(0xFFEDB836),
      'isWhite': true,
    },
    {
      'id': 'rose',
      'labelKey': 'lab_color_rose',
      'color': Color(0xFFE88A96),
      'isWhite': false,
    },
    {
      'id': 'ruby',
      'labelKey': 'lab_color_ruby',
      'color': Color(0xFF9E1B32),
      'isWhite': false,
    },
    {
      'id': 'garnet',
      'labelKey': 'lab_color_garnet',
      'color': Color(0xFF6B1A24),
      'isWhite': false,
    },
  ];

  final Map<String, List<String>> _aromaCategories = {
    'lab_aroma_cat_fruity': [
      'aroma_berries',
      'aroma_cherry',
      'aroma_apple',
      'aroma_peach',
      'aroma_citrus',
    ],
    'lab_aroma_cat_floral': [
      'aroma_violet',
      'aroma_white_flowers',
      'aroma_rose',
    ],
    'lab_aroma_cat_herbal': [
      'aroma_tomato_leaf',
      'aroma_cut_grass',
      'aroma_sage',
    ],
    'lab_aroma_cat_spicy': [
      'aroma_black_pepper',
      'aroma_vanilla',
      'aroma_cinnamon',
      'aroma_tobacco',
    ],
    'lab_aroma_cat_mineral': [
      'aroma_flint',
      'aroma_chalk',
    ],
  };

  void _toggleAroma(String key) {
    setState(() {
      if (_selectedAromas.contains(key)) {
        _selectedAromas.remove(key);
      } else {
        if (_selectedAromas.length < 5) {
          _selectedAromas.add(key);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Massimo 5 aromi selezionabili / Max 5 aromas'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  Map<String, dynamic> _computeMatch() {
    // Determine profile
    int scoreSauvignon = 0;
    int scoreChardonnay = 0;
    int scoreRose = 0;
    int scoreChianti = 0;
    int scoreBarolo = 0;
    int scorePinotNoir = 0;

    // Visual weights
    if (_selectedColor == 'straw_green') scoreSauvignon += 40;
    if (_selectedColor == 'straw_gold') scoreChardonnay += 40;
    if (_selectedColor == 'rose') scoreRose += 50;
    if (_selectedColor == 'ruby') {
      scoreChianti += 30;
      scorePinotNoir += 30;
    }
    if (_selectedColor == 'garnet') scoreBarolo += 45;

    // Tears
    if (_selectedTears == 'dense') {
      scoreBarolo += 10;
      scoreChardonnay += 10;
    } else {
      scoreSauvignon += 10;
      scorePinotNoir += 10;
      scoreRose += 10;
    }

    // Aromas
    for (final aroma in _selectedAromas) {
      if (aroma == 'aroma_apple' ||
          aroma == 'aroma_cut_grass' ||
          aroma == 'aroma_tomato_leaf' ||
          aroma == 'aroma_citrus' ||
          aroma == 'aroma_sage' ||
          aroma == 'aroma_flint') {
        scoreSauvignon += 15;
      }
      if (aroma == 'aroma_peach' ||
          aroma == 'aroma_vanilla' ||
          aroma == 'aroma_chalk' ||
          aroma == 'aroma_white_flowers') {
        scoreChardonnay += 15;
      }
      if (aroma == 'aroma_cherry' ||
          aroma == 'aroma_violet' ||
          aroma == 'aroma_black_pepper') {
        scoreChianti += 15;
      }
      if (aroma == 'aroma_berries' ||
          aroma == 'aroma_tobacco' ||
          aroma == 'aroma_cinnamon') {
        scoreBarolo += 15;
      }
      if (aroma == 'aroma_rose' ||
          aroma == 'aroma_berries' ||
          aroma == 'aroma_cinnamon') {
        scorePinotNoir += 15;
      }
      if (aroma == 'aroma_white_flowers' ||
          aroma == 'aroma_berries' ||
          aroma == 'aroma_peach') {
        scoreRose += 15;
      }
    }

    // Palate
    if (_selectedBody == 'light') {
      scoreSauvignon += 10;
      scoreRose += 10;
    } else if (_selectedBody == 'full') {
      scoreBarolo += 15;
      scoreChardonnay += 10;
    } else {
      scoreChianti += 10;
      scorePinotNoir += 10;
    }

    if (_selectedAcidity == 'vibrant') {
      scoreSauvignon += 15;
      scoreChianti += 10;
    }

    if (_selectedTannins == 'bold') {
      scoreBarolo += 15;
      scoreChianti += 10;
    } else if (_selectedTannins == 'none') {
      scoreSauvignon += 15;
      scoreChardonnay += 15;
      scoreRose += 15;
    }

    final candidates = [
      {
        'id': 'sauvignon',
        'title': 'Bianco Aromatico & Fresco (Sauvignon / Verdicchio)',
        'title_en': 'Crisp & Aromatic White (Sauvignon Blanc / Verdicchio)',
        'score': scoreSauvignon,
        'why':
            'La tonalità paglierino brillante, i profumi vegetali di erba/pomodoro e l\'acidità tagliente sono il timbro inconfondibile di grandi bianchi minerali e fruttati.',
        'why_en':
            'Bright straw-green hue, herbal aromas of cut grass, and crisp acidity are hallmarks of vibrant mineral whites.',
        'examples': 'Sauvignon Blanc Alto Adige, Verdicchio dei Castelli di Jesi, Sancerre',
        'temp': '8° - 10°C',
        'glass': 'Tulipano slanciato',
      },
      {
        'id': 'chardonnay',
        'title': 'Bianco Strutturato & Morbido (Chardonnay / Friulano)',
        'title_en': 'Full-bodied & Rich White (Oaked Chardonnay / Friulano)',
        'score': scoreChardonnay,
        'why':
            'Il riflesso dorato, i profumi di vaniglia, pesca matura e burro, uniti al corpo pieno e morbido, descrivono un grande bianco affinato in botte.',
        'why_en':
            'Golden reflection, aromas of vanilla, ripe stone fruit and butter, combined with a plush body, characterize fine oaked whites.',
        'examples': 'Chardonnay barricato, Friulano riserva, Meursault',
        'temp': '10° - 12°C',
        'glass': 'Renano a grande luce',
      },
      {
        'id': 'rose',
        'title': 'Rosato Vivace & Sapido (Cerasuolo / Chiaretto)',
        'title_en': 'Crisp & Savory Rosé (Cerasuolo d\'Abruzzo / Provence)',
        'score': scoreRose,
        'why':
            'Il colore cerasuolo brillante, le note di fragolina e fiori bianchi e la sapidità fresca lo rendono fresco come un bianco ma con la materia di un rosso.',
        'why_en':
            'Bright cherry-pink color, wild berry notes, and fresh salinity offer white-wine freshness with red-wine substance.',
        'examples': 'Cerasuolo d\'Abruzzo, Bardolino Chiaretto, Bandol Rosé',
        'temp': '9° - 11°C',
        'glass': 'Tulipano medio',
      },
      {
        'id': 'chianti',
        'title': 'Rosso Rubino & Speziato (Chianti Classico / Barbera)',
        'title_en': 'Vibrant & Spicy Red (Chianti Classico / Barbera)',
        'score': scoreChianti,
        'why':
            'Rosso rubino vivo, ciliegia matura, violetta e tannino vivace ed elegante: l\'archetipo dei grandi vini toscani e piemontesi a base Sangiovese o Barbera.',
        'why_en':
            'Vibrant ruby red, ripe cherry, violet, and lively savory tannins represent the archetype of Italian Sangiovese and Barbera.',
        'examples': 'Chianti Classico Riserva, Barbera d\'Alba Superiore, Vino Nobile',
        'temp': '16° - 18°C',
        'glass': 'Ballon Bordolese',
      },
      {
        'id': 'barolo',
        'title': 'Rosso Strutturato da Invecchiamento (Barolo / Brunello)',
        'title_en': 'Full-bodied Age-Worthy Red (Barolo / Brunello / Amarone)',
        'score': scoreBarolo,
        'why':
            'Tonalità granata profonda, bouquet terziario di tabacco, spezie scure e sottobosco con tannino potente: il profilo inconfondibile delle grandi riserve.',
        'why_en':
            'Deep garnet hue, tertiary bouquet of tobacco, dark spices, and powerful tannins: the quintessential aged reserve profile.',
        'examples': 'Barolo DOCG, Brunello di Montalcino, Amarone della Valpolicella',
        'temp': '18°C',
        'glass': 'Borgogna pancia larga o Ballon',
      },
      {
        'id': 'pinot_noir',
        'title': 'Rosso Elegante & Sottile (Pinot Nero / Etna Rosso)',
        'title_en': 'Delicate & Elegant Red (Pinot Noir / Etna Rosso)',
        'score': scorePinotNoir,
        'why':
            'Colore trasparente e luminoso, profumi di frutti rossi ed erbe balsamiche, tannini setosi e acidità minerale di straordinaria finezza.',
        'why_en':
            'Luminous translucent color, wild berry and floral perfumes, silky tannins, and mineral acidity of extraordinary finesse.',
        'examples': 'Pinot Nero Alto Adige, Etna Rosso DOC, Borgogna Village',
        'temp': '15° - 17°C',
        'glass': 'Calice Borgogna a pancia larga',
      },
    ];

    candidates.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    return candidates.first;
  }

  Future<void> _shareTastingSheet(Map<String, dynamic> match) async {
    final buffer = StringBuffer();
    final isIt = appLang.value == 'it';

    buffer.write('🍷 *Wine Advisor — ${t('lab_match_title')}*\n\n');
    buffer.write('🏆 *${isIt ? match['title'] : match['title_en']}*\n');
    buffer.write('✨ ${t('lab_affinity')} 96%\n\n');
    buffer.write('🔍 *${t('lab_why_match')}*\n${isIt ? match['why'] : match['why_en']}\n\n');
    buffer.write('🍾 *${t('lab_examples_title')}*\n${match['examples']}\n\n');
    buffer.write('🌡️ Temp: ${match['temp']} | 🍷 Calice: ${match['glass']}\n');
    buffer.write('\n💡 Analizzato con Wine Tasting Lab 🍇');

    final text = buffer.toString();
    try {
      final box = context.findRenderObject() as RenderBox?;
      final position =
          box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero;

      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: position),
      );
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t('lab_share_copied')),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, _) {
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t('lab_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: const [
              LanguagePill(),
              SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Stepper Progress Header
                  _buildProgressHeader(theme),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: _buildCurrentStep(context, theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressHeader(ThemeData theme) {
    final steps = [
      t('lab_step_visual'),
      t('lab_step_olfactory'),
      t('lab_step_taste'),
      t('lab_step_result'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isDone = _currentStep > index;
          final isCurrent = _currentStep == index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isCurrent || isDone
                              ? theme.colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildVisualStep(theme);
      case 1:
        return _buildOlfactoryStep(theme);
      case 2:
        return _buildTasteStep(theme);
      case 3:
      default:
        return _buildResultStep(theme);
    }
  }

  // STEP 1: VISUAL
  Widget _buildVisualStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('lab_visual_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t('lab_visual_sub'),
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 20),

        ..._colorOptions.map((opt) {
          final isSelected = _selectedColor == opt['id'];
          final color = opt['color'] as Color;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedColor = opt['id'] as String),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t(opt['labelKey'] as String),
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 20),
        Text(
          t('lab_tears_title'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(t('lab_tears_light')),
              selected: _selectedTears == 'light',
              onSelected: (_) => setState(() => _selectedTears = 'light'),
            ),
            ChoiceChip(
              label: Text(t('lab_tears_dense')),
              selected: _selectedTears == 'dense',
              onSelected: (_) => setState(() => _selectedTears = 'dense'),
            ),
          ],
        ),

        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => setState(() => _currentStep = 1),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            t('lab_btn_next'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }

  // STEP 2: OLFACTORY (AROMA WHEEL)
  Widget _buildOlfactoryStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('lab_aroma_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t('lab_aroma_sub'),
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Selezionati / Selected: ${_selectedAromas.length}/5',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),

        ..._aromaCategories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(entry.key),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((aromaKey) {
                  final isSelected = _selectedAromas.contains(aromaKey);
                  return FilterChip(
                    label: Text(t(aromaKey)),
                    selected: isSelected,
                    onSelected: (_) => _toggleAroma(aromaKey),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),

        const SizedBox(height: 24),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 0),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  t('lab_btn_to_taste'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: TASTE (PALATE)
  Widget _buildTasteStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t('lab_taste_title'),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t('lab_taste_sub'),
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
        const SizedBox(height: 24),

        // Body
        Text(
          t('lab_taste_body'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(t('lab_body_light')),
              selected: _selectedBody == 'light',
              onSelected: (_) => setState(() => _selectedBody = 'light'),
            ),
            ChoiceChip(
              label: Text(t('lab_body_med')),
              selected: _selectedBody == 'med',
              onSelected: (_) => setState(() => _selectedBody = 'med'),
            ),
            ChoiceChip(
              label: Text(t('lab_body_full')),
              selected: _selectedBody == 'full',
              onSelected: (_) => setState(() => _selectedBody = 'full'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Acidity
        Text(
          t('lab_taste_acidity'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(t('lab_acid_soft')),
              selected: _selectedAcidity == 'soft',
              onSelected: (_) => setState(() => _selectedAcidity = 'soft'),
            ),
            ChoiceChip(
              label: Text(t('lab_acid_fresh')),
              selected: _selectedAcidity == 'fresh',
              onSelected: (_) => setState(() => _selectedAcidity = 'fresh'),
            ),
            ChoiceChip(
              label: Text(t('lab_acid_vibrant')),
              selected: _selectedAcidity == 'vibrant',
              onSelected: (_) => setState(() => _selectedAcidity = 'vibrant'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Tannins
        Text(
          t('lab_taste_tannins'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text(t('lab_tan_none')),
              selected: _selectedTannins == 'none',
              onSelected: (_) => setState(() => _selectedTannins = 'none'),
            ),
            ChoiceChip(
              label: Text(t('lab_tan_silky')),
              selected: _selectedTannins == 'silky',
              onSelected: (_) => setState(() => _selectedTannins = 'silky'),
            ),
            ChoiceChip(
              label: Text(t('lab_tan_bold')),
              selected: _selectedTannins == 'bold',
              onSelected: (_) => setState(() => _selectedTannins = 'bold'),
            ),
          ],
        ),

        const SizedBox(height: 32),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 3),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  t('lab_btn_compute'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 4: RESULT IDENTIKIT
  Widget _buildResultStep(ThemeData theme) {
    final match = _computeMatch();
    final isIt = appLang.value == 'it';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  t('lab_match_title').toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isIt ? match['title'] as String : match['title_en'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5A93C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${t('lab_affinity')} 96%',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sensory Summary Card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_outlined,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('lab_why_match'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isIt ? match['why'] as String : match['why_en'] as String,
                  style: TextStyle(
                    color: Colors.grey[800],
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.wine_bar,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t('lab_examples_title'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  match['examples'] as String,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    Text('🌡️ ${match['temp']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('🍷 ${match['glass']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: () => _shareTastingSheet(match),
          icon: const Icon(Icons.share, size: 20),
          label: Text(
            t('lab_share_btn'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: () {
            setState(() {
              _currentStep = 0;
              _selectedAromas.clear();
            });
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: Text(t('lab_btn_restart')),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
