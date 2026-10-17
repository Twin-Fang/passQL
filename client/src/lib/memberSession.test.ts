import { describe, expect, it, vi } from "vitest";

// Firebase 초기화 없이 로그아웃만 확인
vi.mock("./firebase", () => ({ firebaseAuth: {} }));
vi.mock("firebase/auth", () => ({ signOut: vi.fn(async () => {}) }));

import { useAuthStore } from "../stores/authStore";
import { useDailySetStore } from "../stores/dailySetStore";
import { usePracticeStore } from "../stores/practiceStore";
import { clearMemberSession } from "./memberSession";
import { queryClient } from "./queryClient";

describe("회원 세션 정리 (#516)", () => {
  it("토큰·회원 저장값·서버 캐시·풀이 상태·인가 대기값을 모두 비운다", () => {
    useAuthStore.getState().setTokens({
      accessToken: "access-a",
      refreshToken: "refresh-a",
      memberUuid: "member-a",
      nickname: "회원A",
    });
    queryClient.setQueryData(["feedback", "my", "member-a"], { items: [{ id: 1 }] });
    useDailySetStore.getState().startSession("daily-session-a", []);
    usePracticeStore.setState({ sessionId: "practice-session-a" });
    sessionStorage.setItem("passql.socialLogin.codeVerifier", "verifier-a");

    clearMemberSession();

    expect(useAuthStore.getState().memberUuid).toBeNull();
    expect(useAuthStore.getState().nickname).toBeNull();
    for (const storageKey of ["passql_access_token", "passql_refresh_token", "passql_member_uuid", "passql_nickname"]) {
      expect(localStorage.getItem(storageKey)).toBeNull();
    }
    expect(queryClient.getQueryCache().getAll()).toHaveLength(0);
    expect(useDailySetStore.getState().sessionUuid).toBeNull();
    expect(usePracticeStore.getState().sessionId).toBeNull();
    expect(sessionStorage.getItem("passql.socialLogin.codeVerifier")).toBeNull();
  });
});
