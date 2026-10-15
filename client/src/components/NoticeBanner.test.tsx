// 공지 배너: 중요 우선 노출, 닫기 기록 스모크 (#464)
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import NoticeBanner from "./NoticeBanner";
import type { AppConfigResponse, AppNotice } from "../types/api";

function buildNotice(noticeUuid: string, title: string, isImportant: boolean): AppNotice {
  return { noticeUuid, title, body: `${title} 본문`, startsAt: null, endsAt: null, isActive: true, isImportant };
}

// 서버 순서 그대로 (중요 먼저)
const APP_CONFIG: AppConfigResponse = {
  maintenance: { isUnderMaintenance: false, message: null },
  notices: [buildNotice("notice-important", "중요 공지", true), buildNotice("notice-normal", "일반 공지", false)],
};

function renderBanner() {
  const queryClient = new QueryClient();
  queryClient.setQueryData(["appConfig"], APP_CONFIG);
  return render(
    <QueryClientProvider client={queryClient}>
      <NoticeBanner />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  localStorage.clear();
  vi.restoreAllMocks();
});

describe("NoticeBanner", () => {
  it("중요 공지 먼저 노출, 클릭 > 본문 모달", () => {
    renderBanner();
    fireEvent.click(screen.getByText("중요 공지"));
    expect(screen.getByRole("dialog")).toHaveTextContent("중요 공지 본문");
  });

  it("닫기 > 기록 저장, 다음 공지 노출, 다시 띄워도 안 보임", () => {
    const { unmount } = renderBanner();
    fireEvent.click(screen.getByRole("button", { name: "공지 닫기" }));
    expect(screen.getByText("일반 공지")).toBeInTheDocument();
    unmount();

    renderBanner();
    expect(screen.queryByText("중요 공지")).not.toBeInTheDocument();
    expect(screen.getByText("일반 공지")).toBeInTheDocument();
  });

  it("저장소 차단 > 오류 없이 이번 화면에서만 닫힘", () => {
    vi.spyOn(localStorage, "setItem").mockImplementation(() => { throw new Error("blocked"); });
    renderBanner();
    fireEvent.click(screen.getByRole("button", { name: "공지 닫기" }));
    expect(screen.queryByText("중요 공지")).not.toBeInTheDocument();
  });
});
