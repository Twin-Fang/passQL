import { useState, useCallback, useRef } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { submitAnswer } from "../api/questions";
import { practiceAiCommentQueryOptions } from "./usePracticeAiComment";
import type { ChoiceItem, QuestionSummary, SubmitResult } from "../types/api";

interface PracticeSetSubmitOptions {
  readonly questions: readonly QuestionSummary[];
  readonly currentIndex: number;
  readonly storeSessionId: string | null;
  readonly submitAndAdvance: (
    questionUuid: string,
    isCorrect: boolean,
    selectedChoiceKey: string,
    selectedChoiceBody: string,
    submissionUuid?: string,
    choiceSetUuid?: string,
  ) => void;
}

// 피드백바 닫힘 후 새 제출 차단 시간 (다음 문제 렌더 완료까지, ms)
const NEXT_QUESTION_TAP_GUARD_MILLISECONDS = 300;

/**
 * 연습 세트 답안 제출: 연타 방지 > 채점 API > 결과 저장·다음 인덱스 (실패 시 오답 처리)
 * 피드백 표시 중에는 직전 문제를 계속 보여 줌
 */
export function usePracticeSetSubmit({ questions, currentIndex, storeSessionId, submitAndAdvance }: PracticeSetSubmitOptions) {
  const queryClient = useQueryClient();
  const [feedback, setFeedback] = useState<SubmitResult | null>(null);
  // 제출 시점의 choiceSetUuid — SubmitResult에 없으므로 별도 보관 (신고 API에 필요)
  const [feedbackChoiceSetUuid, setFeedbackChoiceSetUuid] = useState<string | undefined>(undefined);
  // 답안 제출 API 호출 중 화면 조작 차단
  const [submitting, setSubmitting] = useState(false);
  // 연타 방지 — React state는 async 클로저에서 stale하므로 ref로 동기 플래그 관리
  const isProcessingRef = useRef(false);

  const totalQuestions = questions.length;
  const displayIndex = feedback ? currentIndex - 1 : currentIndex;
  const displayQuestion = questions[displayIndex];

  const submitPracticeAnswer = useCallback(
    async (
      selectedChoiceKey: string,
      choiceSetId: string,
      choices: readonly ChoiceItem[],
    ) => {
      if (!displayQuestion) return;
      // 연타로 인한 중복 제출 방지 — ref는 동기적으로 즉시 반영됨
      if (isProcessingRef.current) return;
      isProcessingRef.current = true;
      // 결과 화면에서 선택지 키(A/B/C/D) 대신 실제 선택지 텍스트를 보여주기 위해 body 추출
      const selectedChoiceBody = choices.find((c) => c.key === selectedChoiceKey)?.body ?? selectedChoiceKey;
      setSubmitting(true);
      try {
        const result = await submitAnswer(
          displayQuestion.questionUuid,
          choiceSetId,
          selectedChoiceKey,
          // sessionId는 startSession 시 crypto.randomUUID()로 생성 — AI 코멘트 세션 집계에 사용
          storeSessionId ?? crypto.randomUUID(),
        );
        setFeedback(result);
        setFeedbackChoiceSetUuid(choiceSetId);
        // submissionUuid: 백엔드가 응답에 포함하면 전달, 없으면 undefined → 결과 화면에서 신고 버튼 미표시
        submitAndAdvance(
          displayQuestion.questionUuid,
          result.isCorrect,
          selectedChoiceKey,
          selectedChoiceBody,
          result.submissionUuid ?? undefined,
          choiceSetId,
        );
        // 마지막 문제 제출 완료 시에만 갱신 — 도중 이탈은 갱신하지 않기로 결정
        // invalidateQueries: 화면에 떠 있는 쿼리만 즉시 재요청, 나머지는 다음 진입 시 재요청
        if (currentIndex + 1 >= totalQuestions) {
          queryClient.invalidateQueries({ queryKey: ["heatmap"] });
          queryClient.invalidateQueries({ queryKey: ["progress"] });
          // AI 코멘트 미리 받기: LLM 대기를 결과 화면 점수 애니메이션 뒤로 숨김
          if (storeSessionId) {
            void queryClient.prefetchQuery(practiceAiCommentQueryOptions(storeSessionId));
          }
        }
      } catch {
        const fallback: SubmitResult = {
          isCorrect: false,
          correctKey: "?",
          rationale: "",
          selectedResult: null,
          correctResult: null,
          selectedSql: null,
          correctSql: null,
          submissionUuid: null,
          explanation: null,
          structuredExplanation: null,
        };
        setFeedback(fallback);
        // 제출 실패 시 submissionUuid 없음 → 신고 버튼 미표시
        submitAndAdvance(
          displayQuestion.questionUuid,
          false,
          selectedChoiceKey,
          selectedChoiceBody,
          undefined,
          choiceSetId,
        );
      } finally {
        isProcessingRef.current = false;
        setSubmitting(false);
      }
    },
    [displayQuestion, submitAndAdvance, currentIndex, totalQuestions, queryClient, storeSessionId],
  );

  const clearFeedbackForNextQuestion = useCallback(() => {
    // 피드백바 닫힘 → 다음 문제 렌더 직후 초이스카드가 즉시 눌리는 탭-스루 방지
    // isProcessingRef를 잠근 뒤 렌더 완료 시점(~300ms)까지 새 제출 차단
    isProcessingRef.current = true;
    setFeedback(null);
    setFeedbackChoiceSetUuid(undefined);
    setTimeout(() => {
      isProcessingRef.current = false;
    }, NEXT_QUESTION_TAP_GUARD_MILLISECONDS);
  }, []);

  return {
    feedback,
    feedbackChoiceSetUuid,
    isSubmitting: submitting,
    displayIndex,
    displayQuestion,
    submitPracticeAnswer,
    clearFeedbackForNextQuestion,
  };
}
