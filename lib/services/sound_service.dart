import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SoundService extends ChangeNotifier {
  bool _enabled = true;

  bool get enabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
    notifyListeners();
  }

  void playTap() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  void playWin() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }

  void playDraw() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }
}
