// 오답 노트 전체 화면 경로 (마이페이지 전체보기·통계 AI 분석 REVIEW_WRONG 진입, App.tsx 라우트와 같음)
export const WRONG_NOTES_PATH = "/mypage/wrong-questions";

// 마이페이지 오답 미리보기 개수 (넘으면 전체보기 노출)
export const WRONG_NOTES_PREVIEW_COUNT = 5;

// 오답 노트 화면 개수 (앱 wrongNotePageSize, 서버 기본값과 같음)
export const WRONG_NOTES_PAGE_SIZE = 20;

// 문제 풀이 진입 경로 쿼리: 오답 노트 다시 풀기면 보기 방식 칩 숨김 (#913, 앱 AppRoutes.wrongNoteRetry 와 같은 값)
export const QUESTION_ENTRY_QUERY = "entry";
export const WRONG_NOTE_ENTRY_QUERY_VALUE = "wrong-note";

/** 오답 노트 다시 풀기 경로: 문제 단독 풀이와 같은 화면, 보기 방식 칩 없음 */
export function toWrongNoteRetryPath(questionUuid: string): string {
  return `/questions/${questionUuid}?${QUESTION_ENTRY_QUERY}=${WRONG_NOTE_ENTRY_QUERY_VALUE}`;
}
