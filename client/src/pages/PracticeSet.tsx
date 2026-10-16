import { useCallback, useEffect } from "react";
import { useParams, useNavigate, Navigate } from "react-router-dom";
import { ArrowLeft } from "lucide-react";
import { usePracticeStore } from "../stores/practiceStore";
import { useAuthStore } from "../stores/authStore";
import { usePracticeSetSubmit } from "../hooks/usePracticeSetSubmit";
import { useSubmissionReport } from "../hooks/useSubmissionReport";
import { usePracticeExitGuard } from "../hooks/usePracticeExitGuard";
import QuestionDetail from "./QuestionDetail";
import PracticeFeedbackBar from "../components/PracticeFeedbackBar";
import ReportModal from "../components/ReportModal";
import LoadingOverlay from "../components/LoadingOverlay";
import ProgressBar from "../components/ProgressBar";
import PracticeTopBar from "../components/practice/PracticeTopBar";
import PracticeQuestionScrollArea from "../components/practice/PracticeQuestionScrollArea";
import WaitingForQuestion from "../components/practice/WaitingForQuestion";
import ExitPracticeConfirmModal from "../components/practice/ExitPracticeConfirmModal";

/**
 * 연습 세트 풀이: 문제 풀이 > 피드백바(신고) > 다음 문제, 마지막 문제 후 결과 화면 이동
 */
export default function PracticeSet() {
  const { sessionId } = useParams<{ sessionId: string }>();
  const navigate = useNavigate();

  const storeSessionId = usePracticeStore((s) => s.sessionId);
  const questions = usePracticeStore((s) => s.questions);
  const currentIndex = usePracticeStore((s) => s.currentIndex);
  const topicName = usePracticeStore((s) => s.topicName);
  const submitAndAdvance = usePracticeStore((s) => s.submitAndAdvance);

  const memberUuid = useAuthStore((s) => s.memberUuid ?? "");

  const {
    feedback,
    feedbackChoiceSetUuid,
    isSubmitting,
    displayIndex,
    displayQuestion,
    submitPracticeAnswer,
    clearFeedbackForNextQuestion,
  } = usePracticeSetSubmit({ questions, currentIndex, storeSessionId, submitAndAdvance });
  const report = useSubmissionReport();

  const totalQuestions = questions.length;
  // 마지막 문제 완료 여부 — 결과 페이지 이동 조건이자 이탈 차단 해제 기준
  const shouldNavigateToResult = !feedback && currentIndex >= totalQuestions;

  // 마지막 문제 완료 전까지 이탈 차단 — 중간 이탈 시 세션 기록 유실 방지
  // submitting 중에는 이탈 차단 해제 — 채점 API 진행 중 모달 충돌 방지
  const exitGuard = usePracticeExitGuard(!shouldNavigateToResult && !isSubmitting);

  const { closeReportModal } = report;
  const handleNext = useCallback(() => {
    clearFeedbackForNextQuestion();
    closeReportModal();
  }, [clearFeedbackForNextQuestion, closeReportModal]);

  // useEffect는 훅 규칙상 조건부 return 이전에 위치해야 함
  useEffect(() => {
    if (shouldNavigateToResult) {
      navigate(`/practice/${sessionId}/result`, { replace: true });
    }
  }, [shouldNavigateToResult, navigate, sessionId]);

  if (!storeSessionId || storeSessionId !== sessionId) {
    return <Navigate to="/questions" replace />;
  }

  if (shouldNavigateToResult) {
    return null;
  }

  // 신고 모달 대상 — submissionUuid가 있어야 신고 가능
  const reportSubmissionUuid = feedback?.submissionUuid;

  return (
    <div className="flex flex-col h-screen max-w-120 mx-auto w-full">
      <div className="px-4 pt-3 pb-2">
        <PracticeTopBar
          exitIcon={<ArrowLeft size={18} className="text-text-secondary" />}
          exitAriaLabel="풀이 나가기"
          onExitClick={exitGuard.openExitConfirm}
          title={<>{displayIndex + 1} / {totalQuestions}</>}
          trailing={
            <div className="justify-self-end">
              <span className="badge-topic">{topicName}</span>
            </div>
          }
        />
        <ProgressBar
          fillPercent={((displayIndex + 1) / totalQuestions) * 100}
          trackClassName="h-1.5 bg-border"
          fillClassName="bg-brand transition-all duration-300"
        />
      </div>

      {displayQuestion ? (
        <PracticeQuestionScrollArea hasFeedbackBar={!!feedback}>
          {/* 제출 후 showExecution=true — ChoiceCard 안에 SQL 실행 버튼 표시 */}
          <QuestionDetail
            key={displayQuestion.questionUuid}
            questionUuid={displayQuestion.questionUuid}
            practiceMode
            practiceSubmitLabel="확인"
            onPracticeSubmit={submitPracticeAnswer}
            showExecution={!!feedback}
          />
        </PracticeQuestionScrollArea>
      ) : (
        <WaitingForQuestion topicName={topicName ?? ""} />
      )}

      {feedback && (
        <PracticeFeedbackBar
          result={feedback}
          onNext={handleNext}
          nextLabel={feedback?.isCorrect ? "계속하기" : "확인"}
          // submissionUuid가 있고 memberUuid가 있을 때만 신고 버튼 표시
          onReport={
            feedback.submissionUuid && memberUuid
              ? report.openReportModal
              : undefined
          }
          isReported={
            feedback.submissionUuid
              ? report.isSubmissionReported(feedback.submissionUuid)
              : false
          }
        />
      )}

      {/* 신고 모달 — submissionUuid를 지역 변수로 추출하여 non-null assertion 없이 타입 안전하게 렌더 */}
      {reportSubmissionUuid && report.isReportModalOpen && displayQuestion && (
        <ReportModal
          questionUuid={displayQuestion.questionUuid}
          submissionUuid={reportSubmissionUuid}
          choiceSetUuid={feedbackChoiceSetUuid}
          onClose={report.closeReportModal}
          onSuccess={() => report.markSubmissionReported(reportSubmissionUuid)}
        />
      )}

      {/* 신고 접수 토스트 */}
      {report.isReportToastVisible && (
        <div className="toast toast-top toast-end z-50">
          <div className="alert alert-success text-sm">
            <span>신고를 접수했어요.</span>
          </div>
        </div>
      )}

      {/* 채점 중 오버레이 — 제출 API 응답 전 화면 조작 차단 */}
      {isSubmitting && (
        <LoadingOverlay
          topicName={topicName ?? ""}
          staticMessage="채점 중이에요"
          subMessage="잠시만 기다려주세요"
          isExecutable={displayQuestion?.executionMode === "EXECUTABLE"}
        />
      )}

      {/* 이탈 방지 확인 모달 — 나가기 버튼 또는 브라우저 뒤로가기(blocker) 대응 */}
      <ExitPracticeConfirmModal
        isOpen={exitGuard.isExitConfirmOpen}
        onCancel={exitGuard.cancelExit}
        onConfirm={exitGuard.confirmExit}
      />
    </div>
  );
}
