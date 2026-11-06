import { apiFetch } from "./client";
import type {
  MockExamAnswerEntry,
  MockExamAnswerSaveRequest,
  MockExamAnswerSaveResponse,
  MockExamHistoryResponse,
  MockExamResultResponse,
  MockExamRoundListResponse,
  MockExamSheetResponse,
} from "../types/api";

/**
 * SQLD 모의고사 API (#866): 회차 목록 > 시작·이어 풀기 > 문항 저장 > 제출 > 결과·추이
 * 시간·채점·등급 판정은 모두 서버 (웹은 받은 값만 표시)
 */

/** 회차 목록 + 시험 형식 + 풀이 중 응시 (목록 진입 때 마감 지난 응시는 서버가 채점) */
export function fetchMockExamRounds(): Promise<MockExamRoundListResponse> {
  return apiFetch("/mock-exams/rounds");
}

/** 응시 시작 (같은 회차 풀이 중이면 그 시험지). 403 PRO_REQUIRED·MOCK_EXAM_FREE_TRIAL_USED, 409 MOCK_EXAM_ATTEMPT_IN_PROGRESS */
export function startMockExamAttempt(roundUuid: string): Promise<MockExamSheetResponse> {
  return apiFetch(`/mock-exams/rounds/${roundUuid}/attempts`, { method: "POST" });
}

/** 시험지 + 남은 시간 (status SUBMITTED 면 결과로) */
export function fetchMockExamSheet(attemptUuid: string): Promise<MockExamSheetResponse> {
  return apiFetch(`/mock-exams/attempts/${attemptUuid}`);
}

/** 문항 1개 답·표시 저장. 409 MOCK_EXAM_TIME_OVER(서버 자동 채점)·MOCK_EXAM_ALREADY_SUBMITTED */
export function saveMockExamAnswer(
  attemptUuid: string,
  questionNumber: number,
  request: MockExamAnswerSaveRequest,
): Promise<MockExamAnswerSaveResponse> {
  return apiFetch(`/mock-exams/attempts/${attemptUuid}/answers/${questionNumber}`, {
    method: "PUT",
    body: JSON.stringify(request),
  });
}

/** 제출 (저장 못 한 답 묶음 함께, 멱등) > 결과 */
export function submitMockExamAttempt(
  attemptUuid: string,
  unsavedAnswers: readonly MockExamAnswerEntry[],
): Promise<MockExamResultResponse> {
  return apiFetch(`/mock-exams/attempts/${attemptUuid}/submit`, {
    method: "POST",
    body: JSON.stringify({ answers: unsavedAnswers }),
  });
}

/** 결과 (무료는 과목·토픽·해설·다음 할 일 비움 + lockedSections). 풀이 중이면 409 MOCK_EXAM_NOT_SUBMITTED */
export function fetchMockExamResult(attemptUuid: string): Promise<MockExamResultResponse> {
  return apiFetch(`/mock-exams/attempts/${attemptUuid}/result`);
}

/** 채점된 응시 점수 추이 (프로 전용, 무료 403 PRO_REQUIRED) */
export function fetchMockExamHistory(): Promise<MockExamHistoryResponse> {
  return apiFetch("/mock-exams/history");
}
