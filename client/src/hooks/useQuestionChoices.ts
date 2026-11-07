import { useState, useEffect, useRef, useCallback } from "react";
import type { ChoiceGenerationError } from "../lib/choiceGenerationError";
import { startChoiceGenerationStream, type PreparedChoiceSet } from "../lib/choiceGenerationStream";
import {
  FRESH_CHOICE_MODE,
  VERIFIED_CHOICE_MODE,
  planChoiceModeSwitch,
  type ChoiceModeSwitchAction,
} from "../lib/choiceModeSwitchPlan";
import { useEffectiveChoiceMode } from "./useEffectiveChoiceMode";
import type { ChoiceGenerationMode, ChoiceItem, QuestionDetail } from "../types/api";

// 바로 쓸 수 있는 선택지 세트 상태값 (서버 choice_set.status)
const READY_CHOICE_SET_STATUS = "OK";
// 선택지를 SSE 로 만들 수 있는 문제 실행 방식
const GENERATABLE_EXECUTION_MODES: ReadonlySet<QuestionDetail["executionMode"]> = new Set([
  "EXECUTABLE",
  "CONCEPT_ONLY",
]);
const NO_CHOICES: readonly ChoiceItem[] = [];

/** 상세 응답의 OK 세트 > 검증된 보기 (없으면 null) */
function toReadyChoiceSet(question: QuestionDetail): PreparedChoiceSet | null {
  const readyChoiceSet = question.choiceSets?.find((choiceSet) => choiceSet.status === READY_CHOICE_SET_STATUS);
  return readyChoiceSet ? { choiceSetId: readyChoiceSet.choiceSetUuid, choices: readyChoiceSet.items } : null;
}

export interface ChoiceModeChangeRequest {
  // 저장된 새 방식의 실효 모드
  readonly targetMode: ChoiceGenerationMode;
  // 제출 중·뒤인지 (채점한 보기는 바꾸지 않음)
  readonly hasSubmissionStarted: boolean;
}

/**
 * 문제 선택지 준비 (#913): AI 새 보기면 OK 세트가 있어도 SSE 로 새로 받기 (고정 보기 문제는 서버가 고정 세트로 답함, DEC-0251)
 * 그 외 OK 세트 재사용 > 없으면 SSE 생성. 풀이 중 보기 방식 변경은 applyChoiceModeChange 로 지금 문제에 반영
 */
