import type { components } from "./generated/openapi";

// 서버 계약(api-contract/openapi.json) 생성 타입. 서버 응답·요청은 별칭만 둔다 (#458, #517)
// 손타입은 생성본에 스키마가 없는 웹 전용(SSE 이벤트·제네릭 Page·화면 상태)만 유지
type ApiSchemas = components["schemas"];

// === Question ===
export type ExecutionMode = ApiSchemas["QuestionSummary"]["executionMode"];
export type ChoiceKind = ApiSchemas["ChoiceItem"]["kind"];
// AI_ONLY: 일반 AI 생성 / ODD_ONE_OUT: "결과가 다른 것은?" 유형 / CURATED_ONLY/HYBRID: 미구현
// RESULT_MATCH: "다음 SQL의 실행 결과로 올바른 것은?" 유형 — 선택지 body가 JSON 배열 결과 테이블
export type ChoiceSetPolicy = ApiSchemas["QuestionDetail"]["choiceSetPolicy"];

export type QuestionSummary = ApiSchemas["QuestionSummary"];

export type ChoiceItem = ApiSchemas["ChoiceItem"];

export type ChoiceSetSource = ApiSchemas["ChoiceSetSummary"]["source"];

export type ChoiceSetStatus = ApiSchemas["ChoiceSetSummary"]["status"];

export type ChoiceSetSummary = ApiSchemas["ChoiceSetSummary"];

export type QuestionDetail = ApiSchemas["QuestionDetail"];

// selectedResult·correctResult: EXECUTABLE 문제만 non-null / explanation: 미리 생성된 AI 해설 (#496)
export type SubmitResult = ApiSchemas["SubmitResult"];

// 문제 화면 테이블 미리보기 (서버가 DDL·샘플 INSERT 를 해석해 내려줌, #520)
export type QuestionSchemaTable = ApiSchemas["QuestionSchemaTable"];

// === SSE (선택지 생성) ===
// SSE 이벤트 본문은 OpenAPI 스키마가 없음 (응답 타입이 SseEmitter) > 웹 손타입 유지
export type SseStatusPhase = "generating" | "validating";

export interface SseStatusEvent {
  readonly phase: SseStatusPhase;
  readonly message: string;
}

export interface SseErrorEvent {
  readonly code: string;
  readonly message: string;
  readonly retryable: boolean;
}

// SSE complete 이벤트 본문 (스키마 없음)
export interface ChoiceSetGeneratedEvent {
  readonly choiceSetId: string;
  // isCorrect, rationale은 사용자 정답 노출 방지를 위해 제외됨
  readonly choices: readonly ChoiceItem[];
}

export type ExecuteResult = ApiSchemas["ExecuteResult"];

// === Page ===
// 생성본은 PageQuestionSummary 하나뿐 > 여러 목록에 쓰는 제네릭 손타입 유지
export interface Page<T> {
  readonly content: readonly T[];
  readonly totalPages: number;
  readonly totalElements: number;
  readonly number: number;
  readonly size: number;
  readonly first: boolean;
  readonly last: boolean;
  readonly empty: boolean;
}

// === Progress ===
export type ToneKey = ApiSchemas["ReadinessResponse"]["toneKey"];

export type ReadinessResponse = ApiSchemas["ReadinessResponse"];

export type ProgressResponse = ApiSchemas["ProgressResponse"];

// === 마이페이지 오답 노트 ===
export type WrongQuestionItem = ApiSchemas["WrongQuestionItem"];

export type WrongQuestionsResponse = ApiSchemas["WrongQuestionsResponse"];

// === Topic Analysis (Issue #79) ===
export type TopicStat = ApiSchemas["TopicStat"];

export type TopicAnalysisResponse = ApiSchemas["TopicAnalysisResponse"];

export type AiCommentResponse = ApiSchemas["AiCommentResponse"];

// === Heatmap ===
export type HeatmapEntry = ApiSchemas["HeatmapEntry"];

export type HeatmapResponse = ApiSchemas["HeatmapResponse"];

// === Meta ===
export type SubtopicItem = ApiSchemas["SubtopicItem"];

export type TopicTree = ApiSchemas["TopicTree"];

export type ConceptTag = ApiSchemas["ConceptTag"];

// === AI ===
export type AiResult = ApiSchemas["AiResult"];

export type SimilarQuestion = ApiSchemas["SimilarQuestion"];

// === Member ===
// 선택지 생성 모드
export type ChoiceGenerationMode = ApiSchemas["MemberMeResponse"]["choiceGenerationMode"];

// nicknameChangedAt: null 이면 닉네임 변경 이력 없음 / authProvider: 탈퇴 시 제공자 연결 해제 분기 원본 (#516)
export type MemberMeResponse = ApiSchemas["MemberMeResponse"];

