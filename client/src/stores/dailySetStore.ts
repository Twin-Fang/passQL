import { create } from "zustand";
import type { QuestionSummary } from "../types/api";

interface DailySetQuestionResult {
  readonly questionUuid: string;
  readonly isCorrect: boolean;
  readonly selectedChoiceKey: string;
  readonly selectedChoiceBody: string;
  readonly durationMs: number;
  readonly submissionUuid?: string;
  readonly choiceSetUuid?: string;
}

interface DailySetState {
  readonly sessionUuid: string | null;
  readonly questions: readonly QuestionSummary[];
  readonly currentIndex: number;
  readonly results: readonly DailySetQuestionResult[];
  // 세션 시작 또는 문제 이동 시각 — 문제별 소요 시간 계산에 사용
  readonly startedAt: number | null;
  readonly correctCount: number | null;
}

// 이어 푼 문제의 "내 답" 자리 문구 (보기 원문은 이전 풀이에만 있음)
export const RESUMED_ANSWER_LABEL = "이전 풀이에서 제출";

/**
 * 이어 풀기 (#566): 문제별 오늘 첫 제출 정오(미제출 null) > 앞에서부터 이어진 제출 결과
 * 마지막 문제는 남겨 둔다 (모두 풀린 상태로 시작하면 이번 세션 제출이 없어 완료할 수 없음)
 */
export function toResumedResults(
  questions: readonly QuestionSummary[],
  answeredResults: readonly (boolean | null)[] | null | undefined,
): DailySetQuestionResult[] {
  const resumed: DailySetQuestionResult[] = [];
  for (let index = 0; index < questions.length - 1; index++) {
    const isCorrect = answeredResults?.[index];
    if (isCorrect === null || isCorrect === undefined) break;
    resumed.push({
      questionUuid: questions[index].questionUuid,
      isCorrect,
      selectedChoiceKey: "",
      selectedChoiceBody: RESUMED_ANSWER_LABEL,
      durationMs: 0,
    });
  }
  return resumed;
}

interface DailySetActions {
  readonly startSession: (
    sessionUuid: string,
    questions: readonly QuestionSummary[],
    answeredResults?: readonly (boolean | null)[] | null,
  ) => void;
  readonly submitAndAdvance: (
    questionUuid: string,
    isCorrect: boolean,
    selectedChoiceKey: string,
    selectedChoiceBody: string,
    submissionUuid?: string,
    choiceSetUuid?: string,
  ) => void;
  readonly setCorrectCount: (count: number) => void;
  readonly reset: () => void;
}

const INITIAL_STATE: DailySetState = {
  sessionUuid: null,
  questions: [],
  currentIndex: 0,
  results: [],
  startedAt: null,
  correctCount: null,
};

export const useDailySetStore = create<DailySetState & DailySetActions>()((set, get) => ({
  ...INITIAL_STATE,

  startSession: (sessionUuid, questions, answeredResults) => {
    const resumedResults = toResumedResults(questions, answeredResults);
    set({
      ...INITIAL_STATE,
      sessionUuid,
      questions,
      results: resumedResults,
      currentIndex: resumedResults.length,
      startedAt: Date.now(),
    });
  },

  submitAndAdvance: (questionUuid, isCorrect, selectedChoiceKey, selectedChoiceBody, submissionUuid, choiceSetUuid) => {
    const { startedAt } = get();
    // startedAt이 null이면 소요 시간을 0으로 처리
    const durationMs = startedAt ? Date.now() - startedAt : 0;
    const newResult: DailySetQuestionResult = {
      questionUuid, isCorrect, selectedChoiceKey, selectedChoiceBody, durationMs, submissionUuid, choiceSetUuid,
    };
    set((s) => ({
      results: [...s.results, newResult],
      currentIndex: s.currentIndex + 1,
      // 다음 문제 소요 시간 측정을 위해 타이머 리셋
      startedAt: Date.now(),
    }));
  },

  setCorrectCount: (count) => set({ correctCount: count }),

  reset: () => set(INITIAL_STATE),
}));
