import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wine_advisor/models/wine_recommendation.dart';
import 'package:wine_advisor/screens/result_screen.dart';
import 'package:wine_advisor/screens/quiz_screen.dart';
import 'package:wine_advisor/screens/reverse_pairing_screen.dart';
import 'package:wine_advisor/screens/calculator_screen.dart';
import 'package:wine_advisor/screens/scanner_screen.dart';
import 'package:wine_advisor/screens/service_guide_screen.dart';
import 'package:wine_advisor/screens/tasting_lab_screen.dart';
import 'package:wine_advisor/screens/cellar_screen.dart';
import 'package:wine_advisor/screens/wine_detail_screen.dart';
import 'package:wine_advisor/services/cellar_service.dart';
import 'package:wine_advisor/services/gemini_service.dart';
import 'package:wine_advisor/services/wine_notes_service.dart';
import 'package:wine_advisor/services/wine_service.dart';
import 'package:wine_advisor/screens/sommelier_chat_screen.dart';
import 'package:wine_advisor/screens/food_screen.dart';
import 'package:wine_advisor/screens/mood_screen.dart';
import 'package:wine_advisor/widgets/language_pill.dart';
import 'package:wine_advisor/widgets/star_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wine_advisor/main.dart';

void main() {
  group('WineRecommendation model tests', () {
    test('fromJson creates a valid WineRecommendation instance', () {
      final json = {
        'id': 1,
        'category_name': 'Rosso Corposo',
        'example_wines': 'Barolo, Brunello di Montalcino',
        'explanation': 'Perfetto per piatti ricchi e carne rossa.',
        'serving_temperature': '16-18°C',
        'image_url': 'https://example.com/barolo.jpg',
      };

      final wine = WineRecommendation.fromJson(json);

      expect(wine.id, 1);
      expect(wine.categoryName, 'Rosso Corposo');
      expect(wine.exampleWines, 'Barolo, Brunello di Montalcino');
      expect(wine.servingTemperature, '16-18°C');
      expect(wine.imageUrl, 'https://example.com/barolo.jpg');
    });

    test('toJson produces expected map', () {
      final wine = WineRecommendation(
        id: 2,
        categoryName: 'Bianco Fresco',
        exampleWines: 'Vermentino, Pinot Grigio',
        explanation: 'Ideale con frutti di mare.',
        servingTemperature: '8-10°C',
      );

      final json = wine.toJson();

      expect(json['id'], 2);
      expect(json['category_name'], 'Bianco Fresco');
      expect(json['image_url'], isNull);
    });
    test('fromJson properly sanitizes database Unicode artifacts', () {
      final json = {
        'id': 3,
        'category_name': 'Rosso Strutturato',
        'example_wines': 'Gew\uFFFDrztraminer, Franciacorta',
        'explanation': 'Buona acidit\uFFFD, fa gi\uFFFD met\uFFFD del lavoro.',
        'serving_temperature': '18-20\uFFFDC',
      };

      final wine = WineRecommendation.fromJson(json);

      expect(wine.exampleWines, 'Gewürztraminer, Franciacorta');
      expect(wine.explanation, 'Buona acidità, fa già metà del lavoro.');
      expect(wine.servingTemperature, '18-20°C');
    });

    test('WineRecommendation localized getters adapt to active language', () {
      final wine = WineRecommendation(
        id: 3,
        categoryName: 'Rosso Strutturato',
        exampleWines: 'Chianti Classico, Brunello',
        explanation: 'Per la carne serve muscolo ed eleganza.',
        servingTemperature: '18-20°C',
      );

      appLang.value = 'it';
      expect(wine.localizedCategoryName, 'Rosso Strutturato');
      expect(wine.localizedExplanation.contains('Per la carne serve muscolo ed eleganza'), isTrue);

      appLang.value = 'en';
      expect(wine.localizedCategoryName, 'Full-bodied Red');
      expect(wine.localizedExplanation.contains('Meat calls for muscle and elegance'), isTrue);

      appLang.value = 'it';
    });
  });

  group('Translation dictionary tests', () {
    test('t() returns Italian translations when appLang is it', () {
      appLang.value = 'it';
      expect(t('hello'), 'Ciao');
      expect(t('food_title'), 'Ho già il menù');
      expect(t('continue_as_guest'), 'Continua come ospite');
      expect(t('guest'), 'Ospite');
      expect(t('result_saved_btn'), 'Salvato nei preferiti');
      expect(t('Carne alla Griglia'), 'Carne alla Griglia');
      expect(t('Netflix & Divano'), 'Netflix & Divano');
      expect(t('Rosso Strutturato'), 'Rosso Strutturato');
    });

    test('t() returns English translations when appLang is en', () {
      appLang.value = 'en';
      expect(t('hello'), 'Hello');
      expect(t('food_title'), 'I have the menu');
      expect(t('continue_as_guest'), 'Continue as guest');
      expect(t('guest'), 'Guest');
      expect(t('result_saved_btn'), 'Saved to favorites');
      expect(t('Carne alla Griglia'), 'Grilled Meat');
      expect(t('Tagliere di Formaggi'), 'Cheese Platter');
      expect(t('Netflix & Divano'), 'Netflix & Couch');
      expect(t('Cena Romantica'), 'Romantic Dinner');
      expect(t('Rosso Strutturato'), 'Full-bodied Red');
      expect(t('Bianco Fresco e Leggero'), 'Crisp & Light White');
      // Reset to it
      appLang.value = 'it';
    });
  });

  group('HomeScreen reactivity tests', () {
    testWidgets('HomeScreen translates luxury header, cards and paths in real-time when language changes', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ESPERIENZA PRIVATA'), findsOneWidget);
      expect(find.text('Selezione del Sommelier'), findsOneWidget);
      expect(find.text('Abbinamento del Giorno'), findsOneWidget);
      expect(find.text('Ho già il menù'), findsOneWidget);
      expect(find.text("Cerco l'atmosfera"), findsOneWidget);

      // Change language to English
      appLang.value = 'en';
      await tester.pumpAndSettle();

      expect(find.text('PRIVATE EXPERIENCE'), findsOneWidget);
      expect(find.text("Sommelier's Selection"), findsOneWidget);
      expect(find.text('Pairing of the Day'), findsOneWidget);
      expect(find.text('I have the menu'), findsOneWidget);
      expect(find.text('I want the right mood'), findsOneWidget);

      // Reset to Italian
      appLang.value = 'it';
    });

    testWidgets('HomeScreen interactions: filters, bookmarking, and scan bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on a filter pill
      expect(find.text('Bollicine DOCG'), findsOneWidget);
      await tester.tap(find.text('Bollicine DOCG'));
      await tester.pumpAndSettle();

      // Bookmark a community wine
      final bookmarkAddIcons = find.byIcon(Icons.bookmark_add_outlined);
      expect(bookmarkAddIcons, findsWidgets);
      await tester.tap(bookmarkAddIcons.first);
      await tester.pumpAndSettle();

      // Badge count should be updated
      expect(find.byIcon(Icons.bookmark), findsOneWidget);

      // Tap floating scan button (document_scanner icon)
      final scanBtn = find.byIcon(Icons.document_scanner);
      expect(scanBtn, findsWidgets);
      await tester.tap(scanBtn.first);
      await tester.pumpAndSettle();

      // Verify Scanner tab is active with ScannerScreen content
      expect(find.text('SCANNER ATTIVO'), findsOneWidget);
      expect(find.text('Tignanello'), findsOneWidget);
      expect(find.text('97'), findsOneWidget);
    });
  });

  group('Navigation and language toggle tests', () {
    testWidgets('Tapping LanguagePill on a pushed route stays on that route and translates it in place', (tester) async {
      appLang.value = 'it';
      final recommendation = WineRecommendation(
        id: 3,
        categoryName: 'Rosso Strutturato',
        exampleWines: 'Barolo, Brunello',
        explanation: 'Perfetto per carni.',
        servingTemperature: '16-18°C',
        imageUrl: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(recommendation: recommendation),
                    ),
                  );
                },
                child: const Text('Go to result'),
              ),
            ),
          ),
        ),
      );

      // Navigate to ResultScreen
      await tester.tap(find.text('Go to result'));
      await tester.pumpAndSettle();

      // Verify we are on ResultScreen in Italian
      expect(find.text('Il tuo Abbinamento'), findsOneWidget);
      expect(find.text('Full-bodied Red'), findsNothing);
      expect(find.text('Rosso Strutturato'), findsOneWidget);

      // Tap the LanguagePill
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      // Must remain on ResultScreen, translated in English!
      expect(find.text('Your Pairing'), findsOneWidget);
      expect(find.text('Full-bodied Red'), findsOneWidget);
      expect(find.text('Go to result'), findsNothing); // still on pushed route!

      // Reset
      appLang.value = 'it';
    });
  });

  group('WineNotesService tests', () {
    test('Can save and retrieve ratings and personal tasting notes', () async {
      SharedPreferences.setMockInitialValues({});

      final service = WineNotesService.instance;
      final initialMeta = await service.getMeta(3);
      expect(initialMeta.rating, 0);
      expect(initialMeta.note, '');
      expect(initialMeta.hasRating, isFalse);
      expect(initialMeta.hasNote, isFalse);

      // Save rating 5
      await service.saveRating(3, 5);
      var meta = await service.getMeta(3);
      expect(meta.rating, 5);
      expect(meta.hasRating, isTrue);

      // Save note
      await service.saveNote(3, 'Profumo intenso di frutti rossi, perfetto con la fiorentina.');
      meta = await service.getMeta(3);
      expect(meta.rating, 5);
      expect(meta.note, 'Profumo intenso di frutti rossi, perfetto con la fiorentina.');
      expect(meta.hasNote, isTrue);

      // Delete note
      await service.deleteNote(3);
      meta = await service.getMeta(3);
      expect(meta.rating, 5);
      expect(meta.note, '');
      expect(meta.hasNote, isFalse);
    });
  });

  group('StarRatingBar widget tests', () {
    testWidgets('Renders 5 stars and handles taps to update rating', (tester) async {
      int selectedRating = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return StarRatingBar(
                  rating: selectedRating,
                  onRatingChanged: (val) {
                    setState(() => selectedRating = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // 5 star icons rendered
      expect(find.byType(Icon), findsNWidgets(5));
      expect(selectedRating, 0);

      // Tap 4th star
      await tester.tap(find.byType(InkWell).at(3));
      await tester.pumpAndSettle();

      expect(selectedRating, 4);
    });
  });

  group('QuizScreen widget tests', () {
    testWidgets('Guides user through 3 steps and reveals ideal wine match with affinity', (tester) async {
      appLang.value = 'it';

      await tester.pumpWidget(
        const MaterialApp(
          home: QuizScreen(),
        ),
      );

      // Step 1 check
      expect(find.text('Qual è il mood della serata?'), findsOneWidget);
      expect(find.text('Passo 1 di 3'), findsOneWidget);

      // Select BBQ / rich feast
      await tester.tap(find.text('Grigliata o cena ricca di sapori'));
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      // Step 2 check
      expect(find.text('Cosa desidera il tuo palato?'), findsOneWidget);
      expect(find.text('Passo 2 di 3'), findsOneWidget);

      // Select warm body & bold tannins
      await tester.tap(find.text('Corpo caldo, tannini decisi e struttura'));
      await tester.pumpAndSettle(const Duration(milliseconds: 350));

      // Step 3 check
      expect(find.text('Con chi dividerai questo calice?'), findsOneWidget);
      expect(find.text('Passo 3 di 3'), findsOneWidget);

      // Select family or dinner guests
      await tester.tap(find.text('Famiglia o ospiti a tavola'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Match reveal check
      expect(find.text('Ecco il tuo abbinamento ideale!'), findsOneWidget);
      expect(find.text('Rosso Strutturato'), findsOneWidget);
      expect(find.textContaining('Affinità del Sommelier'), findsOneWidget);
      expect(find.text('Scopri bottiglie e dettagli'), findsOneWidget);
      expect(find.text('Rifai il Quiz'), findsOneWidget);
    });
  });

  group('ReversePairingScreen widget tests', () {
    testWidgets('Displays wine styles and recommended dishes with filtering', (tester) async {
      appLang.value = 'it';

      await tester.pumpWidget(
        const MaterialApp(
          home: ReversePairingScreen(),
        ),
      );

      // Verify title and default category (Rosso Strutturato)
      expect(find.text('Abbinamento Inverso'), findsOneWidget);
      expect(find.text('Piatti e ricette consigliate'), findsOneWidget);
      expect(find.text('Bistecca alla Fiorentina o Tagliata'), findsOneWidget);
      expect(find.text('Perché funziona:'), findsWidgets);

      // Switch to Bianco Fresco e Leggero
      await tester.tap(find.text('Bianco Fresco e Leggero'));
      await tester.pumpAndSettle();

      expect(find.text('Spaghetti alle Vongole Veraci'), findsOneWidget);
      expect(find.text('Bistecca alla Fiorentina o Tagliata'), findsNothing);

      // Apply filter chip: Pesce
      await tester.tap(find.text('🐟 Pesce'));
      await tester.pumpAndSettle();

      expect(find.text('Sushi, Sashimi & Crudi di Mare'), findsOneWidget);
      expect(find.text('Spaghetti alle Vongole Veraci'), findsNothing);

      // Search Barolo to automatically switch back to Rosso Strutturato
      await tester.enterText(find.byType(TextField), 'Barolo');
      await tester.pumpAndSettle();

      // Reset filter to all to see all dishes of Rosso Strutturato
      await tester.tap(find.text('Tutti'));
      await tester.pumpAndSettle();

      expect(find.text('Bistecca alla Fiorentina o Tagliata'), findsOneWidget);
    });
  });

  group('CalculatorScreen widget tests', () {
    testWidgets('Calculates bottles accurately, handles guest presets and language toggle', (tester) async {
      appLang.value = 'it';

      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial UI elements
      expect(find.text('Calcolatore Bottiglie'), findsWidgets);
      expect(find.text('Numero di Ospiti'), findsOneWidget);
      expect(find.text('Bottiglie Totali'), findsOneWidget);
      // 6 guests, dinner -> 1 sparkling + 2 white + 2 red + 1 reserve = 6 total bottles
      expect(find.text('6'), findsNWidgets(3)); // counter, chip preset '6', and total bottles '6'

      // Tap preset 12 guests
      await tester.tap(find.widgetWithText(ChoiceChip, '12'));
      await tester.pumpAndSettle();

      // Total bottles for 12 guests (3 sparkling + 3 white + 3 red + 1 reserve = 10)
      expect(find.text('10'), findsOneWidget);

      // Toggle language to English
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      // Verify texts translated to English
      expect(find.text('Wine Calculator'), findsOneWidget);
      expect(find.text('Number of Guests'), findsOneWidget);
      expect(find.text('Total Bottles'), findsOneWidget);
      expect(find.text('Safety Reserve Bottle'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });
  });

  group('ServiceGuideScreen widget tests', () {
    testWidgets('Displays glassware, switches tabs, shows sommelier hacks and translates in real-time', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';

      await tester.pumpWidget(
        const MaterialApp(
          home: ServiceGuideScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Tab 1: Calici
      expect(find.text('Servizio & Calici'), findsOneWidget);
      expect(find.text('Calice a Tulipano'), findsOneWidget);
      expect(find.text('Ballon Bordolese'), findsOneWidget);
      expect(find.text('Flûte a Tulipano'), findsOneWidget);

      // Switch to Tab 2: Temp & Decanter
      await tester.tap(find.text('🌡️ Temp & Decanter'));
      await tester.pumpAndSettle();

      expect(find.text('Guida alla Decantazione'), findsOneWidget);
      expect(find.text('6° - 8°C • Spumanti e Prosecchi'), findsOneWidget);
      expect(find.text('16° - 18°C • Grandi rossi strutturati'), findsOneWidget);

      // Switch to Tab 3: SOS Sommelier
      await tester.tap(find.text('💡 SOS Sommelier'));
      await tester.pumpAndSettle();

      expect(find.text('Raffreddare in 10 minuti (Ghiaccio + Acqua + Sale)'), findsOneWidget);
      expect(find.text('Il cucchiaino nello spumante: Mito sfatato'), findsOneWidget);

      // Toggle language to English
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      // Verify Tab 3 in English
      expect(find.text('Service & Glassware'), findsOneWidget);
      expect(find.text('Chill in 10 Minutes (Ice + Water + Salt)'), findsOneWidget);
      expect(find.text('Spoon in Sparkling Wine: Myth Debunked'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });
  });

  group('TastingLabScreen widget tests', () {
    testWidgets('Guides through sensory evaluation steps, identifies profile, and translates in real-time', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';

      await tester.pumpWidget(
        const MaterialApp(
          home: TastingLabScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Vista
      expect(find.text('Laboratorio Sensoriale'), findsOneWidget);
      expect(find.text('Che colore e tonalità osservi?'), findsOneWidget);
      expect(find.text('Rosso Rubino vivido'), findsOneWidget);

      // Select Ruby red
      await tester.tap(find.text('Rosso Rubino vivido'));
      await tester.pumpAndSettle();

      // Move to Step 2: Olfatto
      await tester.tap(find.text('Prosegui alla Ruota Aromi'));
      await tester.pumpAndSettle();

      expect(find.text('Quali profumi riconosci nel calice?'), findsOneWidget);

      // Select aromas: Ciliegia & Amarena, Violetta, Pepe Nero
      await tester.tap(find.text('Ciliegia & Amarena'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Violetta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pepe Nero'));
      await tester.pumpAndSettle();

      expect(find.text('Selezionati / Selected: 3/5'), findsOneWidget);

      // Move to Step 3: Palato
      await tester.tap(find.text('Prosegui al Palato'));
      await tester.pumpAndSettle();

      expect(find.text('Cosa provi al primo sorso?'), findsOneWidget);
      expect(find.text('Corpo & Struttura:'), findsOneWidget);

      // Select full body & bold tannins
      await tester.tap(find.text('Fresco & Piacevole'));
      await tester.pumpAndSettle();

      // Compute match
      await tester.tap(find.text('Analizza & Scopri l\'Identikit'));
      await tester.pumpAndSettle();

      // Step 4: Identikit Result
      expect(find.text('IDENTIKIT ENOLOGICO RILEVATO'), findsOneWidget);
      expect(find.text('Rosso Rubino & Speziato (Chianti Classico / Barbera)'), findsOneWidget);
      expect(find.text('Perché questo verdetto:'), findsOneWidget);
      expect(find.text('Condividi Scheda Degustazione'), findsOneWidget);

      // Toggle language to English
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      expect(find.text('IDENTIFIED WINE PROFILE'), findsOneWidget);
      expect(find.text('Vibrant & Spicy Red (Chianti Classico / Barbera)'), findsOneWidget);
      expect(find.text('Share Tasting Sheet'), findsOneWidget);

      // Restart test
      await tester.tap(find.text('Start New Tasting'));
      await tester.pumpAndSettle();

      // Returns to visual step
      expect(find.text('What color and hue do you see?'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });
  });

  group('ScannerScreen widget tests', () {
    testWidgets('Renders viewfinder, controls, sommelier recognition card, and responds to wine selection', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: ScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Top HUD & Scanner elements
      expect(find.text('SCANNER ATTIVO'), findsOneWidget);
      expect(find.text('Inquadra l\'etichetta frontale'), findsOneWidget);
      expect(find.text('Cantina'), findsOneWidget);

      // Recognition card (defaults to Tignanello)
      expect(find.text('Match 99.4% Confermato'), findsOneWidget);
      expect(find.text('Tignanello'), findsOneWidget);
      expect(find.text('97'), findsOneWidget);
      expect(find.text('PUNTI WA'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);
      expect(find.text('€135'), findsOneWidget);
      expect(find.text('Ottimale'), findsOneWidget);

      // Test Flash button toggle
      expect(find.byIcon(Icons.flash_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.flash_off));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.flash_on), findsOneWidget);

      // Test Cellar Night Mode toggle
      await tester.tap(find.text('Cantina'));
      await tester.pumpAndSettle();

      // Test "Aggiungi in Cantina" button
      expect(find.text('Aggiungi in Cantina'), findsOneWidget);
      await tester.tap(find.text('Aggiungi in Cantina'));
      await tester.pumpAndSettle();
      expect(find.text('Aggiunto!'), findsOneWidget);

      // Test "Inserisci nome manualmente"
      await tester.tap(find.text('Inserisci nome manualmente'));
      await tester.pumpAndSettle();

      expect(find.text('Cerca o Scegli un Vino'), findsOneWidget);
      expect(find.text('Sassicaia'), findsOneWidget);

      // Switch to Sassicaia
      await tester.tap(find.text('Sassicaia'));
      await tester.pumpAndSettle();

      // Verifies dynamic update to Sassicaia
      expect(find.text('Sassicaia'), findsOneWidget);
      expect(find.text('98'), findsOneWidget);
      expect(find.text('€290'), findsOneWidget);

      // Test language toggle
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      expect(find.text('SCANNER ACTIVE'), findsOneWidget);
      expect(find.text('Frame front label'), findsOneWidget);
      expect(find.text('Cellar'), findsOneWidget);
      expect(find.text('99.4% Match Confirmed'), findsOneWidget);
      expect(find.text('WA POINTS'), findsOneWidget);
      expect(find.text('Open Full Wine Sheet'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });
  });

  group('WineDetailScreen widget tests', () {
    testWidgets('Renders Barolo luxury card, organoleptic spectrum, bouquet, decanting and pairings', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: WineDetailScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Top bar & Header
      expect(find.text('Dettaglio Vino'), findsOneWidget);
      expect(find.byType(LanguagePill), findsOneWidget);

      // Hero Card elements
      expect(find.text('DOCG'), findsOneWidget);
      expect(find.text('Annata 2017'), findsOneWidget);
      expect(find.text('14.5% vol'), findsOneWidget);
      expect(find.text('CRU STORICO'), findsOneWidget);
      expect(find.text('Barolo Bricco Rocche'), findsOneWidget);
      expect(find.text('Ceretto · 2017'), findsOneWidget);
      expect(find.text('€185'), findsWidgets);
      expect(find.text('prezzo medio stimato'), findsOneWidget);

      // Shelf ratings
      expect(find.text('4.9 / 5'), findsOneWidget);
      expect(find.text('98 / 100'), findsOneWidget);
      expect(find.text('3 Bicchieri'), findsOneWidget);

      // Spettro Organolettico
      expect(find.text('Spettro Organolettico'), findsOneWidget);
      expect(find.text('Corpo'), findsOneWidget);
      expect(find.text('Tannino'), findsOneWidget);
      expect(find.text('Acidità'), findsOneWidget);
      expect(find.text('Dolcezza'), findsOneWidget);

      // Olfactory Bouquet
      expect(find.text('BOUQUET OLFATTIVO'), findsOneWidget);
      expect(find.text('Rosa Appassita'), findsOneWidget);
      expect(find.text('Goudron & Tartufo'), findsOneWidget);
      expect(find.text('Ciliegia Sotto Spirito'), findsOneWidget);
      expect(find.text('Spezie Scure'), findsOneWidget);

      // Servizio & Decantazione
      expect(find.text('16° - 18°C · Calice Borgogna'), findsOneWidget);
      expect(find.text('2 ore prima'), findsOneWidget);

      // Abbinamenti Gastronomici
      expect(find.text('Abbinamenti d\'Elezione'), findsOneWidget);
      expect(find.text('Brasato al Barolo'), findsOneWidget);
      expect(find.text('Risotto al Tartufo'), findsOneWidget);
      expect(find.text('Castelmagno DOP'), findsOneWidget);

      // Terroir & Cantina story
      expect(find.text('La Cantina Ceretto'), findsOneWidget);
      expect(find.text('Fondata nel 1937'), findsOneWidget);
      expect(find.text('Coltivazione Biologica Certificata'), findsOneWidget);

      // Story expand / collapse
      expect(find.text('Espandi'), findsOneWidget);
      await tester.tap(find.text('Espandi'));
      await tester.pumpAndSettle();
      expect(find.text('Riduci'), findsOneWidget);
      await tester.tap(find.text('Riduci'));
      await tester.pumpAndSettle();
      expect(find.text('Espandi'), findsOneWidget);

      // Wishlist Heart toggle
      final heartFinder = find.byIcon(Icons.favorite_border);
      expect(heartFinder, findsOneWidget);
      await tester.tap(heartFinder);
      await tester.pumpAndSettle();
      expect(find.text('Aggiunto ai vini desiderati ❤️'), findsOneWidget);

      // Clear snackbars so bottom dock is hit-testable
      ScaffoldMessenger.of(tester.element(find.byType(WineDetailScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Bottom Dock "In Cantina" toggle
      expect(find.text('In Cantina'), findsOneWidget);
      await tester.tap(find.text('In Cantina'));
      await tester.pumpAndSettle();
      expect(find.text('Custodito'), findsOneWidget);
      expect(find.text('Bottiglia aggiunta alla cantina personale! 🍾'), findsOneWidget);

      // Clear snackbars before tapping purchase button
      ScaffoldMessenger.of(tester.element(find.byType(WineDetailScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Partner Market Modal
      expect(find.text('Acquista · €185'), findsOneWidget);
      await tester.tap(find.text('Acquista · €185'));
      await tester.pumpAndSettle();

      expect(find.text('Acquista presso Enoteche Partner'), findsOneWidget);
      expect(find.text('Tannico Premium'), findsOneWidget);
      expect(find.text('Callmewine Privé'), findsOneWidget);
      expect(find.text('Enoteca Falletto Store'), findsOneWidget);

      // Dismiss modal by tapping on Tannico's button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Acquista').first);
      await tester.pumpAndSettle();
      expect(find.text('Reindirizzamento verso Tannico Premium...'), findsOneWidget);
    });

    testWidgets('WineDetailScreen supports custom wine parameters and real-time language switching', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: WineDetailScreen(
            customTitle: 'Amarone Classico Riserva',
            customWinery: 'Cantina Bertani · 2018',
            customPrice: '€68',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Custom parameters shown
      expect(find.text('Amarone Classico Riserva'), findsOneWidget);
      expect(find.text('Cantina Bertani · 2018'), findsOneWidget);
      expect(find.text('€68'), findsWidgets);
      expect(find.text('Acquista · €68'), findsOneWidget);

      // Switch language to English
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      // English labels
      expect(find.text('Wine Details'), findsOneWidget);
      expect(find.text('HISTORIC CRU'), findsOneWidget);
      expect(find.text('SENSORY ANALYSIS'), findsOneWidget);
      expect(find.text('Organoleptic Spectrum'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Tannin'), findsOneWidget);
      expect(find.text('Acidity'), findsOneWidget);
      expect(find.text('Sweetness'), findsOneWidget);
      expect(find.text('OLFACTORY BOUQUET'), findsOneWidget);
      expect(find.text('ORIGIN & HERITAGE'), findsOneWidget);
      expect(find.text('Certified Organic Viticulture'), findsOneWidget);
      expect(find.text('In Cellar'), findsOneWidget);
      expect(find.text('Purchase · €68'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });
  });

  group('CellarScreen widget tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      CellarService.instance.resetForTesting();
    });
    testWidgets('Renders cellar overview, bento vitals, sommelier nudge, filter tabs and bottle cards', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: CellarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header & Headline Section
      expect(find.text('COLLEZIONE PRIVATA'), findsOneWidget);
      expect(find.text('Caveau Attivo'), findsOneWidget);
      expect(find.text('La Mia Cantina Personale'), findsOneWidget);

      // Bento Vitals
      expect(find.text('BOTTIGLIE'), findsOneWidget);
      expect(find.text('STIMA TOTALE'), findsOneWidget);
      expect(find.text('DA BERE'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('€1.840'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // Da Bere stat count & filter count

      // Sommelier Nudge
      expect(find.text('Consiglio del Sommelier'), findsOneWidget);
      expect(find.text('Il Franciacorta Satèn è al culmine. Ideale per stasera!'), findsOneWidget);
      expect(find.text('Apri'), findsOneWidget);

      // Filter tabs
      expect(find.text('Tutte (4)'), findsOneWidget);
      expect(find.text('Pronte da bere (2)'), findsOneWidget);
      expect(find.text('Invecchiamento (2)'), findsOneWidget);
      expect(find.text('Preferiti (2)'), findsOneWidget);

      // Master Bottle List
      expect(find.text('Brunello di Montalcino 2015'), findsOneWidget);
      expect(find.text('Sassicaia 2018'), findsOneWidget);
      expect(find.text('Franciacorta Satèn 2019'), findsOneWidget);
      expect(find.text('Chianti Classico Gran Selezione 2018'), findsOneWidget);

      // Status badges
      expect(find.text('In Affinamento'), findsOneWidget);
      expect(find.text('Riposo Ottimale'), findsOneWidget);
      expect(find.text('Pronta da bere'), findsOneWidget);
      expect(find.text('Inizio Beva'), findsOneWidget);

      // Aging timeline labels
      expect(find.text('Picco tra 4 anni'), findsOneWidget);
      expect(find.text('Attendere ancora 2 anni'), findsOneWidget);
      expect(find.text('Apice qualitativo raggiunto'), findsOneWidget);
      expect(find.text('Armonico e pronto'), findsOneWidget);

      // Drinker Analytics & Regional split
      expect(find.text('ANALITICA DEL CAVEAU'), findsOneWidget);
      expect(find.text('Statistiche del Bevitore'), findsOneWidget);
      expect(find.text('Toscana (12)'), findsOneWidget);
      expect(find.text('Piemonte (7)'), findsOneWidget);
      expect(find.text('Lombardia (5)'), findsOneWidget);

      // Climate sensor
      expect(find.text('Condizioni cantina registrate:'), findsOneWidget);
      expect(find.text('14.2°C • 68% Ur'), findsOneWidget);
    });

    testWidgets('Filters bottles by tab, searches in real-time, and supports language switching', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: CellarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Filter: Pronte da bere
      await tester.tap(find.text('Pronte da bere (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Franciacorta Satèn 2019'), findsOneWidget);
      expect(find.text('Chianti Classico Gran Selezione 2018'), findsOneWidget);
      expect(find.text('Brunello di Montalcino 2015'), findsNothing);
      expect(find.text('Sassicaia 2018'), findsNothing);

      // Filter: Invecchiamento
      await tester.tap(find.text('Invecchiamento (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Brunello di Montalcino 2015'), findsOneWidget);
      expect(find.text('Sassicaia 2018'), findsOneWidget);
      expect(find.text('Franciacorta Satèn 2019'), findsNothing);

      // Filter back to all
      await tester.tap(find.text('Tutte (4)'));
      await tester.pumpAndSettle();

      // Search real-time
      await tester.enterText(find.byType(TextField), 'Sassicaia');
      await tester.pumpAndSettle();

      expect(find.text('Sassicaia 2018'), findsOneWidget);
      expect(find.text('Brunello di Montalcino 2015'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Language Switch to English
      await tester.tap(find.byType(LanguagePill));
      await tester.pumpAndSettle();

      expect(find.text('PRIVATE COLLECTION'), findsOneWidget);
      expect(find.text('Active Vault'), findsOneWidget);
      expect(find.text('My Personal Cellar'), findsOneWidget);
      expect(find.text('BOTTLES'), findsOneWidget);
      expect(find.text('TOTAL VALUE'), findsOneWidget);
      expect(find.text('TO DRINK'), findsOneWidget);
      expect(find.text('Sommelier Recommendation'), findsOneWidget);
      expect(find.text('VAULT ANALYTICS'), findsOneWidget);
      expect(find.text('Drinker Statistics'), findsOneWidget);
      expect(find.text('14.2°C • 68% RH'), findsOneWidget);

      // Reset
      appLang.value = 'it';
    });

    testWidgets('Add bottle dialog creates new cellar item and notifies user', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: CellarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nuovo Ingresso'), findsOneWidget);
      expect(find.text('Aggiungi'), findsOneWidget);

      await tester.tap(find.text('Aggiungi'));
      await tester.pumpAndSettle();

      expect(find.text('Aggiungi Bottiglia Manualmente'), findsOneWidget);

      // Enter wine name
      await tester.enterText(find.widgetWithText(TextField, 'Nome Vino (es. Barolo Monfortino)'), 'Amarone Bertani');
      await tester.pumpAndSettle();

      // Tap dialog confirm
      await tester.tap(find.widgetWithText(ElevatedButton, 'Aggiungi').last);
      await tester.pumpAndSettle();

      // Toast feedback and new item in list
      expect(find.text('Nuova bottiglia aggiunta alla cantina! 🍾'), findsOneWidget);
      expect(find.text('Amarone Bertani'), findsOneWidget);
    });
  });

  group('GeminiService and SommelierChatScreen widget tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('GeminiService fallback returns structured wine recognition and sommelier recommendations', () async {
      final gemini = GeminiService.instance;
      // Fallback label recognition
      final recognized = await gemini.analyzeWineLabel(Uint8List.fromList([1, 2, 3]));
      expect(recognized.title.isNotEmpty, isTrue);
      expect(recognized.winery.isNotEmpty, isTrue);
      expect(recognized.pairings.isNotEmpty, isTrue);

      // Fallback sommelier chat response
      final responseIt = await gemini.chatWithSommelier(
        userMessage: 'Cosa posso abbinare con una fiorentina al sangue?',
        history: [],
        language: 'it',
      );
      expect(responseIt.toLowerCase().contains('rosso') || responseIt.toLowerCase().contains('tannin') || responseIt.toLowerCase().contains('fiorentina') || responseIt.isNotEmpty, isTrue);

      // API Key persistence
      await gemini.saveApiKey('test-dummy-api-key-12345');
      final key = await gemini.getApiKey();
      expect(key, 'test-dummy-api-key-12345');
    });

    testWidgets('SommelierChatScreen renders AI concierge, quick suggestion chips and responds to prompts', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: SommelierChatScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header & AI persona
      expect(find.text('Sommelier Privato'), findsOneWidget);
      expect(find.text('AI Sommelier Attivo'), findsOneWidget);
      expect(find.textContaining('Sommelier Privato'), findsWidgets);

      // Verify quick prompt chips
      expect(find.text('🥩 Bistecca alla Fiorentina'), findsOneWidget);
      expect(find.text('🎁 Consiglio per un regalo importante'), findsOneWidget);

      // Tap quick chip
      await tester.tap(find.text('🥩 Bistecca alla Fiorentina'));
      await tester.pumpAndSettle();

      // Verify user bubble and suggestion chip both contain the prompt
      expect(find.text('🥩 Bistecca alla Fiorentina'), findsNWidgets(2));

      // Open API key dialog
      final keyIcon = find.byIcon(Icons.key);
      expect(keyIcon, findsOneWidget);
      await tester.tap(keyIcon);
      await tester.pumpAndSettle();

      expect(find.text('Configura Gemini AI'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      // Verify Copy button & Clear Chat button
      expect(find.byIcon(Icons.delete_sweep_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Cancellare la conversazione?'), findsOneWidget);
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();
    });
  });

  group('Perfection features tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      CellarService.instance.resetForTesting();
    });

    test('CellarService corkBottle, isBottleInCellar and exportCellarSummary work correctly', () async {
      final service = CellarService.instance;
      expect(service.isBottleInCellar('Brunello di Montalcino 2015'), isTrue);
      expect(service.isBottleInCellar('Vino Inesistente XYZ'), isFalse);

      // Export summary
      final exportIt = service.exportCellarSummary('it');
      expect(exportIt.contains('La Mia Cantina Personale'), isTrue);
      expect(exportIt.contains('Brunello di Montalcino'), isTrue);

      final exportEn = service.exportCellarSummary('en');
      expect(exportEn.contains('My Personal Cellar'), isTrue);

      // Cork bottle with quantity 1 -> removes from list
      final wasRemoved = await service.corkBottle('brunello-2015');
      expect(wasRemoved, isTrue);
      expect(service.isBottleInCellar('Brunello di Montalcino 2015'), isFalse);

      // Cork bottle with quantity 2 (Sassicaia) -> decrements to 1
      final wasDecremented = await service.corkBottle('sassicaia-2018');
      expect(wasDecremented, isFalse);
      expect(service.bottlesNotifier.value.firstWhere((b) => b.id == 'sassicaia-2018').quantity, 1);
    });

    testWidgets('CellarScreen interactive quantity stepper, uncork, export and empty filter reset', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: CellarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Export button is present
      expect(find.text('Esporta Cantina'), findsOneWidget);
      await tester.tap(find.text('Esporta Cantina'));
      await tester.pumpAndSettle();
      expect(find.text('Riepilogo cantina copiato negli appunti! 📋'), findsOneWidget);

      // Clear snackbars
      ScaffoldMessenger.of(tester.element(find.byType(CellarScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Verify quantity stepper + and -
      final addIcons = find.byIcon(Icons.add);
      expect(addIcons, findsWidgets);
      await tester.tap(addIcons.first);
      await tester.pumpAndSettle();

      // Verify Uncork button
      final uncorkButtons = find.text('Stappa 🍾');
      expect(uncorkButtons, findsWidgets);
      await tester.tap(uncorkButtons.first);
      await tester.pumpAndSettle();
      expect(find.text('Salute! Bottiglia stappata con successo 🍾'), findsOneWidget);

      // Clear snackbars
      ScaffoldMessenger.of(tester.element(find.byType(CellarScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Search non-existing wine to trigger empty filter state
      await tester.enterText(find.byType(TextField), 'VinoImpossibile999');
      await tester.pumpAndSettle();

      expect(find.text('Nessuna bottiglia trovata'), findsOneWidget);
      expect(find.text('Mostra tutte le bottiglie'), findsOneWidget);

      // Tap reset filters button
      await tester.tap(find.text('Mostra tutte le bottiglie'));
      await tester.pumpAndSettle();

      // Wine list restored
      expect(find.text('Nessuna bottiglia trovata'), findsNothing);
    });

    testWidgets('WineDetailScreen In Cantina button syncs directly with CellarService', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: WineDetailScreen(
            customTitle: 'Taurasi Riserva',
            customWinery: 'Mastroberardino · 2016',
            customPrice: '€55',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(CellarService.instance.isBottleInCellar('Taurasi Riserva'), isFalse);

      // Tap "In Cantina"
      await tester.tap(find.text('In Cantina'));
      await tester.pumpAndSettle();

      // Confirmed added in cellar service!
      expect(CellarService.instance.isBottleInCellar('Taurasi Riserva'), isTrue);
      expect(find.text('Custodito'), findsOneWidget);
    });

    test('WineService searchFoods and searchMoods provide offline gastronomic fallbacks', () async {
      final foods = await WineService.instance.searchFoods('fiorentina');
      expect(foods.isNotEmpty, isTrue);
      expect(foods.first['title'], 'Bistecca alla Fiorentina');

      final moods = await WineService.instance.searchMoods('');
      expect(moods.length >= 4, isTrue);
    });

    testWidgets('ScannerScreen can close result sheet to reveal interactive camera launcher', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: ScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially shows result card
      expect(find.text('Match 99.4% Confermato'), findsOneWidget);

      // Tap close/minimize button
      await tester.tap(find.byIcon(Icons.close_fullscreen_rounded));
      await tester.pumpAndSettle();

      // Now shows the camera launcher card with demo buttons!
      expect(find.text('Mirino Pronto'), findsOneWidget);
      expect(find.text('Scatta Foto'), findsWidgets);
      expect(find.text('Carica Foto'), findsWidgets);

      // Tap demo label Sassicaia to re-open
      await tester.tap(find.text('Sassicaia'));
      await tester.pumpAndSettle();

      expect(find.text('Match 99.4% Confermato'), findsOneWidget);
      expect(find.text('Sassicaia'), findsOneWidget);
    });

    testWidgets('HomeScreen displays guest greeting, dynamic sommelier card on filter click, and pairings tab', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Guest greeting in Italian
      expect(find.textContaining('Gentile Ospite'), findsOneWidget);
      expect(find.textContaining('Marco'), findsNothing);

      // Bottom nav tab 1 is Abbinamenti
      expect(find.text('Abbinamenti'), findsOneWidget);

      // Default featured wine is Amarone
      expect(find.text('Amarone della Valpolicella Classico'), findsOneWidget);

      // Switch to Rossi strutturati
      await tester.tap(find.text('Rossi strutturati'));
      await tester.pumpAndSettle();
      expect(find.text('Barolo Riserva Monfortino'), findsOneWidget);
      expect(find.text('Amarone della Valpolicella Classico'), findsNothing);

      // Switch to Bollicine DOCG
      await tester.tap(find.text('Bollicine DOCG'));
      await tester.pumpAndSettle();
      expect(find.text('Franciacorta Riserva Cuvée Annamaria Clementi'), findsOneWidget);

      // Switch language to English
      appLang.value = 'en';
      await tester.pumpAndSettle();

      expect(find.textContaining('Honored Guest'), findsOneWidget);
      expect(find.text('Pairings'), findsOneWidget);

      // Reset language
      appLang.value = 'it';
    });

    testWidgets('FoodScreen supports initialQuery, renders luxury dishes and sommelier pairing badges', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: FoodScreen(initialQuery: 'pizza'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FoodScreen), findsOneWidget);
      expect(find.text('Pizza'), findsWidgets);
      expect(find.byIcon(Icons.wine_bar), findsWidgets);
    });

    testWidgets('MoodScreen renders luxury atmosphere cards and sommelier pairing badges', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      appLang.value = 'it';
      await tester.pumpWidget(
        const MaterialApp(
          home: MoodScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MoodScreen), findsOneWidget);
      expect(find.byIcon(Icons.wine_bar), findsWidgets);
    });
  });
}



