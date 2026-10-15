import 'package:flutter/services.dart';

/// 햅틱을 한 곳에서 부른다. 화면마다 강도를 다르게 고르지 않게 하기 위함.
abstract final class PassqlHaptics {
  static Future<void> playSelection() => HapticFeedback.selectionClick();
  static Future<void> playCorrectAnswer() => HapticFeedback.mediumImpact();
  static Future<void> playWrongAnswer() => HapticFeedback.heavyImpact();
}
