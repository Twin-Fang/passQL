import { useState, useEffect } from "react";
import { generateChoices } from "../api/questions";
import type { ChoiceItem, QuestionDetail } from "../types/api";

// 60초 내에 complete/error가 오지 않으면 클라이언트 타임아웃으로 에러 전환
// AI 호출 + 샌드박스 3회 재시도 합산 예상 시간 기준
const SSE_TIMEOUT_MS = 60_000;

export interface ChoiceGenerationError {
  readonly code: string;
  readonly retryable: boolean;
}

/**
 * 문제 선택지 결정: GET 응답의 OK 선택지 세트, 없으면 SSE 생성 (타임아웃·재시도 포함)
 * SSE로 받은 선택지가 있으면 우선 사용
 */
export function useQuestionChoices(question: QuestionDetail | undefined, questionUuid: string | undefined) {
  // SSE로 생성된 선택지 (choiceSets[]가 비어있을 때 채워짐)
  const [sseChoices, setSseChoices] = useState<readonly ChoiceItem[] | null>(
    null,
  );
  const [sseChoiceSetId, setSseChoiceSetId] = useState<string | null>(null);
  const [sseError, setSseError] = useState<ChoiceGenerationError | null>(null);
  // 재시도 트리거용 카운터
  const [sseRetryCount, setSseRetryCount] = useState(0);

  // questionUuid가 바뀌면 SSE 상태 전체 초기화
  // practiceMode에서 같은 컴포넌트 인스턴스로 문제가 교체될 때 이전 SSE 에러/결과가 남아
  // needsSseGeneration의 !sseError 조건을 막아 새 SSE가 발화되지 않는 문제 방지
  useEffect(() => {
    setSseChoices(null);
    setSseChoiceSetId(null);
    setSseError(null);
    setSseRetryCount(0);
  }, [questionUuid]);

  const activeChoiceSet = question?.choiceSets?.find(
    (cs) => cs.status === "OK",
  );

  useEffect(() => {
    // question 비동기 로드 전이거나 UUID 없으면 스킵
    if (!question || !questionUuid) return;

    // SSE 생성이 필요 없는 조건:
    //   - GET 응답에 이미 OK 선택지 있음 (activeChoiceSet != null)
    //   - SSE complete로 받은 선택지 있음 (sseChoices != null)
    //   - 에러 상태 (재시도 버튼 대기 중, sseRetryCount 변경 시 다시 실행됨)
    const needsGeneration =
      (question.executionMode === "EXECUTABLE" ||
        question.executionMode === "CONCEPT_ONLY") &&
      activeChoiceSet == null &&
      sseChoices == null &&
      !sseError;

    if (!needsGeneration) return;

    let cancelled = false;
    let streamCleanup: (() => void) | null = null;
    const timeoutId = setTimeout(() => {
      streamCleanup?.();
      if (!cancelled) {
        setSseError({ code: "TIMEOUT", retryable: true });
      }
    }, SSE_TIMEOUT_MS);

    const cleanup = generateChoices(questionUuid, {
      onStatus: () => {},
      onComplete: (response) => {
        clearTimeout(timeoutId);
        if (!cancelled) {
          setSseChoices(response.choices);
          setSseChoiceSetId(response.choiceSetId);
        }
      },
      onError: (event) => {
        clearTimeout(timeoutId);
        if (!cancelled) {
          setSseError({ code: event.code, retryable: event.retryable });
        }
      },
    });
    streamCleanup = cleanup;

    return () => {
      // StrictMode 이중 실행: 첫 번째 cleanup에서 cancelled=true로 콜백 무력화 + abort
      // 두 번째 effect 실행 시 sseChoices/sseError가 여전히 null → needsGeneration=true
      // → 두 번째 effect가 실제 SSE 연결을 담당 (React 권장 패턴)
      cancelled = true;
      clearTimeout(timeoutId);
      cleanup();
    };
    // deps 설계:
    //   question      — 비동기 로드 완료 시 effect 실행 (null → 객체 전환 감지)
    //   questionUuid  — 문제 변경 시 새 SSE 시작
    //   sseRetryCount — 재시도 버튼 클릭 시 새 SSE 시작
    // sseChoices/sseError/activeChoiceSet은 effect 내부 needsGeneration 판단에만 사용
    // deps에 포함하면 onComplete/onError 콜백 후 effect가 재실행되어 중복 요청 발생
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [question, questionUuid, sseRetryCount]);

  // SSE 실패 후 재시도 (상태 초기화 > 카운터 증가로 effect 재실행)
  const retryChoiceGeneration = () => {
    setSseChoices(null);
    setSseChoiceSetId(null);
    setSseError(null);
    setSseRetryCount((c) => c + 1);
  };

  return {
    choices: sseChoices ?? activeChoiceSet?.items ?? [],
    choiceSetId: sseChoiceSetId ?? activeChoiceSet?.choiceSetUuid ?? "",
    choiceGenerationError: sseError,
    retryChoiceGeneration,
  };
}
