import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wine_recommendation.dart';
import '../widgets/language_pill.dart';
import '../main.dart';
import 'result_screen.dart';

class ReversePairingScreen extends StatefulWidget {
  final int? initialCategoryId;

  const ReversePairingScreen({super.key, this.initialCategoryId});

  @override
  State<ReversePairingScreen> createState() => _ReversePairingScreenState();
}

class _ReversePairingScreenState extends State<ReversePairingScreen> {
  late int _selectedCategoryId;
  String _selectedFilter = 'all'; // 'all', 'primi', 'meat', 'fish', 'pizza', 'cheese'
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 3,
      'name_it': 'Rosso Strutturato',
      'name_en': 'Full-bodied Red',
      'examples': 'Barolo, Brunello, Amarone, Nebbiolo',
      'icon': Icons.wine_bar,
      'color': Color(0xFF6D213C),
      'keywords': ['barolo', 'brunello', 'amarone', 'nebbiolo', 'aglianico', 'taurasi', 'rosso strutturato', 'cabernet', 'syrah'],
      'explanation': 'Per la carne e le cene importanti serve muscolo ed eleganza. I tannini decisi si legano alla perfezione con la ricchezza del piatto.',
      'serving_temperature': '16-18°C',
    },
    {
      'id': 1,
      'name_it': 'Bianco Fresco e Leggero',
      'name_en': 'Crisp & Light White',
      'examples': 'Pinot Grigio, Sauvignon, Vermentino',
      'icon': Icons.local_bar,
      'color': Color(0xFF8A9A5B),
      'keywords': ['pinot grigio', 'sauvignon', 'vermentino', 'soave', 'gavi', 'bianco fresco', 'chardonnay'],
      'explanation': 'Mettiti comodo. Per rilassarti non serve un vino che impegni il palato. Vai su un bianco fresco, fruttato e super beverino.',
      'serving_temperature': '8-10°C',
    },
    {
      'id': 2,
      'name_it': 'Bollicina Strutturata',
      'name_en': 'Structured Sparkling',
      'examples': 'Franciacorta, Trento DOC, Champagne',
      'icon': Icons.celebration,
      'color': Color(0xFFC5A059),
      'keywords': ['franciacorta', 'champagne', 'trento doc', 'prosecco', 'spumante', 'metodo classico', 'bollicine'],
      'explanation': 'Per fare colpo serve classe. Una bollicina Metodo Classico porta un\'atmosfera elegante, sta bene con tutto e il perlage crea subito festa.',
      'serving_temperature': '6-8°C',
    },
    {
      'id': 5,
      'name_it': 'Rosso Leggero',
      'name_en': 'Light Red',
      'examples': 'Chianti giovane, Pinot Nero, Valpolicella',
      'icon': Icons.wine_bar_outlined,
      'color': Color(0xFF9E4770),
      'keywords': ['chianti', 'pinot nero', 'valpolicella', 'barbera', 'frappato', 'bardolino', 'rosso leggero'],
      'explanation': 'Serve un vino sbarazzino! L\'acidità di piatti come pizza o pasta chiama un rosso fresco, profumato e con pochi tannini.',
      'serving_temperature': '14-16°C',
    },
    {
      'id': 4,
      'name_it': 'Bianco Strutturato',
      'name_en': 'Full-bodied White',
      'examples': 'Chardonnay barricato, Verdicchio Riserva',
      'icon': Icons.liquor,
      'color': Color(0xFFD4AF37),
      'keywords': ['verdicchio', 'fiano', 'greco di tufo', 'lugana', 'bianco strutturato'],
      'explanation': 'Con piatti di pesce ricchi o cene raffinate serve un vino di spessore con ottima acidità e profumi complessi.',
      'serving_temperature': '10-12°C',
    },
  ];

  static const Map<int, List<Map<String, dynamic>>> _dishesByCategory = {
    // Rosso Strutturato
    3: [
      {
        'title_it': 'Bistecca alla Fiorentina o Tagliata',
        'title_en': 'Florentine T-Bone Steak or Sliced Beef',
        'type': 'meat',
        'icon': '🥩',
        'prep_time': '20 min',
        'why_it': 'I tannini decisi e la struttura avvolgente del vino asciugano la succulenza della carne rossa, rinfrescando il palato a ogni boccone.',
        'why_en': 'Bold tannins and enveloping body cut through the rich succulence of red meat, cleansing your palate with every single bite.',
        'tip_it': 'Cottura al sangue su brace rovente con una generosa manciata di sale grosso e rosmarino.',
        'tip_en': 'Cook rare over very hot embers with coarse sea salt and freshly cracked rosemary.',
      },
      {
        'title_it': 'Pappardelle al Ragù di Cinghiale',
        'title_en': 'Pappardelle with Wild Boar Ragù',
        'type': 'primi',
        'icon': '🍝',
        'prep_time': '3h',
        'why_it': 'Il corpo caldo e speziato del grande rosso bilancia i profumi selvatici e la lunga cottura della selvaggina.',
        'why_en': 'The warm, spiced structure balances the robust wild game flavors and deep slow-cooked savory notes.',
        'tip_it': 'Lascia cuocere a fuoco dolcissimo aggiungendo alloro, bacche di ginepro e un goccio dello stesso vino.',
        'tip_en': 'Simmer slowly with bay leaves, juniper berries, and a splash of the same red wine.',
      },
      {
        'title_it': 'Brasato al Vino Rosso con Polenta',
        'title_en': 'Slow-Braised Beef in Red Wine with Polenta',
        'type': 'meat',
        'icon': '🍲',
        'prep_time': '2h 30m',
        'why_it': 'Matrimonio d\'amore: il vino si fonde nel fondo di cottura creando un\'armonia gustativa insuperabile.',
        'why_en': 'A match made in heaven: the wine melds into the reduction, creating flawless flavor harmony.',
        'tip_it': 'Marina la carne la sera prima con verdure a cubetti e aromi di bosco.',
        'tip_en': 'Marinate the beef overnight with chopped root vegetables and forest aromatics.',
      },
      {
        'title_it': 'Pecorino Stagionato o Formaggi di Fossa',
        'title_en': 'Aged Pecorino or Cave-aged Cheeses',
        'type': 'cheese',
        'icon': '🧀',
        'prep_time': '5 min',
        'why_it': 'L\'alcolicità e la morbidezza del vino smussano la sapidità pungente e la piccantezza della stagionatura.',
        'why_en': 'Warm alcohol and depth soften the sharp pungency and savory saltiness of long-aged cheese.',
        'tip_it': 'Servi a temperatura ambiente accompagnato con gocce di miele di castagno.',
        'tip_en': 'Serve at room temperature drizzled with a touch of dark chestnut honey.',
      },
    ],

    // Bianco Fresco e Leggero
    1: [
      {
        'title_it': 'Spaghetti alle Vongole Veraci',
        'title_en': 'Spaghetti with Fresh Clams',
        'type': 'primi',
        'icon': '🍝',
        'prep_time': '25 min',
        'why_it': 'L\'acidità vivace e le note agrumate del vino esaltano la sapidità marina senza mai coprirne la delicatezza.',
        'why_en': 'Crisp acidity and citrus notes elevate the marine savoriness without overpowering its delicate sweetness.',
        'tip_it': 'Risotta la pasta negli ultimi 2 minuti direttamente nella padella delle vongole con la loro acqua.',
        'tip_en': 'Finish cooking the pasta in the skillet with the clam liquor for maximum emulsified creaminess.',
      },
      {
        'title_it': 'Sushi, Sashimi & Crudi di Mare',
        'title_en': 'Sushi, Sashimi & Fresh Raw Seafood',
        'type': 'fish',
        'icon': '🍣',
        'prep_time': '15 min',
        'why_it': 'Pulisce il palato dalla naturale untuosità del salmone ed esalta le note iodate del pesce fresco.',
        'why_en': 'Cleanses the palate from the natural richness of salmon while highlighting the fresh ocean brine.',
        'tip_it': 'Usa moderazione con salsa di soia e wasabi per preservare le sfumature floreali del vino.',
        'tip_en': 'Go easy on soy sauce and wasabi to let the wine\'s delicate floral nuances shine.',
      },
      {
        'title_it': 'Fritto Misto di Calamari e Gamberi',
        'title_en': 'Crispy Fried Calamari & Shrimp',
        'type': 'fish',
        'icon': '🍤',
        'prep_time': '30 min',
        'why_it': 'La freschezza citrina ripulisce all\'istante il palato dall\'olio della frittura lasciandolo asciutto.',
        'why_en': 'Citrus crispness cuts straight through the fried coating, leaving the palate clean and refreshed.',
        'tip_it': 'Servi bollente con una grattugiata di scorza di limone bio invece del succo per non rammollire la crosta.',
        'tip_en': 'Serve piping hot with grated fresh lemon zest rather than juice to keep the batter super crunchy.',
      },
      {
        'title_it': 'Caprese con Mozzarella di Bufala DOP',
        'title_en': 'Caprese with Buffalo Mozzarella DOP',
        'type': 'cheese',
        'icon': '🧀',
        'prep_time': '10 min',
        'why_it': 'I profumi fruttati e l\'acidità sostengono la ricchezza del latte fresco di bufala e il pomodoro maturo.',
        'why_en': 'Fruity lightness and lively acidity match the rich buffalo milk creaminess and ripe tomatoes.',
        'tip_it': 'Usa pomodori a temperatura ambiente e foglie di basilico spezzate a mano.',
        'tip_en': 'Keep tomatoes at room temperature and tear fresh basil leaves by hand to release essential oils.',
      },
    ],

    // Bollicina Strutturata
    2: [
      {
        'title_it': 'Risotto allo Zafferano e Gamberi Rossi',
        'title_en': 'Saffron Risotto with Red Prawns',
        'type': 'primi',
        'icon': '🍚',
        'prep_time': '35 min',
        'why_it': 'Il perlage fine e persistente ripulisce la mantecatura al burro esaltando la speziatura dello zafferano.',
        'why_en': 'Fine bubbles rinse away the buttery risotto richness, framing the saffron and sweet prawns perfectly.',
        'tip_it': 'Manteca a fuoco spento con burro ghiacciato per ottenere un\'onda lucidissima.',
        'tip_en': 'Beat in ice-cold butter off the heat for a velvety, glossy restaurant finish.',
      },
      {
        'title_it': 'Tagliere di Culatello e Salumi Pregiati',
        'title_en': 'Culatello & Artisanal Charcuterie Board',
        'type': 'meat',
        'icon': '🥓',
        'prep_time': '10 min',
        'why_it': 'L\'anidride carbonica e l\'acidità sciolgono il grasso nobile del salume sprigionando una dolcezza sublime.',
        'why_en': 'Effervescence and acidity melt the noble cured fat, unleashing sweet, delicate complexities.',
        'tip_it': 'Affetta sottilissimo poco prima di servire e accompagna con pane caldo o focaccia.',
        'tip_en': 'Slice paper-thin right before serving alongside warm crusty sourdough.',
      },
      {
        'title_it': 'Tartare di Salmone con Avocado e Lime',
        'title_en': 'Salmon Tartare with Avocado and Lime',
        'type': 'fish',
        'icon': '🐟',
        'prep_time': '15 min',
        'why_it': 'L\'eleganza del metodo classico contrasta la grassezza dell\'avocado e del salmone nobile.',
        'why_en': 'Traditional method elegance cuts through creamy avocado and rich salmon with finesse.',
        'tip_it': 'Condisci con sale Maldon e olio delicato solo un istante prima di portare in tavola.',
        'tip_en': 'Season with flake sea salt and delicate extra virgin olive oil just before serving.',
      },
      {
        'title_it': 'Parmigiano Reggiano 24/36 Mesi a Scaglie',
        'title_en': 'Aged Parmigiano Reggiano 24/36 Months',
        'type': 'cheese',
        'icon': '🧀',
        'prep_time': '5 min',
        'why_it': 'Il perlage doma i cristalli di tirosina e la potenza umami del formaggio reggiano.',
        'why_en': 'Lively fizz harmonizes with tyrosine crystals and rich umami depth.',
        'tip_it': 'Servi a temperatura ambiente con gocce di aceto balsamico tradizionale di Modena.',
        'tip_en': 'Pair at room temperature with a few drops of aged traditional balsamic vinegar.',
      },
    ],

    // Rosso Leggero
    5: [
      {
        'title_it': 'Pizza Margherita o con Funghi e Prosciutto',
        'title_en': 'Margherita Pizza or Mushroom & Ham',
        'type': 'pizza',
        'icon': '🍕',
        'prep_time': '20 min',
        'why_it': 'La spiccata acidità del rosso leggero accompagna l\'acidità del pomodoro e sgrassa la mozzarella fusa.',
        'why_en': 'The bright acidity of light red matches tomato acidity and cleanses melted mozzarella.',
        'tip_it': 'Inforna alla massima temperatura su pietra refrattaria per un bordo gonfio e fragrante.',
        'tip_en': 'Bake at the highest oven temperature on a pizza stone for a crispy, puffed crust.',
      },
      {
        'title_it': 'Pasta al Pomodoro e Basilico Fresco',
        'title_en': 'Classic Tomato & Fresh Basil Pasta',
        'type': 'primi',
        'icon': '🍝',
        'prep_time': '20 min',
        'why_it': 'Tannini morbidi e sentori di ciliegia che danzano in armonia con la dolcezza del pomodoro.',
        'why_en': 'Gentle tannins and cherry aromas dance harmoniously with sweet Italian tomato sauce.',
        'tip_it': 'Usa pomodori datterini dolci e una generosa spolverata di Parmigiano fresco.',
        'tip_en': 'Use sweet baby plum tomatoes and finish with fresh grated Parmigiano.',
      },
      {
        'title_it': 'Hamburger Gourmet con Cheddar e Bacon',
        'title_en': 'Gourmet Cheeseburger with Bacon',
        'type': 'pizza',
        'icon': '🍔',
        'prep_time': '25 min',
        'why_it': 'Fresco, beverino e fruttato: rinfresca la bocca tra un morso succulento e l\'altro senza appesantire.',
        'why_en': 'Fruity, fresh and quaffable: revitalizes the palate between juicy, savory bites.',
        'tip_it': 'Tosta il bun con una noce di burro per creare una barriera impermeabile ai succhi della carne.',
        'tip_en': 'Toast the brioche bun with a hint of butter to keep it pillowy and juices sealed.',
      },
      {
        'title_it': 'Tagliere di Mortadella Bologna IGP e Focaccia',
        'title_en': 'Mortadella Bologna IGP & Warm Focaccia',
        'type': 'meat',
        'icon': '🥪',
        'prep_time': '5 min',
        'why_it': 'I sentori floreali e di frutti rossi alleggeriscono la speziatura e la grassezza della mortadella.',
        'why_en': 'Floral and red berry aromas balance the aromatic spices and richness of mortadella.',
        'tip_it': 'Servi la mortadella affettata a velo insieme a pistacchi tostati e focaccia fragrante.',
        'tip_en': 'Have it shaved razor-thin alongside toasted pistachios and fresh focaccia.',
      },
    ],

    // Bianco Strutturato
    4: [
      {
        'title_it': 'Trancio di Salmone al Forno con Erbe',
        'title_en': 'Herb-Crusted Baked Salmon Fillet',
        'type': 'fish',
        'icon': '🐟',
        'prep_time': '25 min',
        'why_it': 'La ricchezza e la morbidezza del vino sostengono la struttura corposa e nobile del salmone cotto.',
        'why_en': 'The body and mineral richness stand up gracefully to the meaty, flavorful cooked salmon.',
        'tip_it': 'Cuoci a 170°C per mantenere il cuore rosa e succoso, guarnito con aneto e scorza di limone.',
        'tip_en': 'Bake at 170°C to keep the center moist and pink, garnished with dill and lemon zest.',
      },
      {
        'title_it': 'Ravioli di Ricotta e Spinaci con Burro e Salvia',
        'title_en': 'Ricotta & Spinach Ravioli in Sage Butter',
        'type': 'primi',
        'icon': '🥟',
        'prep_time': '25 min',
        'why_it': 'Note burrose e di frutta matura del vino che accarezzano la delicatezza della pasta fresca.',
        'why_en': 'Subtle oak, buttery notes, and ripe orchard fruits cradle the delicate pasta filling.',
        'tip_it': 'Rosola il burro finché diventa nocciola e le foglie di salvia diventano croccanti.',
        'tip_en': 'Brown the butter until nutty and let the sage leaves turn crisp and fragrant.',
      },
      {
        'title_it': 'Pollo Arrosto della Domenica con Porcini',
        'title_en': 'Sunday Roast Chicken with Porcini Mushrooms',
        'type': 'meat',
        'icon': '🍗',
        'prep_time': '1h 15m',
        'why_it': 'L\'intensità aromatica del vino regge splendidamente il profumo terroso dei funghi porcini.',
        'why_en': 'Aromatic intensity embraces the earthy woodland aroma of sautéed porcini mushrooms.',
        'tip_it': 'Bagna la carne a metà cottura con un bicchiere di vino bianco per renderla morbidissima.',
        'tip_en': 'Baste halfway through with white wine to keep the meat tender and create a savory jus.',
      },
      {
        'title_it': 'Formaggi a Pasta Semicotta (Fontina, Asiago)',
        'title_en': 'Semi-aged Alpine Cheeses (Fontina, Asiago)',
        'type': 'cheese',
        'icon': '🧀',
        'prep_time': '5 min',
        'why_it': 'La sapidità minerale del vino si fonde con le note dolci e lattiche della cagliata alpina.',
        'why_en': 'Mineral savoriness melts with the sweet, milky notes of mountain alpine cheeses.',
        'tip_it': 'Accompagna con fette di mela croccante e pane rustico ai cereali.',
        'tip_en': 'Pair with crisp apple slices and hearty rustic seeded bread.',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 3; // Default Rosso Strutturato
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return;

    for (final cat in _categories) {
      final keywords = cat['keywords'] as List<String>;
      final nameIt = (cat['name_it'] as String).toLowerCase();
      final nameEn = (cat['name_en'] as String).toLowerCase();
      final examples = (cat['examples'] as String).toLowerCase();

      if (nameIt.contains(clean) ||
          nameEn.contains(clean) ||
          examples.contains(clean) ||
          keywords.any((k) => k.contains(clean) || clean.contains(k))) {
        setState(() {
          _selectedCategoryId = cat['id'] as int;
        });
        break;
      }
    }
  }

  WineRecommendation _createRecommendation(Map<String, dynamic> cat) {
    return WineRecommendation(
      id: cat['id'] as int,
      categoryName: cat['name_it'] as String,
      exampleWines: cat['examples'] as String,
      explanation: cat['explanation'] as String,
      servingTemperature: cat['serving_temperature'] as String,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCat = _categories.firstWhere(
      (c) => c['id'] == _selectedCategoryId,
      orElse: () => _categories.first,
    );

    final isIt = appLang.value == 'it';
    final allDishes = _dishesByCategory[_selectedCategoryId] ?? [];

    final filteredDishes = _selectedFilter == 'all'
        ? allDishes
        : allDishes.where((d) => d['type'] == _selectedFilter).toList();

    return ValueListenableBuilder<String>(
      valueListenable: appLang,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              t('reverse_title'),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Subtitle
                      Text(
                        t('reverse_subtitle'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Wine Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: t('reverse_search_hint'),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF6D213C)),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFFD6C5B3).withValues(alpha: 0.6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFFD6C5B3).withValues(alpha: 0.6),
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
                      const SizedBox(height: 16),

                      // Wine style horizontal selector
                      SizedBox(
                        height: 96,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final cat = _categories[index];
                            final catId = cat['id'] as int;
                            final isSelected = catId == _selectedCategoryId;
                            final name = isIt ? cat['name_it'] : cat['name_en'];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId = catId;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 140,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF6D213C) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF6D213C)
                                        : const Color(0xFFD6C5B3).withValues(alpha: 0.5),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF6D213C).withValues(alpha: 0.25),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      color: isSelected ? Colors.white : cat['color'] as Color,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Selected Wine Header Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: const Color(0xFFD6C5B3).withValues(alpha: 0.6),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (activeCat['color'] as Color).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  activeCat['icon'] as IconData,
                                  color: activeCat['color'] as Color,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isIt ? activeCat['name_it'] : activeCat['name_en'],
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${isIt ? 'Esempi' : 'Examples'}: ${activeCat['examples']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline, size: 22),
                                tooltip: isIt ? 'Vedi scheda vino' : 'View wine profile',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        recommendation: _createRecommendation(activeCat),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Section Title & Filter Chips
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            t('reverse_dishes_title'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filter Chips Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('all', t('reverse_filter_all')),
                            const SizedBox(width: 8),
                            _buildFilterChip('primi', t('reverse_filter_primi')),
                            const SizedBox(width: 8),
                            _buildFilterChip('meat', t('reverse_filter_meat')),
                            const SizedBox(width: 8),
                            _buildFilterChip('fish', t('reverse_filter_fish')),
                            const SizedBox(width: 8),
                            _buildFilterChip('pizza', t('reverse_filter_pizza')),
                            const SizedBox(width: 8),
                            _buildFilterChip('cheese', t('reverse_filter_cheese')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Recommended Dishes List
                      if (filteredDishes.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: Text(
                              t('reverse_no_dishes'),
                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ...filteredDishes.map((dish) {
                          final title = isIt ? dish['title_it'] : dish['title_en'];
                          final why = isIt ? dish['why_it'] : dish['why_en'];
                          final tip = isIt ? dish['tip_it'] : dish['tip_en'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: const Color(0xFFD6C5B3).withValues(alpha: 0.45),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dish['icon'] as String,
                                        style: const TextStyle(fontSize: 26),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if (dish['prep_time'] != null)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule,
                                                    size: 13,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    dish['prep_time'] as String,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, thickness: 0.6),
                                  const SizedBox(height: 10),

                                  // Why it works
                                  Text(
                                    t('reverse_why'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF6D213C),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    why,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Colors.grey[800],
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Chef's tip box
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF8F5),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFD6C5B3).withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.tips_and_updates_outlined,
                                          size: 18,
                                          color: Color(0xFFE5A93C),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: Colors.grey[800],
                                                height: 1.35,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${t('reverse_chef_tip')} ',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF6D213C),
                                                  ),
                                                ),
                                                TextSpan(text: tip),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
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

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF6D213C),
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6D213C) : const Color(0xFFD6C5B3),
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
    );
  }
}
