import { useQuery } from "@tanstack/react-query";
import { fetchLatestExamTrend, fetchLatestTrendTopics } from "../api/examTrends";

/** 출제 경향 화면 내용 (#523) */
export function useLatestExamTrend() {
  return useQuery({
    queryKey: ["examTrend", "latest"],
    queryFn: fetchLatestExamTrend,
  });
}

/** 최신 경향 문제가 있는 토픽 코드 집합 (불러오기 전·실패면 빈 집합, 토픽 카드 배지) */
export function useLatestTrendTopicCodes(): ReadonlySet<string> {
  const { data } = useQuery({
    queryKey: ["examTrend", "latestTopics"],
    queryFn: fetchLatestTrendTopics,
  });
  return new Set(
    (data ?? [])
      .filter((topicCount) => topicCount.latestTrendQuestionCount > 0)
      .map((topicCount) => topicCount.topicCode),
  );
}
