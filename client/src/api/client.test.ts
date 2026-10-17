import { afterEach, describe, expect, it, vi } from "vitest";
import { apiFetch } from "./client";
import { useAuthStore } from "../stores/authStore";

// 만료 토큰 > 401, 재발급 토큰 > 200
const EXPIRED_ACCESS_TOKEN = "access-expired";
const REISSUED_ACCESS_TOKEN = "access-reissued";
// 재발급 응답 지연 (기존 500ms 대기 재시도보다 길게)
const REISSUE_DELAY_MILLISECONDS = 700;

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), { status });
}

describe("access token 재발급 단일 비행 (#516)", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    useAuthStore.getState().clearTokens();
  });

  it("동시 401 에도 재발급은 1회만 나가고 나머지는 그 결과로 재시도한다", async () => {
    useAuthStore.getState().setTokens({
      accessToken: EXPIRED_ACCESS_TOKEN,
      refreshToken: "refresh-1",
      memberUuid: "member-a",
      nickname: "회원A",
    });
    const reissueRequestBodies: string[] = [];
    vi.stubGlobal("fetch", vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
      const requestPath = new URL(String(input), "http://localhost").pathname;
      if (requestPath.endsWith("/auth/reissue")) {
        reissueRequestBodies.push(String(init?.body));
        await new Promise((resolve) => setTimeout(resolve, REISSUE_DELAY_MILLISECONDS));
        return jsonResponse(200, { accessToken: REISSUED_ACCESS_TOKEN, refreshToken: "refresh-2" });
      }
      const authorization = new Headers(init?.headers).get("Authorization");
      return authorization === `Bearer ${REISSUED_ACCESS_TOKEN}`
        ? jsonResponse(200, { path: requestPath })
        : jsonResponse(401, { errorCode: "ACCESS_TOKEN_EXPIRED" });
    }));

    const responses = await Promise.all([
      apiFetch<{ path: string }>("/members/me"),
      apiFetch<{ path: string }>("/progress"),
      apiFetch<{ path: string }>("/notifications/unread-count"),
    ]);

    expect(responses.map((response) => response.path)).toEqual([
      "/api/members/me",
      "/api/progress",
      "/api/notifications/unread-count",
    ]);
    expect(reissueRequestBodies).toEqual([JSON.stringify({ refreshToken: "refresh-1" })]);
    expect(useAuthStore.getState().refreshToken).toBe("refresh-2");
    expect(localStorage.getItem("passql_refresh_token")).toBe("refresh-2");
  });
});
