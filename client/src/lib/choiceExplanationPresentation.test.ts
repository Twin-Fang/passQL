import { describe, expect, it } from "vitest";
import { composeVerdict, toCompleteChoiceExplanation, toVerdictOnlyExplanation } from "./choiceExplanationPresentation";
import type { ChoiceExplanation } from "../types/api";

// 무료 판정만 응답 모양: 근거·팁은 null, 목록은 빈 값 (ProResponseRedactor)
const verdictOnlyWireExplanation = {
  selectedChoiceKey: "B",
  correctChoiceKey: "A",
  isSelectedCorrect: false,
  verdict: "오답 · B 선택, 정답은 A",
  correctReason: null,
  keyConcepts: [],
  confusingPoints: [],
  choiceAnalyses: [],
  examTip: null,
} as unknown as ChoiceExplanation;

describe("무료 판정 한 줄 해설 (#867)", () => {
  it("응답의 null 근거·팁을 빈 문자열로 바꾼다", () => {
    const explanation = toCompleteChoiceExplanation(verdictOnlyWireExplanation);

    expect(explanation.correctReason).toBe("");
    expect(explanation.examTip).toBe("");
  });

  it("제출 결과로 조립한 판정은 표시 라벨을 쓴다", () => {
    const explanation = toVerdictOnlyExplanation({
      selectedChoiceKey: "k2",
      correctChoiceKey: "k1",
      isCorrect: false,
      initialLockedSections: ["FULL_EXPLANATION"],
    });

    expect(composeVerdict(explanation, { k1: "A", k2: "B" })).toBe("오답 · B 선택, 정답은 A");
  });
});
