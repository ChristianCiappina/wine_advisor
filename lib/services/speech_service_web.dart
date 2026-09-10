import 'dart:js_interop' as js;

@js.JS('speakSommelierText')
external js.JSBoolean _speakSommelierText(js.JSString text, js.JSString lang);

@js.JS('stopSommelierVoice')
external void _stopSommelierVoice();

class PlatformSpeech {
  static bool speak(String text, String lang) {
    try {
      return _speakSommelierText(text.toJS, lang.toJS).toDart;
    } catch (_) {
      return false;
    }
  }

  static void stop() {
    try {
      _stopSommelierVoice();
    } catch (_) {}
  }
}
