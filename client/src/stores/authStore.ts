import { create } from "zustand";

const ACCESS_TOKEN_KEY = "passql_access_token";
const REFRESH_TOKEN_KEY = "passql_refresh_token";
const MEMBER_UUID_KEY = "passql_member_uuid";
const NICKNAME_KEY = "passql_nickname";

interface AuthState {
  readonly accessToken: string | null;
  readonly refreshToken: string | null;
  readonly memberUuid: string | null;
  readonly nickname: string | null;
  // 토큰 갱신 중 중복 호출 방지
  isRefreshing: boolean;
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
}

export const useAuthStore = create<AuthState & AuthActions>()((set) => ({
  accessToken: localStorage.getItem(ACCESS_TOKEN_KEY),
  refreshToken: localStorage.getItem(REFRESH_TOKEN_KEY),
  memberUuid: localStorage.getItem(MEMBER_UUID_KEY),
  nickname: localStorage.getItem(NICKNAME_KEY),
  isRefreshing: false,

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
}));

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
