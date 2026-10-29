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
  // 필드별 구독: 스토어의 다른 값 변경 시 결과 화면 전체 리렌더 방지
  const storeSessionId = usePracticeStore((state) => state.sessionId);
  const topicName = usePracticeStore((state) => state.topicName);
  const results = usePracticeStore((state) => state.results);
  const questions = usePracticeStore((state) => state.questions);
  const returnStep = usePracticeStore((state) => state.returnStep);
  const clearReturnStep = usePracticeStore((state) => state.clearReturnStep);
  const resetPracticeStore = usePracticeStore((state) => state.reset);

  // 다시 풀기 후 복귀 시 step2(index 1)로 바로 진입
  const initialStepRef = useRef(
    returnStep != null ? Math.min(returnStep, 1) : 0,
  );
  const initialStep = initialStepRef.current;

  useEffect(() => {
    clearReturnStep();
  }, [clearReturnStep]);

  const aiComment = usePracticeAiComment(sessionId);
  const { visibleStats, visibleCards, isResultListVisible, revealStatsSequentially } =
    usePracticeResultReveal(aiComment, results);

  const analysis = useMemo(() => {
    const correctCount = results.filter((r) => r.isCorrect).length;
    const totalCount = results.length;
    const totalDurationMs = results.reduce((sum, r) => sum + r.durationMs, 0);
    return { correctCount, totalCount, totalDurationMs };
  }, [results]);

  if (!storeSessionId || storeSessionId !== sessionId) {
    return <Navigate to="/questions" replace />;
  }

  const step1 = (
    <PracticeScoreSummary
      topicName={topicName}
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
            results={results}
            questions={questions}
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
          resetPracticeStore();
          navigate("/questions", { replace: true });
        }}
      />

    </div>
  );
}
