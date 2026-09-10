import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wine_recommendation.dart';
import '../widgets/language_pill.dart';
import '../main.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentStep = 0; // 0, 1, 2
  final List<int?> _selectedOptions = [null, null, null];
  bool _isAnalyzing = false;
  WineRecommendation? _resultWine;
  int _affinityPercent = 98;

  static const Map<int, Map<String, dynamic>> _fallbackCategories = {
    1: {
      'id': 1,
      'category_name': 'Bianco Fresco e Leggero',
      'example_wines': 'Pinot Grigio, Sauvignon Blanc, Vermentino',
      'explanation':
          'Mettiti comodo. Per rilassarti non serve un vino che impegni il palato. Vai su un bianco fresco, fruttato e super beverino.',
      'serving_temperature': '8-10°C',
    },
    2: {
      'id': 2,
      'category_name': 'Bollicina Strutturata',
      'example_wines': 'Franciacorta, Trento DOC, Champagne',
      'explanation':
          'Per fare colpo serve classe. Una bollicina Metodo Classico porta un\'atmosfera elegante, sta bene con tutto e il perlage crea subito festa.',
      'serving_temperature': '6-8°C',
    },
    3: {
      'id': 3,
      'category_name': 'Rosso Strutturato',
      'example_wines': 'Barolo, Brunello di Montalcino, Amarone',
      'explanation':
          'Per la carne e le cene importanti serve muscolo ed eleganza. I tannini decisi si legano alla perfezione con la ricchezza del piatto.',
      'serving_temperature': '16-18°C',
    },
    4: {
      'id': 4,
      'category_name': 'Bianco Strutturato o Bollicina',
      'example_wines': 'Chardonnay barricato, Verdicchio Riserva',
      'explanation':
          'Con piatti di pesce ricchi o cene raffinate serve un vino di spessore con ottima acidità e profumi complessi.',
      'serving_temperature': '10-12°C',
    },
    5: {
      'id': 5,
      'category_name': 'Rosso Leggero',
      'example_wines': 'Pinot Nero, Chianti giovane, Valpolicella',
      'explanation':
          'Serve un vino sbarazzino! L\'acidità di piatti come pizza o pasta chiama un rosso fresco, profumato e con pochi tannini.',
      'serving_temperature': '14-16°C',
    },
  };

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedOptions[_currentStep] = optionIndex;
    });

    if (_currentStep < 2) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            _currentStep++;
          });
        }
      });
    } else {
      // Fine del quiz: calcolo punteggio
      _calculateResult();
    }
  }

  Future<void> _calculateResult() async {
    setState(() {
      _isAnalyzing = true;
    });

    final scores = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    // Step 1 scoring
    final q1 = _selectedOptions[0] ?? 0;
    if (q1 == 0) {
      scores[1] = scores[1]! + 4;
      scores[2] = scores[2]! + 2;
    } else if (q1 == 1) {
      scores[2] = scores[2]! + 4;
      scores[4] = scores[4]! + 3;
    } else if (q1 == 2) {
      scores[3] = scores[3]! + 5;
    } else if (q1 == 3) {
      scores[5] = scores[5]! + 4;
      scores[1] = scores[1]! + 1;
    }

    // Step 2 scoring
    final q2 = _selectedOptions[1] ?? 0;
    if (q2 == 0) {
      scores[1] = scores[1]! + 4;
      scores[4] = scores[4]! + 1;
    } else if (q2 == 1) {
      scores[2] = scores[2]! + 5;
      scores[4] = scores[4]! + 2;
    } else if (q2 == 2) {
      scores[3] = scores[3]! + 5;
    } else if (q2 == 3) {
      scores[5] = scores[5]! + 4;
      scores[1] = scores[1]! + 2;
    }

    // Step 3 scoring
    final q3 = _selectedOptions[2] ?? 0;
    if (q3 == 0) {
      scores[2] = scores[2]! + 3;
      scores[4] = scores[4]! + 2;
      scores[3] = scores[3]! + 1;
    } else if (q3 == 1) {
      scores[5] = scores[5]! + 3;
      scores[3] = scores[3]! + 2;
      scores[2] = scores[2]! + 1;
    } else if (q3 == 2) {
      scores[3] = scores[3]! + 3;
      scores[4] = scores[4]! + 2;
      scores[1] = scores[1]! + 1;
    } else if (q3 == 3) {
      scores[1] = scores[1]! + 4;
      scores[5] = scores[5]! + 2;
    }

    // Categoria vincente
    int bestCategory = 1;
    int maxScore = -1;
    scores.forEach((catId, score) {
      if (score > maxScore) {
        maxScore = score;
        bestCategory = catId;
      }
    });

    final affinity = (93 + (maxScore % 6)).clamp(94, 99);

    WineRecommendation wine;
    try {
      final response = await Supabase.instance.client
          .from('wine_categories')
          .select()
          .eq('id', bestCategory)
          .maybeSingle();

      if (response != null) {
        wine = WineRecommendation.fromJson(response);
      } else {
        wine = WineRecommendation.fromJson(_fallbackCategories[bestCategory]!);
      }
    } catch (_) {
      wine = WineRecommendation.fromJson(_fallbackCategories[bestCategory]!);
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _resultWine = wine;
        _affinityPercent = affinity;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentStep = 0;
      _selectedOptions[0] = null;
      _selectedOptions[1] = null;
      _selectedOptions[2] = null;
      _resultWine = null;
      _isAnalyzing = false;
    });
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
              t('quiz_card_title'),
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: const [
              LanguagePill(),
              SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: _isAnalyzing
                      ? _buildAnalyzingView()
                      : _resultWine != null
                          ? _buildResultView()
                          : _buildQuizQuestionsView(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyzingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFD6C5B3).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            strokeWidth: 3,
            color: Color(0xFF6D213C),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          t('quiz_analyzing'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
                height: 1.4,
              ),
        ),
      ],
    );
  }

  Widget _buildQuizQuestionsView() {
    final stepTitles = [
      t('quiz_step_1_title'),
      t('quiz_step_2_title'),
      t('quiz_step_3_title'),
    ];

    final stepSubs = [
      t('quiz_step_1_sub'),
      t('quiz_step_2_sub'),
      t('quiz_step_3_sub'),
    ];

    final optionsByStep = [
      [
        {'icon': '🥂', 'text': t('quiz_q1_opt1')},
        {'icon': '🕯️', 'text': t('quiz_q1_opt2')},
        {'icon': '🥩', 'text': t('quiz_q1_opt3')},
        {'icon': '🍕', 'text': t('quiz_q1_opt4')},
      ],
      [
        {'icon': '🍋', 'text': t('quiz_q2_opt1')},
        {'icon': '✨', 'text': t('quiz_q2_opt2')},
        {'icon': '🍇', 'text': t('quiz_q2_opt3')},
        {'icon': '🍒', 'text': t('quiz_q2_opt4')},
      ],
      [
        {'icon': '💑', 'text': t('quiz_q3_opt1')},
        {'icon': '🎉', 'text': t('quiz_q3_opt2')},
        {'icon': '🍽️', 'text': t('quiz_q3_opt3')},
        {'icon': '🧘', 'text': t('quiz_q3_opt4')},
      ],
    ];

    final currentOptions = optionsByStep[_currentStep];
    final selectedIdx = _selectedOptions[_currentStep];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stepper indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t('quiz_step_of')
                  .replaceAll('{current}', '${_currentStep + 1}')
                  .replaceAll('{total}', '3'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (_currentStep > 0)
              TextButton.icon(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(
                  appLang.value == 'it' ? 'Indietro' : 'Back',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            minHeight: 8,
            backgroundColor: const Color(0xFFD6C5B3).withValues(alpha: 0.35),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Question Title & Subtitle
        Text(
          stepTitles[_currentStep],
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          stepSubs[_currentStep],
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),

        const SizedBox(height: 24),

        // Options List
        Expanded(
          child: ListView.separated(
            itemCount: currentOptions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final opt = currentOptions[index];
              final isSelected = selectedIdx == index;

              return Card(
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : const Color(0xFFD6C5B3).withValues(alpha: 0.4),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                color: isSelected
                    ? const Color(0xFFFAF2F5)
                    : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _selectOption(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          opt['icon'] ?? '',
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            opt['text'] ?? '',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400],
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final wine = _resultWine!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header celebratory icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFD6C5B3).withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 52,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            t('quiz_match_title'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),

          const SizedBox(height: 14),

          // Affinity Pill Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6D213C),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6D213C).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFE5A93C), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '$_affinityPercent% ${t('quiz_affinity')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Recommended Wine Card
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wine.localizedCategoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${t('result_examples')} ${wine.exampleWines}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 0.7),
                  const SizedBox(height: 14),
                  Text(
                    t('quiz_why_match'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wine.localizedExplanation,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Actions
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(recommendation: wine),
                ),
              );
            },
            icon: const Icon(Icons.wine_bar),
            label: Text(t('quiz_see_details')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _resetQuiz,
            icon: const Icon(Icons.refresh),
            label: Text(t('quiz_retake')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
