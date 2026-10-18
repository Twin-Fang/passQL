import { useState, useCallback } from "react";
import { useParams, useNavigate } from "react-router-dom";
import AiExplanationSheet from "../components/AiExplanationSheet";
import { SchemaViewer } from "../components/SchemaViewer";
import { SqlPlayground } from "../components/SqlPlayground";
import LoadingOverlay from "../components/LoadingOverlay";
import ExitPracticeConfirmModal from "../components/practice/ExitPracticeConfirmModal";
import QuestionDetailSkeleton from "../components/questionDetail/QuestionDetailSkeleton";
import QuestionDetailHeader from "../components/questionDetail/QuestionDetailHeader";
import QuestionStemToggle from "../components/questionDetail/QuestionStemToggle";
import ChoiceGenerationStatus from "../components/questionDetail/ChoiceGenerationStatus";
import QuestionChoiceList from "../components/questionDetail/QuestionChoiceList";
import { executeChoice } from "../api/questions";
import { useQuestionDetail } from "../hooks/useQuestionDetail";
import { useQuestionChoices } from "../hooks/useQuestionChoices";
import { useChoiceExecutionCache } from "../hooks/useChoiceExecutionCache";
import { useAiErrorExplanation } from "../hooks/useAiErrorExplanation";
import { useQuestionAnswerSubmit } from "../hooks/useQuestionAnswerSubmit";
import { usePracticeBottomBarHeight } from "../hooks/usePracticeBottomBarHeight";
import type { ChoiceItem, SubmitResult } from "../types/api";

interface QuestionDetailProps {
  readonly practiceMode?: boolean;
  readonly practiceSubmitLabel?: string;
  readonly questionUuid?: string;
  // AI 코멘트 세션 집계용 — 연습/다시풀기 모드에서 store의 sessionId 전달
  readonly sessionUuid?: string;
  readonly onPracticeSubmit?: (
    selectedChoiceKey: string,
    choiceSetId: string,
    choices: readonly ChoiceItem[],
  ) => void;
  // 데일리 챌린지 모드: 제출 성공 시 호출자가 직접 네비게이션 제어
  readonly onSubmitSuccess?: (
    result: SubmitResult,
    questionUuid: string,
  ) => void;
  // 연습 모드에서 제출 후 true — ChoiceCard 안에 SQL 실행 버튼 표시
  readonly showExecution?: boolean;
}

/**
 * 문제 풀이 화면: 지문 > 스키마 > 선택지(SSE 생성 포함) > SQL 실행기 > 제출
 * 단독 라우트와 연습·데일리 화면(practiceMode) 공용
 */
