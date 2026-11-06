import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useTopics } from "../../hooks/useTopics";
import { useStartTopicPractice } from "../../hooks/useStartTopicPractice";
import ProAccessReasonModal from "../pro/ProAccessReasonModal";
import { WRONG_NOTES_PATH } from "../../constants/wrongNotes";
import type { AiAnalysisAction, TopicTree } from "../../types/api";

interface StatsAiAnalysisActionsProps {
  readonly actions: readonly AiAnalysisAction[];
}

// 출제 경향 화면 경로 (최신 경향 문제 풀기 버튼)
const EXAM_TREND_PATH = "/exam-trend";

/** 웹에서 실행할 수 있는 버튼 1개: 서버 label + 동작 (토픽 연습 시작 / 오답 노트 / 출제 경향 화면) */
type AiAnalysisActionButton =
  | { readonly kind: "PRACTICE_TOPIC"; readonly key: string; readonly label: string; readonly topic: TopicTree }
  | { readonly kind: "REVIEW_WRONG"; readonly key: string; readonly label: string }
  | { readonly kind: "PRACTICE_LATEST_TREND"; readonly key: string; readonly label: string };

/**
 * 서버 행동 > 웹 버튼: PRACTICE_TOPIC(토픽 code 못 찾으면 숨김), REVIEW_WRONG(오답 노트), PRACTICE_LATEST_TREND(출제 경향)
 * RANDOM_PRACTICE 는 웹에 랜덤 풀기 화면이 없어 숨김
 */
function toActionButtons(
  actions: readonly AiAnalysisAction[],
  topics: readonly TopicTree[],
): AiAnalysisActionButton[] {
  return actions.flatMap((action): AiAnalysisActionButton[] => {
    if (action.type === "REVIEW_WRONG") return [{ kind: "REVIEW_WRONG", key: action.type, label: action.label }];
    if (action.type === "PRACTICE_LATEST_TREND") {
      return [{ kind: "PRACTICE_LATEST_TREND", key: action.type, label: action.label }];
    }
    if (action.type !== "PRACTICE_TOPIC") return [];
    const topic = topics.find((candidate) => candidate.topicUuid === action.topicUuid);
    return topic ? [{ kind: "PRACTICE_TOPIC", key: `${action.type}-${topic.topicUuid}`, label: action.label, topic }] : [];
  });
}

/** 통계 AI 분석 행동 버튼: 토픽 연습·오답 노트·출제 경향 (첫 버튼 강조, 시작 중 중복 탭 차단) */
export default function StatsAiAnalysisActions({ actions }: StatsAiAnalysisActionsProps) {
  const navigate = useNavigate();
  const { data: topics } = useTopics();
  const { startTopicPractice, proAccessErrorCode, closeProAccessReason } = useStartTopicPractice();
  const [startingButtonKey, setStartingButtonKey] = useState<string | null>(null);

  const actionButtons = toActionButtons(actions, topics ?? []);
  if (actionButtons.length === 0) return null;

  // 화면 이동 버튼은 바로 이동, 토픽 연습은 시작 (시작 못 하면 화면 유지, 프로 접근 거부는 사유 창)
  const onActionButtonPressed = async (button: AiAnalysisActionButton) => {
    if (button.kind === "REVIEW_WRONG") {
      navigate(WRONG_NOTES_PATH);
      return;
    }
    if (button.kind === "PRACTICE_LATEST_TREND") {
      navigate(EXAM_TREND_PATH);
      return;
    }
    setStartingButtonKey(button.key);
    const startResult = await startTopicPractice({ topicCode: button.topic.code, sessionTitle: button.topic.displayName });
    if (startResult !== "STARTED") setStartingButtonKey(null);
  };

  return (
    <div className="flex flex-col gap-2 pt-1">
      {actionButtons.map((button, index) => (
        <button
          key={button.key}
          type="button"
          className={`btn w-full ${index === 0 ? "btn-primary" : "btn-secondary"}`}
          disabled={startingButtonKey !== null}
          onClick={() => onActionButtonPressed(button)}
        >
          {startingButtonKey === button.key && <span className="loading loading-spinner loading-sm" />}
          {button.label}
        </button>
      ))}
      {proAccessErrorCode && <ProAccessReasonModal errorCode={proAccessErrorCode} onClose={closeProAccessReason} />}
    </div>
  );
}
