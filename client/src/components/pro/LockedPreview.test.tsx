// 잠금 미리보기·사유 화면·등급 칩 (#578): 가운데 한 줄 + 알약 > 앱 안내 창, 결제 꺼짐이면 칩 없음
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import type { ReactElement } from "react";
import LockedPreview from "./LockedPreview";
import PlanChip from "./PlanChip";
import ProAccessReasonView from "./ProAccessReasonView";
import { ExplanationLockedSample } from "./lockedPreviewSamples";
import { useAuthStore } from "../../stores/authStore";
import { stubApiResponses } from "../../test/renderPageForSmokeTest";

function renderWithQueryClient(element: ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(<QueryClientProvider client={queryClient}>{element}</QueryClientProvider>);
}

function buildPlanResponse(isBillingEnabled: boolean, plan: "FREE" | "PRO") {
  return {
    isBillingEnabled,
    plan,
    proExpiresAt: null,
    todayRandomSolvedCount: 0,
    dailyFreeLimit: 10,
    purchasableUntil: null,
    lastPurchasedAt: null,
    lastOrderId: null,
    passOptions: [],
  };
}

describe("LockedPreview", () => {
  afterEach(() => vi.unstubAllGlobals());

  it("가짜 미리보기는 읽기에서 빼고, 알약을 누르면 앱 이용권 안내 창을 연다", () => {
    stubApiResponses({});
    renderWithQueryClient(<LockedPreview preview={<ExplanationLockedSample />} caption="보기별 해설 · 함정 · 시험 팁" />);

    expect(screen.getByRole("region", { name: "보기별 해설 · 함정 · 시험 팁" })).toBeInTheDocument();
    // 흐린 가짜 내용은 화면 낭독·포커스 대상 아님
    expect(screen.getByText("정답 근거").closest('[aria-hidden="true"]')).not.toBeNull();

    fireEvent.click(screen.getByRole("button", { name: "앱에서 이용권으로 열기" }));
    const dialog = screen.getByRole("dialog");
    expect(dialog).toHaveTextContent("passQL 앱에서 이용권(1개월·3개월)을 구매하면 웹에서도 같은 계정으로 열려요.");
    // 관리자 링크가 없으면 고정 App Store 주소, Play 비공개 중이면 준비 중 표시
    expect(screen.getByRole("link")).toHaveAttribute("href", "https://apps.apple.com/kr/app/id6762165005");
    expect(screen.getByRole("img", { name: "Android 출시 준비 중" })).toBeInTheDocument();

    fireEvent.click(screen.getByRole("button", { name: "닫기" }));
    expect(screen.queryByRole("dialog")).toBeNull();
  });
});

describe("ProAccessReasonView", () => {
  it("무료 하루 한도: 사유 + 다시 열리는 때 + 앱 안내 버튼", () => {
    renderWithQueryClient(<ProAccessReasonView errorCode="FREE_DAILY_LIMIT_REACHED" />);
    expect(screen.getByText("오늘 무료 10문제를 다 풀었어요")).toBeInTheDocument();
    expect(screen.getByText("내일 0시에 10문제가 다시 열려요")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "앱에서 이용권으로 열기" })).toBeInTheDocument();
  });

  it("공정 사용 한도는 프로 몫이라 버튼 없음", () => {
    renderWithQueryClient(<ProAccessReasonView errorCode="FAIR_USE_DAILY_LIMIT_REACHED" />);
    expect(screen.getByText("오늘 풀 수 있는 문제를 모두 풀었어요")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "앱에서 이용권으로 열기" })).toBeNull();
  });
});

describe("PlanChip", () => {
  beforeEach(() => useAuthStore.setState({ accessToken: "test-access-token", memberUuid: "m1" }));
  afterEach(() => vi.unstubAllGlobals());

  it("결제 켜짐 + 무료면 FREE 칩, 누르면 앱 안내", async () => {
    stubApiResponses({ "/members/me/plan": buildPlanResponse(true, "FREE") });
    renderWithQueryClient(<PlanChip />);
    fireEvent.click(await screen.findByRole("button", { name: "FREE" }));
    expect(screen.getByRole("dialog")).toBeInTheDocument();
  });

  it("결제 켜짐 + 프로면 PRO 칩 (누를 수 없음)", async () => {
    stubApiResponses({ "/members/me/plan": buildPlanResponse(true, "PRO") });
    renderWithQueryClient(<PlanChip />);
    expect(await screen.findByText("PRO")).toBeInTheDocument();
    expect(screen.queryByRole("button", { name: "PRO" })).toBeNull();
  });

  it("결제 꺼짐이면 칩 없음", async () => {
    const fetchMock = vi.fn(async () => new Response(JSON.stringify(buildPlanResponse(false, "PRO")), { status: 200 }));
    vi.stubGlobal("fetch", fetchMock);
    const { container } = renderWithQueryClient(<PlanChip />);
    await waitFor(() => expect(fetchMock).toHaveBeenCalled());
    expect(container).toBeEmptyDOMElement();
  });
});
