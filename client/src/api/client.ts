import { getAccessToken, getRefreshToken, useAuthStore } from "../stores/authStore";
import { reissue } from "./auth";
import { PRODUCTION_API_BASE_URL } from "../constants/siteUrls";
import { useMaintenanceStore } from "../stores/maintenanceStore";
import { clearMemberSession } from "../lib/memberSession";

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
    const res = await fetch(`${BASE_URL}${path}`, {
      ...options,
      signal: controller.signal,
      headers,
    });

    if (!res.ok) {
      const body = await res.json().catch(() => null);
      log("ERR", method, path, { status: res.status, body });
      reportMaintenanceIfDetected(res.status, body);
      throw new ApiError(res.status, body);
    }

    if (responseKind === "blob") return (await res.blob()) as T;

    // 204 No Content 또는 body가 없는 201 응답은 JSON 파싱 없이 반환
    const contentLength = res.headers.get("content-length");
    const hasBody = res.status !== 204 && contentLength !== "0";
    const data = hasBody ? ((await res.json()) as T) : (undefined as T);
    log("RES", method, path, data);
    return data;
  } finally {
    clearTimeout(timer);
  }
}

// 토큰을 정리하고 로그인 화면으로 보낸다. 이미 로그인 화면이면 새로고침 루프를 막기 위해 이동하지 않는다
function forceLogout() {
  // 로그인 화면에 머무는 경우(새로고침 없음)에도 이전 회원 캐시가 남지 않게 함께 정리
  clearMemberSession();
  if (window.location.pathname !== "/login") {
    window.location.href = "/login";
  }
}

// 진행 중 재발급 1건 (동시 401 이 같은 결과를 기다림, 서버는 회전된 refresh 재사용 시 세션 전체 폐기)
let accessTokenReissueInFlight: Promise<string> | null = null;

/** 재발급 단일 비행: 진행 중이면 그 결과 공유, 없으면 새로 1회 > 새 access token */
function reissueAccessTokenOnce(refreshToken: string): Promise<string> {
  accessTokenReissueInFlight ??= reissueAccessToken(refreshToken).finally(() => {
    accessTokenReissueInFlight = null;
  });
  return accessTokenReissueInFlight;
}

/** refresh token > 재발급 > 토큰 2개 저장 (rotating refresh token) */
async function reissueAccessToken(refreshToken: string): Promise<string> {
  useAuthStore.setState({ isRefreshing: true });
  try {
    const result = await reissue({ refreshToken });
    useAuthStore.getState().setRotatedTokens(result);
    return result.accessToken;
  } finally {
    useAuthStore.setState({ isRefreshing: false });
  }
}

/**
 * 401 이후 재시도용 access token: 다른 요청이 이미 재발급 > 그 토큰 / 아니면 재발급 1회
 * 재발급 불가(refresh 없음·실패)면 로그아웃 처리 후 null (apiFetch·SSE 공통 진입점)
 */
export async function resolveAccessTokenAfterUnauthorized(
  requestAccessToken: string | null,
): Promise<string | null> {
  // 응답 대기 중 다른 요청이 이미 재발급 완료 > 새 토큰으로 재시도만 (재발급 중복 방지)
  const currentAccessToken = getAccessToken();
  if (currentAccessToken && currentAccessToken !== requestAccessToken && !accessTokenReissueInFlight) {
    return currentAccessToken;
  }

  const refreshToken = getRefreshToken();
  // 재발급 수단이 없으면 무효 토큰을 든 채 홈에 갇히므로 바로 로그아웃 처리 (#398)
  if (!refreshToken) {
    forceLogout();
    return null;
  }

  try {
    return await reissueAccessTokenOnce(refreshToken);
  } catch {
    // refresh도 실패하면 로그아웃 처리
    forceLogout();
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
    if (isAuthPath || !(err instanceof ApiError) || err.status !== 401) {
      throw err;
    }

    const retryAccessToken = await resolveAccessTokenAfterUnauthorized(requestAccessToken);
    if (!retryAccessToken) throw err;
    return fetchOnce<T>(path, options, retryAccessToken, responseKind);
  }
}
