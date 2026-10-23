import type { ChoiceExplanation, ChoiceItem, ExecuteResult, ExecutionMode, QuestionSchemaTable } from "./api";

/**
 * 채점 결과 화면 진입 state (QuestionDetail 제출 성공 > navigate state)
 */
export interface AnswerFeedbackState {
  readonly isCorrect: boolean;
  readonly correctKey: string;
  readonly rationale: string;
  // 미리 생성된 AI 해설 (있으면 rationale 대신 표시) (#496)
  readonly explanation?: string | null;
  // 구조화 AI 해설 (있으면 즉시 표시, 없으면 choiceSetUuid 로 조회, #521)
  readonly structuredExplanation?: ChoiceExplanation | null;
  // 무료 응답에서 서버가 뺀 묶음 (제출 응답 그대로, #578)
  readonly lockedSections?: readonly string[];
  // 제출한 선택지 세트 (없으면 옛 진입 > 해설 카드만)
  readonly choiceSetUuid?: string;
  readonly selectedKey: string;
  readonly selectedSql: string | null;
  readonly correctSql: string | null;
  readonly questionUuid: string;
  readonly executionMode?: ExecutionMode;
  readonly selectedResult: ExecuteResult | null;
  readonly correctResult: ExecuteResult | null;
  readonly isDailyChallenge?: boolean;
  readonly choices?: readonly ChoiceItem[];
  // 결과 화면 상단 문제 보기 토글용
  readonly stem?: string;
  readonly topicName?: string;
  readonly schemaTables?: readonly QuestionSchemaTable[];
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}
