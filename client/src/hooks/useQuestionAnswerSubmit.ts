import { useState, useCallback, useRef } from "react";
import { useNavigate, useBlocker } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { useSubmitAnswer } from "./useQuestionDetail";
import type { ChoiceItem, QuestionDetail, SubmitResult } from "../types/api";

interface QuestionAnswerSubmitOptions {
  readonly question: QuestionDetail | undefined;
  readonly questionUuid: string | undefined;
  readonly sessionUuid?: string;
  readonly selectedKey: string | null;
  readonly choices: readonly ChoiceItem[];
  readonly choiceSetId: string;
  readonly practiceMode?: boolean;
  readonly onPracticeSubmit?: (
    selectedChoiceKey: string,
    choiceSetId: string,
    choices: readonly ChoiceItem[],
  ) => void;
  readonly onSubmitSuccess?: (result: SubmitResult, questionUuid: string) => void;
}

/**
 * 답안 제출: 연타 방지 > 연습 모드는 부모 콜백, 단독 모드는 채점 API > 홈 데이터 재조회 > 결과 화면 이동
 * 단독 모드 제출 완료 전까지 이탈 차단 (blocker)
 */
export function useQuestionAnswerSubmit({
  question,
  questionUuid,
  sessionUuid,
  selectedKey,
  choices,
  choiceSetId,
  practiceMode,
  onPracticeSubmit,
  onSubmitSuccess,
}: QuestionAnswerSubmitOptions) {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const submitMutation = useSubmitAnswer(questionUuid!, sessionUuid);
  // 제출 완료 여부 — true가 되면 이탈 차단 해제
  const [submitted, setSubmitted] = useState(false);
  // 연타 방지 — key 변경(문제 교체) 시 컴포넌트 리마운트로 자동 초기화
  const isSubmittingRef = useRef(false);

  // 단독 풀이 모드에서 제출 완료 전까지 이탈 차단 — practiceMode는 부모가 이미 차단하므로 제외
  // practiceMode !== true로 명시해 undefined(단독 모드 기본값)도 정확히 처리
  // submitMutation.isPending 중에도 해제: onSuccess의 navigate가 blocker에 걸리지 않게 (#146 동일 패턴)
  const blocker = useBlocker(practiceMode !== true && !submitted && !submitMutation.isPending);

  const submitSelectedAnswer = useCallback(() => {
    if (!selectedKey || !question || !choiceSetId) return;
    if (isSubmittingRef.current) return;
    isSubmittingRef.current = true;
    if (practiceMode && onPracticeSubmit) {
      onPracticeSubmit(selectedKey, choiceSetId, choices);
      return;
    }
    submitMutation.mutate(
      { choiceSetId, selectedChoiceKey: selectedKey },
      {
        onSuccess: (result) => {
          // 제출 완료 — 이탈 차단 해제 후 네비게이션
          setSubmitted(true);
          const fullResult = {
            ...result,
            selectedKey,
            questionUuid,
            // executionMode는 QuestionDetail에서 전달 (SubmitResult에서 제거됨)
            executionMode: question.executionMode,
            // 선택지 본문 전달: EXECUTABLE은 SQL 실행 비교용, CONCEPT_ONLY는 선택지 텍스트 표시용
            choices,
            // 결과 화면에서 문제 지문/토픽/스키마 표시용 — 백엔드 추가 호출 없이 전달
            stem: question.stem,
            topicName: question.topicName,
            schemaTables: question.schemaTables ?? [],
            schemaDdl: question.schemaDdl ?? null,
            schemaSampleData: question.schemaSampleData ?? null,
          };
          // 제출 완료 시 추천 문제·학습 현황 무효화 — 홈 복귀(마운트) 시 재요청, 화면에 떠 있는 쿼리만 즉시 재요청
          queryClient.invalidateQueries({ queryKey: ["recommendations"] });
          queryClient.invalidateQueries({ queryKey: ["heatmap"] });
          queryClient.invalidateQueries({ queryKey: ["progress"] });
          if (onSubmitSuccess) {
            // 데일리 챌린지 등 호출자가 네비게이션 제어
            onSubmitSuccess(fullResult as SubmitResult, questionUuid!);
          } else {
            navigate(`/questions/${questionUuid}/result`, {
              state: fullResult,
            });
          }
        },
      },
    );
  }, [
    selectedKey,
    choiceSetId,
    choices,
    submitMutation,
    question,
    questionUuid,
    navigate,
    practiceMode,
    onPracticeSubmit,
    onSubmitSuccess,
    queryClient,
  ]);

  return {
    isSubmitPending: submitMutation.isPending,
    submitSelectedAnswer,
    blocker,
  };
}
