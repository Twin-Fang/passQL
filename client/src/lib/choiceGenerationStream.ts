import { generateChoices } from "../api/questions";
import {
  CHOICE_GENERATION_TIMEOUT_ERROR,
  toChoiceGenerationRejectionError,
  toChoiceGenerationStreamError,
  type ChoiceGenerationError,
} from "./choiceGenerationError";
import type { ChoiceItem } from "../types/api";

// 60초 내에 complete/error가 오지 않으면 클라이언트 타임아웃으로 에러 전환
// AI 호출 + 샌드박스 3회 재시도 합산 예상 시간 기준
const CHOICE_GENERATION_TIMEOUT_MILLISECONDS = 60_000;

/** 화면에 보여 줄 수 있는 선택지 세트 (검증된 세트 또는 생성 결과) */
export interface PreparedChoiceSet {
  readonly choiceSetId: string;
  readonly choices: readonly ChoiceItem[];
}

interface ChoiceGenerationStreamCallbacks {
  readonly onComplete: (choiceSet: PreparedChoiceSet) => void;
  readonly onError: (error: ChoiceGenerationError) => void;
}

/**
 * 선택지 생성 SSE 1회: 요청 > complete·error·시작 전 거부·60초 타임아웃 중 먼저 온 것 하나만 콜백
 * 반환: 중단 함수 (중단 뒤에는 콜백 없음)
 */
export function startChoiceGenerationStream(
  questionUuid: string,
  { onComplete, onError }: ChoiceGenerationStreamCallbacks,
): () => void {
  let isFinished = false;
  let closeStream: () => void = () => {};

  // 먼저 끝난 결과만 전달 (타임아웃·스트림 종료 경합)
  const finishOnce = (deliver: () => void) => {
    if (isFinished) return;
    isFinished = true;
    clearTimeout(timeoutId);
    deliver();
  };

  const timeoutId = setTimeout(() => {
    finishOnce(() => onError(CHOICE_GENERATION_TIMEOUT_ERROR));
    closeStream();
  }, CHOICE_GENERATION_TIMEOUT_MILLISECONDS);

  closeStream = generateChoices(questionUuid, {
    onStatus: () => {},
    onComplete: (response) =>
      finishOnce(() => onComplete({ choiceSetId: response.choiceSetId, choices: response.choices })),
    onError: (event) => finishOnce(() => onError(toChoiceGenerationStreamError(event))),
    // 스트림 시작 전 거부 (한도·프로 필요·요청 과다 등 오류 JSON)
    onRejected: (rejection) => finishOnce(() => onError(toChoiceGenerationRejectionError(rejection))),
  });

  return () => {
    finishOnce(() => {});
    closeStream();
  };
}
