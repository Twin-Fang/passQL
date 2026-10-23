import { ApiError } from "./client";
import { toProAccessErrorCode } from "../lib/proAccess";

export function shouldRetry(failureCount: number, error: Error): boolean {
  if (error instanceof ApiError && error.status >= 500) return false;
  // 프로 접근 거부(한도·프로 필요)는 다시 받아도 같은 결과 > 사유 화면 바로 표시 (#578)
  if (toProAccessErrorCode(error)) return false;
  return failureCount < 1;
}
