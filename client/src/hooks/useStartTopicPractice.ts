import { useCallback, useState } from "react";
import { useNavigate } from "react-router-dom";
import { EmptyPracticeTopicError, generatePractice } from "../api/practice";
import { usePracticeStore } from "../stores/practiceStore";
import { toProAccessErrorCode, type ProAccessErrorCode } from "../lib/proAccess";

interface StartTopicPracticeRequest {
  readonly topicCode: string;
  // 풀이 화면 상단 제목 (토픽 이름, 최신 경향이면 접미사 포함)
  readonly sessionTitle: string;
  readonly isLatestTrendOnly?: boolean;
}

// 시작 결과 4종: 풀이 화면 이동, 문제 0개, 프로 접근 거부(사유 창), 그 외 실패
export type TopicPracticeStartResult = "STARTED" | "EMPTY_TOPIC" | "PRO_ACCESS_DENIED" | "FAILED";

/**
 * 토픽 연습 세션 시작: 문제 조회 > 세션 저장 > 풀이 화면 이동 (실패는 결과값, 문제 0개 안내는 호출부)
 * 프로 접근 거부(무료 403 PRO_REQUIRED 등) > proAccessErrorCode > 호출부가 ProAccessReasonModal 표시
 */
export function useStartTopicPractice() {
  const navigate = useNavigate();
  const startSession = usePracticeStore((state) => state.startSession);
  const [proAccessErrorCode, setProAccessErrorCode] = useState<ProAccessErrorCode | null>(null);

  const startTopicPractice = useCallback(
    async ({
      topicCode,
      sessionTitle,
      isLatestTrendOnly = false,
    }: StartTopicPracticeRequest): Promise<TopicPracticeStartResult> => {
      try {
        const { sessionId, questions } = await generatePractice(topicCode, { isLatestTrendOnly });
        startSession(sessionId, topicCode, sessionTitle, questions);
        navigate(`/practice/${sessionId}`);
        return "STARTED";
      } catch (error) {
        if (error instanceof EmptyPracticeTopicError) return "EMPTY_TOPIC";
        const deniedErrorCode = toProAccessErrorCode(error);
        if (deniedErrorCode) {
          setProAccessErrorCode(deniedErrorCode);
          return "PRO_ACCESS_DENIED";
        }
        console.warn("[topic practice] start failed", error);
        return "FAILED";
      }
    },
    [navigate, startSession],
  );

  const closeProAccessReason = useCallback(() => setProAccessErrorCode(null), []);

  return { startTopicPractice, proAccessErrorCode, closeProAccessReason };
}
