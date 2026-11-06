import { Clock } from "lucide-react";
import {
  formatRemainingClock,
  toCountdownTone,
  toRemainingTimeSpeech,
  type CountdownTone,
} from "../../lib/mockExamCountdown";

interface MockExamCountdownBadgeProps {
  readonly remainingSeconds: number;
  // 30·10·5·1분 경계 낭독 문구 (빈 문자열이면 낭독 없음)
  readonly announcement: string;
}

// 색 단계 > 배지 색 (10분 이하 주황, 5분 이하 빨강)
const TONE_CLASS_NAMES: Readonly<Record<CountdownTone, string>> = {
  normal: "bg-surface-code text-text-primary",
  warning: "bg-semantic-warning-light text-semantic-warning-text",
  danger: "bg-semantic-error-light text-semantic-error-text",
};

/**
 * 풀이 남은 시간 배지: 분:초 + 색 단계, 스크린리더는 매초 대신 경계 낭독만 (role=timer 는 기본 낭독 꺼짐)
 */
export default function MockExamCountdownBadge({ remainingSeconds, announcement }: MockExamCountdownBadgeProps) {
  const tone = toCountdownTone(remainingSeconds);
  return (
    <>
      <span
        role="timer"
        aria-label={toRemainingTimeSpeech(remainingSeconds)}
        className={`inline-flex items-center gap-1 rounded-full px-3 py-1 text-sm font-bold tabular-nums ${TONE_CLASS_NAMES[tone]}`}
      >
        <Clock size={14} aria-hidden="true" />
        {formatRemainingClock(remainingSeconds)}
      </span>
      <span className="sr-only" aria-live="assertive" aria-atomic="true">
        {announcement}
      </span>
    </>
  );
}
