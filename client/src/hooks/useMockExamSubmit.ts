import { useCallback, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { submitMockExamAttempt } from "../api/mockExams";
import { toApiErrorCode } from "../api/client";
import { MOCK_EXAM_QUERY_KEYS } from "./useMockExam";
import { toMockExamResultPath } from "../constants/mockExamRoutes";
import { useMockExamPendingAnswerStore } from "../stores/mockExamPendingAnswerStore";
import type { MockExamAnswerEntry } from "../types/api";

interface MockExamSubmitOptions {
  readonly attemptUuid: string;
  readonly toUnsavedAnswerEntries: () => MockExamAnswerEntry[];
}

/**
 * 모의고사 제출: 저장 전 답 묶음 전송 > 결과 캐시 > 목록·추이 무효화 > 결과 화면 (멱등, 중복 탭 차단)
 * 이미 제출됨(다른 기기·시간 끝 서버 채점)도 결과 화면으로, 그 외 실패는 다시 시도 안내
 */
export function useMockExamSubmit({ attemptUuid, toUnsavedAnswerEntries }: MockExamSubmitOptions) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const clearAttempt = useMockExamPendingAnswerStore((state) => state.clearAttempt);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [hasSubmitFailed, setHasSubmitFailed] = useState(false);
  const isSubmittingRef = useRef(false);

  // 결과 화면 이동 (목록·추이는 다음 진입 때 새로 받음)
  const moveToResult = useCallback(() => {
    clearAttempt(attemptUuid);
    void queryClient.invalidateQueries({ queryKey: MOCK_EXAM_QUERY_KEYS.roundsPrefix, refetchType: "none" });
    void queryClient.invalidateQueries({ queryKey: MOCK_EXAM_QUERY_KEYS.historyPrefix, refetchType: "none" });
    navigate(toMockExamResultPath(attemptUuid), { replace: true });
  }, [attemptUuid, clearAttempt, navigate, queryClient]);

  const submit = useCallback(async () => {
    if (isSubmittingRef.current) return;
    isSubmittingRef.current = true;
    setIsSubmitting(true);
    setHasSubmitFailed(false);
    try {
      const submittedResult = await submitMockExamAttempt(attemptUuid, toUnsavedAnswerEntries());
      queryClient.setQueryData(MOCK_EXAM_QUERY_KEYS.result(attemptUuid), submittedResult);
      moveToResult();
    } catch (error) {
      if (toApiErrorCode(error) === "MOCK_EXAM_ALREADY_SUBMITTED") {
        moveToResult();
        return;
      }
      console.warn("[mock exam submit] failed", error);
      isSubmittingRef.current = false;
      setIsSubmitting(false);
      setHasSubmitFailed(true);
    }
  }, [attemptUuid, moveToResult, queryClient, toUnsavedAnswerEntries]);

  return { isSubmitting, hasSubmitFailed, submit, moveToResult };
}
