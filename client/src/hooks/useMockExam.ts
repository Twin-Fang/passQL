import { useQuery } from "@tanstack/react-query";
import {
  fetchMockExamHistory,
  fetchMockExamResult,
  fetchMockExamRounds,
  fetchMockExamSheet,
} from "../api/mockExams";
import { useMemberQueryScope } from "./useMemberQueryScope";
import type { MockExamSheetResponse } from "../types/api";

// 풀이 중 시험지 재동기화 주기 (30초, 남은 시간 보정·다른 기기 제출 감지)
const MOCK_EXAM_SHEET_SYNC_INTERVAL_MILLISECONDS = 30_000;

// 캐시 키 단일 원본 (제출 후 결과 미리 넣기·목록 무효화가 함께 씀)
export const MOCK_EXAM_QUERY_KEYS = {
  roundsPrefix: ["mockExam", "rounds"] as const,
  historyPrefix: ["mockExam", "history"] as const,
  rounds: (memberUuid: string | null) => ["mockExam", "rounds", memberUuid] as const,
  history: (memberUuid: string | null) => ["mockExam", "history", memberUuid] as const,
  sheet: (attemptUuid: string) => ["mockExam", "sheet", attemptUuid] as const,
  result: (attemptUuid: string) => ["mockExam", "result", attemptUuid] as const,
};

/** 시험지 + 받은 순간의 단조 시계 값 (남은 시간 계산 기준점) */
export interface SyncedMockExamSheet {
  readonly sheet: MockExamSheetResponse;
  readonly receivedAtMonotonicMilliseconds: number;
}

/** 회차 목록 (진입마다 새로 받음: 풀이 중 응시 남은 시간·체험 소진이 바로 바뀜) */
export function useMockExamRounds() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: MOCK_EXAM_QUERY_KEYS.rounds(memberUuid),
    queryFn: fetchMockExamRounds,
    enabled: isMemberQueryEnabled,
    staleTime: 0,
  });
}

/** 점수 추이 (프로 전용: 무료는 403 PRO_REQUIRED > 호출부가 잠금 미리보기) */
export function useMockExamHistory() {
  const { memberUuid, isMemberQueryEnabled } = useMemberQueryScope();
  return useQuery({
    queryKey: MOCK_EXAM_QUERY_KEYS.history(memberUuid),
    queryFn: fetchMockExamHistory,
    enabled: isMemberQueryEnabled,
    staleTime: 0,
  });
}

/** 풀이 시험지: 30초마다·탭 복귀 때 다시 받아 남은 시간 보정 (풀이 화면에 있는 동안만) */
export function useMockExamSheet(attemptUuid: string) {
  return useQuery({
    queryKey: MOCK_EXAM_QUERY_KEYS.sheet(attemptUuid),
    queryFn: async (): Promise<SyncedMockExamSheet> => {
      const sheet = await fetchMockExamSheet(attemptUuid);
      return { sheet, receivedAtMonotonicMilliseconds: performance.now() };
    },
    staleTime: 0,
    // 시작 응답을 미리 넣어 두고 풀이 화면이 바로 쓰도록 잠깐 보관
    gcTime: 60_000,
    refetchInterval: MOCK_EXAM_SHEET_SYNC_INTERVAL_MILLISECONDS,
    refetchOnWindowFocus: "always",
  });
}

/** 결과 (제출 응답을 미리 넣어 두면 재요청 없음) */
export function useMockExamResult(attemptUuid: string) {
  return useQuery({
    queryKey: MOCK_EXAM_QUERY_KEYS.result(attemptUuid),
    queryFn: () => fetchMockExamResult(attemptUuid),
  });
}
