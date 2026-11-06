import { getAccessToken, useAuthStore } from "../stores/authStore";
import { reissue } from "./auth";
import { PRODUCTION_API_BASE_URL } from "../constants/siteUrls";
import { useMaintenanceStore } from "../stores/maintenanceStore";
import { clearMemberSessionAndGoToLogin } from "../lib/memberSession";
import {
  createAccessTokenReissueCoordinator,
  runWithAccessTokenReissueLock,
} from "../lib/accessTokenReissueCoordinator";
import type { ApiErrorCode } from "../types/api";

// DEV 환경에서는 Vite 프록시(/api)를 사용하고, prod 환경에서는 실제 API 서버를 기본값으로 사용
export const BASE_URL = import.meta.env.VITE_API_BASE_URL
  ?? (import.meta.env.DEV ? "/api" : PRODUCTION_API_BASE_URL);
const TIMEOUT_MS = 25_000;
const IS_DEV = import.meta.env.DEV;

// auth 관련 경로는 토큰 자동 주입 및 401 재시도에서 제외
const AUTH_PATHS = ["/auth/login", "/auth/reissue", "/auth/logout"];

// 개발 로그 라벨 > 색 토큰 (요청 브랜드, 응답 성공, 그 외 오류)
const LOG_COLOR_TOKEN_BY_LABEL: Readonly<Record<string, string>> = {
  REQ: "--color-brand",
  RES: "--color-semantic-success",
};
const LOG_ERROR_COLOR_TOKEN = "--color-semantic-error";

/** 색 토큰 이름 > 현재 값 (콘솔 %c 는 CSS 변수를 해석하지 못함) */
function readColorToken(tokenName: string): string {
  return getComputedStyle(document.documentElement).getPropertyValue(tokenName).trim();
}

function log(label: string, method: string, path: string, data?: unknown) {
  if (!IS_DEV) return;
  const colorToken = LOG_COLOR_TOKEN_BY_LABEL[label] ?? LOG_ERROR_COLOR_TOKEN;
  const style = `color:${readColorToken(colorToken)};font-weight:bold`;
  console.groupCollapsed(`%c[API ${label}] ${method} ${path}`, style);
  if (data !== undefined) console.log(data);
  console.groupEnd();
}

// 서버 점검 차단 응답: 503 + errorCode (MaintenanceModeFilter, #464)
const MAINTENANCE_HTTP_STATUS = 503;
const MAINTENANCE_ERROR_CODE = "SERVICE_UNDER_MAINTENANCE";

/** 점검 차단 응답이면 true (503 + errorCode 일치) */
export function isMaintenanceResponse(status: number, body: unknown): boolean {
  return (
    status === MAINTENANCE_HTTP_STATUS &&
    typeof body === "object" &&
    body !== null &&
    (body as { errorCode?: unknown }).errorCode === MAINTENANCE_ERROR_CODE
  );
}

/** 오류 응답 > 점검 차단이면 점검 화면 전환 (apiFetch·SSE 공통 진입점) */
export function reportMaintenanceIfDetected(status: number, body: unknown): void {
  if (isMaintenanceResponse(status, body)) {
    useMaintenanceStore.getState().markMaintenanceDetectedByApi();
  }
}

export class ApiError extends Error {
  readonly status: number;
  readonly body: unknown;

  constructor(status: number, body: unknown) {
    super(`API Error ${status}`);
    this.name = "ApiError";
    this.status = status;
    this.body = body;
  }
}

/** 오류 > 서버 errorCode 문자열 (ApiError 아님·코드 없음은 null, 오류 코드 분기 공통) */
export function toApiErrorCode(error: unknown): string | null {
  if (!(error instanceof ApiError)) return null;
  const errorCode = (error.body as { errorCode?: unknown } | null)?.errorCode;
  return typeof errorCode === "string" ? errorCode : null;
}

// 응답 해석 방식: 기본 JSON, 인증이 필요한 이미지는 blob
type ResponseKind = "json" | "blob";

