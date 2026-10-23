// 내 등급 훅 (#578): 결제 켜짐 + 무료만 잠금 UI, 결제 꺼짐·로그아웃·조회 실패면 등급 모름
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { renderHook, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { useMemberPlan } from "./useMemberPlan";
import { useAuthStore } from "../stores/authStore";
import { apiErrorResponse, stubApiResponses } from "../test/renderPageForSmokeTest";

function renderMemberPlanHook() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const wrapper = ({ children }: { readonly children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
  return renderHook(() => useMemberPlan(), { wrapper });
}

function buildPlanResponse(isBillingEnabled: boolean, plan: "FREE" | "PRO") {
  return {
    isBillingEnabled,
    plan,
    proExpiresAt: null,
    todayRandomSolvedCount: 3,
    dailyFreeLimit: 10,
    purchasableUntil: null,
    lastPurchasedAt: null,
    lastOrderId: null,
    passOptions: [],
  };
}

describe("useMemberPlan", () => {
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1" }));
  afterEach(() => {
    vi.unstubAllGlobals();
    useAuthStore.setState({ accessToken: null, memberUuid: null });
  });

  it("결제 켜짐 + 무료 > 잠금 UI", async () => {
    stubApiResponses({ "/members/me/plan": buildPlanResponse(true, "FREE") });
    const { result } = renderMemberPlanHook();
    await waitFor(() => expect(result.current.plan).toBeDefined());
    expect(result.current.shouldShowProUi).toBe(true);
    expect(result.current.shouldShowProBadge).toBe(false);
  });

  it("결제 꺼짐 > 잠금 UI·칩 없음", async () => {
    stubApiResponses({ "/members/me/plan": buildPlanResponse(false, "PRO") });
    const { result } = renderMemberPlanHook();
    await waitFor(() => expect(result.current.plan).toBeDefined());
    expect(result.current.shouldShowProUi).toBe(false);
    expect(result.current.shouldShowProBadge).toBe(false);
  });

  it("조회 실패 > 등급 모름 (잠그지 않음)", async () => {
    const fetchMock = vi.fn(async () => new Response(JSON.stringify({ message: "실패" }), { status: 500 }));
    vi.stubGlobal("fetch", fetchMock);
    const { result } = renderMemberPlanHook();
    await waitFor(() => expect(fetchMock).toHaveBeenCalled());
    expect(result.current.shouldShowProUi).toBe(false);
  });

  it("로그아웃 상태면 조회하지 않음", () => {
    useAuthStore.setState({ accessToken: null, memberUuid: null });
    stubApiResponses({ "/members/me/plan": apiErrorResponse(401, {}) });
    const { result } = renderMemberPlanHook();
    expect(fetch).not.toHaveBeenCalled();
    expect(result.current.shouldShowProUi).toBe(false);
  });
});
