import 'package:flutter/services.dart';

/// 햅틱을 한 곳에서 부른다. 화면마다 강도를 다르게 고르지 않게 하기 위함.
abstract final class PassqlHaptics {
  static Future<void> playSelection() => HapticFeedback.selectionClick();

  /// 가장 약한 탭 (단계 연출의 첫 칸·숫자 바뀜, #764)
  static Future<void> playLight() => HapticFeedback.lightImpact();
  static Future<void> playCorrectAnswer() => HapticFeedback.mediumImpact();
  static Future<void> playWrongAnswer() => HapticFeedback.heavyImpact();

  /// 채점 결과 > 정답·오답 햅틱 (챕터 피드백 바·결과 화면 공통)
  static Future<void> playAnswerResult({required bool isCorrect}) =>
      isCorrect ? playCorrectAnswer() : playWrongAnswer();
}
