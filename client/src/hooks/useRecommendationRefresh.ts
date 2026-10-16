import { useState, useCallback, useEffect } from "react";
import { useRefreshRecommendations } from "./useHome";
import type { QuestionSummary } from "../types/api";

// 세션 내 추천 제외 목록 최대 개수 (FIFO)
const MAXIMUM_SEEN_RECOMMENDATION_COUNT = 30;

/**
 * 홈 추천 문제 새로고침: 본 문제 UUID 누적 > 제외 목록으로 재요청, 버튼 1회전·카드 재등장 트리거
 */
export function useRecommendationRefresh(
  recommendedQuestions: readonly QuestionSummary[] | undefined,
  isRecommendationsFetching: boolean,
) {
  const refreshRecommendations = useRefreshRecommendations();
  // 버튼 1회전 트리거 — 애니메이션 클래스를 뗐다 붙이기 위해 별도 state 사용
  const [isSpinning, setIsSpinning] = useState(false);
  // 카드 페이드인 재트리거 — key가 바뀌면 카드 목록이 재마운트되어 애니메이션 재실행
  const [refreshKey, setRefreshKey] = useState(0);
  // 세션 내 이미 추천된 UUID 누적 — 새로고침 시 제외 목록으로 전달
  const [seenUuids, setSeenUuids] = useState<string[]>([]);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // 추천 결과가 도착하면 해당 UUID를 seenUuids에 누적
  // questions 배열 참조 기준으로 의존 — recommendations 객체 전체를 넣으면
  // 다른 필드 변경에도 effect가 실행되어 불필요한 state 업데이트 발생
  useEffect(() => {
    if (!recommendedQuestions || recommendedQuestions.length === 0) return;
    setSeenUuids((prev) => {
      const newUuids = recommendedQuestions
        .map((q) => q.questionUuid)
        .filter((uuid) => !prev.includes(uuid));
      if (newUuids.length === 0) return prev;
      // FIFO 30개 유지 — 무제한 누적 시 POST body 비대화 방지
      return [...prev, ...newUuids].slice(-MAXIMUM_SEEN_RECOMMENDATION_COUNT);
    });
  }, [recommendedQuestions]);

  const isRefreshDisabled = isRecommendationsFetching || isRefreshing || isSpinning;

  const refresh = useCallback(() => {
    if (isRecommendationsFetching || isRefreshing || isSpinning) return;
    setIsSpinning(true);
    setIsRefreshing(true);
    // 새로고침 시에만 seenUuids를 제외 목록으로 전달 — 평소엔 queryKey 고정 유지
    // finally로 에러 시에도 isRefreshing 복구 — 미처리 시 버튼 영구 비활성화 발생
    refreshRecommendations(seenUuids)
      .then(() => { setRefreshKey((k) => k + 1); })
      .finally(() => { setIsRefreshing(false); });
  }, [isRecommendationsFetching, isRefreshing, isSpinning, refreshRecommendations, seenUuids]);

  return {
    isSpinning,
    isRefreshDisabled,
    refreshKey,
    refresh,
    stopSpinning: () => setIsSpinning(false),
  };
}
