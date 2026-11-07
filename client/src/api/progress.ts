import { apiFetch } from "./client";
import type {
  ProgressResponse,
  HeatmapResponse,
  TopicAnalysisResponse,
  AiCommentResponse,
  WrongQuestionsResponse,
  StudyPatternResponse,
  AccuracyDetailResponse,
} from "../types/api";

export function fetchProgress(): Promise<ProgressResponse> {
  return apiFetch("/progress");
}

export function fetchHeatmap(from?: string, to?: string): Promise<HeatmapResponse> {
  const query = new URLSearchParams();
  if (from) query.set("from", from);
  if (to) query.set("to", to);
  const queryString = query.toString();
  return apiFetch(`/progress/heatmap${queryString ? `?${queryString}` : ""}`);
}

export function fetchTopicAnalysis(): Promise<TopicAnalysisResponse> {
  return apiFetch("/progress/topic-analysis");
}

// sessionUuid 있으면 세션 단위 캐시 2h (결과 화면), 없으면 멤버 단위 캐시 (통계 화면)
export function fetchAiComment(sessionUuid?: string): Promise<AiCommentResponse> {
  const queryString = sessionUuid ? `?sessionUuid=${sessionUuid}` : "";
  return apiFetch(`/progress/ai-comment${queryString}`);
}

export function fetchWrongQuestions(size = 20): Promise<WrongQuestionsResponse> {
  return apiFetch(`/progress/wrong-questions?size=${size}`);
}

// 학습 패턴 (#909, 무료): 최근 4주 날짜별 풀이·요약, 최근 12주 요일·시간대, 학습일·최장 연속
export function fetchStudyPattern(): Promise<StudyPatternResponse> {
  return apiFetch("/progress/study-pattern");
}

// 정답률 상세 (#909, 프로 > 무료는 403 PRO_REQUIRED): 난이도별 정답률, 오답 정리, 주별 남은 오답
export function fetchAccuracyDetail(): Promise<AccuracyDetailResponse> {
  return apiFetch("/progress/accuracy-detail");
}
