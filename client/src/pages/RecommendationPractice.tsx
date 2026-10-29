import { useState, useCallback, useRef } from "react";
import { useNavigate, useParams, useLocation, useBlocker } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { Home } from "lucide-react";
import { submitAnswer } from "../api/questions";
import { invalidateLearningRecordQueries } from "../lib/learningRecordQueries";
import { usePracticeStore } from "../stores/practiceStore";

import QuestionDetail from "./QuestionDetail";
import PracticeFeedbackBar from "../components/PracticeFeedbackBar";
import ExitPracticeConfirmModal from "../components/practice/ExitPracticeConfirmModal";
import LoadingOverlay from "../components/LoadingOverlay";
import PracticeTopBar from "../components/practice/PracticeTopBar";
import PracticeQuestionScrollArea from "../components/practice/PracticeQuestionScrollArea";
import ExplanationPanel from "../components/aiExplanation/ExplanationPanel";
import {
  buildExplanationHistoryEntry,
  useExplanationHistoryStore,
  type ExplanationHistoryEntry,
} from "../stores/explanationHistoryStore";
import type { ChoiceItem, SubmitResult } from "../types/api";

export default function RecommendationPractice() {
  const { questionUuid } = useParams<{ questionUuid: string }>();
  const navigate = useNavigate();
  const location = useLocation();
  const queryClient = useQueryClient();
  const { setReturnStep, sessionId: storeSessionId } = usePracticeStore();

  // PracticeResult 등 이전 화면으로 복귀할 경로 — 없으면 홈으로
  const locationState = location.state as { returnPath?: string; initialStep?: number } | null;
  const returnPath = locationState?.returnPath ?? "/";
  // PracticeResult에서 진입한 경우 — 타이틀 "틀린 문제", 복귀 시 step3 유지
  const isPracticeReview = returnPath !== "/";
  const returnInitialStep = locationState?.initialStep ?? 0;

  const [feedback, setFeedback] = useState<SubmitResult | null>(null);
  // 피드백 바 해설 미리보기 대상 (#521)
  const [feedbackExplanationEntry, setFeedbackExplanationEntry] = useState<ExplanationHistoryEntry | null>(null);
  const addExplanationEntry = useExplanationHistoryStore((state) => state.addEntry);
  // 제출 API 호출 중 화면 조작 차단
  const [isSubmitting, setIsSubmitting] = useState(false);
  // 연타 방지 — React state는 async 클로저에서 stale하므로 ref로 동기 플래그 관리
  const isProcessingRef = useRef(false);
  // 다시 풀기 시 QuestionDetail 강제 리마운트 — isSubmittingRef 초기화 목적
  const [retryCount, setRetryCount] = useState(0);
  // sessionUuid — 마운트 시 1회 생성하여 다시 풀기 시에도 동일 세션으로 집계
  const [sessionUuid] = useState(() => storeSessionId ?? crypto.randomUUID());

  // 제출 완료 전까지 이탈 차단 — isSubmitting 중에는 해제 (catch navigate 허용)
  const blocker = useBlocker(feedback === null && !isSubmitting);

  const handlePracticeSubmit = useCallback(
    async (selectedChoiceKey: string, choiceSetId: string, choices: readonly ChoiceItem[]) => {
      if (!questionUuid) return;
      // 연타로 인한 중복 제출 방지
      if (isProcessingRef.current) return;
      isProcessingRef.current = true;

      setIsSubmitting(true);
      try {
        const result = await submitAnswer(questionUuid, choiceSetId, selectedChoiceKey, sessionUuid);
        // 추천 문제·학습 현황 무효화 (복귀 시 재요청) — 홈 복귀 시 새 목록·heatmap 반영
        // excludeUuids=[]로 새 랜덤 세트를 받음 — 문제를 푼 직후이므로 의도된 동작
        queryClient.invalidateQueries({ queryKey: ["recommendations"] });
        invalidateLearningRecordQueries(queryClient);
        // 해설함 등록 > 미리보기 즉시 조회 시작 (다시 풀기 기록도 해설함에 남음)
        const explanationEntry = buildExplanationHistoryEntry({
          questionUuid,
          choiceSetUuid: choiceSetId,
          selectedChoiceKey,
          choices,
          result,
        });
        addExplanationEntry(explanationEntry);
        setFeedbackExplanationEntry(explanationEntry);
        setFeedback(result);
      } catch {
        navigate("/", { replace: true });
      } finally {
        isProcessingRef.current = false;
        setIsSubmitting(false);
      }
    },
    [questionUuid, navigate, queryClient, sessionUuid, addExplanationEntry],
  );

  if (!questionUuid) {
    return null;
  }

  return (
    <div className="flex flex-col h-screen max-w-120 mx-auto w-full">
      {/* 단건 풀이 헤더 */}
      <div className="px-4 pt-3 pb-2">
        <PracticeTopBar
          exitIcon={<Home size={18} className="text-text-secondary" />}
          onExitClick={() => navigate("/")}
          title={isPracticeReview ? "틀린 문제" : "추천 문제"}
        />
        {/* 제출 전: 비어있음 / 제출 후: 완료 표시 */}
        <div className="w-full h-1.5 bg-border rounded-full overflow-hidden">
          <div
            className={`h-full bg-brand rounded-full transition-all duration-300 ${feedback ? "w-full" : "w-0"}`}
          />
        </div>
      </div>

      {/* 피드백바 높이만큼 bottom padding — 마지막 선택지 카드가 가려지지 않게 */}
      <PracticeQuestionScrollArea hasFeedbackBar={!!feedback}>
        {/* 제출 후 showExecution=true — ChoiceCard 안에 SQL 실행 버튼 표시 */}
        <QuestionDetail
          key={`${questionUuid}-${retryCount}`}
          questionUuid={questionUuid}
          practiceMode
          practiceSubmitLabel="확인"
          onPracticeSubmit={handlePracticeSubmit}
          showExecution={!!feedback}
        />
      </PracticeQuestionScrollArea>

      {/* 제출 후 인라인 피드백 — returnPath 있으면 "돌아가기", 없으면 "홈으로 가기" */}
      {feedback && (
        <PracticeFeedbackBar
          result={feedback}
          explanationEntry={feedbackExplanationEntry}
          nextLabel={isPracticeReview ? "돌아가기" : "홈으로 가기"}
          onNext={() => {
            // location.state 대신 store를 통해 returnStep 전달 — React Router v7 state 전달 불안정 이슈 우회
            if (isPracticeReview) setReturnStep(returnInitialStep);
            navigate(returnPath, { replace: true });
          }}
          {...(!feedback.isCorrect && {
            secondaryLabel: "다시 풀기",
            // 피드백 닫힘 후 초이스카드 즉시 눌림 방지 — 300ms 쿨다운
            // retryCount 변경 → QuestionDetail 리마운트 → isSubmittingRef 초기화
            onSecondary: () => {
              isProcessingRef.current = true;
              setFeedback(null);
              setRetryCount((c) => c + 1);
              setTimeout(() => { isProcessingRef.current = false; }, 300);
            },
          })}
        />
      )}

      {/* AI 해설 비모달 패널 — 다시 풀기 중에도 앞 해설을 볼 수 있음 (#521) */}
      <ExplanationPanel />

      {/* 채점 중 오버레이 — 제출 API 응답 전 화면 조작 차단 */}
      {isSubmitting && (
        <LoadingOverlay
          topicName="추천 문제"
          staticMessage="채점 중이에요"
          subMessage="잠시만 기다려주세요"
        />
      )}

      {/* 이탈 방지 확인 모달 */}
      <ExitPracticeConfirmModal
        isOpen={blocker.state === "blocked"}
        onCancel={() => blocker.reset?.()}
        onConfirm={() => blocker.proceed?.()}
      />
    </div>
  );
}
