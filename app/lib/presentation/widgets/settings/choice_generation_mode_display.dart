import '../../../data/models/member/choice_generation_mode.dart';

/// 선택지 생성 방식의 화면 문구 단일 원본: 짧은 이름(연습/실전) + 한 줄 설명
/// 설정 ChoiceModeTile 과 문제 탭 ChoiceModeShortcutRow 가 함께 사용
extension ChoiceGenerationModeDisplay on ChoiceGenerationMode {
  /// 짧은 이름
  String get shortName => switch (this) {
    ChoiceGenerationMode.practice => '연습',
    ChoiceGenerationMode.real => '실전',
  };

  /// 한 줄 설명 (스위치 옆에서 두 줄로 끊기지 않게 짧게)
  String get description => switch (this) {
    ChoiceGenerationMode.practice => '검증된 선택지를 먼저 써요',
    ChoiceGenerationMode.real => '매번 AI가 새 선택지를 만들어요',
  };
}
