import { apiFetch } from "./client";
import type {
  AiResult,
  ChoiceExplanationResponse,
  SimilarQuestion,
  ExplainErrorPayload,
  DiffExplainPayload,
} from "../types/api";

export function explainError(payload: ExplainErrorPayload): Promise<AiResult> {
  return apiFetch("/ai/explain-error", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function diffExplain(payload: DiffExplainPayload): Promise<AiResult> {
  return apiFetch("/ai/diff-explain", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function fetchSimilar(questionUuid: string, k = 5): Promise<SimilarQuestion[]> {
  return apiFetch(`/ai/similar/${questionUuid}?k=${k}`);
}

export interface ChoiceExplanationQuery {
  readonly questionUuid: string;
  // 생략 시 서버가 이 문제 마지막 제출의 세트·보기 사용
  readonly choiceSetUuid?: string | null;
  readonly selectedChoiceKey?: string | null;
}

/**
 * 선택지 해설 조회 (기다리지 않음): READY 해설 / GENERATING 재조회 간격 / FAILED (#521)
 */
export function fetchChoiceExplanation({
  questionUuid,
  choiceSetUuid,
  selectedChoiceKey,
}: ChoiceExplanationQuery): Promise<ChoiceExplanationResponse> {
  const searchParams = new URLSearchParams({ questionUuid });
  // 빈 값은 보내지 않음 (서버 기본값 사용)
  if (choiceSetUuid) searchParams.set("choiceSetUuid", choiceSetUuid);
  if (selectedChoiceKey) searchParams.set("selectedChoiceKey", selectedChoiceKey);
  return apiFetch(`/ai/choice-explanation?${searchParams.toString()}`);
}