export type NicknameRegenerateResponse = ApiSchemas["NicknameRegenerateResponse"];

export type NicknameCheckResponse = ApiSchemas["NicknameCheckResponse"];

export type NicknameChangeResponse = ApiSchemas["NicknameChangeResponse"];

// === AI Payloads ===
// 서버 요청 본문이 Map 이라 스키마 없음 > 웹 손타입 유지
export interface ExplainErrorPayload {
  readonly questionUuid: string;
  readonly sql: string;
  readonly errorMessage: string;
}

export interface DiffExplainPayload {
  readonly questionUuid: string;
  readonly selectedChoiceKey: string;
}

// === Today / Recommendations ===
export interface TodayQuestionResponse {
  readonly question: QuestionSummary | null;
  readonly alreadySolvedToday: boolean;
}

// === Daily Set ===
// results: 문제별 정답 여부 (미완료면 null)
export type DailySetTodayResponse = ApiSchemas["DailySetTodayResponse"];

export type DailySetCompleteResponse = ApiSchemas["DailySetCompleteResponse"];

export type LeaderboardEntry = ApiSchemas["LeaderboardEntry"];

export type LeaderboardResponse = ApiSchemas["LeaderboardResponse"];

export type RecommendationsResponse = ApiSchemas["RecommendationsResponse"];

// === Home ===
export type GreetingMessageType = ApiSchemas["GreetingResponse"]["messageType"];

export type GreetingResponse = ApiSchemas["GreetingResponse"];

// === ExamSchedule ===
export type ExamScheduleResponse = ApiSchemas["ExamScheduleResponse"];

// === Practice ===
// 연습 세트 결과는 서버로 보내지 않는 화면 상태 > 웹 손타입
export interface PracticeQuestionResult {
  readonly questionUuid: string;
  readonly isCorrect: boolean;
  readonly selectedChoiceKey: string;
  // 결과 화면에서 선택지 키(A/B/C/D) 대신 실제 선택지 텍스트를 보여주기 위해 저장
  readonly selectedChoiceBody: string;
  readonly durationMs: number;
  // 신고 기능에 사용 — 제출 시 서버가 반환한 UUID (백엔드 미지원 시 undefined)
  readonly submissionUuid?: string;
  // 신고 시 어떤 선택지 세트를 사용했는지 식별
  readonly choiceSetUuid?: string;
}

// === Feedback ===
// 서버가 status 를 String 으로 내보내 계약에 enum 없음 > 웹이 아는 값 3개로 좁힘
export type FeedbackStatus = "PENDING" | "REVIEWED" | "APPLIED";

export type FeedbackItem = Omit<ApiSchemas["FeedbackItem"], "status"> & {
  readonly status: FeedbackStatus;
};

export type FeedbackListResponse = Omit<ApiSchemas["FeedbackListResponse"], "items"> & {
  readonly items: readonly FeedbackItem[];
};

export type FeedbackSubmitResponse = Omit<ApiSchemas["FeedbackSubmitResponse"], "status"> & {
  readonly status: FeedbackStatus;
};

// === App Config (#464) ===
// 웹은 점검·공지만 사용 (ios·android 버전 정책은 앱 전용) / notices: 노출 대상만 중요 먼저 > 최근 등록 순
export type AppNotice = ApiSchemas["AppNoticeResponse"];

// 공지 목록 한 페이지 (지난 공지 포함, 노출 중 중요 먼저 > 게시 최신 순, #529)
export type AppNoticePage = ApiSchemas["AppNoticePageResponse"];

export type AppConfigResponse = ApiSchemas["AppConfigResponse"];

// ── 알림함 (#491) ──
// 알림함 두 탭: 알림(GENERAL) / 공지(NOTICE)
export type NotificationCategory = "GENERAL" | "NOTICE";
// type·linkTarget: 서버가 String 으로 내보내 계약에 enum 없음 > 서버 enum 값으로 좁힘
export type NotificationType = "ADMIN_MESSAGE" | "REPORT_RESOLVED" | "DAILY_SET_REMINDER" | "NOTICE";
// 서버 PushLinkTarget 와 같은 값 (앱 푸시 이동 허용 목록)
export type NotificationLinkTarget = "HOME" | "DAILY_SET" | "QUESTIONS" | "QUESTION_DETAIL" | "STATS";

// id: NOTICE 는 공지 UUID / nextCursor: null 이면 마지막 페이지
export type NotificationItem = Omit<ApiSchemas["NotificationItemResponse"], "type" | "linkTarget"> & {
  readonly type: NotificationType;
  readonly linkTarget: NotificationLinkTarget | null;
};

export type NotificationPage = Omit<ApiSchemas["NotificationPageResponse"], "items"> & {
  readonly items: readonly NotificationItem[];
};

export type UnreadNotificationCount = ApiSchemas["UnreadNotificationCountResponse"];
