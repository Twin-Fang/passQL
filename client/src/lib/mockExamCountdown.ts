/**
 * 모의고사 남은 시간 계산·표시 (#866): 서버 남은 초 + 단조 시계 경과 > 남은 초 > 시계 문구·색 단계·낭독 시점
 * 기기 시각(Date)은 쓰지 않음 > 시각을 바꿔도 시간이 늘거나 줄지 않음
 */

// 색 단계 경계 (초): 10분 이하 주의, 5분 이하 위험
const WARNING_REMAINING_SECONDS = 10 * 60;
const DANGER_REMAINING_SECONDS = 5 * 60;

// 스크린리더 낭독 시점 (남은 분, 큰 순)
const ANNOUNCEMENT_REMAINING_MINUTES = [30, 10, 5, 1] as const;

const MILLISECONDS_PER_SECOND = 1000;
const SECONDS_PER_MINUTE = 60;

export type CountdownTone = "normal" | "warning" | "danger";

/** 서버 남은 초 - 받은 뒤 흐른 단조 시간 > 지금 남은 초 (0 미만은 0) */
export function toRemainingSecondsAt(
  serverRemainingSeconds: number,
  syncedAtMonotonicMilliseconds: number,
  nowMonotonicMilliseconds: number,
): number {
  const elapsedSeconds = Math.floor(
    Math.max(0, nowMonotonicMilliseconds - syncedAtMonotonicMilliseconds) / MILLISECONDS_PER_SECOND,
  );
  return Math.max(0, serverRemainingSeconds - elapsedSeconds);
}

/** 남은 초 > 시계 문구 (5400 > "90:00", 59 > "00:59") */
export function formatRemainingClock(remainingSeconds: number): string {
  const safeSeconds = Math.max(0, Math.floor(remainingSeconds));
  const minutes = Math.floor(safeSeconds / SECONDS_PER_MINUTE);
  const seconds = safeSeconds % SECONDS_PER_MINUTE;
  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}

/** 남은 초 > 낭독 문구 ("남은 시간 12분", 1분 미만은 초) */
export function toRemainingTimeSpeech(remainingSeconds: number): string {
  const safeSeconds = Math.max(0, Math.floor(remainingSeconds));
  if (safeSeconds < SECONDS_PER_MINUTE) return `남은 시간 ${safeSeconds}초`;
  return `남은 시간 ${Math.ceil(safeSeconds / SECONDS_PER_MINUTE)}분`;
}

/** 남은 초 > 색 단계 (10분 이하 warning, 5분 이하 danger) */
export function toCountdownTone(remainingSeconds: number): CountdownTone {
  if (remainingSeconds <= DANGER_REMAINING_SECONDS) return "danger";
  if (remainingSeconds <= WARNING_REMAINING_SECONDS) return "warning";
  return "normal";
}

/**
 * 이전 <-> 지금 남은 초 사이에 지난 낭독 시점 (분), 없으면 null
 * 여러 시점을 한 번에 지났으면(백그라운드 복귀) 가장 작은 시점 1개만
 */
export function findCrossedAnnouncementMinute(previousSeconds: number, currentSeconds: number): number | null {
  const crossedMinutes = ANNOUNCEMENT_REMAINING_MINUTES.filter(
    (minute) => previousSeconds > minute * SECONDS_PER_MINUTE && currentSeconds <= minute * SECONDS_PER_MINUTE,
  );
  return crossedMinutes.length > 0 ? crossedMinutes[crossedMinutes.length - 1] : null;
}
