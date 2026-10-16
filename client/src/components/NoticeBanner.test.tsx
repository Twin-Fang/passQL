// 공지 배너: 안 읽은 중요 공지만 노출, 닫기 = 서버 읽음 (낙관적) (#491)
import { afterEach, describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import NoticeBanner from "./NoticeBanner";
import { useAuthStore } from "../stores/authStore";
import type { NotificationItem } from "../types/api";

function buildNotice(id: string, title: string, overrides: Partial<NotificationItem>): NotificationItem {
  return {
    id, category: "NOTICE", type: "NOTICE", title, body: `${title} 본문`, linkTarget: null,
    linkQuestionUuid: null, isRead: false, createdAt: "2026-10-16T09:00:00", isImportant: true, ...overrides,
  };
}

const NOTICES = [
  buildNotice("read-important", "읽은 중요 공지", { isRead: true }),
  buildNotice("normal", "일반 공지", { isImportant: false }),
  buildNotice("unread-important", "안 읽은 중요 공지", {}),
];

/** 경로별 가짜 응답 + 읽음 요청 기록 (readStatus: 읽음 POST 응답 코드) */
function mockFetch(readStatus: number, unreadNoticeCount: number = 2) {
  const fetchMock = vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = String(input);
    if (url.includes("/unread-count")) {
      return new Response(JSON.stringify({ general: 0, notice: unreadNoticeCount, total: unreadNoticeCount }), { status: 200 });
    }
    if (init?.method === "POST") return new Response(null, { status: readStatus });
    return new Response(JSON.stringify({ items: NOTICES, nextCursor: null }), { status: 200 });
  });
  vi.stubGlobal("fetch", fetchMock);
  return fetchMock;
}

function renderBanner() {
  useAuthStore.setState({ accessToken: "token", memberUuid: "member-1" });
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <NoticeBanner />
    </QueryClientProvider>,
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
  useAuthStore.setState({ accessToken: null, memberUuid: null });
});

describe("NoticeBanner", () => {
  it("안 읽은 중요 공지만 노출, 클릭 > 본문 모달", async () => {
    mockFetch(204);
    renderBanner();
    fireEvent.click(await screen.findByText("안 읽은 중요 공지"));
    expect(screen.getByRole("dialog")).toHaveTextContent("안 읽은 중요 공지 본문");
    expect(screen.queryByText("읽은 중요 공지")).not.toBeInTheDocument();
    expect(screen.queryByText("일반 공지")).not.toBeInTheDocument();
  });

  it("닫기 > 공지 읽음 POST 후 숨김", async () => {
    const fetchMock = mockFetch(204);
    renderBanner();
    fireEvent.click(await screen.findByRole("button", { name: "공지 닫기" }));
    expect(screen.queryByText("안 읽은 중요 공지")).not.toBeInTheDocument();
    await waitFor(() => {
      const readCall = fetchMock.mock.calls.find(([, init]) => init?.method === "POST");
      expect(String(readCall?.[0])).toContain("/members/me/notifications/unread-important/read?category=NOTICE");
    });
  });

  it("읽음 요청 실패해도 배너는 닫힘", async () => {
    mockFetch(500);
    renderBanner();
    fireEvent.click(await screen.findByRole("button", { name: "공지 닫기" }));
    expect(screen.queryByText("안 읽은 중요 공지")).not.toBeInTheDocument();
  });

  it("안 읽은 공지 0건이면 목록 조회 없이 숨김", async () => {
    const fetchMock = mockFetch(204, 0);
    renderBanner();
    await waitFor(() => expect(fetchMock).toHaveBeenCalled());
    expect(screen.queryByRole("region", { name: "공지" })).not.toBeInTheDocument();
    expect(fetchMock.mock.calls.some(([url]) => !String(url).includes("/unread-count"))).toBe(false);
  });
});
