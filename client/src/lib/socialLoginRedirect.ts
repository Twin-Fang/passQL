import type { AuthorizationCodeProvider } from "../api/auth";

// 인가 요청 때 만든 state 저장 키 (콜백에서 위조 요청 차단용 비교)
const STATE_STORAGE_KEY = "passql.socialLogin.state";

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

/** state 생성·저장 > 인가 페이지 주소 */
export function buildAuthorizeUrl(provider: AuthorizationCodeProvider, clientId: string): string {
  const state = crypto.randomUUID();
  sessionStorage.setItem(STATE_STORAGE_KEY, state);
  const params = new URLSearchParams({
    response_type: "code",
    client_id: clientId,
    redirect_uri: callbackUrlOf(provider),
    state,
  });
  // GitHub 는 공개 프로필만 읽는다
  if (provider === "GITHUB") params.set("scope", "read:user");
  return `${AUTHORIZE_URL[provider]}?${params.toString()}`;
}

/** 콜백 state 가 인가 때 저장한 값과 같은지 (한 번 쓰면 지움) */
export function isExpectedState(returnedState: string | null): boolean {
  const savedState = sessionStorage.getItem(STATE_STORAGE_KEY);
  sessionStorage.removeItem(STATE_STORAGE_KEY);
  return savedState !== null && savedState === returnedState;
}
