// 오늘의 세트 이어 풀기 (#566): 앞에서부터 이어진 제출만 복원, 마지막 문제는 남김
import { describe, expect, it } from "vitest";
import type { QuestionSummary } from "../types/api";
import { RESUMED_ANSWER_LABEL, toResumedResults } from "./dailySetStore";

const questions = ["q1", "q2", "q3"].map((questionUuid) => ({ questionUuid }) as QuestionSummary);

describe("toResumedResults", () => {
  it("앞에서부터 이어진 제출만 결과로 복원한다", () => {
    const resumed = toResumedResults(questions, [true, null, false]);

    expect(resumed).toHaveLength(1);
    expect(resumed[0]).toMatchObject({ questionUuid: "q1", isCorrect: true, selectedChoiceBody: RESUMED_ANSWER_LABEL });
  });

  it("모두 제출했어도 마지막 문제는 다시 풀게 남긴다", () => {
    expect(toResumedResults(questions, [true, false, true])).toHaveLength(2);
  });

  it("기록이 없으면 처음부터", () => {
    expect(toResumedResults(questions, null)).toHaveLength(0);
  });
});