async function fetchOnce<T>(
  path: string,
  options: RequestInit,
  accessToken: string | null,
  responseKind: ResponseKind,
): Promise<T> {
  const method = options.method ?? "GET";
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);

  // FormData 는 브라우저가 multipart boundary 를 붙이도록 Content-Type 을 비움
  const isFormData = options.body instanceof FormData;
  const headers: Record<string, string> = {
    ...(isFormData ? {} : { "Content-Type": "application/json" }),
    ...(options.headers as Record<string, string>),
  };

  // 인증 경로가 아닌 경우에만 Bearer 토큰 주입
  if (accessToken && !AUTH_PATHS.some((p) => path.startsWith(p))) {
    headers["Authorization"] = `Bearer ${accessToken}`;
  }

  log("REQ", method, path, options.body && !isFormData ? JSON.parse(options.body as string) : undefined);

  try {
    const response = await fetch(`${BASE_URL}${path}`, {
      ...options,
      signal: controller.signal,
      headers,
    });

    if (!response.ok) {
      const body = await response.json().catch(() => null);
      log("ERR", method, path, { status: response.status, body });
      reportMaintenanceIfDetected(response.status, body);
      throw new ApiError(response.status, body);
    }

    if (responseKind === "blob") return (await response.blob()) as T;

    // 204 No Content 또는 body가 없는 201 응답은 JSON 파싱 없이 반환
    const contentLength = response.headers.get("content-length");
    const hasBody = response.status !== 204 && contentLength !== "0";
    const data = hasBody ? ((await response.json()) as T) : (undefined as T);
    log("RES", method, path, data);
    return data;
  } finally {
    clearTimeout(timer);
  }
}

// 재발급 실패 중 세션이 끝난 응답: 401 전부(무효·만료·재사용 판정) + 회원 없음(탈퇴), 그 외는 일시 오류
const SESSION_ENDING_REISSUE_ERROR_CODES: ReadonlySet<string> = new Set<ApiErrorCode>(["MEMBER_NOT_FOUND"]);
// 인증 필요·토큰 무효 응답 (apiFetch·SSE 재발급 기준)
export const UNAUTHORIZED_HTTP_STATUS = 401;

/** 재발급 실패가 세션 종료인지 (네트워크·타임아웃·5xx 는 false > 세션 유지) */
function isSessionEndingReissueError(error: unknown): boolean {
  if (!(error instanceof ApiError)) return false;
  if (error.status === UNAUTHORIZED_HTTP_STATUS) return true;
  const errorCode = toApiErrorCode(error);
  return errorCode !== null && SESSION_ENDING_REISSUE_ERROR_CODES.has(errorCode);
}

// 재발급 조율 1개 (탭 안 단일 비행 + 탭 간 잠금, 저장값은 매번 다시 읽음)
const accessTokenReissueCoordinator = createAccessTokenReissueCoordinator({
  readLatestStoredTokens: () => useAuthStore.getState().syncTokensFromStorage(),
  requestRotatedTokens: (refreshToken) => reissue({ refreshToken }),
  saveRotatedTokens: (rotatedTokens) => useAuthStore.getState().setRotatedTokens(rotatedTokens),
  runExclusivelyAcrossTabs: runWithAccessTokenReissueLock,
});

/**
 * 401 이후 재시도용 access token: 다른 요청·탭이 이미 재발급 > 그 토큰 / 아니면 재발급 1회
 * 세션 종료(로그아웃됨·401·회원 없음)면 로그아웃 처리 후 null, 일시 오류는 세션 유지하고 throw (apiFetch·SSE 공통 진입점)
 */
export async function resolveAccessTokenAfterUnauthorized(
  requestAccessToken: string | null,
): Promise<string | null> {
  try {
    const reissueOutcome = await accessTokenReissueCoordinator.resolveAccessToken(requestAccessToken);
    // 재발급 수단이 없으면 무효 토큰을 든 채 홈에 갇히므로 바로 로그아웃 처리 (#398)
    if (reissueOutcome.kind === "signedOut") {
      clearMemberSessionAndGoToLogin();
      return null;
    }
    return reissueOutcome.accessToken;
  } catch (reissueError) {
    if (!isSessionEndingReissueError(reissueError)) throw reissueError;
    clearMemberSessionAndGoToLogin();
    return null;
  }
}

export function apiFetch<T>(path: string, options: RequestInit = {}): Promise<T> {
  return fetchWithReissue<T>(path, options, "json");
}

/** 인증이 필요한 바이너리(이미지) 조회 > Blob (401 재발급 동작은 apiFetch 와 동일) */
export function apiFetchBlob(path: string): Promise<Blob> {
  return fetchWithReissue<Blob>(path, {}, "blob");
}

async function fetchWithReissue<T>(path: string, options: RequestInit, responseKind: ResponseKind): Promise<T> {
  const isAuthPath = AUTH_PATHS.some((p) => path.startsWith(p));
  const requestAccessToken = getAccessToken();

  try {
    return await fetchOnce<T>(path, options, requestAccessToken, responseKind);
  } catch (err) {
    // 인증 경로는 재시도 없음, 401이 아니면 그대로 throw
    if (isAuthPath || !(err instanceof ApiError) || err.status !== UNAUTHORIZED_HTTP_STATUS) {
      throw err;
    }

    const retryAccessToken = await resolveAccessTokenAfterUnauthorized(requestAccessToken);
    if (!retryAccessToken) throw err;
    return fetchOnce<T>(path, options, retryAccessToken, responseKind);
  }
}
