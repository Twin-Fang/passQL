import { describe, expect, it } from "vitest";
import { useRecentLoginProviderStore } from "./recentLoginProviderStore";

// 최근 로그인 기록 판정 (#908): 로그인 성공 기록 > 탈퇴 삭제
describe("useRecentLoginProviderStore", () => {
  it("기록한 제공자를 돌려주고, 지우면 없음", () => {
    useRecentLoginProviderStore.getState().rememberRecentLoginProvider("NAVER");
    expect(useRecentLoginProviderStore.getState().recentLoginProvider).toBe("NAVER");

    useRecentLoginProviderStore.getState().clearRecentLoginProvider();
    expect(useRecentLoginProviderStore.getState().recentLoginProvider).toBeNull();
  });
});
