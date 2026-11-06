import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";

// 브라우저 저장 키 (이 기기 전용 편의: 저장 못 한 모의고사 답, #866)
const MOCK_EXAM_PENDING_ANSWER_STORAGE_KEY = "passql.mockExam.pendingAnswers";

export interface MockExamLocalAnswer {
  readonly selectedChoiceKey: string | null;
  readonly isFlagged: boolean;
}

// 응시 UUID > 문항 번호(문자열 키) > 서버 저장 확인 전 답
type PendingAnswersByAttemptUuid = Readonly<Record<string, Readonly<Record<string, MockExamLocalAnswer>>>>;

interface MockExamPendingAnswerState {
  readonly pendingAnswersByAttemptUuid: PendingAnswersByAttemptUuid;
  putPendingAnswer: (attemptUuid: string, questionNumber: number, answer: MockExamLocalAnswer) => void;
  removePendingAnswerIfUnchanged: (attemptUuid: string, questionNumber: number, savedAnswer: MockExamLocalAnswer) => void;
  clearAttempt: (attemptUuid: string) => void;
}

/** 두 답이 같은지 (저장 중 다시 바뀐 답을 지우지 않게) */
function isSameAnswer(left: MockExamLocalAnswer | undefined, right: MockExamLocalAnswer): boolean {
  return !!left && left.selectedChoiceKey === right.selectedChoiceKey && left.isFlagged === right.isFlagged;
}

/**
 * 서버 저장 확인 전 모의고사 답: 바꿀 때 기록 > 저장 성공하면 삭제 > 제출 때 남은 것 함께 전송
 * 브라우저 저장은 새로고침·탭 종료 대비 편의 (막혀 있으면 메모리로만 동작), 원본은 서버
 */
export const useMockExamPendingAnswerStore = create<MockExamPendingAnswerState>()(
  persist(
    (set) => ({
      pendingAnswersByAttemptUuid: {},
      putPendingAnswer: (attemptUuid, questionNumber, answer) =>
        set((state) => ({
          pendingAnswersByAttemptUuid: {
            ...state.pendingAnswersByAttemptUuid,
            [attemptUuid]: { ...state.pendingAnswersByAttemptUuid[attemptUuid], [String(questionNumber)]: answer },
          },
        })),
      removePendingAnswerIfUnchanged: (attemptUuid, questionNumber, savedAnswer) =>
        set((state) => {
          const attemptPendingAnswers = state.pendingAnswersByAttemptUuid[attemptUuid];
          if (!isSameAnswer(attemptPendingAnswers?.[String(questionNumber)], savedAnswer)) return state;
          const { [String(questionNumber)]: _savedAnswer, ...remainingAnswers } = attemptPendingAnswers;
          return {
            pendingAnswersByAttemptUuid: { ...state.pendingAnswersByAttemptUuid, [attemptUuid]: remainingAnswers },
          };
        }),
      clearAttempt: (attemptUuid) =>
        set((state) => {
          const { [attemptUuid]: _clearedAttempt, ...remainingAttempts } = state.pendingAnswersByAttemptUuid;
          return { pendingAnswersByAttemptUuid: remainingAttempts };
        }),
    }),
    {
      name: MOCK_EXAM_PENDING_ANSWER_STORAGE_KEY,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ pendingAnswersByAttemptUuid: state.pendingAnswersByAttemptUuid }),
    },
  ),
);
