import { useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, Info, Lock } from "lucide-react";
import ConfirmModal from "../components/ConfirmModal";
import ErrorFallback from "../components/ErrorFallback";
import MockExamRuleSummaryCard from "../components/mockExam/MockExamRuleSummaryCard";
import ProAccessReasonView from "../components/pro/ProAccessReasonView";
import UnlockInAppButton from "../components/pro/UnlockInAppButton";
import { startMockExamAttempt } from "../api/mockExams";
import { MOCK_EXAM_QUERY_KEYS, useMockExamRounds } from "../hooks/useMockExam";
import { useMemberPlan } from "../hooks/useMemberPlan";
import { toProAccessErrorCode, type ProAccessErrorCode } from "../lib/proAccess";
import { toUserErrorMessage } from "../lib/userErrorMessage";
import { MOCK_EXAM_ROUNDS_PATH, toMockExamAttemptPath, toMockExamResultPath } from "../constants/mockExamRoutes";
import {
  MOCK_EXAM_FREE_TRIAL_NOTICE,
  MOCK_EXAM_GUIDE_FIXED_LINES,
  MOCK_EXAM_START_BLOCK_REASON_LABELS,
  MOCK_EXAM_START_CONFIRM,
} from "../constants/mockExamCopy";

/**
 * 시험 안내 (#866): 회차 제목 > 형식·합격·과락·자동 제출·이어 풀기 안내 > (무료) 체험 안내 > 시작 확인
 * 시작 가능 여부는 서버 canStart, 시작 거부(체험 소진·다른 응시 풀이 중·프로 필요)는 서버 오류 그대로 안내
 */
export default function MockExamGuide() {
  const { roundUuid = "" } = useParams<{ roundUuid: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { data: roundList, isLoading, isError, refetch } = useMockExamRounds();
  const { shouldShowProUi } = useMemberPlan();
  const [isStartConfirmOpen, setIsStartConfirmOpen] = useState(false);
  const [isStarting, setIsStarting] = useState(false);
  const [startErrorMessage, setStartErrorMessage] = useState<string | null>(null);
  const [startProAccessErrorCode, setStartProAccessErrorCode] = useState<ProAccessErrorCode | null>(null);

  const backLink = (
    <Link to={MOCK_EXAM_ROUNDS_PATH} className="inline-flex items-center gap-1 text-sm text-text-secondary hover:text-text-primary">
      <ArrowLeft size={16} aria-hidden="true" />
      모의고사 목록
    </Link>
  );

  if (isError) {
    return (
      <div className="py-6 space-y-4">
        {backLink}
        <ErrorFallback onRetry={() => refetch()} />
      </div>
    );
  }
  if (isLoading || !roundList) {
    return (
      <div className="py-6 space-y-3" aria-busy="true">
        <div className="skeleton h-8 w-1/2 rounded-lg" />
        <div className="skeleton h-56 rounded-2xl" />
      </div>
    );
  }

  const round = roundList.rounds.find((candidate) => candidate.roundUuid === roundUuid);
  if (!round) {
    return (
      <div className="py-6 space-y-4">
        {backLink}
        <p className="bg-surface-card border border-border rounded-2xl p-6 text-sm text-text-secondary text-center">
          지금은 볼 수 없는 회차예요
        </p>
      </div>
    );
  }

  const isResumable = round.lastAttempt?.status === "IN_PROGRESS";
  const canStart = round.canStart || isResumable;
  const lastSubmittedAttemptUuid = round.lastAttempt?.status === "SUBMITTED" ? round.lastAttempt.attemptUuid : null;
  const blockReasonLabel = round.startBlockReason ? MOCK_EXAM_START_BLOCK_REASON_LABELS[round.startBlockReason] : null;

  // 시작·이어 풀기: 시험지 캐시 > 풀이 화면 (목록으로 뒤로가기 되게 안내 화면 교체)
  const startAttempt = async () => {
    setIsStartConfirmOpen(false);
    setIsStarting(true);
    setStartErrorMessage(null);
    try {
      const sheet = await startMockExamAttempt(round.roundUuid);
      queryClient.setQueryData(MOCK_EXAM_QUERY_KEYS.sheet(sheet.attemptUuid), {
        sheet,
        receivedAtMonotonicMilliseconds: performance.now(),
      });
      navigate(toMockExamAttemptPath(sheet.attemptUuid), { replace: true });
    } catch (error) {
      setIsStarting(false);
      setStartProAccessErrorCode(toProAccessErrorCode(error));
      setStartErrorMessage(toUserErrorMessage(error, "시험을 시작하지 못했어요. 잠시 뒤 다시 시도해 주세요"));
      void refetch();
    }
  };

  if (startProAccessErrorCode) {
    return (
      <div className="py-6 space-y-4">
        {backLink}
        <ProAccessReasonView errorCode={startProAccessErrorCode} />
      </div>
    );
  }

  return (
    <div className="py-6 space-y-5">
      {backLink}
      <section>
        <p className="text-xs text-text-caption">시험 안내</p>
        <h1 className="text-h1 mt-1">{round.title}</h1>
      </section>

      <MockExamRuleSummaryCard examRule={roundList.examRule} extraLines={MOCK_EXAM_GUIDE_FIXED_LINES} title="시작 전에 확인해 주세요" />

      {shouldShowProUi && (
        <p className="flex items-start gap-2 rounded-2xl bg-brand-light px-4 py-3 text-sm text-text-primary break-keep">
          <Info size={16} className="text-brand shrink-0 mt-0.5" aria-hidden="true" />
          {MOCK_EXAM_FREE_TRIAL_NOTICE}
        </p>
      )}

      {!canStart && blockReasonLabel && (
        <div role="status" className="flex flex-col items-center gap-3 rounded-2xl border border-border bg-surface-card px-4 py-5 text-center">
          <Lock size={20} className="text-text-caption" aria-hidden="true" />
          <p className="text-sm text-text-primary break-keep">{blockReasonLabel}</p>
          {round.startBlockReason !== "OTHER_ATTEMPT_IN_PROGRESS" && shouldShowProUi && <UnlockInAppButton />}
        </div>
      )}

      {startErrorMessage && (
        <p role="alert" className="rounded-xl border border-semantic-error-border bg-surface-card px-4 py-3 text-sm text-semantic-error-text break-keep">
          {startErrorMessage}
        </p>
      )}

      {/* 시작 버튼 (풀이 중이면 확인 없이 이어 풀기) */}
      <button
        type="button"
        className="btn btn-primary w-full"
        disabled={!canStart || isStarting}
        onClick={() => (isResumable ? void startAttempt() : setIsStartConfirmOpen(true))}
      >
        {isStarting && <span className="loading loading-spinner loading-sm" />}
        {isResumable ? "이어 풀기" : "시험 시작하기"}
      </button>
      {lastSubmittedAttemptUuid && (
        <Link to={toMockExamResultPath(lastSubmittedAttemptUuid)} className="btn btn-ghost w-full">
          지난 결과 보기
        </Link>
      )}

      <ConfirmModal
        isOpen={isStartConfirmOpen}
        title={MOCK_EXAM_START_CONFIRM.title}
        description={`${roundList.examRule.durationMinutes}분 타이머가 바로 시작돼요. ${MOCK_EXAM_START_CONFIRM.description}`}
        confirmLabel={MOCK_EXAM_START_CONFIRM.confirmLabel}
        cancelLabel={MOCK_EXAM_START_CONFIRM.cancelLabel}
        isConfirmEmphasized
        onCancel={() => setIsStartConfirmOpen(false)}
        onConfirm={() => void startAttempt()}
      />
    </div>
  );
}
