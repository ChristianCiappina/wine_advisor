import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class WineService {
  WineService._();
  static final WineService instance = WineService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Recupera tutti i cibi o cerca per query su titolo, tipo cibo o vino abbinato (multilingua)
  Future<List<Map<String, dynamic>>> searchFoods([String query = '']) async {
    List<Map<String, dynamic>> allFoods;
    try {
      final response = await _client
          .from('foods')
          .select('id, title, food_type, wine_categories(*)')
          .order('id');
      allFoods = List<Map<String, dynamic>>.from(response);
      if (allFoods.isEmpty) {
        allFoods = _fallbackFoods;
      }
    } catch (_) {
      allFoods = _fallbackFoods;
    }

    final trimmed = query.trim().toLowerCase();

    if (trimmed.isEmpty) {
      return allFoods;
    }

    return allFoods.where((food) {
      final title = (food['title'] ?? '').toString().toLowerCase();
      final localizedTitle = t(food['title'] ?? '').toLowerCase();
      final type = (food['food_type'] ?? '').toString().toLowerCase();
      final localizedType = t(food['food_type'] ?? '').toLowerCase();
      final category = food['wine_categories'] as Map<String, dynamic>?;
      final catName = (category?['category_name'] ?? '').toString().toLowerCase();
      final catId = category?['id'];
      final localizedCatName = (catId != null ? t('cat_name_$catId') : t(category?['category_name'] ?? '')).toLowerCase();
      final examples = (category?['example_wines'] ?? '').toString().toLowerCase();

      return title.contains(trimmed) ||
          localizedTitle.contains(trimmed) ||
          type.contains(trimmed) ||
          localizedType.contains(trimmed) ||
          catName.contains(trimmed) ||
          localizedCatName.contains(trimmed) ||
          examples.contains(trimmed);
    }).toList();
  }

  /// Recupera tutti i mood o cerca per titolo, nome vino o esempi (multilingua)
  Future<List<Map<String, dynamic>>> searchMoods([String query = '']) async {
    List<Map<String, dynamic>> allMoods;
    try {
      final response = await _client
          .from('moods')
          .select('id, title, wine_categories(*)')
          .order('id');
      allMoods = List<Map<String, dynamic>>.from(response);
      if (allMoods.isEmpty) {
        allMoods = _fallbackMoods;
      }
    } catch (_) {
      allMoods = _fallbackMoods;
    }

    final trimmed = query.trim().toLowerCase();

    if (trimmed.isEmpty) {
      return allMoods;
    }

    return allMoods.where((mood) {
      final title = (mood['title'] ?? '').toString().toLowerCase();
      final localizedTitle = t(mood['title'] ?? '').toLowerCase();
      final category = mood['wine_categories'] as Map<String, dynamic>?;
      final catName = (category?['category_name'] ?? '').toString().toLowerCase();
      final catId = category?['id'];
      final localizedCatName = (catId != null ? t('cat_name_$catId') : t(category?['category_name'] ?? '')).toLowerCase();
      final examples = (category?['example_wines'] ?? '').toString().toLowerCase();

      return title.contains(trimmed) ||
          localizedTitle.contains(trimmed) ||
          catName.contains(trimmed) ||
          localizedCatName.contains(trimmed) ||
          examples.contains(trimmed);
    }).toList();
  }

  /// Recupera i preferiti dell'utente corrente ordinati per data decrescente
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('favorites')
        .select('saved_at, wine_categories(*)')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Verifica se una categoria è già salvata nei preferiti dell'utente
  Future<bool> isFavorite(int categoryId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _client
        .from('favorites')
        .select('category_id')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .maybeSingle();

    return response != null;
  }

  /// Inverte lo stato del preferito (salva se assente, elimina se già presente)
  Future<bool> toggleFavorite(int categoryId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Utente non autenticato');

    final alreadySaved = await isFavorite(categoryId);
    if (alreadySaved) {
      await deleteFavorite(categoryId);
      return false;
    } else {
      await saveFavorite(categoryId);
      return true;
    }
  }

  /// Salva una categoria di vino nei preferiti dell'utente corrente
  Future<void> saveFavorite(int categoryId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Utente non autenticato');

    await _client.from('favorites').insert({
      'user_id': userId,
      'category_id': categoryId,
    });
  }

  /// Elimina una categoria di vino dai preferiti dell'utente corrente
  Future<void> deleteFavorite(int categoryId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('favorites').delete().match({
      'user_id': userId,
      'category_id': categoryId,
    });
  }

  // Fallback Gastronomico Incorporato & Offline
  static final List<Map<String, dynamic>> _fallbackFoods = [
    {
      'id': 1,
      'title': 'Bistecca alla Fiorentina',
      'food_type': 'carne',
      'wine_categories': {
        'id': 3,
        'category_name': 'Rosso Strutturato',
        'example_wines': 'Chianti Classico Gran Selezione, Brunello di Montalcino, Bolgheri Rosso',
        'explanation': 'La succulenza e la marezzatura della carne al sangue richiedono tannini nobili e viva acidità per sgrassare il palato.',
        'serving_temperature': '16-18°C',
      },
    },
    {
      'id': 2,
      'title': 'Spaghetti alla Carbonara',
      'food_type': 'pasta',
      'wine_categories': {
        'id': 1,
        'category_name': 'Bianco Sapido o Bollicina',
        'example_wines': 'Frascati Superiore DOCG, Franciacorta Satèn, Fiano di Avellino',
        'explanation': 'La cremosità del tuorlo d\'uovo e la ricchezza del guanciale croccante si bilanciano magnificamente con freschezza minerale e fine effervescenza.',
        'serving_temperature': '8-10°C',
      },
    },
    {
      'id': 3,
      'title': 'Pizza Napoletana Margherita',
      'food_type': 'pizza',
      'wine_categories': {
        'id': 2,
        'category_name': 'Rosso Giovane o Spumante',
        'example_wines': 'Gragnano della Penisola Sorrentina, Asprinio di Aversa, Barbera d\'Asti',
        'explanation': 'L\'acidità del pomodoro San Marzano e la grassezza della mozzarella di bufala esigono un vino brioso, fresco e dal frutto vivace.',
        'serving_temperature': '12-14°C',
      },
    },
    {
      'id': 4,
      'title': 'Crudo di Mare & Ostriche',
      'food_type': 'pesce',
      'wine_categories': {
        'id': 2,
        'category_name': 'Bollicina Metodo Classico',
        'example_wines': 'Franciacorta Dosaggio Zero, Champagne Blanc de Blancs, Trento DOC Pas Dosé',
        'explanation': 'Note iodate e dolcezza del crostaceo trovano nella lama acida e nelle bollicine millimetriche l\'esaltazione gastronomica perfetta.',
        'serving_temperature': '6-8°C',
      },
    },
    {
      'id': 5,
      'title': 'Tagliolini al Tartufo Bianco d\'Alba',
      'food_type': 'pasta',
      'wine_categories': {
        'id': 3,
        'category_name': 'Rosso Nobile Evoluto',
        'example_wines': 'Barolo d\'annata, Barbaresco, Nebbiolo d\'Alba',
        'explanation': 'Gli aromi terziari e terrosi del tartufo dialogano all\'unisono con i profumi di rosa appassita, goudron e sottobosco del Nebbiolo.',
        'serving_temperature': '16-18°C',
      },
    },
    {
      'id': 6,
      'title': 'Risotto ai Funghi Porcini',
      'food_type': 'primi',
      'wine_categories': {
        'id': 3,
        'category_name': 'Rosso Medio Corpo',
        'example_wines': 'Pinot Nero dell\'Alto Adige, Etna Rosso, Valtellina Superiore',
        'explanation': 'La mantecatura al burro e la spiccata aromaticità del porcino si sposano con eleganza a vini rossi setosi e di grande finezza.',
        'serving_temperature': '14-16°C',
      },
    },
    {
      'id': 7,
      'title': 'Cinghiale in Umido con Polenta',
      'food_type': 'carne',
      'wine_categories': {
        'id': 3,
        'category_name': 'Grande Rosso da Invecchiamento',
        'example_wines': 'Amarone della Valpolicella, Taurasi, Morellino di Scansano Riserva',
        'explanation': 'La selvaggina ricca di erbe aromatiche necessita di calore alcolico avvolgente, corpo robusto e profumi di prugna e confettura scura.',
        'serving_temperature': '18°C',
      },
    },
    {
      'id': 8,
      'title': 'Selezione Formaggi Erborinati (Gorgonzola, Roquefort)',
      'food_type': 'formaggi',
      'wine_categories': {
        'id': 5,
        'category_name': 'Vino Passito o Fortificato',
        'example_wines': 'Passito di Pantelleria, Barolo Chinato, Vin Santo Toscano',
        'explanation': 'La piccantezza e la sapidità penetrante delle muffe nobili esigono la sontuosa dolcezza e la viscosità di un grande vino da meditazione.',
        'serving_temperature': '12-14°C',
      },
    },
  ];

  static final List<Map<String, dynamic>> _fallbackMoods = [
    {
      'id': 1,
      'title': 'Cena Romantica a Lume di Candela',
      'wine_categories': {
        'id': 2,
        'category_name': 'Spumante Rosé Metodo Classico',
        'example_wines': 'Franciacorta Rosé, Champagne Brut Rosé, Pinot Nero',
        'explanation': 'Atmosfera intima ed emozione: perlage setoso e profumi di piccoli frutti di bosco per un brindisi memorabile.',
        'serving_temperature': '8-10°C',
      },
    },
    {
      'id': 2,
      'title': 'Aperitivo Spensierato con Amici',
      'wine_categories': {
        'id': 2,
        'category_name': 'Bollicina Giovane o Bianco Minerale',
        'example_wines': 'Prosecco Superiore Valdobbiadene DOCG, Vermentino di Gallura, Lugana',
        'explanation': 'Facilità di beva, freschezza dissetante e profumi agrumati perfetti per brindisi e chiacchiere in allegria.',
        'serving_temperature': '6-8°C',
      },
    },
    {
      'id': 3,
      'title': 'Relax sul Divano con un Buon Libro o Film',
      'wine_categories': {
        'id': 3,
        'category_name': 'Rosso da Meditazione',
        'example_wines': 'Amarone Classico, Sagrantino di Montefalco, Valpolicella Ripasso',
        'explanation': 'Un calice avvolgente e complesso da sorseggiare lentamente per sciogliere le tensioni della giornata.',
        'serving_temperature': '16-18°C',
      },
    },
    {
      'id': 4,
      'title': 'Pranzo della Domenica in Famiglia',
      'wine_categories': {
        'id': 3,
        'category_name': 'Rosso Tradizionale Conviviale',
        'example_wines': 'Chianti Classico, Barbera d\'Alba, Montepulciano d\'Abruzzo',
        'explanation': 'Vini che sanno di casa, generosi e versatili, capaci di accompagnare primi al ragù e arrosti della tradizione.',
        'serving_temperature': '16-18°C',
      },
    },
  ];
}
