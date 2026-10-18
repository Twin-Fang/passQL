import { useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { fetchChoiceExplanation } from "../api/ai";
import { useAuthStore } from "../stores/authStore";
import { canPollAgain, computeNextPollDelayMilliseconds } from "../lib/choiceExplanationPolling";
import type { ChoiceExplanation, ChoiceExplanationResponse } from "../types/api";

export interface ChoiceExplanationTarget {
  readonly questionUuid: string;
  readonly choiceSetUuid: string;
  readonly selectedChoiceKey: string;
  // 제출 응답 구조화 해설: 있으면 조회 없이 즉시 READY
  readonly initialExplanation: ChoiceExplanation | null;
  // 실패·구조화 없음일 때 마크다운 폴백
  readonly fallbackText: string | null;
}

// 화면 상태 3개: 기다림 / 보여 줄 해설 있음 / 실패(재시도 가능)
export type ChoiceExplanationPhase = "loading" | "ready" | "failed";

export interface ChoiceExplanationView {
  readonly phase: ChoiceExplanationPhase;
  // 구조화 해설 (고정 세트·옛 해설이면 null, markdownText 만)
  readonly explanation: ChoiceExplanation | null;
  // ready: 구조화 없을 때 본문 / loading: 옛 해설 임시 표시 / failed: 폴백
  readonly markdownText: string | null;
  readonly retry: () => void;
}

/** 쿼리 키: 회원·문제·세트·보기 (다음 문제로 넘어가도 같은 키로 캐시 재사용) */
export function choiceExplanationQueryKey(memberUuid: string, target: ChoiceExplanationTarget) {
  return ["choiceExplanation", memberUuid, target.questionUuid, target.choiceSetUuid, target.selectedChoiceKey] as const;
}

/** 제출 응답 구조화 해설 > 조회 응답 모양 (initialData) */
function toReadyResponse(target: ChoiceExplanationTarget, explanation: ChoiceExplanation): ChoiceExplanationResponse {
  return {
    choiceSetUuid: target.choiceSetUuid,
    selectedChoiceKey: target.selectedChoiceKey,
    status: "READY",
    explanation,
    text: null,
    promptVersion: null,
    retryAfterMilliseconds: null,
  };
}

/**
 * 선택지 해설 1건: 제출 응답 즉시 표시 > 없으면 조회 > GENERATING 이면 retryAfter·백오프로 재조회 (최대 8회)
 * 응답 > 화면 상태 변환: READY 해설 / GENERATING 기다림(옛 해설 임시) / FAILED·오류·횟수 초과 실패
 */
export function useChoiceExplanation(target: ChoiceExplanationTarget): ChoiceExplanationView {
  const memberUuid = useAuthStore((state) => state.memberUuid ?? "");
  const queryClient = useQueryClient();
  const queryKey = choiceExplanationQueryKey(memberUuid, target);
  const initialExplanation = target.initialExplanation;

  const query = useQuery({
    queryKey,
    queryFn: () =>
      fetchChoiceExplanation({
        questionUuid: target.questionUuid,
        choiceSetUuid: target.choiceSetUuid,
        selectedChoiceKey: target.selectedChoiceKey,
      }),
    initialData: initialExplanation ? toReadyResponse(target, initialExplanation) : undefined,
    // 해설은 세션 안에서 바뀌지 않음 > 다시 열 때 재요청 없음 (재조회는 refetchInterval 만)
    staleTime: Infinity,
    // 해설함에서 다시 열면 즉시 (30분 보관)
    gcTime: 1000 * 60 * 30,
    enabled: memberUuid !== "",
    // GENERATING 동안만 재조회, 받은 응답 수로 백오프 순번 계산
    refetchInterval: (currentQuery) => {
      const response = currentQuery.state.data;
      if (response?.status !== "GENERATING") return false;
      const receivedResponseCount = currentQuery.state.dataUpdateCount;
      if (!canPollAgain(receivedResponseCount)) return false;
      return computeNextPollDelayMilliseconds(receivedResponseCount - 1, response.retryAfterMilliseconds);
    },
    // 탭이 가려져도 완료까지 재조회 (넘어간 문제 해설을 해설함에서 바로 보게)
    refetchIntervalInBackground: true,
  });

  // 처음부터 다시: 받은 응답 수를 0 으로 되돌려 백오프·횟수 초기화
  const retry = useCallback(() => {
    void queryClient.resetQueries({ queryKey });
    // queryKey 는 매 렌더 새 배열 > 구성 값으로 의존성 고정
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [queryClient, memberUuid, target.questionUuid, target.choiceSetUuid, target.selectedChoiceKey]);

  // 받은 응답 수: 관찰 결과에 없어 캐시 상태에서 읽음
  // 같은 GENERATING 응답은 data 참조가 그대로라 dataUpdatedAt 을 읽어 응답마다 다시 렌더되게 구독
  const hasReceivedResponse = query.dataUpdatedAt > 0;
  const receivedResponseCount = hasReceivedResponse ? (queryClient.getQueryState(queryKey)?.dataUpdateCount ?? 0) : 0;
  return toExplanationView(query.data, query.isError, receivedResponseCount, target.fallbackText, retry);
}

/** 조회 응답 + 오류 여부 + 받은 응답 수 > 화면 상태 */
function toExplanationView(
  response: ChoiceExplanationResponse | undefined,
  isError: boolean,
  receivedResponseCount: number,
  fallbackText: string | null,
  retry: () => void,
): ChoiceExplanationView {
  const failed = (markdownText: string | null): ChoiceExplanationView => ({
    phase: "failed",
    explanation: null,
    markdownText: markdownText || fallbackText,
    retry,
  });
  if (isError && !response) return failed(null);
  if (!response) return { phase: "loading", explanation: null, markdownText: null, retry };

  switch (response.status) {
    case "READY": {
      const markdownText = response.text || fallbackText;
      // 구조화·마크다운 둘 다 없으면 보여 줄 것이 없음 > 실패
      if (!response.explanation && !markdownText) return failed(null);
      return { phase: "ready", explanation: response.explanation, markdownText, retry };
    }
    case "GENERATING":
      // 재조회 횟수를 다 쓰면 실패 (재시도로 다시 기다림)
      if (!canPollAgain(receivedResponseCount)) return failed(response.text);
      return { phase: "loading", explanation: null, markdownText: response.text, retry };
    case "FAILED":
      return failed(response.text);
  }
}
