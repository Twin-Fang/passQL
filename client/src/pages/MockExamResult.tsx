import { useEffect, useMemo, useState } from "react";
import { Link, Navigate, useParams } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import ErrorFallback from "../components/ErrorFallback";
import LockedPreview from "../components/pro/LockedPreview";
import { MockExamReviewLockedSample, MockExamSubjectLockedSample } from "../components/pro/lockedPreviewSamples";
import MockExamVerdictHero from "../components/mockExam/MockExamVerdictHero";
import MockExamSubjectAnalysis from "../components/mockExam/MockExamSubjectAnalysis";
import MockExamQuestionNumberGrid from "../components/mockExam/MockExamQuestionNumberGrid";
import MockExamReviewList, { toReviewRowElementId } from "../components/mockExam/MockExamReviewList";
import MockExamNextStepCard from "../components/mockExam/MockExamNextStepCard";
import { toApiErrorCode } from "../api/client";
import { useMockExamResult } from "../hooks/useMockExam";
import { useMockExamPendingAnswerStore } from "../stores/mockExamPendingAnswerStore";
import {
  LOCKED_SECTION_MOCK_EXAM_REVIEW,
  LOCKED_SECTION_MOCK_EXAM_SUBJECT_DETAIL,
  groupBySubject,
  toResultCells,
} from "../lib/mockExamPresentation";
import { LOCKED_PREVIEW_CAPTIONS } from "../constants/proAccessCopy";
import { MOCK_EXAM_ROUNDS_PATH, toMockExamAttemptPath } from "../constants/mockExamRoutes";

/**
 * 모의고사 결과 (#866): 합격/불합격 > 과목·토픽(프로) > 정오표(모두) > 다음에 할 일·문항 해설(프로)
 * 무료는 서버가 비운 묶음(lockedSections) 자리에 잠금 미리보기, 풀이 중 응시면 풀이 화면으로
 */
export default function MockExamResult() {
  const { attemptUuid = "" } = useParams<{ attemptUuid: string }>();
  const { data: result, error, isError, refetch } = useMockExamResult(attemptUuid);
  const clearAttempt = useMockExamPendingAnswerStore((state) => state.clearAttempt);
  const [openQuestionNumber, setOpenQuestionNumber] = useState<number | null>(null);

  // 채점 끝 > 이 기기에 남은 저장 전 답 정리
  useEffect(() => {
    if (result) clearAttempt(attemptUuid);
  }, [result, attemptUuid, clearAttempt]);

  // 정오표·목록에서 고른 문항 > 그 행으로 스크롤
  useEffect(() => {
    if (openQuestionNumber === null) return;
    document.getElementById(toReviewRowElementId(openQuestionNumber))?.scrollIntoView({ block: "start" });
  }, [openQuestionNumber]);

  const resultCellGroups = useMemo(() => (result ? groupBySubject(toResultCells(result.questionMarks)) : []), [result]);

  if (toApiErrorCode(error) === "MOCK_EXAM_NOT_SUBMITTED") {
    return <Navigate to={toMockExamAttemptPath(attemptUuid)} replace />;
  }

  const backLink = (
    <Link to={MOCK_EXAM_ROUNDS_PATH} className="inline-flex items-center gap-1 text-sm text-text-secondary hover:text-text-primary">
      <ArrowLeft size={16} aria-hidden="true" />
      모의고사 목록
    </Link>
  );
  const pageClassName = "min-h-dvh bg-surface max-w-180 mx-auto w-full px-4 py-6";

  if (isError) {
    return (
      <div className={`${pageClassName} space-y-4`}>
        {backLink}
        <ErrorFallback onRetry={() => refetch()} />
      </div>
    );
  }
  if (!result) {
    return (
      <div className={`${pageClassName} space-y-3`} aria-busy="true">
        <div className="skeleton h-56 rounded-2xl" />
        <div className="skeleton h-32 rounded-2xl" />
      </div>
    );
  }

  const isSubjectDetailLocked = result.lockedSections.includes(LOCKED_SECTION_MOCK_EXAM_SUBJECT_DETAIL);
  const isReviewLocked = result.lockedSections.includes(LOCKED_SECTION_MOCK_EXAM_REVIEW);
  const hasReviews = !isReviewLocked && result.reviews.length > 0;
  const toggleQuestion = (questionNumber: number) =>
    setOpenQuestionNumber((previous) => (previous === questionNumber ? null : questionNumber));

  return (
    <div className={`${pageClassName} space-y-6`}>
      {backLink}
      <MockExamVerdictHero result={result} />

      {isSubjectDetailLocked ? (
        <LockedPreview preview={<MockExamSubjectLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.mockExamSubjectDetail} />
      ) : (
        <MockExamSubjectAnalysis subjects={result.subjects} topics={result.topics} />
      )}

      {/* 정오표: 무료도 공개, 해설이 있으면 번호 누르면 해설로 */}
      <section aria-label="문항별 정오">
        <h2 className="text-sm text-text-secondary mb-2 px-1">문항별 정오</h2>
        <div className="bg-surface-card border border-border rounded-2xl p-4">
          <MockExamQuestionNumberGrid
            groups={resultCellGroups}
            onSelectQuestion={hasReviews ? (questionNumber) => setOpenQuestionNumber(questionNumber) : undefined}
          />
        </div>
      </section>

      {result.nextStep && <MockExamNextStepCard nextStep={result.nextStep} />}

      {isReviewLocked ? (
        <LockedPreview preview={<MockExamReviewLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.mockExamReview} />
      ) : (
        hasReviews && (
          <MockExamReviewList reviews={result.reviews} openQuestionNumber={openQuestionNumber} onToggleQuestion={toggleQuestion} />
        )
      )}

      <Link to={MOCK_EXAM_ROUNDS_PATH} className="btn btn-secondary w-full">
        모의고사 목록으로
      </Link>
    </div>
  );
}
