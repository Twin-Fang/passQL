/** 문제 난이도 최대 단계 (서버 관리자 등록·AI 서버 ai_request.py·앱 question_difficulty.dart 와 같은 1~5) */
export const MAX_QUESTION_DIFFICULTY = 5;

/** 난이도 필터 선택지 (1~5) */
export const QUESTION_DIFFICULTY_LEVELS: readonly number[] = Array.from(
  { length: MAX_QUESTION_DIFFICULTY },
  (_, index) => index + 1,
);
