// 재발급 조율 핵심 판정 (#881): 회전된 refresh token 을 두 번 보내지 않는다 (서버는 재사용을 탈취로 보고 전 기기 세션 폐기)
import { describe, expect, it, vi } from "vitest";
import {
  createAccessTokenReissueCoordinator,
  type AccessTokenReissueCoordinator,
  type AuthTokens,
} from "./accessTokenReissueCoordinator";
import type { StoredAuthTokens } from "../stores/authStore";

/** 탭 공유 저장소 + 탭 간 잠금 + 회전하는 가짜 서버 (탭마다 coordinator 1개) */
function createBrowserWithTabs(initialTokens: StoredAuthTokens) {
  let sharedStoredTokens = initialTokens;
  let lockQueue: Promise<unknown> = Promise.resolve();
  let rotationCount = 0;
  const sentRefreshTokens: string[] = [];

  const requestRotatedTokens = vi.fn(async (refreshToken: string): Promise<AuthTokens> => {
    sentRefreshTokens.push(refreshToken);
    await Promise.resolve();
    rotationCount += 1;
    return { accessToken: `access-${rotationCount}`, refreshToken: `refresh-${rotationCount}` };
  });

  const openTab = (): AccessTokenReissueCoordinator =>
    createAccessTokenReissueCoordinator({
      readLatestStoredTokens: () => sharedStoredTokens,
      requestRotatedTokens,
      saveRotatedTokens: (rotatedTokens) => {
        sharedStoredTokens = rotatedTokens;
      },
      // Web Locks 대역: 같은 이름 잠금을 순서대로 실행
      runExclusivelyAcrossTabs: <T,>(task: () => Promise<T>): Promise<T> => {
        const taskResult = lockQueue.then(task);
        lockQueue = taskResult.catch(() => undefined);
        return taskResult;
      },
    });

  return {
    openTab,
    requestRotatedTokens,
    sentRefreshTokens,
    signOutInStorage: () => {
      sharedStoredTokens = { accessToken: null, refreshToken: null };
    },
  };
}

describe("access token 재발급 조율", () => {
  it("같은 탭 동시 401 은 재발급 1회를 공유한다", async () => {
    const browser = createBrowserWithTabs({ accessToken: "access-0", refreshToken: "refresh-0" });
    const tab = browser.openTab();

    const outcomes = await Promise.all([tab.resolveAccessToken("access-0"), tab.resolveAccessToken("access-0")]);

    expect(browser.requestRotatedTokens).toHaveBeenCalledTimes(1);
    expect(outcomes.map((outcome) => outcome.kind === "signedOut" ? null : outcome.accessToken))
      .toEqual(["access-1", "access-1"]);
  });

  it("두 탭이 동시에 만료돼도 옛 refresh token 은 한 번만 보낸다", async () => {
    const browser = createBrowserWithTabs({ accessToken: "access-0", refreshToken: "refresh-0" });
    const firstTab = browser.openTab();
    const secondTab = browser.openTab();

    const [firstOutcome, secondOutcome] = await Promise.all([
      firstTab.resolveAccessToken("access-0"),
      secondTab.resolveAccessToken("access-0"),
    ]);

    expect(browser.sentRefreshTokens).toEqual(["refresh-0"]);
    expect(firstOutcome).toEqual({ kind: "reissued", accessToken: "access-1" });
    expect(secondOutcome).toEqual({ kind: "reusedLatest", accessToken: "access-1" });
  });

  it("다른 탭이 로그아웃했으면 재발급하지 않고 로그아웃 결과를 준다", async () => {
    const browser = createBrowserWithTabs({ accessToken: "access-0", refreshToken: "refresh-0" });
    const tab = browser.openTab();
    browser.signOutInStorage();

    await expect(tab.resolveAccessToken("access-0")).resolves.toEqual({ kind: "signedOut" });
    expect(browser.requestRotatedTokens).not.toHaveBeenCalled();
  });

  it("재발급 실패는 그대로 전달하고 다음 401 에서 다시 시도한다", async () => {
    const browser = createBrowserWithTabs({ accessToken: "access-0", refreshToken: "refresh-0" });
    const tab = browser.openTab();
    browser.requestRotatedTokens.mockRejectedValueOnce(new TypeError("Failed to fetch"));

    await expect(tab.resolveAccessToken("access-0")).rejects.toThrow("Failed to fetch");
    await expect(tab.resolveAccessToken("access-0")).resolves.toEqual({ kind: "reissued", accessToken: "access-1" });
  });
});
