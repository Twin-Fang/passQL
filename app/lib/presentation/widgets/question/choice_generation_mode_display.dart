import '../../../data/models/member/choice_generation_mode.dart';

/// 선택지 생성 방식의 화면 문구 단일 원본: 켜고 끄는 이름 + 모드별 짧은 이름·한 줄 설명
/// "실전"은 모의고사(#866) 이름이라 쓰지 않음 (#863). 설정 ChoiceModeTile·풀이 ChoiceModeIndicator 공용
extension ChoiceGenerationModeDisplay on ChoiceGenerationMode {
  /// 켜고 끄는 기능 이름 (켜면 real)
  static const String freshChoicesTitle = '새 보기로 풀기';

  /// 짧은 이름 (풀이 화면 표시·스크린리더). 연습 모드는 `기본 보기`: AI 새 보기보다 좋아 보이는 말을 쓰지 않음 (#971)
  String get shortName => switch (this) {
    ChoiceGenerationMode.practice => '기본 보기',
    ChoiceGenerationMode.real => 'AI 새 보기',
  };

  /// 한 줄 설명 (스위치 옆에서 두 줄로 끊기지 않게 짧게)
  String get description => switch (this) {
    ChoiceGenerationMode.practice => '늘 같은 보기로 풀어요',
    ChoiceGenerationMode.real => '풀 때마다 AI가 새 보기를 만들어요',
  };
}
