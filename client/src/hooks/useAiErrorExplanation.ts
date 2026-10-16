import { useState, useCallback } from "react";
import { useMutation } from "@tanstack/react-query";
import { explainError } from "../api/ai";
import type { ChoiceItem } from "../types/api";

/**
 * 선택지 SQL 실행 에러 AI 해설: 시트 열기 > 해설 요청 > 본문 표시
 */
export function useAiErrorExplanation(choices: readonly ChoiceItem[], questionUuid: string) {
  const [isSheetOpen, setIsSheetOpen] = useState(false);
  const [explanationText, setExplanationText] = useState("");

  const explainMutation = useMutation({ mutationFn: explainError });
  const requestExplanation = explainMutation.mutate;

  const askAiAboutError = useCallback(
    (choiceKey: string, _errorCode: string, errorMessage: string) => {
      setIsSheetOpen(true);
      setExplanationText("");
      const choice = choices.find((c) => c.key === choiceKey);
      // 호출 단위 onSuccess: 마지막 요청 응답만 반영 (앞선 요청의 늦은 응답 무시)
      requestExplanation(
        { questionUuid, sql: choice?.body ?? "", errorMessage },
        { onSuccess: (result) => setExplanationText(result.text) },
      );
    },
    [choices, questionUuid, requestExplanation],
  );

  return {
    isSheetOpen,
    explanationText,
    isExplanationLoading: explainMutation.isPending,
    isExplanationError: explainMutation.isError,
    askAiAboutError,
    closeSheet: () => setIsSheetOpen(false),
  };
}
