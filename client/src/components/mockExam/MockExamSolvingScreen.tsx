import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { X } from "lucide-react";
import ConfirmModal from "../ConfirmModal";
import ProgressBar from "../ProgressBar";
import MockExamCountdownBadge from "./MockExamCountdownBadge";
import MockExamQuestionView from "./MockExamQuestionView";
import MockExamSolvingBottomBar from "./MockExamSolvingBottomBar";
import MockExamAnswerPaletteSheet from "./MockExamAnswerPaletteSheet";
import MockExamSubmitStatusOverlay from "./MockExamSubmitStatusOverlay";
import SolvingMemoBoard from "../solvingMemo/SolvingMemoBoard";
import { useMockExamCountdown } from "../../hooks/useMockExamCountdown";
import { useMockExamAnswerSync } from "../../hooks/useMockExamAnswerSync";
import { useMockExamSubmit } from "../../hooks/useMockExamSubmit";
import { usePracticeExitGuard } from "../../hooks/usePracticeExitGuard";
import { useSolvingMemo } from "../../hooks/useSolvingMemo";
import { groupBySubject, toSolvingCells } from "../../lib/mockExamPresentation";
import { MOCK_EXAM_ROUNDS_PATH } from "../../constants/mockExamRoutes";
import { MOCK_EXAM_LEAVE_CONFIRM, MOCK_EXAM_SUBMIT_CONFIRM } from "../../constants/mockExamCopy";
import type { SyncedMockExamSheet } from "../../hooks/useMockExam";

interface MockExamSolvingScreenProps {
  // 최신 시험지 (30초·복귀마다 다시 받음, 문항·첫 답은 처음 받은 것 기준)
  readonly syncedSheet: SyncedMockExamSheet;
  // 화면 복귀 때 시험지 다시 받기
  readonly onSyncRequested: () => void;
}

/**
 * 모의고사 풀이: 남은 시간 > 문항(보기 선택·해제 즉시 저장) > 이전·표시·다음 > 번호판 > 제출
 * 시간 0 > 자동 제출 > 결과, 나가기·뒤로가기는 "시간은 계속 흘러요" 확인 후 목록
 */
