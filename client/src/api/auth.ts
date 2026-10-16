import { apiFetch } from "./client";

export type AuthProvider = "GOOGLE" | "KAKAO" | "NAVER" | "APPLE" | "GITHUB";

export interface LoginRequest {
  readonly authProvider: AuthProvider;
  readonly idToken: string;
}

export interface LoginResponse {
  readonly accessToken: string;
  readonly refreshToken: string;
  readonly isNewMember: boolean;
  readonly memberUuid: string;
  readonly nickname: string;
}

export interface ReissueRequest {
  readonly refreshToken: string;
}

export interface ReissueResponse {
  readonly accessToken: string;
  readonly refreshToken: string;
}

export function login(req: LoginRequest): Promise<LoginResponse> {
  return apiFetch<LoginResponse>("/auth/login", {
    method: "POST",
    body: JSON.stringify(req),
  });
}

/** 인가 코드 로그인 제공자 3개 (#509) */
export type AuthorizationCodeProvider = "KAKAO" | "NAVER" | "GITHUB";

export interface AuthorizationCodeLoginRequest {
  readonly authProvider: AuthorizationCodeProvider;
  readonly code: string;
  readonly redirectUri: string;
  readonly state: string | null;
}

/** 제공자 공개 설정: 사용 여부 + 공개 client ID (secret 없음) */
export interface SocialLoginClientConfig {
  readonly authProvider: AuthorizationCodeProvider;
  readonly isEnabled: boolean;
  readonly clientId: string | null;
}

export function loginWithAuthorizationCode(req: AuthorizationCodeLoginRequest): Promise<LoginResponse> {
  return apiFetch<LoginResponse>("/auth/login/code", {
    method: "POST",
    body: JSON.stringify(req),
  });
}

export function fetchSocialLoginConfig(): Promise<SocialLoginClientConfig[]> {
  return apiFetch<SocialLoginClientConfig[]>("/auth/social-config");
}

export function reissue(req: ReissueRequest): Promise<ReissueResponse> {
  return apiFetch<ReissueResponse>("/auth/reissue", {
    method: "POST",
    body: JSON.stringify(req),
  });
}

export function logout(refreshToken: string): Promise<void> {
  return apiFetch<void>("/auth/logout", {
    method: "POST",
    body: JSON.stringify({ refreshToken }),
  });
}