export function useQuestionChoices(question: QuestionDetail | undefined, questionUuid: string | undefined) {
  const { effectiveMode, isModeSettled } = useEffectiveChoiceMode();
  const [shownChoiceSet, setShownChoiceSet] = useState<PreparedChoiceSet | null>(null);
  const [generationError, setGenerationError] = useState<ChoiceGenerationError | null>(null);

  // 받아 둔 세트: 검증된 보기(상세의 OK 세트 또는 검증된 보기 모드 생성), AI 새 보기(새 보기 모드 생성)
  const readyChoiceSetRef = useRef<PreparedChoiceSet | null>(null);
  const freshChoiceSetRef = useRef<PreparedChoiceSet | null>(null);
  // 진행 중인 생성의 모드 (없으면 null). 보기 방식을 바꿔도 끊지 않고 결과만 보관
  const inFlightGenerationModeRef = useRef<ChoiceGenerationMode | null>(null);
  // 진행 중인 생성 결과를 화면에 보여 줄지 (다른 세트로 바꿔 둔 동안은 보관만)
  const isGenerationResultShownRef = useRef(true);
  const stopGenerationRef = useRef<(() => void) | null>(null);
  // 지금 문제에 적용 중인 실효 모드 (다시 시도 기준)
  const appliedModeRef = useRef<ChoiceGenerationMode>(VERIFIED_CHOICE_MODE);

  const stopGeneration = useCallback(() => {
    stopGenerationRef.current?.();
    stopGenerationRef.current = null;
    inFlightGenerationModeRef.current = null;
  }, []);

  /** 받아 둔 세트로 교체 (진행 중 생성은 끊지 않고 결과만 보관) */
  const showPreparedChoiceSet = useCallback((choiceSet: PreparedChoiceSet | null) => {
    isGenerationResultShownRef.current = false;
    setGenerationError(null);
    setShownChoiceSet(choiceSet);
  }, []);

  /** SSE 생성 시작 (진행 중 생성은 끊고 새로) > 결과는 생성 모드 자리에 보관 > 보여 주는 중이면 화면 반영 */
  const startGeneration = useCallback(
    (generationMode: ChoiceGenerationMode) => {
      if (!questionUuid) return;
      stopGeneration();
      isGenerationResultShownRef.current = true;
      inFlightGenerationModeRef.current = generationMode;
      setShownChoiceSet(null);
      setGenerationError(null);
      stopGenerationRef.current = startChoiceGenerationStream(questionUuid, {
        onComplete: (generatedChoiceSet) => {
          if (generationMode === FRESH_CHOICE_MODE) freshChoiceSetRef.current = generatedChoiceSet;
          else readyChoiceSetRef.current ??= generatedChoiceSet;
          stopGenerationRef.current = null;
          inFlightGenerationModeRef.current = null;
          if (isGenerationResultShownRef.current) setShownChoiceSet(generatedChoiceSet);
        },
        onError: (error) => {
          stopGenerationRef.current = null;
          inFlightGenerationModeRef.current = null;
          // 보관만 하던 생성이면 화면은 그대로
          if (isGenerationResultShownRef.current) setGenerationError(error);
        },
      });
    },
    [questionUuid, stopGeneration],
  );

  // 문제·실효 모드가 정해지면 1회 준비 (모드 조회 실패·비로그인은 검증된 보기)
  const hasQuestionLoaded = question != null;
  useEffect(() => {
    if (!question || !questionUuid || !isModeSettled) return;
    const readyChoiceSet = toReadyChoiceSet(question);
    readyChoiceSetRef.current = readyChoiceSet;
    freshChoiceSetRef.current = null;
    appliedModeRef.current = effectiveMode ?? VERIFIED_CHOICE_MODE;
    const shouldGenerate =
      GENERATABLE_EXECUTION_MODES.has(question.executionMode) &&
      (readyChoiceSet == null || appliedModeRef.current === FRESH_CHOICE_MODE);
    if (shouldGenerate) startGeneration(appliedModeRef.current);
    else showPreparedChoiceSet(readyChoiceSet);
    // StrictMode 이중 실행·문제 교체·화면 이탈 시 진행 중 생성 중단
    return stopGeneration;
    // deps: 문제 로드·교체, 모드 확정 시점만. 모드 변경은 applyChoiceModeChange 가 반영 (재준비하면 받아 둔 세트를 잃음)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [questionUuid, hasQuestionLoaded, isModeSettled]);

  // 생성 실패 후 다시 시도 (지금 적용 중인 모드로)
  const retryChoiceGeneration = useCallback(() => startGeneration(appliedModeRef.current), [startGeneration]);

  /** 풀이 중 보기 방식 변경(저장 성공 뒤) 반영: 제출 전이면 지금 문제 보기 교체, 제출 중·뒤면 다음 풀이부터 (판정 planChoiceModeSwitch) */
  const applyChoiceModeChange = useCallback(
    ({ targetMode, hasSubmissionStarted }: ChoiceModeChangeRequest): ChoiceModeSwitchAction => {
      const action = planChoiceModeSwitch({
        hasSubmissionStarted,
        targetMode,
        hasReadyChoiceSet: readyChoiceSetRef.current != null,
        hasFreshChoiceSet: freshChoiceSetRef.current != null,
        inFlightGenerationMode: inFlightGenerationModeRef.current,
      });
      if (action === "KEEP_UNTIL_NEXT_SOLVE") return action;
      appliedModeRef.current = targetMode;
      switch (action) {
        case "SHOW_READY_CHOICE_SET":
          showPreparedChoiceSet(readyChoiceSetRef.current);
          break;
        case "SHOW_FRESH_CHOICE_SET":
          showPreparedChoiceSet(freshChoiceSetRef.current);
          break;
        case "AWAIT_IN_FLIGHT_GENERATION":
          isGenerationResultShownRef.current = true;
          setShownChoiceSet(null);
          setGenerationError(null);
          break;
        case "GENERATE_CHOICES":
          startGeneration(targetMode);
          break;
      }
      return action;
    },
    [showPreparedChoiceSet, startGeneration],
  );

  return {
    choices: shownChoiceSet?.choices ?? NO_CHOICES,
    choiceSetId: shownChoiceSet?.choiceSetId ?? "",
    choiceGenerationError: generationError,
    retryChoiceGeneration,
    applyChoiceModeChange,
  };
}
