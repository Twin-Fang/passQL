import { create } from "zustand";

const ACCESS_TOKEN_KEY = "passql_access_token";
const REFRESH_TOKEN_KEY = "passql_refresh_token";
const MEMBER_UUID_KEY = "passql_member_uuid";
const NICKNAME_KEY = "passql_nickname";
// 다른 탭 변경을 받아 올 저장 키 4개 (storage 이벤트 필터)
const AUTH_STORAGE_KEYS: ReadonlySet<string> = new Set([
  ACCESS_TOKEN_KEY,
  REFRESH_TOKEN_KEY,
  MEMBER_UUID_KEY,
  NICKNAME_KEY,
]);

interface AuthState {
  readonly accessToken: string | null;
  readonly refreshToken: string | null;
  readonly memberUuid: string | null;
  readonly nickname: string | null;
}

export interface StoredAuthTokens {
  readonly accessToken: string | null;
  readonly refreshToken: string | null;
}

interface AuthActions {
  setTokens: (params: {
    accessToken: string;
    refreshToken: string;
    memberUuid: string;
    nickname: string;
  }) => void;
  setAccessToken: (accessToken: string) => void;
  setRotatedTokens: (params: { accessToken: string; refreshToken: string }) => void;
  setNickname: (nickname: string) => void;
  clearTokens: () => void;
  // 저장소 최신값 > 메모리 반영 (같은 브라우저 다른 탭이 회전·로그아웃했을 수 있음)
  syncTokensFromStorage: () => StoredAuthTokens;
}

/** localStorage 의 인증 값 4개 > 상태 (탭 간 공유 원본) */
function readStoredAuthState(): AuthState {
  return {
    accessToken: localStorage.getItem(ACCESS_TOKEN_KEY),
    refreshToken: localStorage.getItem(REFRESH_TOKEN_KEY),
    memberUuid: localStorage.getItem(MEMBER_UUID_KEY),
    nickname: localStorage.getItem(NICKNAME_KEY),
  };
}

export const useAuthStore = create<AuthState & AuthActions>()((set, get) => ({
  ...readStoredAuthState(),

  setTokens: ({ accessToken, refreshToken, memberUuid, nickname }) => {
    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
    localStorage.setItem(MEMBER_UUID_KEY, memberUuid);
    localStorage.setItem(NICKNAME_KEY, nickname);
    set({ accessToken, refreshToken, memberUuid, nickname });
  },

  setAccessToken: (accessToken) => {
    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    set({ accessToken });
  },

  // 재발급 응답 토큰 2개 저장 (rotating refresh token, 회원 정보는 유지)
  setRotatedTokens: ({ accessToken, refreshToken }) => {
    localStorage.setItem(ACCESS_TOKEN_KEY, accessToken);
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken);
    set({ accessToken, refreshToken });
  },

  setNickname: (nickname) => {
    localStorage.setItem(NICKNAME_KEY, nickname);
    set({ nickname });
  },

  clearTokens: () => {
    localStorage.removeItem(ACCESS_TOKEN_KEY);
    localStorage.removeItem(REFRESH_TOKEN_KEY);
    localStorage.removeItem(MEMBER_UUID_KEY);
    localStorage.removeItem(NICKNAME_KEY);
    set({ accessToken: null, refreshToken: null, memberUuid: null, nickname: null });
  },

  syncTokensFromStorage: () => {
    const storedAuthState = readStoredAuthState();
    const currentState = get();
    const hasChanged = (Object.keys(storedAuthState) as (keyof AuthState)[])
      .some((key) => storedAuthState[key] !== currentState[key]);
    // 바뀐 게 없으면 set 생략 (구독 화면 불필요한 렌더 방지)
    if (hasChanged) set(storedAuthState);
    return { accessToken: storedAuthState.accessToken, refreshToken: storedAuthState.refreshToken };
  },
}));

/** 다른 탭 인증 값 변경 구독(storage 이벤트): 회전 토큰 반영 > 옛 refresh token 재사용 방지, 로그아웃이면 콜백 > 해제 함수 */
export function subscribeToAuthStorageChangesInOtherTabs(onSignedOutInOtherTab: () => void): () => void {
  const handleStorageChange = (event: StorageEvent) => {
    // key null 은 저장소 전체 clear()
    const isAuthStorageChange = event.key === null || AUTH_STORAGE_KEYS.has(event.key);
    if (event.storageArea !== localStorage || !isAuthStorageChange) return;

    const wasSignedIn = useAuthStore.getState().refreshToken !== null;
    const latestTokens = useAuthStore.getState().syncTokensFromStorage();
    if (wasSignedIn && latestTokens.refreshToken === null) onSignedOutInOtherTab();
  };
  window.addEventListener("storage", handleStorageChange);
  return () => window.removeEventListener("storage", handleStorageChange);
}

export function getAccessToken(): string | null {
  return useAuthStore.getState().accessToken;
}

export function getRefreshToken(): string | null {
  return useAuthStore.getState().refreshToken;
}

/** 로그인 여부 확인 */
export function isAuthenticated(): boolean {
  return !!useAuthStore.getState().accessToken;
}
