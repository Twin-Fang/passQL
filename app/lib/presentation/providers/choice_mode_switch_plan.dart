import '../../data/models/member/choice_generation_mode.dart';

/// 풀이 중 보기 방식을 바꿨을 때 지금 문제에 하는 일 5가지 (#907)
enum ChoiceModeSwitchAction {
  /// 제출 중·제출 뒤: 채점한 보기 유지, 다음 풀이부터 새 방식
  keepUntilNextSolve,

  /// 이 문제의 검증된 보기로 바로 교체
  showReadyChoiceSet,

  /// 이 화면에서 이미 받은 AI 새 보기로 교체 (다시 생성하지 않음)
  showFreshChoiceSet,

  /// 진행 중인 생성 결과를 기다림 (생성을 겹치지 않음)
  awaitInFlightGeneration,

  /// 서버에 새로 받기 (SSE, 적용 모드는 서버가 판정)
  generateChoices;

  /// 지금 문제 보기에 바로 반영되는가 (아니면 다음 풀이부터 적용 안내)
  bool get isAppliedToCurrentQuestion => this != keepUntilNextSolve;
}

/// 보기 방식 변경 적용 판정: 제출 여부 > 이미 받은 세트 재사용 > 진행 중 생성 합류 > 새로 받기
/// [targetMode] 는 실효 모드 (무료는 검증된 보기, 서버 FeatureAccessPolicy 와 같은 규칙)
ChoiceModeSwitchAction planChoiceModeSwitch({
  required bool hasSubmissionStarted,
  required ChoiceGenerationMode targetMode,
  required bool hasReadyChoiceSet,
  required bool hasFreshChoiceSet,
  required ChoiceGenerationMode? inFlightGenerationMode,
}) {
  if (hasSubmissionStarted) return ChoiceModeSwitchAction.keepUntilNextSolve;
  final isFreshTarget = targetMode == ChoiceGenerationMode.real;
  if (!isFreshTarget && hasReadyChoiceSet) {
    return ChoiceModeSwitchAction.showReadyChoiceSet;
  }
  if (isFreshTarget && hasFreshChoiceSet) {
    return ChoiceModeSwitchAction.showFreshChoiceSet;
  }
  // 검증된 보기가 없으면 연습 모드도 AI 생성이라 진행 중인 어느 생성이든 결과를 그대로 씀
  final canJoinInFlightGeneration =
      inFlightGenerationMode != null &&
      (inFlightGenerationMode == targetMode || !isFreshTarget);
  if (canJoinInFlightGeneration) {
    return ChoiceModeSwitchAction.awaitInFlightGeneration;
  }
  return ChoiceModeSwitchAction.generateChoices;
}
