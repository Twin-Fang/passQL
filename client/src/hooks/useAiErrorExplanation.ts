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

  const explainMutation = useMutation({
    mutationFn: explainError,
    onSuccess: (result) => setExplanationText(result.text),
  });

  const askAiAboutError = useCallback(
    (choiceKey: string, _errorCode: string, errorMessage: string) => {
      setIsSheetOpen(true);
      setExplanationText("");
      const choice = choices.find((c) => c.key === choiceKey);
      explainMutation.mutate({
        questionUuid,
        sql: choice?.body ?? "",
        errorMessage,
      });
    },
    [choices, questionUuid, explainMutation],
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
