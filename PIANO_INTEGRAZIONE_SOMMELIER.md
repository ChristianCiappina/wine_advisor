# Piano di integrazione — Wine Advisor (sommelier / affidabilità dati)

> Origine: riassunto integrazioni preparato per il lavoro in Codex
> (`README_RIASSUNTO_INTEGRAZIONI.md`, pacchetto del 18/09/2026).
> Questo documento incrocia quel riassunto con lo stato reale del codice
> in questo repository (unico commit su `main`, app Flutter) per capire
> cosa esiste già, cosa manca e da dove iniziare.

## Stato reale del codice (verificato in questo repo)

- Nessuna cartella `supabase/` nel repo: schema, grants, RLS e funzioni
  server (punto 10) non sono versionati qui. L'app si collega a Supabase
  solo lato client (`supabase_flutter` in `lib/services/*.dart`).
- Nessun controllo di ruolo (admin/sommelier/editor) in `lib/main.dart`
  né altrove: l'autenticazione esiste (`login_screen.dart`,
  `Supabase.instance.client.auth`), ma non c'è un'area riservata né una
  distinzione di ruoli — punto 3 e punto 10 sono da costruire da zero.
- `lib/services/gemini_service.dart`:
  - `analyzeWineLabel()` chiede a Gemini di **inventare** punteggio,
    prezzo medio, range di mercato e finestra di beva anche quando non
    sono dati reali noti (prompt righe 108–138). Questo è esattamente
    il comportamento vietato dal punto 9 ("l'AI non deve inventare
    prezzi, punteggi o approvazioni").
  - Se manca la API key o la chiamata fallisce, `_generateSmartFallbackWine()`
    (righe 253–280) restituisce **sempre** la stessa scheda fissa
    ("Barolo Bricco Rocche, Ceretto, 2016, 98 punti, €210...") come se
    fosse un riconoscimento reale. Nessuno stato "non riconosciuto /
    servizio non disponibile / demo" — è la falla descritta nel punto 5
    (scanner affidabile).
  - `chatWithSommelier()` ha lo stesso schema: se manca la key, risponde
    con un motore a regole fisso (`_generateSommelierRuleResponse`) senza
    segnalare all'utente che non sta parlando con l'AI vera.
- `lib/services/wine_service.dart`: `searchFoods`/`searchMoods` hanno
  fallback locali (`_fallbackFoods`, `_fallbackMoods`) usati solo quando
  Supabase non risponde o è vuoto — corretto come fallback dei contenuti
  editoriali pubblicati, ma senza distinzione visibile "dati offline" vs
  "dati live" per l'utente (rilevante per il punto 7, stato
  offline/sincronizzazione).
- `lib/services/cellar_service.dart`: modello `CellarBottleItem` con
  `quantity`, `priceEstimate` separato da eventuali dati di mercato, ma
  la persistenza è `shared_preferences` + Supabase senza una gestione
  esplicita di migrazione schema né isolamento guest/utente A/utente B
  verificabile da qui (punto 7).
- Non esiste un modello dati editoriale separato (vini/annate, piatti,
  abbinamenti condizionati, guide, segnalazioni) — oggi tutto passa per
  `wine_categories`/`foods`/`moods` su Supabase, letti direttamente dai
  service client-side (punto 1).
- Non esiste alcun workflow `draft → in_review → approved → published →
  withdrawn`, né UI di revisione (punto 2, punto 3).
- Non esiste un simulatore né un campione di casi di test per gli
  abbinamenti (punto 4).

## Mappa dei 12 punti sullo stato reale

| # | Tema | Stato in questo repo | Nota |
|---|------|----------------------|------|
| 1 | Modello dati editoriale | Assente | Solo tabelle piatte `wine_categories`/`foods`/`moods` |
| 2 | Workflow sommelier | Assente | Nessun concetto di stato/versione dei contenuti |
| 3 | Area riservata sommelier | Assente | Nessuna UI/ruolo dedicato |
| 4 | Simulatore | Assente | Nessun harness di test per gli abbinamenti |
| 5 | Scanner affidabile | **Da correggere** | Fallback fisso spacciato per riconoscimento reale (`gemini_service.dart:253`) |
| 6 | Identità vino coerente | Parziale | `RecognizedWine` e `CellarBottleItem` sono modelli separati, non un'unica identità condivisa |
| 7 | Cantina reale/sync | Parziale | Esiste servizio e persistenza, manca stato offline visibile e piano migrazioni |
| 8 | Note/preferiti per oggetto corretto | Parziale | `favorites`/`wine_notes_service.dart` legati a `category_id`, non a vino+annata+degustazione |
| 9 | AI come interprete, non fonte | **Da correggere** | Prompt Gemini chiede di inventare prezzo/punteggio (`gemini_service.dart:118-121`) |
| 10 | Backend e sicurezza | Assente in repo | Nessun `supabase/` versionato, nessun controllo ruoli server-side |
| 11 | UI a 12 schermate | Parziale | Esistono già molte schermate (`lib/screens/`) ma non tracciate rispetto ai mockup del pacchetto grafico |
| 12 | Integrazioni esterne | Non iniziato | Corretto: da valutare solo dopo il nucleo affidabile |

## Priorità immediate (coerenti con l'ordine di sviluppo del pacchetto)

1. **Scanner e AI (punti 5 e 9)** — quelli con codice attivo e rischio
   reputazionale più alto, perché *oggi* l'app mostra dati inventati
   come se fossero reali:
   - Rimuovere l'invenzione di punteggio/prezzo/maturazione dal prompt
     Gemini quando non sono verificabili, oppure marcarli esplicitamente
     come stima non ufficiale.
   - Sostituire `_generateSmartFallbackWine()` con stati espliciti:
     riconosciuto / ambiguo / non riconosciuto / servizio non disponibile
     / demo — mai una scheda finta presentata come riconoscimento vero.
2. **Identità vino unica (punto 6)** — consolidare `RecognizedWine`,
   `CellarBottleItem` e le voci di `wine_categories` dietro un solo ID
   di vino/annata, così scanner → dettaglio → cantina → note →
   abbinamenti puntano alla stessa entità.
3. **Backend versionato (punto 10)** — portare schema, RLS e grants di
   Supabase dentro il repo (cartella `supabase/`) prima di costruire
   workflow editoriale e area riservata, altrimenti punti 1–3 non hanno
   fondamenta verificabili.
4. Solo dopo: modello dati editoriale, workflow sommelier, area
   riservata, simulatore — come indicato nell'ordine di sviluppo del
   pacchetto originale.

## Riferimenti al pacchetto originale

Il pacchetto completo (prompt operativo, schede sommelier, piano
verifiche, campione 10 casi, grafica 12 schermate, audit, dossier) non è
allegato a questo repository — è stato descritto solo nel riassunto
caricato in sessione. Chi riprende questo piano deve recuperare quei file
dal pacchetto Codex originale se servono i dettagli operativi punto per
punto (struttura schede, criteri del simulatore, ecc.).
