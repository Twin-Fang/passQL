import type { ChoiceGenerationMode } from "../types/api";

// 풀이 중 보기 방식 변경 시 지금 문제에 하는 일 5가지 (#913, 앱 choice_mode_switch_plan.dart 와 같은 판정)
export type ChoiceModeSwitchAction =
  | "KEEP_UNTIL_NEXT_SOLVE" // 제출 중·뒤: 채점한 보기 유지 > 다음 풀이부터
  | "SHOW_READY_CHOICE_SET" // 이 문제의 검증된 보기로 바로 교체
  | "SHOW_FRESH_CHOICE_SET" // 이미 받은 AI 새 보기로 교체 (다시 생성하지 않음)
  | "AWAIT_IN_FLIGHT_GENERATION" // 진행 중인 생성 결과를 기다림 (겹쳐 생성하지 않음)
  | "GENERATE_CHOICES"; // 서버에 새로 받기 (SSE, 적용 모드는 서버가 판정)

// 매번 AI 가 새로 만드는 모드 (서버 REAL)
export const FRESH_CHOICE_MODE: ChoiceGenerationMode = "REAL";
// 검증된 보기를 먼저 쓰는 모드 (서버 PRACTICE)
export const VERIFIED_CHOICE_MODE: ChoiceGenerationMode = "PRACTICE";

export interface ChoiceModeSwitchInput {
  readonly hasSubmissionStarted: boolean;
  // 실효 모드 (무료는 검증된 보기, 서버 FeatureAccessPolicy 와 같은 규칙)
  readonly targetMode: ChoiceGenerationMode;
  readonly hasReadyChoiceSet: boolean;
  readonly hasFreshChoiceSet: boolean;
  // 진행 중인 생성의 모드 (없으면 null)
  readonly inFlightGenerationMode: ChoiceGenerationMode | null;
}

/** 보기 방식 변경 적용 판정: 제출 여부 > 이미 받은 세트 재사용 > 진행 중 생성 합류 > 새로 받기 */
export function planChoiceModeSwitch({
  hasSubmissionStarted,
  targetMode,
  hasReadyChoiceSet,
  hasFreshChoiceSet,
  inFlightGenerationMode,
}: ChoiceModeSwitchInput): ChoiceModeSwitchAction {
  if (hasSubmissionStarted) return "KEEP_UNTIL_NEXT_SOLVE";
  const isFreshTarget = targetMode === FRESH_CHOICE_MODE;
  if (!isFreshTarget && hasReadyChoiceSet) return "SHOW_READY_CHOICE_SET";
  if (isFreshTarget && hasFreshChoiceSet) return "SHOW_FRESH_CHOICE_SET";
  // 검증된 보기가 없으면 검증된 보기 모드도 AI 생성이라 진행 중인 어느 생성이든 결과를 그대로 씀
  const canJoinInFlightGeneration =
    inFlightGenerationMode !== null && (inFlightGenerationMode === targetMode || !isFreshTarget);
  if (canJoinInFlightGeneration) return "AWAIT_IN_FLIGHT_GENERATION";
  return "GENERATE_CHOICES";
}

/** 지금 문제 보기에 바로 반영되는가 (아니면 다음 풀이부터 적용 안내) */
export function isAppliedToCurrentQuestion(action: ChoiceModeSwitchAction): boolean {
  return action !== "KEEP_UNTIL_NEXT_SOLVE";
}

/** 저장된 모드 > 실효 모드: 무료(결제 켜짐)는 저장값과 무관하게 검증된 보기 (서버 FeatureAccessPolicy 보정과 같은 규칙) */
export function toEffectiveChoiceMode(
  storedMode: ChoiceGenerationMode,
  shouldShowProUi: boolean,
): ChoiceGenerationMode {
  return shouldShowProUi ? VERIFIED_CHOICE_MODE : storedMode;
}
