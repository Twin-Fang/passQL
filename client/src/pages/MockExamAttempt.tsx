import { useCallback } from "react";
import { Link, Navigate, useParams } from "react-router-dom";
import ErrorFallback from "../components/ErrorFallback";
import MockExamSolvingScreen from "../components/mockExam/MockExamSolvingScreen";
import { useMockExamSheet } from "../hooks/useMockExam";
import { MOCK_EXAM_ROUNDS_PATH, toMockExamResultPath } from "../constants/mockExamRoutes";

/**
 * 모의고사 풀이 라우트 (#866): 시험지 받기 > 제출된 응시면 결과로 > 풀이 화면
 * 시험지는 30초마다·복귀 때 다시 받아 남은 시간 보정 (다른 기기 제출·시간 끝 채점도 여기서 감지)
 */
export default function MockExamAttempt() {
  const { attemptUuid = "" } = useParams<{ attemptUuid: string }>();
  const { data: syncedSheet, isError, refetch } = useMockExamSheet(attemptUuid);
  const requestSync = useCallback(() => {
    void refetch();
  }, [refetch]);

  if (syncedSheet?.sheet.status === "SUBMITTED") {
    return <Navigate to={toMockExamResultPath(attemptUuid)} replace />;
  }

  if (syncedSheet) {
    return <MockExamSolvingScreen syncedSheet={syncedSheet} onSyncRequested={requestSync} />;
  }

  if (isError) {
    return (
      <div className="min-h-dvh bg-surface max-w-120 mx-auto w-full px-4 py-10 space-y-4">
        <ErrorFallback onRetry={requestSync} />
        <Link to={MOCK_EXAM_ROUNDS_PATH} className="btn btn-ghost w-full">
          모의고사 목록으로
        </Link>
      </div>
    );
  }

  return (
    <div className="min-h-dvh bg-surface max-w-120 mx-auto w-full px-4 py-6 space-y-3" aria-busy="true">
      <div className="skeleton h-10 rounded-xl" />
      <div className="skeleton h-32 rounded-2xl" />
      <div className="skeleton h-16 rounded-xl" />
      <div className="skeleton h-16 rounded-xl" />
      <div className="skeleton h-16 rounded-xl" />
    </div>
  );
}
