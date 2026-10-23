// 무료/프로 판정 (#578): 등급 > 잠금 UI, 오류 > 사유, lockedSections, 재시도·오류 문구 공통 지점
import { describe, expect, it } from "vitest";
import { ApiError } from "../api/client";
import { shouldRetry } from "../api/retry";
import {
  isFullExplanationLocked,
  shouldShowProBadgeForPlan,
  shouldShowProUiForPlan,
  toProAccessErrorCode,
  toProAccessReason,
} from "./proAccess";
import { toUserErrorMessage } from "./userErrorMessage";
import type { MemberPlanResponse } from "../types/api";

function buildPlan(overrides: Partial<MemberPlanResponse>): MemberPlanResponse {
  return {
    isBillingEnabled: true,
    plan: "FREE",
    proExpiresAt: null,
    todayRandomSolvedCount: 0,
    dailyFreeLimit: 10,
    purchasableUntil: null,
    lastPurchasedAt: null,
    lastOrderId: null,
    passOptions: [],
    ...overrides,
  };
}

describe("등급 > 잠금 UI", () => {
  it("결제 켜짐 + 무료만 잠금 UI, 결제 켜짐 + 프로만 PRO 칩", () => {
    expect(shouldShowProUiForPlan(buildPlan({}))).toBe(true);
    expect(shouldShowProBadgeForPlan(buildPlan({}))).toBe(false);
    expect(shouldShowProUiForPlan(buildPlan({ plan: "PRO" }))).toBe(false);
    expect(shouldShowProBadgeForPlan(buildPlan({ plan: "PRO" }))).toBe(true);
  });

  it("결제 꺼짐·등급 모름이면 아무것도 그리지 않는다", () => {
    expect(shouldShowProUiForPlan(buildPlan({ isBillingEnabled: false }))).toBe(false);
    expect(shouldShowProBadgeForPlan(buildPlan({ isBillingEnabled: false, plan: "PRO" }))).toBe(false);
    expect(shouldShowProUiForPlan(undefined)).toBe(false);
  });
});

describe("오류 > 사유", () => {
  it("프로 접근 오류 3종만 코드로 바꾸고 나머지는 null", () => {
    expect(toProAccessErrorCode(new ApiError(403, { errorCode: "PRO_REQUIRED" }))).toBe("PRO_REQUIRED");
    expect(toProAccessErrorCode(new ApiError(403, { errorCode: "FREE_DAILY_LIMIT_REACHED" }))).toBe("FREE_DAILY_LIMIT_REACHED");
    expect(toProAccessErrorCode(new ApiError(429, { errorCode: "FAIR_USE_DAILY_LIMIT_REACHED" }))).toBe(
      "FAIR_USE_DAILY_LIMIT_REACHED",
    );
    expect(toProAccessErrorCode(new ApiError(403, { errorCode: "ACCESS_DENIED" }))).toBeNull();
    expect(toProAccessErrorCode(new Error("network"))).toBeNull();
  });

  it("앱과 같은 사유 문구, 공정 사용 한도는 이용권 버튼 없음", () => {
    expect(toProAccessReason("FREE_DAILY_LIMIT_REACHED")).toEqual({
      title: "오늘 무료 10문제를 다 풀었어요",
      resetNotice: "내일 0시에 10문제가 다시 열려요",
      canUnlockWithPass: true,
    });
    expect(toProAccessReason("FAIR_USE_DAILY_LIMIT_REACHED").canUnlockWithPass).toBe(false);
    expect(toProAccessReason("PRO_REQUIRED").resetNotice).toBeNull();
  });

  it("오류 문구는 서버 옛 문구 대신 웹 사유, 재시도하지 않는다", () => {
    const proRequiredError = new ApiError(403, { errorCode: "PRO_REQUIRED", message: "회차 패스가 필요한 기능이에요" });
    expect(toUserErrorMessage(proRequiredError, "실패")).toBe("이용권이 필요한 기능이에요");
    expect(shouldRetry(0, proRequiredError)).toBe(false);
    expect(shouldRetry(0, new ApiError(404, { errorCode: "QUESTION_NOT_FOUND" }))).toBe(true);
  });
});

describe("lockedSections", () => {
  it("FULL_EXPLANATION 이 있을 때만 해설 잠김", () => {
    expect(isFullExplanationLocked(["FULL_EXPLANATION"])).toBe(true);
    expect(isFullExplanationLocked(["EXECUTION_RESULT"])).toBe(false);
    expect(isFullExplanationLocked([])).toBe(false);
    expect(isFullExplanationLocked(undefined)).toBe(false);
  });
});
