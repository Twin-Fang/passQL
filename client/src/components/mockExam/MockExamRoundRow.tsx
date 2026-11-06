import { Link } from "react-router-dom";
import { ChevronRight, Lock, PlayCircle } from "lucide-react";
import { toMockExamAttemptPath, toMockExamGuidePath } from "../../constants/mockExamRoutes";
import { MOCK_EXAM_FREE_TRIAL_BADGE, MOCK_EXAM_START_BLOCK_REASON_LABELS } from "../../constants/mockExamCopy";
import { formatMonthDay } from "../../lib/mockExamPresentation";
import type { MockExamRoundSummary } from "../../types/api";

interface MockExamRoundRowProps {
  readonly round: MockExamRoundSummary;
}

/** 마지막 응시 > 한 줄 ("11월 7일 · 64점 합격"), 풀이 중이면 이어 풀기 */
function toLastAttemptLine(round: MockExamRoundSummary): string | null {
  const lastAttempt = round.lastAttempt;
  if (!lastAttempt) return null;
  if (lastAttempt.status === "IN_PROGRESS") return "풀고 있어요 · 이어 풀기";
  const dateLabel = lastAttempt.submittedAt ? `${formatMonthDay(lastAttempt.submittedAt)} · ` : "";
  const verdictLabel = lastAttempt.isPassed ? "합격" : "불합격";
  return `${dateLabel}${lastAttempt.totalScore ?? 0}점 ${verdictLabel}`;
}

/**
 * 회차 행: 회차·제목·무료 체험 배지 > 최고 점수·마지막 결과 > 잠금 이유
 * 풀이 중 응시면 풀이로, 그 외는 시험 안내로 (시작 가능 여부는 서버 canStart)
 */
export default function MockExamRoundRow({ round }: MockExamRoundRowProps) {
  const isInProgress = round.lastAttempt?.status === "IN_PROGRESS";
  const destinationPath =
    isInProgress && round.lastAttempt ? toMockExamAttemptPath(round.lastAttempt.attemptUuid) : toMockExamGuidePath(round.roundUuid);
  const lastAttemptLine = toLastAttemptLine(round);
  const blockReasonLabel = round.startBlockReason ? MOCK_EXAM_START_BLOCK_REASON_LABELS[round.startBlockReason] : null;
  const isLocked = !round.canStart && !isInProgress;

  return (
    <li>
      <Link
        to={destinationPath}
        className="flex items-center gap-3 p-4 hover:bg-surface-zebra transition-colors focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-brand"
      >
        <div
          className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${isLocked ? "bg-surface-code" : "bg-brand-light"}`}
          aria-hidden="true"
        >
          {isLocked ? <Lock size={18} className="text-text-caption" /> : <PlayCircle size={20} className="text-brand" />}
        </div>
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <p className="text-sm font-semibold text-text-primary">{round.title}</p>
            {round.isFreeTrialRound && (
              <span className="badge badge-sm border-0 bg-semantic-success-light text-semantic-success-text">
                {MOCK_EXAM_FREE_TRIAL_BADGE}
              </span>
            )}
          </div>
          <p className="text-xs text-text-secondary mt-1 tabular-nums">
            {round.bestScore !== null ? `최고 ${round.bestScore}점 · 응시 ${round.submittedAttemptCount}회` : "아직 응시하지 않았어요"}
          </p>
          {lastAttemptLine && <p className="text-xs text-text-caption mt-0.5">{lastAttemptLine}</p>}
          {blockReasonLabel && !isInProgress && (
            <p className="text-xs text-semantic-warning-text mt-0.5">{blockReasonLabel}</p>
          )}
        </div>
        <ChevronRight size={16} className="text-text-caption shrink-0" aria-hidden="true" />
      </Link>
    </li>
  );
}
