/**
 * 선택지 해설 재조회 간격: 서버 retryAfter 준수 + 지수 백오프 (#521)
 * 간격 1500 > 2250 > 3375 > 5063 > 6000 ... (상한 6000ms), 최대 8회 = 약 30초
 */

// 서버가 간격을 안 줄 때 기본값이자 백오프 시작 간격 (ms)
export const BASE_POLL_DELAY_MILLISECONDS = 1500;
// 재조회마다 간격 배수
export const POLL_BACKOFF_MULTIPLIER = 1.5;
// 간격 상한 (ms)
export const MAXIMUM_POLL_DELAY_MILLISECONDS = 6000;
// GENERATING 응답을 받은 뒤 다시 묻는 최대 횟수 (넘으면 실패 처리, 재시도 버튼)
export const MAXIMUM_POLL_ATTEMPT_COUNT = 8;

/**
 * 재조회 순번(0부터) + 서버 권장 간격 > 다음 조회까지 대기 (ms)
 */
export function computeNextPollDelayMilliseconds(
  pollAttemptIndex: number,
  retryAfterMilliseconds: number | null | undefined,
): number {
  const backoffDelay = BASE_POLL_DELAY_MILLISECONDS * POLL_BACKOFF_MULTIPLIER ** Math.max(0, pollAttemptIndex);
  const serverDelay = retryAfterMilliseconds ?? BASE_POLL_DELAY_MILLISECONDS;
  return Math.min(MAXIMUM_POLL_DELAY_MILLISECONDS, Math.max(serverDelay, backoffDelay));
}

/** 받은 GENERATING 응답 수 > 더 물어볼 수 있는지 */
export function canPollAgain(receivedResponseCount: number): boolean {
  return receivedResponseCount < MAXIMUM_POLL_ATTEMPT_COUNT;
}
