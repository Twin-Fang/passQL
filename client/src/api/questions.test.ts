import { afterEach, describe, expect, it, vi } from "vitest";
import { waitFor } from "@testing-library/react";
import { generateChoices } from "./questions";
import { useAuthStore } from "../stores/authStore";
import type { ChoiceSetGeneratedEvent, SseErrorEvent } from "../types/api";

// 만료 토큰 > 401, 재발급 토큰 > SSE 200
const EXPIRED_ACCESS_TOKEN = "access-expired";
const REISSUED_ACCESS_TOKEN = "access-reissued";
const COMPLETE_EVENT_BODY = 'event:complete\ndata:{"choiceSetId":"set-1","choices":[]}\n\n';

function jsonResponse(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), { status });
}

/** SSE 콜백 > 완료·오류 수집 */
function collectCallbacks() {
  const completedEvents: ChoiceSetGeneratedEvent[] = [];
  const errorEvents: SseErrorEvent[] = [];
  return {
    completedEvents,
    errorEvents,
    callbacks: {
      onStatus: () => {},
      onComplete: (event: ChoiceSetGeneratedEvent) => completedEvents.push(event),
      onError: (event: SseErrorEvent) => errorEvents.push(event),
    },
  };
}

/** 요청 경로·토큰 기록 fetch (재발급 성공 여부 지정) */
function stubFetch(isReissueSuccessful: boolean) {
  const generateAuthorizations: (string | null)[] = [];
  let reissueCount = 0;
  vi.stubGlobal("fetch", vi.fn(async (input: RequestInfo | URL, init?: RequestInit) => {
    const requestPath = new URL(String(input), "http://localhost").pathname;
    if (requestPath.endsWith("/auth/reissue")) {
      reissueCount += 1;
      return isReissueSuccessful
        ? jsonResponse(200, { accessToken: REISSUED_ACCESS_TOKEN, refreshToken: "refresh-2" })
        : jsonResponse(401, { errorCode: "REFRESH_TOKEN_EXPIRED" });
    }
    const authorization = new Headers(init?.headers).get("Authorization");
    generateAuthorizations.push(authorization);
    return authorization === `Bearer ${REISSUED_ACCESS_TOKEN}`
      ? new Response(COMPLETE_EVENT_BODY, { status: 200 })
      : jsonResponse(401, { errorCode: "ACCESS_TOKEN_EXPIRED" });
  }));
  return { generateAuthorizations, getReissueCount: () => reissueCount };
}

describe("선택지 생성 SSE 401 재발급", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    useAuthStore.getState().clearTokens();
  });

  it("401 이면 토큰 재발급 후 1회 재시도해 complete 를 받는다", async () => {
    useAuthStore.getState().setTokens({
      accessToken: EXPIRED_ACCESS_TOKEN,
      refreshToken: "refresh-1",
      memberUuid: "member-a",
      nickname: "회원A",
    });
    const { generateAuthorizations, getReissueCount } = stubFetch(true);
    const { completedEvents, errorEvents, callbacks } = collectCallbacks();

    generateChoices("question-1", callbacks);

    await waitFor(() => expect(completedEvents).toHaveLength(1));
    expect(completedEvents[0].choiceSetId).toBe("set-1");
    expect(errorEvents).toEqual([]);
    expect(getReissueCount()).toBe(1);
    expect(generateAuthorizations).toEqual([
      `Bearer ${EXPIRED_ACCESS_TOKEN}`,
      `Bearer ${REISSUED_ACCESS_TOKEN}`,
    ]);
    expect(useAuthStore.getState().refreshToken).toBe("refresh-2");
  });

  it("재발급 실패면 재시도 없이 401 오류를 전달한다", async () => {
    useAuthStore.getState().setTokens({
      accessToken: EXPIRED_ACCESS_TOKEN,
      refreshToken: "refresh-1",
      memberUuid: "member-a",
      nickname: "회원A",
    });
    const { generateAuthorizations } = stubFetch(false);
    const { completedEvents, errorEvents, callbacks } = collectCallbacks();

    generateChoices("question-1", callbacks);

    await waitFor(() => expect(errorEvents).toHaveLength(1));
    expect(errorEvents[0].code).toBe("HTTP_401");
    expect(completedEvents).toEqual([]);
    expect(generateAuthorizations).toHaveLength(1);
  });
});
