import { useCallback, useEffect, useRef, useState } from "react";
import { saveMockExamAnswer } from "../api/mockExams";
import { toApiErrorCode } from "../api/client";
import { useMockExamPendingAnswerStore, type MockExamLocalAnswer } from "../stores/mockExamPendingAnswerStore";
import type { MockExamAnswerEntry, MockExamSheetResponse } from "../types/api";

// 저장 거부 = 응시가 이미 닫힘 (시간 끝 서버 채점 / 다른 곳에서 제출) > 결과로 이동
const ATTEMPT_CLOSED_ERROR_CODES: ReadonlySet<string> = new Set(["MOCK_EXAM_TIME_OVER", "MOCK_EXAM_ALREADY_SUBMITTED"]);

type AnswerByQuestionNumber = Readonly<Record<number, MockExamLocalAnswer>>;

interface MockExamAnswerSyncOptions {
  readonly sheet: MockExamSheetResponse;
  // 저장 응답의 남은 초 > 타이머 기준점
  readonly onRemainingSecondsSynced: (remainingSeconds: number, syncedAtMonotonicMilliseconds: number) => void;
  // 응시가 닫혀 저장 거부됨 > 결과 화면
  readonly onAttemptClosed: () => void;
}

/** 시험지 답 + 이 기기에 남은 저장 전 답(더 최신) > 화면 답 */
function toInitialAnswers(
  sheet: MockExamSheetResponse,
  pendingAnswers: Readonly<Record<string, MockExamLocalAnswer>> | undefined,
): AnswerByQuestionNumber {
  const answers: Record<number, MockExamLocalAnswer> = {};
  for (const question of sheet.questions) {
    answers[question.questionNumber] = pendingAnswers?.[String(question.questionNumber)] ?? {
      selectedChoiceKey: question.selectedChoiceKey,
      isFlagged: question.isFlagged,
    };
  }
  return answers;
}

/**
 * 모의고사 답 저장: 바꿀 때마다 즉시 PUT (문항별 순서 보장) > 실패면 저장 전 답으로 남기고 "저장 안 됨" 표시
 * 저장 전 답은 다음 재시도·제출 묶음에 함께 실림 (서버 응답이 원본, #866)
 */
export function useMockExamAnswerSync({ sheet, onRemainingSecondsSynced, onAttemptClosed }: MockExamAnswerSyncOptions) {
  const attemptUuid = sheet.attemptUuid;
  const putPendingAnswer = useMockExamPendingAnswerStore((state) => state.putPendingAnswer);
  const removePendingAnswerIfUnchanged = useMockExamPendingAnswerStore((state) => state.removePendingAnswerIfUnchanged);
  const [answers, setAnswers] = useState<AnswerByQuestionNumber>(() =>
    toInitialAnswers(sheet, useMockExamPendingAnswerStore.getState().pendingAnswersByAttemptUuid[attemptUuid]),
  );
  const [failedQuestionNumbers, setFailedQuestionNumbers] = useState<ReadonlySet<number>>(new Set());
  const answersRef = useRef(answers);
  // 문항별 저장 줄 (앞 저장이 끝난 뒤 최신 답을 보냄 > 늦게 도착한 옛 답이 덮지 않게)
  const saveQueueByQuestionNumberRef = useRef(new Map<number, Promise<void>>());
  const callbacksRef = useRef({ onRemainingSecondsSynced, onAttemptClosed });
  useEffect(() => {
    callbacksRef.current = { onRemainingSecondsSynced, onAttemptClosed };
  }, [onRemainingSecondsSynced, onAttemptClosed]);

  const markFailed = useCallback((questionNumber: number, hasFailed: boolean) => {
    setFailedQuestionNumbers((previous) => {
      if (previous.has(questionNumber) === hasFailed) return previous;
      const next = new Set(previous);
      if (hasFailed) next.add(questionNumber);
      else next.delete(questionNumber);
      return next;
    });
  }, []);

  // 문항 1개 저장 (줄 뒤에 붙임, 실행 시점의 최신 답 전송)
  const enqueueSave = useCallback(
    (questionNumber: number) => {
      const previousSave = saveQueueByQuestionNumberRef.current.get(questionNumber) ?? Promise.resolve();
      const nextSave = previousSave.then(async () => {
        const latestAnswer = answersRef.current[questionNumber];
        if (!latestAnswer) return;
        try {
          const response = await saveMockExamAnswer(attemptUuid, questionNumber, latestAnswer);
          removePendingAnswerIfUnchanged(attemptUuid, questionNumber, latestAnswer);
          markFailed(questionNumber, false);
          callbacksRef.current.onRemainingSecondsSynced(response.remainingSeconds, performance.now());
        } catch (error) {
          const errorCode = toApiErrorCode(error);
          if (errorCode && ATTEMPT_CLOSED_ERROR_CODES.has(errorCode)) {
            callbacksRef.current.onAttemptClosed();
            return;
          }
          console.warn(`[mock exam answer] save failed : question ${questionNumber}`, error);
          markFailed(questionNumber, true);
        }
      });
      saveQueueByQuestionNumberRef.current.set(questionNumber, nextSave);
    },
    [attemptUuid, markFailed, removePendingAnswerIfUnchanged],
  );

  /** 답 바꾸기: 화면 반영 > 저장 전 답 기록 > 저장 */
  const changeAnswer = useCallback(
    (questionNumber: number, nextAnswer: MockExamLocalAnswer) => {
      answersRef.current = { ...answersRef.current, [questionNumber]: nextAnswer };
      setAnswers(answersRef.current);
      putPendingAnswer(attemptUuid, questionNumber, nextAnswer);
      enqueueSave(questionNumber);
    },
    [attemptUuid, enqueueSave, putPendingAnswer],
  );

  /** 저장 전 답 다시 보내기 (재동기화 주기·복귀 때) */
  const retryUnsavedAnswers = useCallback(() => {
    const pendingAnswers = useMockExamPendingAnswerStore.getState().pendingAnswersByAttemptUuid[attemptUuid] ?? {};
    for (const questionNumberKey of Object.keys(pendingAnswers)) enqueueSave(Number(questionNumberKey));
  }, [attemptUuid, enqueueSave]);

  /** 제출 묶음: 서버 저장 확인 전 답 전부 */
  const toUnsavedAnswerEntries = useCallback((): MockExamAnswerEntry[] => {
    const pendingAnswers = useMockExamPendingAnswerStore.getState().pendingAnswersByAttemptUuid[attemptUuid] ?? {};
    return Object.entries(pendingAnswers).map(([questionNumberKey, answer]) => ({
      questionNumber: Number(questionNumberKey),
      selectedChoiceKey: answer.selectedChoiceKey,
      isFlagged: answer.isFlagged,
    }));
  }, [attemptUuid]);

  // 새로고침 전 남은 저장 전 답 1회 재전송
  useEffect(() => {
    retryUnsavedAnswers();
  }, [retryUnsavedAnswers]);

  return { answers, failedQuestionNumbers, changeAnswer, retryUnsavedAnswers, toUnsavedAnswerEntries };
}