export default function MockExamSolvingScreen({ syncedSheet, onSyncRequested }: MockExamSolvingScreenProps) {
  const [initialSyncedSheet] = useState(syncedSheet);
  const { sheet } = initialSyncedSheet;
  const questions = sheet.questions;
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPaletteOpen, setIsPaletteOpen] = useState(false);
  const [isSubmitConfirmOpen, setIsSubmitConfirmOpen] = useState(false);
  const [isAttemptClosed, setIsAttemptClosed] = useState(false);
  const scrollAreaRef = useRef<HTMLDivElement>(null);
  // 문항별 메모 (#904): 이 응시 화면 동안만 메모리에, 나가거나 제출하면 사라짐
  const solvingMemo = useSolvingMemo();

  const { remainingSeconds, announcement, syncRemainingSeconds } = useMockExamCountdown({
    serverRemainingSeconds: initialSyncedSheet.sheet.remainingSeconds,
    syncedAtMonotonicMilliseconds: initialSyncedSheet.receivedAtMonotonicMilliseconds,
  });
  const onAttemptClosed = useCallback(() => setIsAttemptClosed(true), []);
  const answerSync = useMockExamAnswerSync({ sheet, onRemainingSecondsSynced: syncRemainingSeconds, onAttemptClosed });
  const { isSubmitting, hasSubmitFailed, submit, moveToResult } = useMockExamSubmit({
    attemptUuid: sheet.attemptUuid,
    toUnsavedAnswerEntries: answerSync.toUnsavedAnswerEntries,
  });
  const exitGuard = usePracticeExitGuard(!isSubmitting && !isAttemptClosed, MOCK_EXAM_ROUNDS_PATH);
  const isTimeUp = remainingSeconds <= 0;

  // 새 시험지 > 타이머 기준점 교체 + 저장 전 답 재전송
  const { retryUnsavedAnswers } = answerSync;
  useEffect(() => {
    syncRemainingSeconds(syncedSheet.sheet.remainingSeconds, syncedSheet.receivedAtMonotonicMilliseconds);
    retryUnsavedAnswers();
  }, [syncedSheet, syncRemainingSeconds, retryUnsavedAnswers]);

  // 창 포커스 복귀 > 다시 받기 (탭 전환은 react-query 가 처리)
  useEffect(() => {
    window.addEventListener("focus", onSyncRequested);
    return () => window.removeEventListener("focus", onSyncRequested);
  }, [onSyncRequested]);

  // 응시 닫힘(서버 채점) > 결과 (blocker 해제 뒤)
  useEffect(() => {
    if (isAttemptClosed) moveToResult();
  }, [isAttemptClosed, moveToResult]);

  // 시간 끝 > 자동 제출 1회 (실패면 오버레이 다시 시도)
  const hasAutoSubmittedRef = useRef(false);
  useEffect(() => {
    if (!isTimeUp || hasAutoSubmittedRef.current) return;
    hasAutoSubmittedRef.current = true;
    setIsSubmitConfirmOpen(false);
    setIsPaletteOpen(false);
    void submit();
  }, [isTimeUp, submit]);

  // 문항 이동 > 스크롤 맨 위
  useEffect(() => {
    scrollAreaRef.current?.scrollTo({ top: 0 });
  }, [currentIndex]);

  const currentQuestion = questions[currentIndex];
  const currentAnswer = answerSync.answers[currentQuestion.questionNumber];
  const paletteGroups = useMemo(
    () => groupBySubject(toSolvingCells(questions, answerSync.answers, currentQuestion.questionNumber)),
    [questions, answerSync.answers, currentQuestion.questionNumber],
  );
  const unansweredCount = questions.filter((question) => answerSync.answers[question.questionNumber]?.selectedChoiceKey == null).length;
  const flaggedCount = questions.filter((question) => answerSync.answers[question.questionNumber]?.isFlagged).length;
  const answeredCount = questions.length - unansweredCount;

  // 보기 누름: 같은 보기면 해제, 다르면 선택
  const onChoicePressed = (choiceKey: string) => {
    const nextChoiceKey = currentAnswer?.selectedChoiceKey === choiceKey ? null : choiceKey;
    answerSync.changeAnswer(currentQuestion.questionNumber, { selectedChoiceKey: nextChoiceKey, isFlagged: currentAnswer?.isFlagged ?? false });
  };
  const onFlagPressed = () => {
    answerSync.changeAnswer(currentQuestion.questionNumber, {
      selectedChoiceKey: currentAnswer?.selectedChoiceKey ?? null,
      isFlagged: !(currentAnswer?.isFlagged ?? false),
    });
  };
  const onPaletteQuestionSelected = (questionNumber: number) => {
    const nextIndex = questions.findIndex((question) => question.questionNumber === questionNumber);
    if (nextIndex >= 0) setCurrentIndex(nextIndex);
    setIsPaletteOpen(false);
  };
  const closePalette = useCallback(() => setIsPaletteOpen(false), []);
  const closeSubmitConfirm = useCallback(() => setIsSubmitConfirmOpen(false), []);

  return (
    <div className="flex flex-col h-dvh max-w-120 mx-auto w-full bg-surface">
      {/* 상단: 나가기 / 제목·진행 / 남은 시간 */}
      <header className="px-4 pt-3 pb-2 space-y-2">
        <div className="flex items-center gap-2">
          <button type="button" aria-label="시험 나가기" className="btn btn-ghost btn-sm btn-square" onClick={exitGuard.openExitConfirm}>
            <X size={18} aria-hidden="true" />
          </button>
          <div className="flex-1 min-w-0">
            <p className="text-xs text-text-caption truncate">{sheet.title}</p>
            <p className="text-sm font-semibold text-text-primary tabular-nums">
              {currentQuestion.questionNumber} / {questions.length}
              <span className="ml-2 text-xs font-normal text-text-secondary">답함 {answeredCount}</span>
            </p>
          </div>
          <MockExamCountdownBadge remainingSeconds={remainingSeconds} announcement={announcement} />
        </div>
        <ProgressBar
          fillPercent={(answeredCount / questions.length) * 100}
          trackClassName="h-1.5 bg-border"
          fillClassName="bg-brand transition-all duration-300"
        />
      </header>

      <div ref={scrollAreaRef} className="flex-1 overflow-y-auto px-4 pt-2 pb-36">
        <SolvingMemoBoard memo={solvingMemo} pageKey={String(currentQuestion.questionNumber)}>
          <MockExamQuestionView
            key={currentQuestion.questionNumber}
            question={currentQuestion}
            selectedChoiceKey={currentAnswer?.selectedChoiceKey ?? null}
            isUnsaved={answerSync.failedQuestionNumbers.has(currentQuestion.questionNumber)}
            onChoicePressed={onChoicePressed}
          />
        </SolvingMemoBoard>
      </div>

      <MockExamSolvingBottomBar
        hasPreviousQuestion={currentIndex > 0}
        hasNextQuestion={currentIndex < questions.length - 1}
        isFlagged={currentAnswer?.isFlagged ?? false}
        unansweredCount={unansweredCount}
        isSubmitting={isSubmitting}
        onPreviousPressed={() => setCurrentIndex((index) => Math.max(0, index - 1))}
        onNextPressed={() => setCurrentIndex((index) => Math.min(questions.length - 1, index + 1))}
        onFlagPressed={onFlagPressed}
        onPaletteOpenPressed={() => setIsPaletteOpen(true)}
        onSubmitPressed={() => setIsSubmitConfirmOpen(true)}
      />

      <MockExamAnswerPaletteSheet
        isOpen={isPaletteOpen}
        groups={paletteGroups}
        unansweredCount={unansweredCount}
        flaggedCount={flaggedCount}
        onSelectQuestion={onPaletteQuestionSelected}
        onClose={closePalette}
      />

      <ConfirmModal
        isOpen={isSubmitConfirmOpen}
        title={MOCK_EXAM_SUBMIT_CONFIRM.title}
        description={`안 푼 문항 ${unansweredCount}개 · 표시한 문항 ${flaggedCount}개. 제출하면 고칠 수 없어요.`}
        confirmLabel={MOCK_EXAM_SUBMIT_CONFIRM.confirmLabel}
        cancelLabel={MOCK_EXAM_SUBMIT_CONFIRM.cancelLabel}
        onCancel={closeSubmitConfirm}
        onConfirm={() => {
          setIsSubmitConfirmOpen(false);
          void submit();
        }}
      />

      <ConfirmModal
        isOpen={exitGuard.isExitConfirmOpen}
        title={MOCK_EXAM_LEAVE_CONFIRM.title}
        description={MOCK_EXAM_LEAVE_CONFIRM.description}
        confirmLabel={MOCK_EXAM_LEAVE_CONFIRM.confirmLabel}
        cancelLabel={MOCK_EXAM_LEAVE_CONFIRM.cancelLabel}
        onCancel={exitGuard.cancelExit}
        onConfirm={exitGuard.confirmExit}
      />

      <MockExamSubmitStatusOverlay
        isTimeUp={isTimeUp}
        isSubmitting={isSubmitting}
        hasSubmitFailed={hasSubmitFailed}
        onRetryPressed={() => void submit()}
      />
    </div>
  );
}
