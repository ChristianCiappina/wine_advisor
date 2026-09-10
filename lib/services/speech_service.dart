import 'package:flutter/foundation.dart';
import 'speech_service_stub.dart'
    if (dart.library.html) 'speech_service_web.dart';

class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  bool speak(String text, String lang) {
    stop();
    final ok = PlatformSpeech.speak(text, lang);
    if (ok) {
      isSpeaking.value = true;
    }
    return ok;
  }

  void stop() {
    PlatformSpeech.stop();
    isSpeaking.value = false;
  }
}
