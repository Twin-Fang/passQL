import type { MockExamLocalAnswer } from "../stores/mockExamPendingAnswerStore";
import type {
  MockExamQuestionMark,
  MockExamResultResponse,
  MockExamRule,
  MockExamSheetQuestion,
  MockExamSubject,
} from "../types/api";

/**
 * 모의고사 서버 값 > 화면 문구 (#866): 형식 안내 줄, 과목 짧은 이름, 합격·불합격 이유 한 줄, 과목별 묶기
 * 판정은 하지 않음 (합격·과락·점수는 서버 값 그대로)
 */

// 결과 응답 lockedSections 값 (무료 회원에서 서버가 비운 묶음)
export const LOCKED_SECTION_MOCK_EXAM_SUBJECT_DETAIL = "MOCK_EXAM_SUBJECT_DETAIL";
export const LOCKED_SECTION_MOCK_EXAM_REVIEW = "MOCK_EXAM_REVIEW";

// 과목 코드 > 짧은 이름 (번호판 묶음 머리·과목 카드)
const SUBJECT_SHORT_LABELS: Readonly<Record<MockExamSubject, string>> = {
  SUBJECT_ONE: "1과목",
  SUBJECT_TWO: "2과목",
};

/** 과목 코드 > "1과목" */
export function toSubjectShortLabel(subject: MockExamSubject): string {
  return SUBJECT_SHORT_LABELS[subject];
}

/** 시험 형식 > 안내 줄 4종: 형식, 과목 구성, 합격 기준, 과락 기준 */
export function toExamRuleLines(examRule: MockExamRule): string[] {
  const subjectCompositionLine = examRule.subjects
    .map((subjectRule) => `${toSubjectShortLabel(subjectRule.subject)} ${subjectRule.questionCount}문항`)
    .join(" · ");
  const subjectFailLine = examRule.subjects
    .map((subjectRule) => `${toSubjectShortLabel(subjectRule.subject)} ${subjectRule.failBelowScore}점 미만`)
    .join(", ");
  return [
    `객관식 ${examRule.questionCount}문항 · ${examRule.durationMinutes}분 · ${examRule.maxScore}점 만점`,
    subjectCompositionLine,
    `총점 ${examRule.passScore}점 이상이면 합격`,
    `과목별 과락: ${subjectFailLine}이면 총점과 상관없이 불합격`,
  ];
}

/** 결과 > 이유 한 줄 (합격선 대비, 과락 과목은 프로만 이름까지) */
export function toVerdictReasonLine(result: MockExamResultResponse): string {
  switch (result.failReason) {
    case "NONE":
      return `합격선 ${result.passScore}점을 넘었어요`;
    case "TOTAL_SCORE_BELOW":
      return `합격선 ${result.passScore}점까지 ${Math.max(0, result.passScore - result.totalScore)}점 남았어요`;
    case "SUBJECT_FAIL": {
      const failedSubjectLabels = result.subjects
        .filter((subjectResult) => subjectResult.isFailed)
        .map((subjectResult) => toSubjectShortLabel(subjectResult.subject));
      return failedSubjectLabels.length > 0
        ? `${failedSubjectLabels.join(", ")} 과락이에요`
        : "과락 과목이 있어 불합격이에요";
    }
  }
}

/** 시간 끝 자동 제출이면 덧붙일 안내 */
export function toSubmitReasonNote(result: MockExamResultResponse): string | null {
  return result.submitReason === "TIME_UP" ? "시간이 끝나 자동으로 제출됐어요" : null;
}

export interface SubjectGroup<T> {
  readonly subject: MockExamSubject;
  readonly label: string;
  readonly items: readonly T[];
}

/** 과목별 묶기 (처음 나온 순서 유지, 번호판·정오표 공통) */
export function groupBySubject<T extends { readonly subject: MockExamSubject }>(items: readonly T[]): SubjectGroup<T>[] {
  const itemsBySubject = new Map<MockExamSubject, T[]>();
  for (const item of items) {
    const subjectItems = itemsBySubject.get(item.subject) ?? [];
    subjectItems.push(item);
    itemsBySubject.set(item.subject, subjectItems);
  }
  return [...itemsBySubject.entries()].map(([subject, subjectItems]) => ({
    subject,
    label: toSubjectShortLabel(subject),
    items: subjectItems,
  }));
}

// 번호판 칸 상태: 풀이 중(답함·안 품) / 결과(정답·오답·안 품)
export type QuestionNumberCellTone = "answered" | "unanswered" | "correct" | "wrong" | "skipped";

export interface QuestionNumberCell {
  readonly questionNumber: number;
  readonly subject: MockExamSubject;
  readonly tone: QuestionNumberCellTone;
  readonly isFlagged: boolean;
  readonly isCurrent: boolean;
  // 스크린리더 칸 이름 ("12번, 답함, 표시함")
  readonly ariaLabel: string;
}

/** 풀이 문항 + 화면 답 > 번호판 칸 (답함·표시·지금 문항) */
export function toSolvingCells(
  questions: readonly MockExamSheetQuestion[],
  answerByQuestionNumber: Readonly<Record<number, MockExamLocalAnswer>>,
  currentQuestionNumber: number,
): QuestionNumberCell[] {
  return questions.map((question) => {
    const answer = answerByQuestionNumber[question.questionNumber];
    const isAnswered = answer?.selectedChoiceKey != null;
    const isFlagged = answer?.isFlagged ?? false;
    const isCurrent = question.questionNumber === currentQuestionNumber;
    const labelParts = [
      `${question.questionNumber}번`,
      isAnswered ? "답함" : "안 품",
      ...(isFlagged ? ["표시함"] : []),
      ...(isCurrent ? ["지금 문항"] : []),
    ];
    return {
      questionNumber: question.questionNumber,
      subject: question.subject,
      tone: isAnswered ? "answered" : "unanswered",
      isFlagged,
      isCurrent,
      ariaLabel: labelParts.join(", "),
    };
  });
}

/** 결과 정오 표시 > 정오표 칸 (정답·오답·안 품, 표시 점) */
export function toResultCells(questionMarks: readonly MockExamQuestionMark[]): QuestionNumberCell[] {
  return questionMarks.map((mark) => {
    const tone: QuestionNumberCellTone = !mark.isAnswered ? "skipped" : mark.isCorrect ? "correct" : "wrong";
    const toneLabel = tone === "skipped" ? "안 품" : tone === "correct" ? "정답" : "오답";
    return {
      questionNumber: mark.questionNumber,
      subject: mark.subject,
      tone,
      isFlagged: mark.isFlagged,
      isCurrent: false,
      ariaLabel: [`${mark.questionNumber}번`, toneLabel, ...(mark.isFlagged ? ["표시함"] : [])].join(", "),
    };
  });
}

/** ISO 시각 > "11월 7일" (회차 행·추이 축) */
export function formatMonthDay(isoDateTime: string): string {
  return new Date(isoDateTime).toLocaleDateString("ko-KR", { month: "long", day: "numeric" });
}
