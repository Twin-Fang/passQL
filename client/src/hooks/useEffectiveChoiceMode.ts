import { toEffectiveChoiceMode } from "../lib/choiceModeSwitchPlan";
import type { ChoiceGenerationMode } from "../types/api";
import { useMember } from "./useMember";
import { useMemberPlan } from "./useMemberPlan";
import { useMemberQueryScope } from "./useMemberQueryScope";

/**
 * 실제로 적용되는 보기 방식 (#913): 회원 저장값 + 무료(결제 켜짐)면 검증된 보기 (판정 원본은 서버 FeatureAccessPolicy)
 * effectiveMode null = 모름 (불러오는 중·실패·비로그인) > 칩 숨김, 선택지 준비는 검증된 보기
 */
export function useEffectiveChoiceMode() {
  const { isMemberQueryEnabled } = useMemberQueryScope();
  const memberQuery = useMember();
  const { shouldShowProUi } = useMemberPlan();
  const storedMode: ChoiceGenerationMode | null = memberQuery.data?.choiceGenerationMode ?? null;
  return {
    effectiveMode: storedMode ? toEffectiveChoiceMode(storedMode, shouldShowProUi) : null,
    // 선택지 준비를 시작해도 되는지 (응답 또는 실패로 끝남, 조회 불가 포함)
    isModeSettled: !isMemberQueryEnabled || memberQuery.isSuccess || memberQuery.isError,
    shouldShowProUi,
  };
}
