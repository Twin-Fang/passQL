import { useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { generatePractice } from "../api/practice";
import { usePracticeStore } from "../stores/practiceStore";

interface StartTopicPracticeRequest {
  readonly topicCode: string;
  // 풀이 화면 상단 제목 (토픽 이름, 최신 경향이면 접미사 포함)
  readonly sessionTitle: string;
  readonly isLatestTrendOnly?: boolean;
}

/**
 * 토픽 연습 세션 시작: 문제 조회 > 세션 저장 > 풀이 화면 이동
 * 문제 0개(EmptyPracticeTopicError)·조회 실패는 그대로 던짐 > 호출부가 안내 방식 결정
 */
export function useStartTopicPractice() {
  const navigate = useNavigate();
  const startSession = usePracticeStore((state) => state.startSession);

  return useCallback(
    async ({ topicCode, sessionTitle, isLatestTrendOnly = false }: StartTopicPracticeRequest) => {
      const { sessionId, questions } = await generatePractice(topicCode, { isLatestTrendOnly });
      startSession(sessionId, topicCode, sessionTitle, questions);
      navigate(`/practice/${sessionId}`);
    },
    [navigate, startSession],
  );
}
