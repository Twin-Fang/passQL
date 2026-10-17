import type { AuthorizationCodeProvider } from "../api/auth";

// 인가 요청 때 만든 state 저장 키 (콜백에서 위조 요청 차단용 비교)
const STATE_STORAGE_KEY = "passql.socialLogin.state";
// PKCE code_verifier 저장 키 (state 와 같은 인가 요청 1건 동안만 보관)
const CODE_VERIFIER_STORAGE_KEY = "passql.socialLogin.codeVerifier";
// PKCE 지원 제공자 (카카오·네이버 웹 인가는 서버가 client secret 으로 교환)
const PKCE_PROVIDERS: ReadonlySet<AuthorizationCodeProvider> = new Set(["GITHUB"]);
// code_verifier 원본 바이트 수 (base64url 43자, RFC 7636 최소 길이)
const CODE_VERIFIER_BYTE_LENGTH = 32;

/** 제공자별 인가 페이지 주소 3개 */
const AUTHORIZE_URL: Record<AuthorizationCodeProvider, string> = {
  KAKAO: "https://kauth.kakao.com/oauth/authorize",
  NAVER: "https://nid.naver.com/oauth2.0/authorize",
  GITHUB: "https://github.com/login/oauth/authorize",
};

/** 제공자 > 콜백 주소 ({origin}/auth/callback/{provider 소문자}), 서버 허용 목록과 같은 모양 */
export function callbackUrlOf(provider: AuthorizationCodeProvider): string {
  return `${window.location.origin}/auth/callback/${provider.toLowerCase()}`;
}

/** 콜백 경로 조각(kakao) > 제공자(KAKAO), 모르는 값은 null */
export function providerFromCallbackPath(pathProvider: string | undefined): AuthorizationCodeProvider | null {
  const upper = pathProvider?.toUpperCase();
  return upper === "KAKAO" || upper === "NAVER" || upper === "GITHUB" ? upper : null;
}

/** state(+GitHub 는 PKCE verifier) 생성·저장 > 인가 페이지 주소 */
export async function buildAuthorizeUrl(provider: AuthorizationCodeProvider, clientId: string): Promise<string> {
  const state = crypto.randomUUID();
  sessionStorage.setItem(STATE_STORAGE_KEY, state);
  sessionStorage.removeItem(CODE_VERIFIER_STORAGE_KEY);
  const params = new URLSearchParams({
    response_type: "code",
    client_id: clientId,
    redirect_uri: callbackUrlOf(provider),
    state,
  });
  // GitHub 는 공개 프로필만 읽는다
  if (provider === "GITHUB") params.set("scope", "read:user");
  // 인가 코드 탈취 시 교환 차단 (S256)
  if (PKCE_PROVIDERS.has(provider)) {
    const codeVerifier = createCodeVerifier();
    sessionStorage.setItem(CODE_VERIFIER_STORAGE_KEY, codeVerifier);
    params.set("code_challenge", await createCodeChallenge(codeVerifier));
    params.set("code_challenge_method", "S256");
  }
  return `${AUTHORIZE_URL[provider]}?${params.toString()}`;
}

/** 콜백 state 가 인가 때 저장한 값과 같은지 (한 번 쓰면 지움) */
export function isExpectedState(returnedState: string | null): boolean {
  const savedState = sessionStorage.getItem(STATE_STORAGE_KEY);
  sessionStorage.removeItem(STATE_STORAGE_KEY);
  return savedState !== null && savedState === returnedState;
}

/** 인가 때 저장한 PKCE code_verifier 꺼내기 (한 번 쓰면 지움, PKCE 미사용 제공자는 null) */
export function takeSavedCodeVerifier(): string | null {
  const codeVerifier = sessionStorage.getItem(CODE_VERIFIER_STORAGE_KEY);
  sessionStorage.removeItem(CODE_VERIFIER_STORAGE_KEY);
  return codeVerifier;
}

/** 인가 대기값(state·code_verifier) 삭제 (계정 정리 시) */
export function clearSavedAuthorizationRequest(): void {
  sessionStorage.removeItem(STATE_STORAGE_KEY);
  sessionStorage.removeItem(CODE_VERIFIER_STORAGE_KEY);
}

/** 무작위 32바이트 > base64url code_verifier */
function createCodeVerifier(): string {
  return toBase64Url(crypto.getRandomValues(new Uint8Array(CODE_VERIFIER_BYTE_LENGTH)));
}

/** code_verifier > base64url(SHA-256) code_challenge */
export async function createCodeChallenge(codeVerifier: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(codeVerifier));
  return toBase64Url(new Uint8Array(digest));
}

/** 바이트 > base64url (패딩 없음, RFC 7636) */
function toBase64Url(bytes: Uint8Array): string {
  const binary = Array.from(bytes, (byte) => String.fromCharCode(byte)).join("");
  return btoa(binary).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
