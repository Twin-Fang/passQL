import type { WeeklyWrongCount } from "../types/api";

/** 요일 이름 (서버 weekdayAttemptCounts·busiestWeekdayIndex 순서: 월 0 ~ 일 6, 앱 study_stats_summaries.dart 와 같은 값) */
export const WEEKDAY_SHORT_NAMES = ["월", "화", "수", "목", "금", "토", "일"] as const;

/** 시각(0~23) > 읽는 말 (0 > 밤 12시, 3 > 새벽 3시, 12 > 낮 12시, 15 > 오후 3시, 21 > 밤 9시) */
export function toSpokenHourLabel(hour: number): string {
  if (hour === 0) return "밤 12시";
  if (hour < 6) return `새벽 ${hour}시`;
  if (hour < 12) return `오전 ${hour}시`;
  if (hour === 12) return "낮 12시";
  if (hour < 18) return `오후 ${hour - 12}시`;
  return `밤 ${hour - 12}시`;
}

/** 'yyyy-MM-dd' > 'M/d' (형식이 다르면 원문) */
export function toMonthDayLabel(isoDate: string): string {
  const [, month, day] = isoDate.split("-").map(Number);
  if (!month || !day) return isoDate;
  return `${month}/${day}`;
}

/** 정답률 % (반올림, 풀이 없으면 0) */
export function toCorrectPercent(correctCount: number, attemptCount: number): number {
  return attemptCount === 0 ? 0 : Math.round((correctCount * 100) / attemptCount);
}

/** 지난주 대비 이번 주 남은 오답 변화 (늘면 양수, 두 주가 안 되면 null) */
export function toWeeklyRemainingWrongChange(trend: readonly WeeklyWrongCount[]): number | null {
  if (trend.length < 2) return null;
  return trend[trend.length - 1].remainingWrongCount - trend[trend.length - 2].remainingWrongCount;
}
