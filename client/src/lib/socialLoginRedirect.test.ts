import { describe, expect, it, beforeEach } from "vitest";
import { buildAuthorizeUrl, callbackUrlOf, isExpectedState, providerFromCallbackPath } from "./socialLoginRedirect";

describe("소셜 인가 주소 (#509)", () => {
  beforeEach(() => sessionStorage.clear());

  it("카카오 인가 주소는 코드 응답·콜백·state 를 담는다", () => {
    const url = new URL(buildAuthorizeUrl("KAKAO", "kakao-client"));
    expect(url.origin + url.pathname).toBe("https://kauth.kakao.com/oauth/authorize");
    expect(url.searchParams.get("response_type")).toBe("code");
    expect(url.searchParams.get("client_id")).toBe("kakao-client");
    expect(url.searchParams.get("redirect_uri")).toBe(callbackUrlOf("KAKAO"));
    expect(url.searchParams.get("state")).toBeTruthy();
  });

  it("GitHub 는 공개 프로필 범위만 요청한다", () => {
    const url = new URL(buildAuthorizeUrl("GITHUB", "github-client"));
    expect(url.searchParams.get("scope")).toBe("read:user");
  });

  it("콜백 state 는 저장한 값과 같을 때만 통과하고 한 번 쓰면 지운다", () => {
    const state = new URL(buildAuthorizeUrl("NAVER", "naver-client")).searchParams.get("state");
    expect(isExpectedState("other")).toBe(false);
    buildAuthorizeUrl("NAVER", "naver-client");
    const latestState = new URL(buildAuthorizeUrl("NAVER", "naver-client")).searchParams.get("state");
    expect(isExpectedState(latestState)).toBe(true);
    expect(isExpectedState(latestState)).toBe(false);
    expect(state).not.toBe(latestState);
  });

  it("콜백 경로 조각은 아는 제공자만 받는다", () => {
    expect(providerFromCallbackPath("github")).toBe("GITHUB");
    expect(providerFromCallbackPath("google")).toBeNull();
    expect(providerFromCallbackPath(undefined)).toBeNull();
  });
});
