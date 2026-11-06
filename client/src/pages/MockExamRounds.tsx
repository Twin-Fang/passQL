import { Link } from "react-router-dom";
import { ChevronRight, ClipboardCheck, Timer } from "lucide-react";
import ErrorFallback from "../components/ErrorFallback";
import MockExamRuleSummaryCard from "../components/mockExam/MockExamRuleSummaryCard";
import MockExamRoundRow from "../components/mockExam/MockExamRoundRow";
import MockExamScoreTrendSection from "../components/mockExam/MockExamScoreTrendSection";
import { useMockExamRounds } from "../hooks/useMockExam";
import { useStagger } from "../hooks/useStagger";
import { toMockExamAttemptPath } from "../constants/mockExamRoutes";
import { MOCK_EXAM_ENTRY_DESCRIPTION, MOCK_EXAM_TITLE } from "../constants/mockExamCopy";
import { toRemainingTimeSpeech } from "../lib/mockExamCountdown";
import type { MockExamInProgressAttempt } from "../types/api";

/**
 * SQLD 모의고사 회차 목록 (#866): 제목 > 이어 풀기 띠 > 시험 형식 > 회차 목록 > 점수 추이(프로)
 * 시작 가능·잠금 이유·최고 점수는 서버 값 그대로 (등급 판정 없음)
 */
export default function MockExamRounds() {
  const { data: roundList, isLoading, isError, refetch } = useMockExamRounds();
  const stagger = useStagger();
  const s0 = stagger(0); // 제목·이어 풀기
  const s1 = stagger(1); // 형식·회차
  const s2 = stagger(2); // 점수 추이

  const header = (
    <section className={s0.className}>
      <h1 className="text-h1 mb-1 flex items-center gap-2">
        <ClipboardCheck size={24} aria-hidden="true" />
        {MOCK_EXAM_TITLE}
      </h1>
      <p className="text-secondary">{MOCK_EXAM_ENTRY_DESCRIPTION}</p>
    </section>
  );

  if (isError) {
    return (
      <div className="py-6 space-y-4">
        {header}
        <ErrorFallback onRetry={() => refetch()} />
      </div>
    );
  }

  if (isLoading || !roundList) {
    return (
      <div className="py-6 space-y-3" aria-busy="true">
        {header}
        <div className="skeleton h-36 rounded-2xl" />
        <div className="skeleton h-48 rounded-2xl" />
      </div>
    );
  }

  return (
    <div className="py-6 space-y-6">
      <div className="space-y-4">
        {header}
        {roundList.inProgressAttempt && (
          <InProgressAttemptBanner attempt={roundList.inProgressAttempt} className={s0.className} />
        )}
      </div>

      <div className={`space-y-6 ${s1.className}`}>
        <MockExamRuleSummaryCard examRule={roundList.examRule} />

        <section aria-label="회차">
          <h2 className="text-sm text-text-secondary mb-2 px-1">회차</h2>
          {roundList.rounds.length === 0 ? (
            <p className="bg-surface-card border border-border rounded-2xl p-6 text-sm text-text-secondary text-center">
              곧 첫 회차가 열려요
            </p>
          ) : (
            <ul className="bg-surface-card border border-border rounded-2xl divide-y divide-border overflow-hidden">
              {roundList.rounds.map((round) => (
                <MockExamRoundRow key={round.roundUuid} round={round} />
              ))}
            </ul>
          )}
        </section>
      </div>

      <div className={s2.className}>
        <MockExamScoreTrendSection maxScore={roundList.examRule.maxScore} />
      </div>
    </div>
  );
}

interface InProgressAttemptBannerProps {
  readonly attempt: MockExamInProgressAttempt;
  readonly className: string;
}

/** 풀이 중 응시 이어 풀기 띠: 회차·남은 시간·답한 수 (시간은 계속 흐름) */
function InProgressAttemptBanner({ attempt, className }: InProgressAttemptBannerProps) {
  return (
    <Link
      to={toMockExamAttemptPath(attempt.attemptUuid)}
      className={`flex items-center gap-3 rounded-2xl border border-brand bg-brand-light px-4 py-3 hover:-translate-y-0.5 transition-transform ${className}`}
    >
      <Timer size={20} className="text-brand shrink-0" aria-hidden="true" />
      <div className="flex-1 min-w-0">
        <p className="text-sm font-semibold text-text-primary">{attempt.title} 이어 풀기</p>
        <p className="text-xs text-text-secondary mt-0.5 tabular-nums">
          {toRemainingTimeSpeech(attempt.remainingSeconds)} · 답한 문항 {attempt.answeredCount}개
        </p>
      </div>
      <ChevronRight size={16} className="text-brand shrink-0" aria-hidden="true" />
    </Link>
  );
}
