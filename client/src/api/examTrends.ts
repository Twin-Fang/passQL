import { apiFetch } from "./client";
import type { ExamTrendReportResponse, LatestTrendTopicCount } from "../types/api";

/** 출제 경향 화면 내용 (#523) */
export function fetchLatestExamTrend(): Promise<ExamTrendReportResponse> {
  return apiFetch("/exam-trends/latest");
}

/** 토픽별 최신 경향 문제 수 (1개 이상인 활성 토픽만) */
export function fetchLatestTrendTopics(): Promise<LatestTrendTopicCount[]> {
  return apiFetch("/exam-trends/latest/topics");
}
