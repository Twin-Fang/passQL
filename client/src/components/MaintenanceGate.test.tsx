// 점검 분기·503 전환 스모크 (#464)
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import MaintenanceGate from "./MaintenanceGate";
import { apiFetch } from "../api/client";
import { useMaintenanceStore } from "../stores/maintenanceStore";
import type { AppConfigResponse } from "../types/api";

/** app-config 응답 > fetch 응답 (그 외 경로는 503 점검 차단 응답) */
function mockFetchResponses(appConfig: AppConfigResponse) {
  vi.stubGlobal("fetch", vi.fn(async (input: RequestInfo | URL) => {
    const requestUrl = String(input);
    if (requestUrl.includes("/meta/app-config")) {
      return new Response(JSON.stringify(appConfig), { status: 200 });
    }
    return new Response(
      JSON.stringify({ errorCode: "SERVICE_UNDER_MAINTENANCE", message: "점검" }),
      { status: 503 },
    );
  }));
}

function renderGate() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MaintenanceGate>
        <p>앱 화면</p>
      </MaintenanceGate>
    </QueryClientProvider>,
  );
}

function buildAppConfig(isUnderMaintenance: boolean, message: string | null): AppConfigResponse {
  // 앱 전용 버전 정책 (웹 점검 판정과 무관)
  const platformVersion = { minimumVersion: "1.0.0", recommendedVersion: "1.0.0", storeUrl: "" };
  return { android: platformVersion, ios: platformVersion, maintenance: { isUnderMaintenance, message }, notices: [], isAndroidBillingEnabled: false,
    businessInfo: { companyName: null, representativeName: null, registrationNumber: null, contactEmail: null, mailOrderSalesNumber: null } };
}

afterEach(() => {
  vi.unstubAllGlobals();
  useMaintenanceStore.getState().clearMaintenanceDetectedByApi();
});

describe("MaintenanceGate", () => {
  it("점검 아님 > 앱 화면 유지", async () => {
    mockFetchResponses(buildAppConfig(false, null));
    renderGate();
    await waitFor(() => expect(fetch).toHaveBeenCalled());
    expect(screen.getByText("앱 화면")).toBeInTheDocument();
  });

  it("시작 설정 점검 중 > 관리자 문구로 점검 화면", async () => {
    mockFetchResponses(buildAppConfig(true, "오늘 2시까지 점검"));
    renderGate();
    expect(await screen.findByText("오늘 2시까지 점검")).toBeInTheDocument();
    expect(screen.queryByText("앱 화면")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: /다시 확인/ })).toBeInTheDocument();
  });

  it("설정 조회 실패 > 막지 않음", async () => {
    vi.stubGlobal("fetch", vi.fn(async () => { throw new TypeError("network"); }));
    renderGate();
    await waitFor(() => expect(fetch).toHaveBeenCalled());
    expect(screen.getByText("앱 화면")).toBeInTheDocument();
  });

  it("사용 중 API 503 SERVICE_UNDER_MAINTENANCE > 점검 화면 전환", async () => {
    mockFetchResponses(buildAppConfig(false, null));
    renderGate();
    await waitFor(() => expect(fetch).toHaveBeenCalled());
    await expect(apiFetch("/home/greeting")).rejects.toThrow();
    expect(await screen.findByText("서비스 점검 중이에요")).toBeInTheDocument();
  });
});
