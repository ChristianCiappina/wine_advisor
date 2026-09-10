import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wine_advisor/main.dart';
import 'package:wine_advisor/services/gemini_service.dart';
import 'package:wine_advisor/services/speech_service.dart';
import 'package:wine_advisor/widgets/language_pill.dart';

class SommelierChatScreen extends StatefulWidget {
  final String? initialQuery;

  const SommelierChatScreen({super.key, this.initialQuery});

  @override
  State<SommelierChatScreen> createState() => _SommelierChatScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _SommelierChatScreenState extends State<SommelierChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initWelcome();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSend(widget.initialQuery!);
      });
    }
  }

  void _initWelcome() {
    final lang = appLang.value;
    final welcomeText = lang == 'it'
        ? 'Salute e benvenuto! 🍷\nSono il tuo **Sommelier Privato** di Wine Advisor.\n\nChiedimi qualsiasi consiglio: abbinamenti perfetti per la tua cena, suggerimenti per un regalo, o curiosità su vitigni e calici. Cosa degusterai oggi?'
        : 'Welcome and cheers! 🍷\nI am your **Private Sommelier** at Wine Advisor.\n\nAsk me anything: ideal pairings for dinner, gift recommendations, or glassware and decanting tips. What are we pouring today?';

    _messages.add(
      _ChatMessage(
        text: welcomeText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _handleSend([String? textToSend]) async {
    final text = (textToSend ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    // Prepare history for Gemini
    final history = _messages
        .take(_messages.length - 1)
        .map((m) => {
              'role': m.isUser ? 'user' : 'model',
              'text': m.text,
            })
        .toList();

    try {
      final response = await GeminiService.instance.chatWithSommelier(
        history: history,
        userMessage: text,
        language: appLang.value,
      );

      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: appLang.value == 'it'
                  ? 'Mi scuso, si è verificata un\'interruzione momentanea nella comunicazione. Riprova tra poco.'
                  : 'I apologize, there was a temporary issue retrieving sommelier advice. Please try again.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showApiKeyDialog() async {
    final currentKey = await GeminiService.instance.getApiKey() ?? '';
    final keyController = TextEditingController(text: currentKey);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFCF9F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF7B581C)),
            const SizedBox(width: 8),
            Text(
              appLang.value == 'it'
                  ? 'Configura Gemini AI'
                  : 'Configure Gemini AI',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3C0311),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLang.value == 'it'
                  ? 'Inserisci la tua chiave gratuita di Google Gemini (da Google AI Studio) per abilitare il Sommelier AI illimitato e la scansione multimodale delle etichette:'
                  : 'Enter your free Google Gemini API key (from Google AI Studio) for unlimited real-time AI Sommelier & label analysis:',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: keyController,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                labelText: 'Google Gemini API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              appLang.value == 'it'
                  ? 'Nota: se lasci vuoto, l\'app utilizzerà il motore di regole Sommelier integrato.'
                  : 'Note: If left blank, the app uses the built-in Sommelier rule engine.',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581825),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              await GeminiService.instance.saveApiKey(keyController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      appLang.value == 'it'
                          ? 'Chiave API salvata con successo! ✨'
                          : 'API Key saved successfully! ✨',
                    ),
                    backgroundColor: const Color(0xFF581825),
                  ),
                );
              }
            },
            child: Text(t('result_save')),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline, color: Color(0xFF581825)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('clear_chat_title'),
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(t('clear_chat_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF581825),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _initWelcome();
              });
            },
            child: Text(t('clear_chat_confirm')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = appLang.value;

    final suggestionChips = lang == 'it'
        ? [
            '🍝 Cosa abbino alla Carbonara?',
            '🥩 Bistecca alla Fiorentina',
            '🍣 Vino perfetto per il Sushi',
            '🎁 Consiglio per un regalo importante',
            '🌡️ Come e quando decantare un Barolo?',
          ]
        : [
            '🍝 Best wine for Carbonara?',
            '🥩 Wine for Grilled Ribeye Steak',
            '🍣 Wine pairing for fresh Sushi',
            '🎁 Gift wine recommendations under €40',
            '🌡️ When to decant a bold Red?',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F6),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              lang == 'it' ? 'Sommelier Privato' : 'Private Sommelier',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: const Color(0xFF3C0311),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  lang == 'it' ? 'AI Sommelier Attivo' : 'AI Sommelier Online',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B581C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF7B581C), size: 20),
            tooltip: lang == 'it' ? 'Azzera conversazione' : 'Clear chat',
            onPressed: _showClearChatDialog,
          ),
          IconButton(
            icon: const Icon(Icons.key, color: Color(0xFF7B581C), size: 20),
            tooltip: lang == 'it' ? 'Imposta API Key' : 'Configure API Key',
            onPressed: _showApiKeyDialog,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: LanguagePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // Chat message list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildMessageBubble(msg);
                    },
                  ),
                ),

                // Typing Indicator
                if (_isLoading)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFFDCC85)
                                    .withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF7B581C),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SoundWaveVisualizer(
                                isPlaying: true,
                                color: Color(0xFF7B581C),
                                height: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                lang == 'it'
                                    ? 'Il Sommelier sta formulando il consiglio...'
                                    : 'The Sommelier is thinking...',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF7B581C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Quick Suggestion Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: suggestionChips.map((chipText) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(
                            chipText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3C0311),
                            ),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color:
                                const Color(0xFFFDCC85).withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onPressed: () => _handleSend(chipText),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color:
                            const Color(0xFF2C2224).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (val) => _handleSend(val),
                          decoration: InputDecoration(
                            hintText: lang == 'it'
                                ? 'Chiedi al Sommelier (es. abbinamento, vino...)'
                                : 'Ask the Sommelier (e.g. food pairing, wine...)',
                            hintStyle: const TextStyle(
                                fontSize: 13, color: Colors.black45),
                            filled: true,
                            fillColor: const Color(0xFFFCF9F6),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: const Color(0xFF2C2224)
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: const Color(0xFF2C2224)
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFF7B581C),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF581825),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                        ),
                        onPressed: _isLoading ? null : () => _handleSend(),
                        icon: const Icon(Icons.send_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF581825),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sommelier Bubble
    final isLastSommelier = !msg.isUser && msg == _messages.last && !_isLoading;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF3C0311),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFDCC85), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3C0311).withValues(alpha: 0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.wine_bar_rounded, color: Color(0xFFFDCC85), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: const Color(0xFF2C2224).withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        msg.text,
                        style: const TextStyle(
                          color: Color(0xFF2C2224),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Tasto Ascolta Sommelier
                          ValueListenableBuilder<bool>(
                            valueListenable: SpeechService.instance.isSpeaking,
                            builder: (context, isSpeaking, _) {
                              return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  if (isSpeaking) {
                                    SpeechService.instance.stop();
                                  } else {
                                    final ok = SpeechService.instance.speak(
                                      msg.text,
                                      appLang.value,
                                    );
                                    if (ok && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(t('speech_playing')),
                                          backgroundColor: const Color(0xFF7B581C),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSpeaking) ...[
                                        const SoundWaveVisualizer(
                                          isPlaying: true,
                                          color: Color(0xFF581825),
                                          height: 12,
                                        ),
                                        const SizedBox(width: 5),
                                      ] else ...[
                                        const Icon(
                                          Icons.volume_up,
                                          size: 13,
                                          color: Color(0xFF7B581C),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        isSpeaking ? t('stop_advice') : t('listen_advice'),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: isSpeaking ? const Color(0xFF581825) : const Color(0xFF7B581C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // Tasto Copia
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Clipboard.setData(ClipboardData(text: msg.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(t('copied_to_clipboard')),
                                  backgroundColor: const Color(0xFF581825),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.copy, size: 12, color: Color(0xFF7B581C)),
                                  const SizedBox(width: 4),
                                  Text(
                                    appLang.value == 'it' ? 'Copia' : 'Copy',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7B581C),
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
                ),
              ),
            ],
          ),
          // Follow-up suggestion prompts for the latest sommelier answer
          if (isLastSommelier) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    t('followup_temp'),
                    t('followup_glass'),
                    t('followup_budget'),
                    t('followup_aging'),
                  ].map((prompt) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        avatar: const Icon(Icons.auto_awesome, size: 12, color: Color(0xFF7B581C)),
                        label: Text(
                          prompt,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3C0311),
                          ),
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: const Color(0xFFFDCC85).withValues(alpha: 0.8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _handleSend(prompt);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated 4-bar golden audio wave indicator
class SoundWaveVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color? color;
  final double height;

  const SoundWaveVisualizer({
    super.key,
    required this.isPlaying,
    this.color,
    this.height = 14,
  });

  @override
  State<SoundWaveVisualizer> createState() => _SoundWaveVisualizerState();
}

class _SoundWaveVisualizerState extends State<SoundWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting && widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SoundWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTesting) {
      if (widget.isPlaying && !_controller.isAnimating) {
        _controller.repeat();
      } else if (!widget.isPlaying && _controller.isAnimating) {
        _controller.stop();
        _controller.value = 0.3;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.color ?? const Color(0xFF7B581C);

    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final h1 = 3.0 + 7.0 * ((math.sin(t * 2 * math.pi)).abs());
          final h2 = 3.0 + 9.0 * ((math.sin((t + 0.25) * 2 * math.pi)).abs());
          final h3 = 3.0 + 8.0 * ((math.sin((t + 0.5) * 2 * math.pi)).abs());
          final h4 = 3.0 + 6.0 * ((math.sin((t + 0.75) * 2 * math.pi)).abs());

          final heights =
              widget.isPlaying ? [h1, h2, h3, h4] : [3.0, 6.0, 4.0, 3.0];

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: heights.map((h) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.2),
                width: 2.2,
                height: h.clamp(2.5, widget.height),
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
