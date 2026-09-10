import 'dart:async';
import 'package:flutter/foundation.dart';

/// Utility class to delay execution of actions until a specified duration
/// has elapsed since the last time the action was invoked.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 350)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
