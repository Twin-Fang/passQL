import { describe, expect, it } from "vitest";
import {
  isAppliedToCurrentQuestion,
  planChoiceModeSwitch,
  toEffectiveChoiceMode,
  type ChoiceModeSwitchInput,
} from "./choiceModeSwitchPlan";

/** 기본값: 제출 전, 검증 세트 있음, 받아 둔 새 보기·진행 중 생성 없음 */
function planOf(input: Partial<ChoiceModeSwitchInput> & Pick<ChoiceModeSwitchInput, "targetMode">) {
  return planChoiceModeSwitch({
    hasSubmissionStarted: false,
    hasReadyChoiceSet: true,
    hasFreshChoiceSet: false,
    inFlightGenerationMode: null,
    ...input,
  });
}

// 보기 방식 변경 적용 판정 (#913, 앱 #907 과 같은 표): 제출 전 지금 문제 반영 / 제출 뒤 다음 풀이부터, 생성 겹침 방지
describe("planChoiceModeSwitch", () => {
  it("제출 중·뒤면 어느 방식이든 채점한 보기 유지, 다음 풀이부터", () => {
    for (const targetMode of ["PRACTICE", "REAL"] as const) {
      const action = planOf({ hasSubmissionStarted: true, targetMode });
      expect(action).toBe("KEEP_UNTIL_NEXT_SOLVE");
      expect(isAppliedToCurrentQuestion(action)).toBe(false);
    }
  });

  it("제출 전 AI 새 보기: 처음이면 생성, 받아 둔 새 보기가 있으면 재사용", () => {
    expect(planOf({ targetMode: "REAL" })).toBe("GENERATE_CHOICES");
    expect(planOf({ targetMode: "REAL", hasFreshChoiceSet: true })).toBe("SHOW_FRESH_CHOICE_SET");
  });

  it("제출 전 검증된 보기: 이 문제 검증 세트로 바로 교체 (진행 중 생성이 있어도)", () => {
    expect(planOf({ targetMode: "PRACTICE", inFlightGenerationMode: "REAL" })).toBe("SHOW_READY_CHOICE_SET");
  });

  it("새 보기 생성 중 다시 새 보기로 오면 겹쳐 생성하지 않고 기다림 (연타 1회 생성)", () => {
    expect(planOf({ targetMode: "REAL", inFlightGenerationMode: "REAL" })).toBe("AWAIT_IN_FLIGHT_GENERATION");
  });

  it("검증 세트 없는 문제: 검증된 보기는 진행 중 생성을 기다리고, 새 보기는 검증된 보기 생성에 합류하지 않음", () => {
    expect(planOf({ targetMode: "PRACTICE", hasReadyChoiceSet: false, inFlightGenerationMode: "REAL" })).toBe(
      "AWAIT_IN_FLIGHT_GENERATION",
    );
    expect(planOf({ targetMode: "REAL", hasReadyChoiceSet: false, inFlightGenerationMode: "PRACTICE" })).toBe(
      "GENERATE_CHOICES",
    );
  });
});

describe("toEffectiveChoiceMode", () => {
  it("무료(잠금 UI)는 저장값이 AI 새 보기여도 검증된 보기, 그 외는 저장값 그대로", () => {
    expect(toEffectiveChoiceMode("REAL", true)).toBe("PRACTICE");
    expect(toEffectiveChoiceMode("REAL", false)).toBe("REAL");
    expect(toEffectiveChoiceMode("PRACTICE", false)).toBe("PRACTICE");
  });
});
