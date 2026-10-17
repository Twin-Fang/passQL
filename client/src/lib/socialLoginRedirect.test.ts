import { createHash } from "node:crypto";
import { describe, expect, it, beforeEach } from "vitest";
import {
  buildAuthorizeUrl,
  callbackUrlOf,
  clearSavedAuthorizationRequest,
  createCodeChallenge,
  isExpectedState,
  providerFromCallbackPath,
  takeSavedCodeVerifier,
} from "./socialLoginRedirect";

describe("소셜 인가 주소 (#509)", () => {
  beforeEach(() => sessionStorage.clear());

  it("카카오 인가 주소는 코드 응답·콜백·state 를 담는다", async () => {
    const url = new URL(await buildAuthorizeUrl("KAKAO", "kakao-client"));
    expect(url.origin + url.pathname).toBe("https://kauth.kakao.com/oauth/authorize");
    expect(url.searchParams.get("response_type")).toBe("code");
    expect(url.searchParams.get("client_id")).toBe("kakao-client");
    expect(url.searchParams.get("redirect_uri")).toBe(callbackUrlOf("KAKAO"));
    expect(url.searchParams.get("state")).toBeTruthy();
  });

  it("GitHub 는 공개 프로필 범위만 요청한다", async () => {
    const url = new URL(await buildAuthorizeUrl("GITHUB", "github-client"));
    expect(url.searchParams.get("scope")).toBe("read:user");
  });

  it("콜백 state 는 저장한 값과 같을 때만 통과하고 한 번 쓰면 지운다", async () => {
    const state = new URL(await buildAuthorizeUrl("NAVER", "naver-client")).searchParams.get("state");
    expect(isExpectedState("other")).toBe(false);
    await buildAuthorizeUrl("NAVER", "naver-client");
    const latestState = new URL(await buildAuthorizeUrl("NAVER", "naver-client")).searchParams.get("state");
    expect(isExpectedState(latestState)).toBe(true);
    expect(isExpectedState(latestState)).toBe(false);
    expect(state).not.toBe(latestState);
  });

  it("콜백 경로 조각은 아는 제공자만 받는다", () => {
    expect(providerFromCallbackPath("github")).toBe("GITHUB");
    expect(providerFromCallbackPath("google")).toBeNull();
    expect(providerFromCallbackPath(undefined)).toBeNull();
  });

  it("GitHub 인가는 PKCE S256 challenge 를 담고 verifier 는 콜백에서 한 번만 꺼낸다 (#516)", async () => {
    const url = new URL(await buildAuthorizeUrl("GITHUB", "github-client"));
    expect(url.searchParams.get("code_challenge_method")).toBe("S256");
    const codeVerifier = takeSavedCodeVerifier();
    expect(codeVerifier).toMatch(/^[A-Za-z0-9_-]{43}$/);
    expect(url.searchParams.get("code_challenge")).toBe(await createCodeChallenge(codeVerifier ?? ""));
    expect(takeSavedCodeVerifier()).toBeNull();
  });

  it("카카오·네이버 인가는 PKCE 를 쓰지 않는다", async () => {
    await buildAuthorizeUrl("GITHUB", "github-client");
    const url = new URL(await buildAuthorizeUrl("KAKAO", "kakao-client"));
    expect(url.searchParams.get("code_challenge")).toBeNull();
    // 이전 GitHub 요청의 verifier 가 다음 요청에 섞이지 않음
    expect(takeSavedCodeVerifier()).toBeNull();
  });

  it("code_challenge 는 base64url(SHA-256(verifier)) 와 같다", async () => {
    const codeVerifier = "dBjftJeZ4CVP-mJ92IXwHRgUzxwtNp8nW6E8xrlNM8k";
    const expectedChallenge = createHash("sha256").update(codeVerifier).digest("base64url");
    expect(await createCodeChallenge(codeVerifier)).toBe(expectedChallenge);
  });

  it("계정 정리 시 인가 대기값(state·verifier)을 모두 지운다", async () => {
    const state = new URL(await buildAuthorizeUrl("GITHUB", "github-client")).searchParams.get("state");
    clearSavedAuthorizationRequest();
    expect(takeSavedCodeVerifier()).toBeNull();
    expect(isExpectedState(state)).toBe(false);
  });
});
