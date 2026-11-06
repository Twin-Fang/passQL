import { useState } from "react";
import { EmptyPracticeTopicError } from "../../api/practice";
import { useTopics } from "../../hooks/useTopics";
import { useStartTopicPractice } from "../../hooks/useStartTopicPractice";
import type { AiAnalysisAction, TopicTree } from "../../types/api";

interface StatsAiAnalysisActionsProps {
  readonly actions: readonly AiAnalysisAction[];
}

/** 웹에서 실행할 수 있는 버튼 1개: 서버 label + 연습 시작에 쓸 토픽 */
interface PracticeTopicButton {
  readonly key: string;
  readonly label: string;
  readonly topic: TopicTree;
}

/** 서버 행동 > 웹 버튼: PRACTICE_TOPIC 만 (토픽 code 못 찾으면 숨김), REVIEW_WRONG 은 웹 오답 화면이 없어 숨김 */
function toPracticeTopicButtons(
  actions: readonly AiAnalysisAction[],
  topics: readonly TopicTree[],
): PracticeTopicButton[] {
  return actions.flatMap((action) => {
    if (action.type !== "PRACTICE_TOPIC") return [];
    const topic = topics.find((candidate) => candidate.topicUuid === action.topicUuid);
    return topic ? [{ key: `${action.type}-${topic.topicUuid}`, label: action.label, topic }] : [];
  });
}

/** 통계 AI 분석 바로 풀기 버튼 (첫 버튼 강조, 시작 중 중복 탭 차단) */
export default function StatsAiAnalysisActions({ actions }: StatsAiAnalysisActionsProps) {
  const { data: topics } = useTopics();
  const startTopicPractice = useStartTopicPractice();
  const [startingButtonKey, setStartingButtonKey] = useState<string | null>(null);

  const practiceTopicButtons = toPracticeTopicButtons(actions, topics ?? []);
  if (practiceTopicButtons.length === 0) return null;

  // 토픽 연습 시작 (문제 0개·조회 실패면 화면 유지, 출제 경향 화면과 같은 처리)
  const onPracticeButtonPressed = async (button: PracticeTopicButton) => {
    setStartingButtonKey(button.key);
    try {
      await startTopicPractice({ topicCode: button.topic.code, sessionTitle: button.topic.displayName });
    } catch (error) {
      if (!(error instanceof EmptyPracticeTopicError)) console.warn("[stats ai analysis] practice start failed", error);
      setStartingButtonKey(null);
    }
  };

  return (
    <div className="flex flex-col gap-2 pt-1">
      {practiceTopicButtons.map((button, index) => (
        <button
          key={button.key}
          type="button"
          className={`btn w-full ${index === 0 ? "btn-primary" : "btn-secondary"}`}
          disabled={startingButtonKey !== null}
          onClick={() => onPracticeButtonPressed(button)}
        >
          {startingButtonKey === button.key && <span className="loading loading-spinner loading-sm" />}
          {button.label}
        </button>
      ))}
    </div>
  );
}
