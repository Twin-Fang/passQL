import type { ChoiceItem, ExecuteResult, ExecutionMode } from "./api";

/**
 * 채점 결과 화면 진입 state (QuestionDetail 제출 성공 > navigate state)
 */
export interface AnswerFeedbackState {
  readonly isCorrect: boolean;
  readonly correctKey: string;
  readonly rationale: string;
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
  readonly schemaDisplay?: string | null;
  readonly schemaDdl?: string | null;
  readonly schemaSampleData?: string | null;
}
