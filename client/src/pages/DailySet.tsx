import { useState, useCallback, useRef, useEffect } from "react";
import { useNavigate, Navigate, useBlocker } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { Home } from "lucide-react";
import { useDailySet } from "../hooks/useHome";
import { useDailySetStore } from "../stores/dailySetStore";
import { useAuthStore } from "../stores/authStore";
import { submitAnswer } from "../api/questions";
import { completeDailySet } from "../api/dailySet";
import QuestionDetail from "./QuestionDetail";
import PracticeFeedbackBar from "../components/PracticeFeedbackBar";
import ConfirmModal from "../components/ConfirmModal";
import LoadingOverlay from "../components/LoadingOverlay";
import ProgressBar from "../components/ProgressBar";
import PracticeTopBar from "../components/practice/PracticeTopBar";
import PracticeQuestionScrollArea from "../components/practice/PracticeQuestionScrollArea";
import ExplanationPanel from "../components/aiExplanation/ExplanationPanel";
import {
  buildExplanationHistoryEntry,
  useExplanationHistoryStore,
  type ExplanationHistoryEntry,
} from "../stores/explanationHistoryStore";
import type { ChoiceItem, SubmitResult } from "../types/api";

export default function DailySet() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const memberUuid = useAuthStore((s) => s.memberUuid ?? "");
  const { data: dailySet, isLoading } = useDailySet();

  const store = useDailySetStore();
  const [feedback, setFeedback] = useState<SubmitResult | null>(null);
  // 피드백 바 해설 미리보기 대상 (#521)
  const [feedbackExplanationEntry, setFeedbackExplanationEntry] = useState<ExplanationHistoryEntry | null>(null);
  const addExplanationEntry = useExplanationHistoryStore((state) => state.addEntry);
  const [submitting, setSubmitting] = useState(false);
  // 연타 방지 — React state는 async 클로저에서 stale하므로 ref로 동기 플래그 관리
  const isProcessingRef = useRef(false);
  const [sessionUuid] = useState(() => crypto.randomUUID());

  // 세션 초기화 — dailySet 로드 완료 후 1회만 실행
  const initialized = useRef(false);
  useEffect(() => {
    if (dailySet?.questions && dailySet.questions.length > 0 && !initialized.current) {
      store.startSession(sessionUuid, dailySet.questions);
      initialized.current = true;
    }
  }, [dailySet?.questions, sessionUuid, store]);

  const totalQuestions = store.questions.length;
  // 피드백 표시 중엔 현재 문제(이전 인덱스)를 보여주어야 함
  const displayIndex = feedback ? store.currentIndex - 1 : store.currentIndex;
  const displayQuestion = store.questions[displayIndex];

  // 마지막 문제 완료 여부 — complete API 호출 및 결과 화면 이동 조건
  const shouldNavigateToResult = !feedback && store.currentIndex >= totalQuestions && totalQuestions > 0;

  // 마지막 문제 완료 → complete API 호출 후 결과 화면으로 이동
  useEffect(() => {
    if (!shouldNavigateToResult) return;
    const correctCount = store.results.filter((r) => r.isCorrect).length;
    store.setCorrectCount(correctCount);
    completeDailySet(correctCount, sessionUuid)
      .then(() => {
        // 데일리 세트 완료 후 관련 캐시 갱신 — 홈 화면 상태 최신화
        queryClient.invalidateQueries({ queryKey: ["dailySet"] });
        queryClient.invalidateQueries({ queryKey: ["heatmap"] });
        queryClient.invalidateQueries({ queryKey: ["progress"] });
      })
      .catch(() => {})
      .finally(() => {
        navigate("/daily-set/result", { replace: true });
      });
  }, [shouldNavigateToResult, store, sessionUuid, navigate, queryClient]);

  // 풀이 중 이탈 차단 — 피드백 표시 중이거나 제출 중이면 blocker 비활성화
  const blocker = useBlocker(!shouldNavigateToResult && feedback === null && !submitting && totalQuestions > 0);

  const handleSubmit = useCallback(
    async (selectedChoiceKey: string, choiceSetId: string, choices: readonly ChoiceItem[]) => {
      if (!displayQuestion) return;
      if (isProcessingRef.current) return;
      isProcessingRef.current = true;

      const selectedChoice = choices.find((c) => c.key === selectedChoiceKey);

      setSubmitting(true);
      try {
        const result = await submitAnswer(
          displayQuestion.questionUuid, choiceSetId, selectedChoiceKey, sessionUuid,
        );
        store.submitAndAdvance(
          displayQuestion.questionUuid,
          result.isCorrect,
          selectedChoiceKey,
          selectedChoice?.body ?? "",
          result.submissionUuid ?? undefined,
          choiceSetId,
        );
        // 해설함 등록 > 미리보기 즉시 조회 시작
        const explanationEntry = buildExplanationHistoryEntry({
          questionUuid: displayQuestion.questionUuid,
          choiceSetUuid: choiceSetId,
          selectedChoiceKey,
          questionNumber: displayIndex + 1,
          choices,
          result,
        });
        addExplanationEntry(explanationEntry);
        setFeedbackExplanationEntry(explanationEntry);
        setFeedback(result);
      } catch {
        // 제출 실패 시 홈으로 이동 — 세션 기록 손실을 감수하고 UX 안정성 우선
        navigate("/", { replace: true });
      } finally {
        isProcessingRef.current = false;
        setSubmitting(false);
      }
    },
    [displayQuestion, displayIndex, sessionUuid, store, navigate, addExplanationEntry],
  );

  // memberUuid 미사용 경고 억제 — 추후 신고 기능 등에 활용 예정
  void memberUuid;

  // 이미 완료한 경우 결과 화면으로 리다이렉트
  if (!isLoading && dailySet?.alreadyCompleted) {
    return <Navigate to="/daily-set/result" replace />;
  }

  // 세트 미준비 상태 — 로딩 완료 후 문제가 없는 경우
  if (!isLoading && (!dailySet?.questions || dailySet.questions.length === 0)) {
    return (
      <div className="flex flex-col items-center justify-center h-screen gap-4 text-center px-4">
        <p className="text-body text-text-secondary">오늘의 세트가 아직 준비 중이에요</p>
        <button type="button" className="btn-primary px-6" onClick={() => navigate("/", { replace: true })}>
          홈으로 가기
        </button>
      </div>
    );
  }

  const progressPct = totalQuestions > 0 ? (store.currentIndex / totalQuestions) * 100 : 0;

  return (
    <div className="flex flex-col h-screen max-w-120 mx-auto w-full">
      <div className="px-4 pt-3 pb-2">
        <PracticeTopBar
          exitIcon={<Home size={18} className="text-text-secondary" />}
          onExitClick={() => navigate("/")}
          title={<>데일리 세트 {store.currentIndex}/{totalQuestions}</>}
        />
        <ProgressBar
          fillPercent={progressPct}
          trackClassName="h-1.5 bg-border"
          fillClassName="bg-brand transition-all duration-300"
        />
      </div>

      {/* 피드백바 높이(~200px)만큼 bottom padding — 마지막 초이스카드가 가려지지 않게 */}
      <PracticeQuestionScrollArea hasFeedbackBar={!!feedback}>
        {displayQuestion && (
          <QuestionDetail
            key={`${displayQuestion.questionUuid}-${store.currentIndex}`}
            questionUuid={displayQuestion.questionUuid}
            practiceMode
            practiceSubmitLabel="확인"
            onPracticeSubmit={handleSubmit}
            showExecution={!!feedback}
          />
        )}
      </PracticeQuestionScrollArea>

      {feedback && (
        <PracticeFeedbackBar
          result={feedback}
          explanationEntry={feedbackExplanationEntry}
          nextLabel={store.currentIndex >= totalQuestions ? "결과 보기" : "다음 문제"}
          onNext={() => setFeedback(null)}
        />
      )}

      {/* AI 해설 비모달 패널 — 떠 있어도 다음 문제 진행 가능 (#521) */}
      <ExplanationPanel />

      {submitting && (
        <LoadingOverlay topicName="데일리 세트" staticMessage="채점 중이에요" subMessage="잠시만 기다려주세요" />
      )}

      <ConfirmModal
        isOpen={blocker.state === "blocked"}
        title="세트를 그만할까요?"
        description="지금 나가면 현재 진행 기록이 저장되지 않아요."
        cancelLabel="계속 풀기"
        confirmLabel="나가기"
        onCancel={() => blocker.reset?.()}
        onConfirm={() => blocker.proceed?.()}
      />
    </div>
  );
}
