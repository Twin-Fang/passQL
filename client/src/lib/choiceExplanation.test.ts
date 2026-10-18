// 선택지 해설 순수 규칙 (#521): 재조회 간격·횟수, 표시 라벨(#512) 판정 문구·보기 순서
import { describe, expect, it } from "vitest";
import {
  MAXIMUM_POLL_ATTEMPT_COUNT,
  MAXIMUM_POLL_DELAY_MILLISECONDS,
  canPollAgain,
  computeNextPollDelayMilliseconds,
} from "./choiceExplanationPolling";
import {
  buildDisplayLabelByChoiceKey,
  composeVerdict,
  sortChoiceAnalysesByDisplayOrder,
} from "./choiceExplanationPresentation";
import type { ChoiceExplanation, ChoiceItem } from "../types/api";

describe("재조회 간격", () => {
  it("1500ms 에서 1.5배씩 늘고 6000ms 에서 멈춘다", () => {
    expect([0, 1, 2, 3, 4, 5].map((attempt) => computeNextPollDelayMilliseconds(attempt, null))).toEqual([
      1500, 2250, 3375, 5062.5, 6000, 6000,
    ]);
  });

  it("서버 권장 간격이 더 길면 따르고, 상한은 넘지 않는다", () => {
    expect(computeNextPollDelayMilliseconds(0, 4000)).toBe(4000);
    expect(computeNextPollDelayMilliseconds(0, 60000)).toBe(MAXIMUM_POLL_DELAY_MILLISECONDS);
  });

  it("최대 횟수에 닿으면 더 묻지 않는다 (8회 합계 약 30초)", () => {
    expect(canPollAgain(MAXIMUM_POLL_ATTEMPT_COUNT - 1)).toBe(true);
    expect(canPollAgain(MAXIMUM_POLL_ATTEMPT_COUNT)).toBe(false);
    const totalMilliseconds = Array.from({ length: MAXIMUM_POLL_ATTEMPT_COUNT }, (_, attempt) =>
      computeNextPollDelayMilliseconds(attempt, null),
    ).reduce((sum, delay) => sum + delay, 0);
    expect(totalMilliseconds).toBeGreaterThan(25000);
    expect(totalMilliseconds).toBeLessThan(40000);
  });
});

// 서버가 보기 순서를 섞어 보낸 상황: 화면 순서 C, A, D, B
const SHUFFLED_CHOICES: readonly ChoiceItem[] = ["C", "A", "D", "B"].map((key, index) => ({
  key,
  kind: "TEXT",
  body: `보기 ${key}`,
  isCorrect: key === "A",
  rationale: "",
  sortOrder: index + 1,
}));

const WRONG_EXPLANATION: ChoiceExplanation = {
  selectedChoiceKey: "B",
  correctChoiceKey: "A",
  isSelectedCorrect: false,
  verdict: "오답 · B 선택, 정답은 A · 서버 문구",
  correctReason: "`DENSE_RANK` 는 순위를 건너뛰지 않음",
  keyConcepts: [],
  confusingPoints: [],
  choiceAnalyses: [
    { choiceKey: "A", isCorrect: true, reason: "건너뛰지 않아 3" },
    { choiceKey: "B", isCorrect: false, reason: "4 는 `RANK` 기준" },
    { choiceKey: "C", isCorrect: false, reason: "2 는 동점 순위" },
    { choiceKey: "D", isCorrect: false, reason: "1 은 최고 순위" },
  ],
  examTip: "",
};

describe("표시 라벨 판정 문구", () => {
  const labelByChoiceKey = buildDisplayLabelByChoiceKey(SHUFFLED_CHOICES);

  it("화면 순서로 A~D 라벨을 붙인다", () => {
    expect(labelByChoiceKey).toEqual({ C: "A", A: "B", D: "C", B: "D" });
  });

  it("오답이면 서버 verdict 대신 표시 라벨로 조립한다", () => {
    expect(composeVerdict(WRONG_EXPLANATION, labelByChoiceKey)).toBe("오답 · D 선택, 정답은 B · 4 는 `RANK` 기준");
  });

  it("정답이면 내 보기 이유만 붙인다", () => {
    const correctExplanation = { ...WRONG_EXPLANATION, selectedChoiceKey: "A", isSelectedCorrect: true };
    expect(composeVerdict(correctExplanation, labelByChoiceKey)).toBe("정답 · 건너뛰지 않아 3");
  });

  it("라벨 정보가 없으면 key 그대로 쓴다", () => {
    expect(composeVerdict(WRONG_EXPLANATION, {})).toBe("오답 · B 선택, 정답은 A · 4 는 `RANK` 기준");
  });

  it("보기별 판단은 화면 표시 순서로 정렬한다", () => {
    expect(sortChoiceAnalysesByDisplayOrder(WRONG_EXPLANATION.choiceAnalyses, labelByChoiceKey).map((analysis) => analysis.choiceKey)).toEqual([
      "C",
      "A",
      "D",
      "B",
    ]);
  });
});
