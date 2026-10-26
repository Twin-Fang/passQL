// 사업자 정보 표기: app-config businessInfo 표시, 빈 값 줄·조회 실패 숨김 (#658)
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import BusinessInfoNotice from "./BusinessInfoNotice";

/** app-config 가짜 응답 (status: 응답 코드) */
function mockAppConfigResponse(body: unknown, status: number = 200) {
  vi.stubGlobal("fetch", vi.fn(async () => new Response(JSON.stringify(body), { status })));
}

function renderNotice() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <BusinessInfoNotice />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("BusinessInfoNotice", () => {
  it("상호·대표자·사업자등록번호·문의 표시, 빈 신고번호 줄 숨김", async () => {
    mockAppConfigResponse({
      businessInfo: {
        companyName: "콜리랩(KOLLYLAB)", representativeName: "서새찬", registrationNumber: "331-37-01670",
        contactEmail: "chan4760@naver.com", mailOrderSalesNumber: null,
      },
    });
    renderNotice();

    expect(await screen.findByText("콜리랩(KOLLYLAB)")).toBeInTheDocument();
    expect(screen.getByText("331-37-01670")).toBeInTheDocument();
    expect(screen.getByText("chan4760@naver.com")).toBeInTheDocument();
    expect(screen.queryByText(/통신판매업/)).not.toBeInTheDocument();
  });

  it("구버전 서버(businessInfo 없음)면 렌더하지 않음", async () => {
    mockAppConfigResponse({ notices: [] });
    const { container } = renderNotice();

    await vi.waitFor(() => expect(fetch).toHaveBeenCalled());
    expect(container).toBeEmptyDOMElement();
  });
});
