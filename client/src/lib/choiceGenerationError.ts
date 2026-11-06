import { ApiError } from "../api/client";
import { toProAccessErrorCode } from "./proAccess";
import { toUserErrorMessage } from "./userErrorMessage";
import type { SseErrorEvent } from "../types/api";

/**
 * 선택지 생성(SSE) 실패 > 화면 오류 (#881): 스트림 시작 전 거부(HTTP 오류 JSON)·스트림 error 이벤트·클라이언트 타임아웃
 * 프로 접근 거부(한도·프로 필요)는 사유 화면, 그 외는 문구 + 재시도
 */
export interface ChoiceGenerationError {
  // 서버 errorCode 또는 웹 코드 (TIMEOUT, STREAM_CLOSED, HTTP_상태)
  readonly code: string;
  readonly isRetryable: boolean;
  // 스트림 시작 전 거부의 안내 문구 (4xx 서버 문구, 5xx 기본 문구) / 그 외 null > 코드별 웹 문구
  readonly userMessage: string | null;
}

const CHOICE_GENERATION_FAILED_MESSAGE = "선택지 생성에 실패했어요";
// 웹이 직접 만드는 오류 코드 2개: 60초 무응답, 완료 없이 스트림 종료
const CHOICE_GENERATION_TIMEOUT_CODE = "TIMEOUT";
const CHOICE_GENERATION_STREAM_CLOSED_CODE = "STREAM_CLOSED";

// 60초 안에 complete·error 가 없을 때 (클라이언트 타임아웃)
export const CHOICE_GENERATION_TIMEOUT_ERROR: ChoiceGenerationError = {
  code: CHOICE_GENERATION_TIMEOUT_CODE,
  isRetryable: true,
  userMessage: null,
};

/** 스트림 시작 전 거부 응답 > 화면 오류 (프로 접근은 재시도 없음, 그 외 4xx 는 서버 문구) */
export function toChoiceGenerationRejectionError(rejection: ApiError): ChoiceGenerationError {
  const proAccessErrorCode = toProAccessErrorCode(rejection);
  if (proAccessErrorCode) return { code: proAccessErrorCode, isRetryable: false, userMessage: null };

  const errorCode = (rejection.body as { errorCode?: unknown } | null)?.errorCode;
  return {
    code: typeof errorCode === "string" ? errorCode : `HTTP_${rejection.status}`,
    isRetryable: true,
    userMessage: toUserErrorMessage(rejection, CHOICE_GENERATION_FAILED_MESSAGE),
  };
}

/** 스트림 error 이벤트 > 화면 오류 (문구는 코드별 웹 문구) */
export function toChoiceGenerationStreamError(errorEvent: SseErrorEvent): ChoiceGenerationError {
  return { code: errorEvent.code, isRetryable: errorEvent.retryable, userMessage: null };
}

/** 화면 오류 > 안내 문구 (거부 응답 문구 > 타임아웃·연결 끊김 > 기본) */
export function toChoiceGenerationErrorMessage(error: ChoiceGenerationError): string {
  if (error.userMessage) return error.userMessage;
  if (error.code === CHOICE_GENERATION_TIMEOUT_CODE) return "선택지 생성 시간이 초과되었어요";
  if (error.code === CHOICE_GENERATION_STREAM_CLOSED_CODE) return "서버 연결이 예기치 않게 끊겼어요";
  return CHOICE_GENERATION_FAILED_MESSAGE;
}
