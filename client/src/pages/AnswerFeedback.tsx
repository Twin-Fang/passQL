import { useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import { useSimilarQuestions } from "../hooks/useSimilarQuestions";
import { useAnswerFeedbackExecution } from "../hooks/useAnswerFeedbackExecution";
import AnswerFeedbackHeader from "../components/answerFeedback/AnswerFeedbackHeader";
import FeedbackStemToggleCard from "../components/answerFeedback/FeedbackStemToggleCard";
import ConceptAnswerCards from "../components/answerFeedback/ConceptAnswerCards";
import RationaleCard from "../components/answerFeedback/RationaleCard";
import AiExplanationCard from "../components/answerFeedback/AiExplanationCard";
import SqlComparisonSection from "../components/answerFeedback/SqlComparisonSection";
import SimilarQuestionList from "../components/answerFeedback/SimilarQuestionList";
import { buildExplanationHistoryEntry } from "../stores/explanationHistoryStore";
import type { AnswerFeedbackState } from "../types/answerFeedback";

/**
 * 채점 결과 화면: 헤더 > 문제 보기 > 답 비교(개념형) > 해설 > SQL 실행 비교(실행형) > 유사 문제
 */
export default function AnswerFeedback() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state as AnswerFeedbackState | null;

  const similarQuery = useSimilarQuestions(state?.questionUuid ?? "");
  const execution = useAnswerFeedbackExecution(state);

  // state 없으면 렌더 중 직접 navigate 대신 effect로 이동 — 렌더 중 side effect 방지
  useEffect(() => {
    if (!state) navigate("/questions", { replace: true });
  }, [state, navigate]);

  if (!state) return null;

  const {
    isCorrect,
    rationale,
    explanation,
    selectedSql,
    correctSql,
    executionMode,
    isDailyChallenge,
    choices,
    selectedKey,
    correctKey,
    stem,
    schemaTables,
    schemaDdl,
    schemaSampleData,
    choiceSetUuid,
    structuredExplanation,
  } = state;

  const isExecutable = executionMode === "EXECUTABLE";

  // CONCEPT_ONLY 답 본문: 제출 응답 SQL 우선, 없으면 선택지 본문
  const selectedBody =
    selectedSql ?? choices?.find((c) => c.key === selectedKey)?.body ?? null;
  const correctBody =
    correctSql ?? choices?.find((c) => c.key === correctKey)?.body ?? null;

  // AI 해설 대상: 제출 세트를 아는 진입만 (옛 state 는 해설 카드 폴백)
  const explanationEntry = choiceSetUuid
    ? buildExplanationHistoryEntry({
        questionUuid: state.questionUuid,
        choiceSetUuid,
        selectedChoiceKey: selectedKey,
        choices: choices ?? [],
        result: {
          isCorrect,
          correctKey,
          rationale,
          explanation: explanation ?? null,
          structuredExplanation: structuredExplanation ?? null,
          selectedResult: null,
          correctResult: null,
          selectedSql,
          correctSql,
          submissionUuid: null,
        },
      })
    : null;

  const handleBottomButtonClick = () => {
    if (isDailyChallenge) {
      navigate(isCorrect ? "/" : "/daily-challenge", { replace: true });
    } else {
      navigate("/questions");
    }
  };

  return (
    <div className="min-h-screen bg-surface flex flex-col">
      {/* 헤더 — 최상단 고정 영역 */}
      <AnswerFeedbackHeader isCorrect={isCorrect} />

      <div className="flex-1 mx-auto max-w-180 w-full px-4 pt-4 pb-24 space-y-3">
        {/* 문제 보기 토글 — stem이 있을 때만 표시 */}
        {stem ? (
          <FeedbackStemToggleCard
            stem={stem}
            schemaTables={schemaTables}
            schemaDdl={schemaDdl}
            schemaSampleData={schemaSampleData}
          />
        ) : null}
        {!isExecutable ? (
          <ConceptAnswerCards isCorrect={isCorrect} selectedBody={selectedBody} correctBody={correctBody} />
        ) : null}
        {explanationEntry ? (
          <AiExplanationCard entry={explanationEntry} />
        ) : (
          <RationaleCard rationale={explanation || rationale} isAiExplanation={Boolean(explanation)} />
        )}
        {isExecutable && execution.sqlChoices.length > 0 ? (
          <SqlComparisonSection
            sqlChoices={execution.sqlChoices}
            correctKey={correctKey}
            selectedKey={selectedKey}
            openKeys={execution.openKeys}
            executingKeys={execution.executingKeys}
            resultCache={execution.resultCache}
            executionErrorByKey={execution.executionErrorByKey}
            onToggle={execution.toggleOpen}
            onExecute={execution.executeChoiceSql}
            onExecuteAll={execution.executeAllChoices}
          />
        ) : null}

        {/* 유사 문제 */}
        {similarQuery.data && similarQuery.data.length > 0 && (
          <SimilarQuestionList similarQuestions={similarQuery.data} />
        )}
      </div>

      {/* fixed bottom 버튼 — 항상 인디고(btn-primary) */}
      <div className="fixed bottom-0 inset-x-0 z-20 bg-surface">
        <div className="mx-auto max-w-180 px-4 py-4">
          <button
            type="button"
            className="btn-primary w-full"
            onClick={handleBottomButtonClick}
          >
            {isDailyChallenge
              ? isCorrect ? "홈으로 가기" : "다시 풀기"
              : "문제 목록으로"}
          </button>
        </div>
      </div>
    </div>
  );
}
