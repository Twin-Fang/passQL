import { ApiError } from "../api/client";

// 서버 문구를 그대로 보여 줄 상태 범위 (4xx 입력·권한 오류, 5xx 는 내부 문구 노출 방지)
const CLIENT_ERROR_STATUS_MIN = 400;
const SERVER_ERROR_STATUS_MIN = 500;

/**
 * 오류 > 사용자 문구: 4xx ErrorResponse.message 우선, 그 외(5xx·네트워크·타임아웃)는 fallback
 * "API Error 500"·"Failed to fetch" 같은 내부 문구는 화면에 내보내지 않음
 */
export function toUserErrorMessage(error: unknown, fallbackMessage: string): string {
  if (!(error instanceof ApiError)) return fallbackMessage;
  if (error.status < CLIENT_ERROR_STATUS_MIN || error.status >= SERVER_ERROR_STATUS_MIN) return fallbackMessage;
  const serverMessage = (error.body as { message?: unknown } | null)?.message;
  return typeof serverMessage === "string" && serverMessage.trim() ? serverMessage : fallbackMessage;
}