export default function QuestionDetail({
  practiceMode,
  practiceSubmitLabel,
  questionUuid: propUuid,
  sessionUuid,
  onPracticeSubmit,
  onSubmitSuccess,
  showExecution = false,
}: QuestionDetailProps = {}) {
  const { questionUuid: paramUuid } = useParams<{ questionUuid: string }>();
  const questionUuid = propUuid ?? paramUuid;
  const navigate = useNavigate();
  const { data: question, isLoading } = useQuestionDetail(questionUuid!);

  const [selectedKey, setSelectedKey] = useState<string | null>(null);
  const [isStemOpen, setIsStemOpen] = useState(true);

  const { choices, choiceSetId, choiceGenerationError, retryChoiceGeneration } =
    useQuestionChoices(question, questionUuid);
  const { executeCache, executingKeys, executeChoiceSql } = useChoiceExecutionCache(questionUuid!);
  const aiExplanation = useAiErrorExplanation(choices, questionUuid!);
  const { isSubmitPending, submitSelectedAnswer, blocker } = useQuestionAnswerSubmit({
    question,
    questionUuid,
    sessionUuid,
    selectedKey,
    choices,
    choiceSetId,
    practiceMode,
    onPracticeSubmit,
    onSubmitSuccess,
  });

  // 제출 바 높이 공개 > 해설 하단 시트가 제출 버튼을 가리지 않음 (#521)
  const submitBarRef = usePracticeBottomBarHeight();

  const handleSelect = useCallback((choiceKey: string, _sql: string) => {
    // 풀이 중 SQL 자동 실행 없음 — 제출 후 결과 화면에서 실행
    setSelectedKey(choiceKey);
  }, []);

  if (isLoading || !question) {
    return <QuestionDetailSkeleton isPracticeMode={!!practiceMode} />;
  }

  const isSubmitReady =
    selectedKey !== null &&
    choices.length > 0 &&
    choiceSetId !== "" &&
    !isSubmitPending;


  // standalone 모드: 전체화면 + max-w-120 집중 레이아웃 (DailyChallenge와 동일)
  // practiceMode: DailyChallenge가 외부 컨테이너(flex-1 overflow-y-auto px-4) 제공
  // pb-24: fixed bottom 버튼 높이만큼 스크롤 영역 하단 여백 확보
  const containerClass = practiceMode
    ? "flex flex-col px-1 pb-24"
    : "flex flex-col min-h-screen bg-surface max-w-120 mx-auto w-full px-4 pb-24";

  return (
    <div className={containerClass}>
      {/* 헤더: 일반 모드에서만 뒤로가기 + 메타 정보 */}
      {!practiceMode && (
        <QuestionDetailHeader
          topicName={question.topicName ?? ""}
          difficulty={question.difficulty}
          onBack={() => navigate(-1)}
        />
      )}

      {/* 문제 지문 (토글) */}
      <QuestionStemToggle
        stem={question.stem}
        isStemOpen={isStemOpen}
        onToggle={() => setIsStemOpen((prev) => !prev)}
      />

      {/* 테이블 (지문 바로 아래, 스키마 없는 개념형은 렌더 안 함) */}
      <SchemaViewer
        schemaTables={question.schemaTables}
        schemaDdl={question.schemaDdl}
        schemaSampleData={question.schemaSampleData}
      />

      {/* 선택지 + SQL 실행기 */}
      {choices.length === 0 ? (
        <ChoiceGenerationStatus generationError={choiceGenerationError} onRetry={retryChoiceGeneration} />
      ) : (
        <QuestionChoiceList
          choices={choices}
          selectedKey={selectedKey}
          showExecution={showExecution}
          isExecutableQuestion={question.executionMode === "EXECUTABLE"}
          executeCache={executeCache}
          executingKeys={executingKeys}
          onSelect={handleSelect}
          onExecute={executeChoiceSql}
          onAskAi={aiExplanation.askAiAboutError}
        />
      )}
      {question.executionMode === "EXECUTABLE" && (
        <SqlPlayground
          onExecute={(sql) => executeChoice(questionUuid!, sql)}
        />
      )}

      {/* fixed bottom 제출 버튼 — PracticeFeedbackBar(z-30)가 제출 후 자연스럽게 덮음 */}
      <div ref={submitBarRef} className="fixed bottom-0 inset-x-0 z-20 bg-surface">
        <div className="mx-auto max-w-120 px-4 py-4">
          <button
            type="button"
            className={`w-full btn-primary ${!isSubmitReady ? "opacity-40 cursor-not-allowed" : ""}`}
            disabled={!isSubmitReady}
            onClick={submitSelectedAnswer}
          >
            {isSubmitPending
              ? "제출 중..."
              : (practiceSubmitLabel ?? "답안 제출하기")}
          </button>
        </div>
      </div>

      <AiExplanationSheet
        isOpen={aiExplanation.isSheetOpen}
        isLoading={aiExplanation.isExplanationLoading}
        isError={aiExplanation.isExplanationError}
        text={aiExplanation.explanationText}
        onClose={aiExplanation.closeSheet}
      />

      {/* 채점 중 오버레이 — API 호출 기간 동안 표시 */}
      {isSubmitPending && (
        <LoadingOverlay
          topicName={question.topicName ?? ""}
          staticMessage="채점 중이에요"
          subMessage="정답을 확인하고 있어요"
          isExecutable={question.executionMode === "EXECUTABLE"}
        />
      )}

      {/* 단독 풀이 모드에서만 이탈 방지 모달 표시 */}
      {!practiceMode && (
        <ExitPracticeConfirmModal
          isOpen={blocker.state === "blocked"}
          onCancel={() => blocker.reset?.()}
          onConfirm={() => blocker.proceed?.()}
        />
      )}
    </div>
  );
}
