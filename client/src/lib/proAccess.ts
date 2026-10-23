import { ApiError } from "../api/client";
import {
  FAIR_USE_DAILY_LIMIT_REASON,
  FAIR_USE_LIMIT_RESET_NOTICE,
  FREE_DAILY_LIMIT_REASON,
  FREE_DAILY_LIMIT_RESET_NOTICE,
  PRO_REQUIRED_REASON,
} from "../constants/proAccessCopy";
import type { ApiErrorCode, MemberPlanResponse } from "../types/api";

/**
 * 무료/프로 판정 공통 (#578): 등급 > 잠금 UI 여부, 오류 > 사유, lockedSections > 잠긴 묶음
 * 판정 원본은 서버 (결제 꺼짐이면 서버가 잠그지 않음 > 웹도 아무것도 그리지 않음)
 */

// 등급 응답 plan 값 (계약은 string)
const PLAN_FREE = "FREE";
const PLAN_PRO = "PRO";

// 서버 프로 접근 오류 3종 (계약 ErrorCode 에서 좁힘 > 서버가 이름을 바꾸면 tsc 실패)
export type ProAccessErrorCode = Extract<
  ApiErrorCode,
  "PRO_REQUIRED" | "FREE_DAILY_LIMIT_REACHED" | "FAIR_USE_DAILY_LIMIT_REACHED"
>;
const PRO_ACCESS_ERROR_CODES: ReadonlySet<string> = new Set<ProAccessErrorCode>([
  "PRO_REQUIRED",
  "FREE_DAILY_LIMIT_REACHED",
  "FAIR_USE_DAILY_LIMIT_REACHED",
]);

// 응답 lockedSections 값: 정답 근거·핵심 개념·헷갈리는 지점·보기별·시험 팁 (제출·해설 응답)
// EXECUTION_RESULT(제출 실행 결과)는 웹이 제출 결과 표를 그리지 않아 미사용
export const LOCKED_SECTION_FULL_EXPLANATION = "FULL_EXPLANATION";

/** 잠금 UI 를 그릴지: 결제 켜짐 + 무료 (등급 모름·결제 꺼짐·프로는 false) */
export function shouldShowProUiForPlan(plan: MemberPlanResponse | undefined): boolean {
  return !!plan && plan.isBillingEnabled && plan.plan === PLAN_FREE;
}

/** PRO 칩을 그릴지: 결제 켜짐 + 프로 */
export function shouldShowProBadgeForPlan(plan: MemberPlanResponse | undefined): boolean {
  return !!plan && plan.isBillingEnabled && plan.plan === PLAN_PRO;
}

/** 오류 > 프로 접근 오류 코드 (그 외 오류는 null) */
export function toProAccessErrorCode(error: unknown): ProAccessErrorCode | null {
  if (!(error instanceof ApiError)) return null;
  const errorCode = (error.body as { errorCode?: unknown } | null)?.errorCode;
  return typeof errorCode === "string" && PRO_ACCESS_ERROR_CODES.has(errorCode)
    ? (errorCode as ProAccessErrorCode)
    : null;
}

export interface ProAccessReason {
  readonly title: string;
  // 다시 열리는 때 (프로 필요는 없음)
  readonly resetNotice: string | null;
  // 이용권 안내 버튼 여부 (공정 사용 한도는 프로 사용자 몫이라 없음)
  readonly canUnlockWithPass: boolean;
}

/** 프로 접근 오류 코드 > 사유 화면 문구 */
export function toProAccessReason(errorCode: ProAccessErrorCode): ProAccessReason {
  switch (errorCode) {
    case "FREE_DAILY_LIMIT_REACHED":
      return { title: FREE_DAILY_LIMIT_REASON, resetNotice: FREE_DAILY_LIMIT_RESET_NOTICE, canUnlockWithPass: true };
    case "FAIR_USE_DAILY_LIMIT_REACHED":
      return { title: FAIR_USE_DAILY_LIMIT_REASON, resetNotice: FAIR_USE_LIMIT_RESET_NOTICE, canUnlockWithPass: false };
    case "PRO_REQUIRED":
      return { title: PRO_REQUIRED_REASON, resetNotice: null, canUnlockWithPass: true };
  }
}

/** 해설 묶음이 잠겼는지 (제출·해설 응답 공통) */
export function isFullExplanationLocked(lockedSections: readonly string[] | undefined): boolean {
  return lockedSections?.includes(LOCKED_SECTION_FULL_EXPLANATION) ?? false;
}

