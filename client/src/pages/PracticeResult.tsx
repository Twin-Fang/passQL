import { useMemo, useRef, useEffect } from "react";
import { useParams, useNavigate, Navigate } from "react-router-dom";
import { usePracticeStore } from "../stores/practiceStore";
import { usePracticeAiComment } from "../hooks/usePracticeAiComment";
import { usePracticeResultReveal } from "../hooks/usePracticeResultReveal";
import StepNavigator from "../components/StepNavigator";
import PracticeScoreSummary from "../components/practiceResult/PracticeScoreSummary";
import PracticeAiReport from "../components/practiceResult/PracticeAiReport";
import PracticeQuestionResultList from "../components/practiceResult/PracticeQuestionResultList";

/**
 * 연습 세트 결과: 1단계 점수·통계 > 2단계 AI 리포트 + 문제별 결과
 */
export default function PracticeResult() {
  const { sessionId } = useParams<{ sessionId: string }>();
  const navigate = useNavigate();
  const store = usePracticeStore();

  // 다시 풀기 후 복귀 시 step2로 바로 진입 (기존 step3 → 통합 후 step2)
  const initialStepRef = useRef(
    store.returnStep != null ? Math.min(store.returnStep, 1) : 0,
  );
  const initialStep = initialStepRef.current;

  useEffect(() => {
    store.clearReturnStep();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const aiComment = usePracticeAiComment(sessionId);
  const { visibleStats, visibleCards, isResultListVisible, revealStatsSequentially } =
    usePracticeResultReveal(aiComment, store.results);

  const analysis = useMemo(() => {
    const results = store.results;
    const correctCount = results.filter((r) => r.isCorrect).length;
    const totalCount = results.length;
    const totalDurationMs = results.reduce((sum, r) => sum + r.durationMs, 0);
    return { correctCount, totalCount, totalDurationMs };
  }, [store.results]);

  if (!store.sessionId || store.sessionId !== sessionId) {
    return <Navigate to="/questions" replace />;
  }

  const step1 = (
    <PracticeScoreSummary
      topicName={store.topicName}
      correctCount={analysis.correctCount}
      totalCount={analysis.totalCount}
      totalDurationMilliseconds={analysis.totalDurationMs}
      visibleStats={visibleStats}
      onScoreCountComplete={revealStatsSequentially}
    />
  );

  // Step2: AI 분석 + 문제별 결과 통합
  // AI 실패 시 뱃지/텍스트 영역 전체 숨김 — 문제 결과만 바로 표시
  const step2 = (
    <div className="text-left w-full px-4">
      {/* AI 성공 시에만 뱃지 + 텍스트 표시 */}
      {aiComment !== false && <PracticeAiReport aiComment={aiComment} />}

      {/* 문제별 결과 — AI 애니메이션 완료 후 등장 */}
      <div
        className={`transition-all duration-400 ease-out ${
          isResultListVisible
            ? "opacity-100 translate-y-0"
            : "opacity-0 translate-y-3"
        }`}
      >
        {isResultListVisible && (
          <PracticeQuestionResultList
            results={store.results}
            questions={store.questions}
            sessionId={sessionId}
            visibleCards={visibleCards}
          />
        )}
      </div>
    </div>
  );

  return (
    <div className="h-screen max-w-120 mx-auto px-4">
      <StepNavigator
        key={initialStep}
        steps={[step1, step2]}
        initialStep={initialStep}
        lastButtonLabel="태그 목록으로"
        onLastStep={() => {
          store.reset();
          navigate("/questions", { replace: true });
        }}
      />

    </div>
  );
}
