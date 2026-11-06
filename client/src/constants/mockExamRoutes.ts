// SQLD 모의고사 경로 단일 원본 (#866): App.tsx 라우트 정의와 화면 이동이 함께 읽음

// 회차 목록 (홈 카드·AI문제 탭 진입)
export const MOCK_EXAM_ROUNDS_PATH = "/mock-exams";

// 라우트 패턴 (App.tsx 전용, 앞 슬래시 없음)
export const MOCK_EXAM_ROUTE_PATTERNS = {
  rounds: "mock-exams",
  guide: "mock-exams/rounds/:roundUuid",
  attempt: "mock-exams/attempts/:attemptUuid",
  result: "mock-exams/attempts/:attemptUuid/result",
} as const;

/** 회차 > 시험 안내: /mock-exams/rounds/{roundUuid} */
export function toMockExamGuidePath(roundUuid: string): string {
  return `${MOCK_EXAM_ROUNDS_PATH}/rounds/${roundUuid}`;
}

/** 응시 > 풀이: /mock-exams/attempts/{attemptUuid} */
export function toMockExamAttemptPath(attemptUuid: string): string {
  return `${MOCK_EXAM_ROUNDS_PATH}/attempts/${attemptUuid}`;
}

/** 응시 > 결과: /mock-exams/attempts/{attemptUuid}/result */
export function toMockExamResultPath(attemptUuid: string): string {
  return `${toMockExamAttemptPath(attemptUuid)}/result`;
}
