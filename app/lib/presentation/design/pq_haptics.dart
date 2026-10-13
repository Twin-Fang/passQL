import 'package:flutter/services.dart';

/// 햅틱을 한 곳에서 부른다. 화면마다 강도를 다르게 고르지 않게 하기 위함.
abstract final class PqHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();
  static Future<void> correct() => HapticFeedback.mediumImpact();
  static Future<void> wrong() => HapticFeedback.heavyImpact();
}
