import { Link } from "react-router-dom";
import { Check } from "lucide-react";
import HomeCardError from "./HomeCardError";
import type { DailySetTodayResponse } from "../../types/api";

interface DailySetCardProps {
  readonly dailySet: DailySetTodayResponse | undefined;
  readonly isLoading: boolean;
  readonly isError: boolean;
  readonly onRetry: () => void;
}

/**
 * 홈 오늘의 데일리 세트 카드: 로딩 / 실패 / 완료(순위 링크) / 미완료(도전 링크) / 세트 없음(문제 목록 링크)
 */
export default function DailySetCard({ dailySet, isLoading, isError, onRetry }: DailySetCardProps) {
  if (isLoading) return <div className="skeleton h-full min-h-28 rounded-2xl" />;
  if (isError) return <HomeCardError title="오늘의 데일리 세트" onRetry={onRetry} />;
  if (!(dailySet?.questions && dailySet.questions.length > 0)) {
    return (
      // 오늘 데일리 세트 없음 — 문제 목록으로 유도
      <Link to="/questions" className="block">
        <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 h-full flex flex-col justify-center cursor-pointer hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
          <p className="text-sm text-text-secondary">오늘의 데일리 세트</p>
          <p className="text-sm text-text-primary mt-1">오늘은 준비 중이에요</p>
        </div>
      </Link>
    );
  }
  if (dailySet.alreadyCompleted) {
    return (
      // 완료 상태: 회색 dimmed 카드 — 이미 끝난 항목임을 시각적으로 표현
      <div className="h-full flex flex-col gap-2 rounded-xl p-5 cursor-default bg-surface-code border border-border">
        <div className="flex items-center justify-between">
          <p className="text-sm text-text-secondary">오늘의 데일리 세트</p>
          <span className="flex items-center gap-1 text-xs font-semibold text-semantic-success-text">
            <Check size={11} strokeWidth={3} />
            완료
          </span>
        </div>
        <p className="text-xs text-text-caption">
          {dailySet.correctCount !== null ? `${dailySet.correctCount} / ${dailySet.questions.length} 정답` : ""}
        </p>
        <Link to="/leaderboard" className="mt-auto">
          <span className="text-xs text-brand font-semibold">순위 확인하기 →</span>
        </Link>
      </div>
    );
  }
  return (
    // 미완료 상태: 데일리 세트 페이지로 이동
    <Link to="/daily-set" className="block">
      <div className="bg-surface-card border border-border rounded-2xl p-4 sm:p-6 h-full flex flex-col gap-2 cursor-pointer hover:-translate-y-0.5 hover:border-brand transition-all duration-200">
        <p className="text-sm text-text-secondary">오늘의 데일리 세트</p>
        <p className="text-sm text-text-primary">{dailySet.questions.length}문제 도전하기</p>
        <div className="flex items-center gap-2 mt-auto">
          <span className="badge-topic">{dailySet.questions[0]?.topicName}</span>
          <span className="text-xs text-text-caption">외 {dailySet.questions.length - 1}개 토픽</span>
        </div>
      </div>
    </Link>
  );
}
