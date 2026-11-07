import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/presentation/providers/choice_mode_switch_plan.dart';

// 보기 방식 변경 적용 판정 (#907): 제출 전 지금 문제 반영 / 제출 뒤 다음 풀이부터, 생성 겹침 방지
void main() {
  ChoiceModeSwitchAction planOf({
    bool hasSubmissionStarted = false,
    required ChoiceGenerationMode targetMode,
    bool hasReadyChoiceSet = true,
    bool hasFreshChoiceSet = false,
    ChoiceGenerationMode? inFlightGenerationMode,
  }) => planChoiceModeSwitch(
    hasSubmissionStarted: hasSubmissionStarted,
    targetMode: targetMode,
    hasReadyChoiceSet: hasReadyChoiceSet,
    hasFreshChoiceSet: hasFreshChoiceSet,
    inFlightGenerationMode: inFlightGenerationMode,
  );

  test('제출 중·뒤면 어느 방식이든 채점한 보기 유지, 다음 풀이부터', () {
    for (final targetMode in ChoiceGenerationMode.values) {
      final action = planOf(hasSubmissionStarted: true, targetMode: targetMode);
      expect(action, ChoiceModeSwitchAction.keepUntilNextSolve);
      expect(action.isAppliedToCurrentQuestion, isFalse);
    }
  });

  test('제출 전 AI 새 보기: 처음이면 생성, 받아 둔 새 보기가 있으면 재사용', () {
    expect(
      planOf(targetMode: ChoiceGenerationMode.real),
      ChoiceModeSwitchAction.generateChoices,
    );
    expect(
      planOf(targetMode: ChoiceGenerationMode.real, hasFreshChoiceSet: true),
      ChoiceModeSwitchAction.showFreshChoiceSet,
    );
  });

  test('제출 전 검증된 보기: 이 문제 검증 세트로 바로 교체 (진행 중 생성이 있어도)', () {
    expect(
      planOf(
        targetMode: ChoiceGenerationMode.practice,
        inFlightGenerationMode: ChoiceGenerationMode.real,
      ),
      ChoiceModeSwitchAction.showReadyChoiceSet,
    );
  });

  test('새 보기 생성 중 다시 새 보기로 오면 겹쳐 생성하지 않고 기다림', () {
    expect(
      planOf(
        targetMode: ChoiceGenerationMode.real,
        inFlightGenerationMode: ChoiceGenerationMode.real,
      ),
      ChoiceModeSwitchAction.awaitInFlightGeneration,
    );
  });

  test('검증 세트 없는 문제: 연습 모드는 진행 중 생성을 기다리고, 새 보기는 연습 생성에 합류하지 않음', () {
    expect(
      planOf(
        targetMode: ChoiceGenerationMode.practice,
        hasReadyChoiceSet: false,
        inFlightGenerationMode: ChoiceGenerationMode.real,
      ),
      ChoiceModeSwitchAction.awaitInFlightGeneration,
    );
    expect(
      planOf(
        targetMode: ChoiceGenerationMode.real,
        hasReadyChoiceSet: false,
        inFlightGenerationMode: ChoiceGenerationMode.practice,
      ),
      ChoiceModeSwitchAction.generateChoices,
    );
  });
}
