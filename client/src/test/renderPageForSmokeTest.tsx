// 페이지 렌더 스모크 테스트 공통: 가짜 API 응답 + 메모리 라우터 + React Query
import type { ReactElement } from "react";
import { vi } from "vitest";
import { render } from "@testing-library/react";
import { createMemoryRouter, RouterProvider } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

/** API 경로(/api 뒤, 쿼리 제외) > 응답 본문. 목록에 없는 경로는 404 */
export function stubApiResponses(responseBodyByApiPath: Readonly<Record<string, unknown>>) {
  vi.stubGlobal("fetch", vi.fn(async (input: RequestInfo | URL) => {
    const requestPath = new URL(String(input), "http://localhost").pathname;
    const apiPath = requestPath.replace(/^.*?\/api(?=\/)/, "");
    if (apiPath in responseBodyByApiPath) {
      return new Response(JSON.stringify(responseBodyByApiPath[apiPath]), { status: 200 });
    }
    return new Response(JSON.stringify({ message: "not stubbed" }), { status: 404 });
  }));
}

interface RenderPageOptions {
  readonly routePath: string;
  readonly initialPath: string;
  readonly initialState?: unknown;
}

/** 페이지 1개 > 데이터 라우터(useBlocker 지원) 안에서 렌더 */
export function renderPageForSmokeTest(pageElement: ReactElement, { routePath, initialPath, initialState }: RenderPageOptions) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  const router = createMemoryRouter(
    [
      { path: routePath, element: pageElement },
      { path: "*", element: <p>다른 화면</p> },
    ],
    { initialEntries: [{ pathname: initialPath, state: initialState }] },
  );
  const renderResult = render(
    <QueryClientProvider client={queryClient}>
      <RouterProvider router={router} />
    </QueryClientProvider>,
  );
  return { ...renderResult, router };
}
