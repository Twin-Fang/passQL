import { useState, useCallback, useRef } from "react";
import { useNavigate, Navigate, useBlocker } from "react-router-dom";
import { useQueryClient } from "@tanstack/react-query";
import { Home } from "lucide-react";
import { useTodayQuestion } from "../hooks/useHome";
import { useAuthStore } from "../stores/authStore";
import { submitAnswer } from "../api/questions";
import QuestionDetail from "./QuestionDetail";
import PracticeFeedbackBar from "../components/PracticeFeedbackBar";
import ExitPracticeConfirmModal from "../components/practice/ExitPracticeConfirmModal";
import LoadingOverlay from "../components/LoadingOverlay";
import PracticeTopBar from "../components/practice/PracticeTopBar";
import PracticeQuestionScrollArea from "../components/practice/PracticeQuestionScrollArea";
import type { ChoiceItem, SubmitResult } from "../types/api";

export default function DailyChallenge() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const uuid = useAuthStore((s) => s.memberUuid ?? "");
  const { data: today, isLoading } = useTodayQuestion();
  const [feedback, setFeedback] = useState<SubmitResult | null>(null);
  // 답안 제출 API 호출 중 화면 조작 차단
  const [submitting, setSubmitting] = useState(false);
  // 연타 방지 — React state는 async 클로저에서 stale하므로 ref로 동기 플래그 관리
  const isProcessingRef = useRef(false);
  // 다시 풀기 시 QuestionDetail 강제 리마운트 — isSubmittingRef 초기화 목적
  const [retryCount, setRetryCount] = useState(0);
  // sessionUuid — 마운트 시 1회 생성하여 정답/다시 풀기 시에도 동일 세션으로 집계
  const [sessionUuid] = useState(() => crypto.randomUUID());

  // 제출 완료 전까지 이탈 차단 — 로딩 중·제출 완료·제출 API 호출 중에는 차단 해제
  // submitting 중에도 해제: catch 블록의 navigate("/")가 모달 없이 통과되어야 함
  // useBlocker는 훅이므로 조건부 return 이전에 호출해야 함
  const blocker = useBlocker(!isLoading && feedback === null && !submitting);

  // 정답 시에만 submitAnswer 호출 — 오답은 로컬 피드백만 표시해 alreadySolvedToday 유지
  const handlePracticeSubmit = useCallback(
    async (selectedChoiceKey: string, choiceSetId: string, choices: readonly ChoiceItem[]) => {
      if (!today?.question) return;
      // 연타로 인한 중복 제출 방지
      if (isProcessingRef.current) return;
      isProcessingRef.current = true;

      const selectedChoice = choices.find((c) => c.key === selectedChoiceKey);
      const correctChoice = choices.find((c) => c.isCorrect);

      setSubmitting(true);
      if (selectedChoice?.isCorrect) {
        // 정답: 백엔드에 제출 → 완료 처리 (alreadySolvedToday=true)
        try {
          const result = await submitAnswer(today.question.questionUuid, choiceSetId, selectedChoiceKey, sessionUuid);
          // 캐시 무효화 (복귀 시 재요청) — 홈 복귀 시 완료 상태·추천 문제 목록·학습 현황 반영
          queryClient.invalidateQueries({ queryKey: ["todayQuestion", uuid] });
          // excludeUuids=[]로 새 랜덤 세트를 받음 — 데일리 챌린지 완료 후이므로 의도된 동작
          queryClient.invalidateQueries({ queryKey: ["recommendations"] });
          queryClient.invalidateQueries({ queryKey: ["heatmap"] });
          queryClient.invalidateQueries({ queryKey: ["progress"] });
          setFeedback(result);
        } catch {
          navigate("/", { replace: true });
        } finally {
          isProcessingRef.current = false;
          setSubmitting(false);
        }
      } else {
        // 오답: submitAnswer 호출 안 함 → 미완료 상태 유지 → 다시 풀기 가능
        const localResult: SubmitResult = {
          isCorrect: false,
          correctKey: correctChoice?.key ?? "",
          rationale: correctChoice?.rationale ?? selectedChoice?.rationale ?? "",
          selectedResult: null,
          correctResult: null,
          selectedSql: null,
          correctSql: null,
        };
        setFeedback(localResult);
        isProcessingRef.current = false;
        setSubmitting(false);
      }
    },
    [today?.question, navigate, queryClient, uuid, sessionUuid],
  );

  // 이미 오늘 풀었으면 홈으로 리다이렉트 — 피드백바 표시 중엔 건너뜀
  if (!isLoading && today?.alreadySolvedToday && !feedback) {
    return <Navigate to="/" replace />;
  }

  // 오늘의 문제 없음
  if (!isLoading && !today?.question) {
    return (
      <div className="flex flex-col items-center justify-center h-screen gap-4 text-center px-4">
        <p className="text-body text-text-secondary">오늘의 문제가 아직 없어요</p>
        <button
          type="button"
          className="btn-primary px-6"
          onClick={() => navigate("/", { replace: true })}
        >
          홈으로 가기
        </button>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-screen max-w-120 mx-auto w-full">
      {/* PracticeSet과 동일한 헤더 구조 */}
      <div className="px-4 pt-3 pb-2">
        <PracticeTopBar
          exitIcon={<Home size={18} className="text-text-secondary" />}
          onExitClick={() => navigate("/")}
          title="오늘의 문제"
        />
        {/* 제출 전: 비어있음 / 제출 후: 완료 표시 */}
        <div className="w-full h-1.5 bg-border rounded-full overflow-hidden">
          <div
            className={`h-full bg-brand rounded-full transition-all duration-300 ${feedback ? "w-full" : "w-0"}`}
          />
        </div>
      </div>

      {/* 피드백바 높이만큼 bottom padding — 마지막 초이스카드가 가려지지 않게 */}
      <PracticeQuestionScrollArea hasFeedbackBar={!!feedback}>
        {/* 제출 후 showExecution=true — ChoiceCard 안에 SQL 실행 버튼 표시 */}
        <QuestionDetail
          key={`${today?.question?.questionUuid}-${retryCount}`}
          questionUuid={today?.question?.questionUuid}
          practiceMode
          practiceSubmitLabel="확인"
          onPracticeSubmit={handlePracticeSubmit}
          showExecution={!!feedback}
        />
      </PracticeQuestionScrollArea>

      {/* 제출 후 인라인 피드백 — 정답: 홈으로 / 오답: 홈으로 가기 + 다시 풀기 */}
      {feedback && (
        <PracticeFeedbackBar
          result={feedback}
          nextLabel="홈으로 가기"
          onNext={() => navigate("/", { replace: true })}
          {...(!feedback.isCorrect && {
            secondaryLabel: "다시 풀기",
            // retryCount 변경 → QuestionDetail 리마운트 → isSubmittingRef 초기화
            onSecondary: () => { setFeedback(null); setRetryCount((c) => c + 1); },
          })}
        />
      )}

      {/* 채점 중 오버레이 — 제출 API 응답 전 화면 조작 차단 */}
      {submitting && (
        <LoadingOverlay
          topicName="오늘의 문제"
          staticMessage="채점 중이에요"
          subMessage="잠시만 기다려주세요"
        />
      )}

      {/* 이탈 방지 확인 모달 */}
      <ExitPracticeConfirmModal
        isOpen={blocker.state === "blocked"}
        onCancel={() => blocker.reset?.()}
        onConfirm={() => blocker.proceed?.()}
      />
    </div>
  );
}
