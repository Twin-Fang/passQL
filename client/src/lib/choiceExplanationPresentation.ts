import type { ChoiceAnalysis, ChoiceExplanation, ChoiceItem } from "../types/api";

/** choiceKey > 화면 표시 라벨 (A, B, C, D) */
export type DisplayLabelByChoiceKey = Readonly<Record<string, string>>;

const FIRST_DISPLAY_LABEL_CODE = "A".charCodeAt(0);

/**
 * 보기 목록(화면 순서) > choiceKey 별 표시 라벨 (#512: 서버가 순서를 섞어 보내 key 글자 대신 표시 순번 사용)
 */
export function buildDisplayLabelByChoiceKey(choices: readonly ChoiceItem[]): DisplayLabelByChoiceKey {
  const labelByChoiceKey: Record<string, string> = {};
  choices.forEach((choice, displayIndex) => {
    labelByChoiceKey[choice.key] = String.fromCharCode(FIRST_DISPLAY_LABEL_CODE + displayIndex);
  });
  return labelByChoiceKey;
}

/** choiceKey > 표시 라벨 (목록에 없으면 key 그대로) */
export function toDisplayLabel(labelByChoiceKey: DisplayLabelByChoiceKey, choiceKey: string): string {
  return labelByChoiceKey[choiceKey] ?? choiceKey;
}

/** 내가 고른 보기의 판단 (없으면 null) */
export function findSelectedChoiceAnalysis(explanation: ChoiceExplanation): ChoiceAnalysis | null {
  return explanation.choiceAnalyses.find((analysis) => analysis.choiceKey === explanation.selectedChoiceKey) ?? null;
}

/**
 * 판정 한 줄 (서버 verdict 대신 표시 라벨로 조립)
 * 정답: `정답 · {내 보기 이유}` / 오답: `오답 · {내 라벨} 선택, 정답은 {정답 라벨} · {내 보기 이유}`
 */
export function composeVerdict(explanation: ChoiceExplanation, labelByChoiceKey: DisplayLabelByChoiceKey): string {
  const selectedReason = findSelectedChoiceAnalysis(explanation)?.reason;
  const reasonSuffix = selectedReason ? ` · ${selectedReason}` : "";
  if (explanation.isSelectedCorrect) return `정답${reasonSuffix}`;
  const selectedLabel = toDisplayLabel(labelByChoiceKey, explanation.selectedChoiceKey);
  const correctLabel = toDisplayLabel(labelByChoiceKey, explanation.correctChoiceKey);
  return `오답 · ${selectedLabel} 선택, 정답은 ${correctLabel}${reasonSuffix}`;
}

/** 보기별 판단 > 화면 표시 순서 (표시 라벨 오름차순, 라벨 없는 보기는 뒤로) */
export function sortChoiceAnalysesByDisplayOrder(
  choiceAnalyses: readonly ChoiceAnalysis[],
  labelByChoiceKey: DisplayLabelByChoiceKey,
): readonly ChoiceAnalysis[] {
  return [...choiceAnalyses].sort((left, right) =>
    toDisplayLabel(labelByChoiceKey, left.choiceKey).localeCompare(toDisplayLabel(labelByChoiceKey, right.choiceKey)),
  );
}
