import { apiFetch } from "./client";
import type {
  AuthorizationCodeLoginRequest,
  LoginRequest,
  LoginResponse,
  ReissueRequest,
  ReissueResponse,
  SocialLoginClientConfig,
} from "../types/api";

export function login(req: LoginRequest): Promise<LoginResponse> {
  return apiFetch<LoginResponse>("/auth/login", {
    method: "POST",
    body: JSON.stringify(req),
  });
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
