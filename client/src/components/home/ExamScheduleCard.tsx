import HomeCardError from "./HomeCardError";
import type { ExamScheduleResponse } from "../../types/api";

interface ExamScheduleCardProps {
  readonly schedule: ExamScheduleResponse | null | undefined;
  readonly isLoading: boolean;
  readonly isError: boolean;
  readonly onRetry: () => void;
}

// 하루 길이 (밀리초)
const DAY_MILLISECONDS = 86400000;

/** 시험일 > D-day 문구 (오늘 00:00 기준, 지나면 D+N) */
function formatExamDday(examDate: string): string {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const exam = new Date(examDate);
  exam.setHours(0, 0, 0, 0);
  const diff = Math.round((exam.getTime() - today.getTime()) / DAY_MILLISECONDS);
  if (diff > 0) return `D-${diff}`;
  if (diff === 0) return "D-Day";
  return `D+${Math.abs(diff)}`;
}

/**
 * 홈 시험 일정 카드: 로딩 스켈레톤 / 실패 재시도 / D-day 강조 / 선택 일정 없음
 */
export default function ExamScheduleCard({ schedule, isLoading, isError, onRetry }: ExamScheduleCardProps) {
  if (isLoading) return <div className="skeleton h-full min-h-28 rounded-2xl" />;
  if (isError) return <HomeCardError title="시험 일정" onRetry={onRetry} />;
  if (!schedule) {
    return (
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 h-full flex flex-col justify-center">
        <p className="text-sm text-text-secondary">시험 일정</p>
        <p className="text-sm text-text-caption mt-1">선택된 일정 없음</p>
      </div>
    );
  }
  return (
    // 인디고 단색 카드 — D-day를 전면에 강조해 시험 긴박감 전달
    <div className="h-full rounded-xl p-4 sm:p-6 flex flex-col justify-center relative overflow-hidden bg-brand">
      {/* 배경 장식 원 — 단색 배경의 단조로움을 덜어주는 subtle한 레이어 */}
      <div className="absolute -right-4 -top-4 w-20 h-20 rounded-full bg-on-brand/10" />
      <div className="absolute right-4 -bottom-8 w-24 h-24 rounded-full bg-on-brand/5" />
      <p className="text-xs font-medium text-on-brand/70 mb-1 relative z-10">
        {schedule.certType} {schedule.round}회
      </p>
      <p className="text-3xl font-bold text-on-brand leading-tight relative z-10">
        {formatExamDday(schedule.examDate)}
      </p>
      <p className="text-sm text-on-brand/70 mt-1 relative z-10">{schedule.examDate}</p>
    </div>
  );
}
