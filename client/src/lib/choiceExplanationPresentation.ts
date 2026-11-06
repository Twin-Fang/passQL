import type { ChoiceAnalysis, ChoiceExplanation, ChoiceItem } from "../types/api";
import { isFullExplanationLocked } from "./proAccess";

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
 * 정답: `정답 · {내 보기 이유}` / 오답: `오답 · {내 라벨} 선택, 정답은 {정답 라벨} · {내 보기 이유}` (보기 키를 모르면 `오답`)
 */
export function composeVerdict(explanation: ChoiceExplanation, labelByChoiceKey: DisplayLabelByChoiceKey): string {
  const selectedReason = findSelectedChoiceAnalysis(explanation)?.reason;
  const reasonSuffix = selectedReason ? ` · ${selectedReason}` : "";
  if (explanation.isSelectedCorrect) return `정답${reasonSuffix}`;
  if (!explanation.selectedChoiceKey || !explanation.correctChoiceKey) return `오답${reasonSuffix}`;
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

/** 응답 해설의 null 필드(무료 판정만 응답은 근거·팁이 null) > 빈 값: 화면이 문자열·목록으로 바로 씀 (#867) */
export function toCompleteChoiceExplanation(explanation: ChoiceExplanation): ChoiceExplanation {
  // 생성 타입은 필수지만 서버는 null 을 보냄 > 실제 응답 모양으로 읽음
  const wireExplanation = explanation as { readonly [Key in keyof ChoiceExplanation]: ChoiceExplanation[Key] | null };
  return {
    selectedChoiceKey: wireExplanation.selectedChoiceKey ?? "",
    correctChoiceKey: wireExplanation.correctChoiceKey ?? "",
    isSelectedCorrect: wireExplanation.isSelectedCorrect ?? false,
    verdict: wireExplanation.verdict ?? "",
    correctReason: wireExplanation.correctReason ?? "",
    keyConcepts: wireExplanation.keyConcepts ?? [],
    confusingPoints: wireExplanation.confusingPoints ?? [],
    choiceAnalyses: wireExplanation.choiceAnalyses ?? [],
    examTip: wireExplanation.examTip ?? "",
  };
}

/** 판정 한 줄을 조립할 재료 (해설함 항목 중 제출 결과 값) */
interface VerdictSource {
  readonly selectedChoiceKey: string;
  readonly correctChoiceKey: string | null;
  readonly isCorrect: boolean;
  readonly initialLockedSections: readonly string[];
}

/** 판정만 남긴 해설 (이유 없음): 무료 회원에게 판정까지 비어 오거나 해설이 실패했을 때 판정 한 줄 자리 (#867) */
export function toVerdictOnlyExplanation(source: VerdictSource): ChoiceExplanation {
  return toCompleteChoiceExplanation({
    selectedChoiceKey: source.selectedChoiceKey,
    correctChoiceKey: source.correctChoiceKey ?? "",
    isSelectedCorrect: source.isCorrect,
  } as ChoiceExplanation);
}

/** 무료 판정 한 줄 자리로 대신할지: 제출 응답에서 해설 묶음이 잠겼고(결제 UI 대상) 보여 줄 글이 없음 */
export function shouldShowVerdictOnly(source: VerdictSource, shouldShowProUi: boolean, markdownText: string | null): boolean {
  return shouldShowProUi && isFullExplanationLocked(source.initialLockedSections) && !markdownText?.trim();
}
