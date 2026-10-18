// 공지 상세: 중요 배지·제목·게시일·마크다운 본문(링크), 없는 공지 안내 (#529)
import { afterEach, describe, expect, it, vi } from "vitest";
import { render, screen } from "@testing-library/react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { MemoryRouter, Route, Routes } from "react-router-dom";
import NoticeDetail from "./NoticeDetail";
import NoticeList from "./NoticeList";

const NOTICE = {
  noticeUuid: "notice-1",
  title: "서버 점검 안내",
  body: "**10월 20일** 새벽 점검이 있어요.\n\n- 점검 중에는 풀이 기록이 저장되지 않아요\n- 자세히: [안내 페이지](https://passql.example/maintenance)",
  startsAt: null,
  endsAt: null,
  isActive: true,
  isImportant: true,
  publishedAt: "2026-10-18T09:00:00",
};

/** 경로별 가짜 응답 (상세 status 지정) */
function mockFetch(detailStatus: number = 200) {
  vi.stubGlobal(
    "fetch",
    vi.fn(async (input: RequestInfo | URL) => {
      const url = String(input);
      if (url.includes("/meta/notices/")) {
        return detailStatus === 200
          ? new Response(JSON.stringify(NOTICE), { status: 200 })
          : new Response(JSON.stringify({ errorCode: "APP_NOTICE_NOT_FOUND" }), { status: detailStatus });
      }
      return new Response(JSON.stringify({ notices: [NOTICE], page: 0, hasNextPage: false }), { status: 200 });
    }),
  );
}

function renderAt(path: string) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter initialEntries={[path]}>
        <Routes>
          <Route path="/notices" element={<NoticeList />} />
          <Route path="/notices/:noticeUuid" element={<NoticeDetail />} />
        </Routes>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

afterEach(() => vi.unstubAllGlobals());

describe("NoticeDetail", () => {
  it("중요 배지 > 제목 > 게시일 > 마크다운 본문과 링크", async () => {
    mockFetch();
    renderAt("/notices/notice-1");
    expect(await screen.findByRole("heading", { name: "서버 점검 안내" })).toBeInTheDocument();
    expect(screen.getByText("중요")).toBeInTheDocument();
    expect(screen.getByText("2026.10.18")).toBeInTheDocument();
    expect(screen.getByText("10월 20일").tagName).toBe("STRONG");
    expect(screen.getByRole("link", { name: "안내 페이지" })).toHaveAttribute("href", "https://passql.example/maintenance");
    expect(screen.getByRole("link", { name: "다른 공지 보기" })).toHaveAttribute("href", "/notices");
  });

  it("없는 공지면 안내 문구", async () => {
    mockFetch(404);
    renderAt("/notices/missing");
    expect(await screen.findByText("공지를 찾을 수 없어요")).toBeInTheDocument();
  });
});

describe("NoticeList", () => {
  it("행: 중요 배지, 제목, 본문 미리보기, 게시일, 상세 링크", async () => {
    mockFetch();
    renderAt("/notices");
    const row = await screen.findByRole("link", { name: /서버 점검 안내/ });
    expect(row).toHaveAttribute("href", "/notices/notice-1");
    expect(row).toHaveTextContent("10월 20일 새벽 점검이 있어요.");
    expect(row).toHaveTextContent("2026.10.18");
  });
});
