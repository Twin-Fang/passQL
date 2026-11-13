---
type: doc
id: DOC-0007
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [question-bank]
topics_ref: [admin, ai, notification]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0038-question-json-roundtrip-format]]", "[[DEC-0046-oracle-sql-translate-or-concept-only]]", "[[DEC-0127-question-delete-as-deactivation]]", "[[DEC-0141-curated-only-oracle-verified-choices]]", "[[DEC-0225-oracle-conversion-single-converter]]", "[[DEC-0226-vector-prune-after-deactivation-commit]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]", "[[DEC-0277-no-dash-middle-dot-server-cleaner]]", "[[DOC-0004-ai-implementation-code-trace]]", "[[DOC-0006-notification-implementation-code-trace]]"]
---

# DOC-0007: 문제 등록·검증·신고 구현 코드 추적 — 관리자·서버

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 문제 은행 지도다. 문제는 관리자 화면에서 직접 입력, AI 생성 후 검수, JSON 가져오기 세 경로로 들어오고, 저장 전에 Oracle 문법 변환과 문항 형식 규칙(`QuestionFormatRule`) 관문을 거친다. 저장 커밋 뒤에는 벡터 색인이 붙는다. 사용자 신고는 제출 1건당 1회이고, 관리자가 처리하면 문제 비활성화, 제출 소급 보정, 신고자 알림까지 한 번에 한다. 삭제는 영구 삭제가 아니라 비활성화다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 위치
| 영역 | 주요 위치 |
|---|---|
| 관리자 화면·API | `PQL-Web/.../controller/admin/`(`AdminQuestionController` `/admin/questions`, `AdminQuestionImportExportController`, `AdminChoiceSetController` `/admin/choice-sets`, `AdminReportController`·`AdminReportViewController`, `AdminQuestionFormatController`·`AdminQuestionFormatApiController`) |
| 등록·가져오기 | `PQL-Domain-Question/.../service/`(`QuestionGenerateService`, `QuestionService`, `QuestionImportExportService`, `QuestionImportItemValidator`, `OracleSqlCompatibilityConverter`) |
| 형식 규칙 | `QuestionFormatRule`(단일 원본), `QuestionFormatGate`(저장 관문), `QuestionFormatCheckService`, `PQL-Application/.../questionformat/`(`QuestionFormatAuditService`, `QuestionFormatAutoFixService`) |
| 신고 | `PQL-Web/.../QuestionReportController`, `PQL-Application/.../service/QuestionReportService` |
| 색인 | `QuestionVectorIndexService`(AI 서버 경로는 [[DOC-0004-ai-implementation-code-trace]]) |

### 등록 경로 3개
1. **직접 입력** `POST /admin/questions/register` > `QuestionGenerateService.createQuestionWithOracleConversion`: `OracleSqlCompatibilityConverter.toPostgresCompatible`로 안전한 치환, Oracle 전용 문법이 남으면 `CONCEPT_ONLY`로 자동 전환 > 저장. 선택지 없이 저장하면 풀이 때 AI가 만든다. 고정 보기(`CURATED_ONLY`)는 보기가 있는 JSON 가져오기로만 등록한다(컨트롤러 주석, 보기 없이 만들면 AI 보기로 대체 출제).
2. **AI 생성 후 검수** `POST /admin/questions/generate-full` > `QuestionGenerateService.generate` > `aiGatewayClient.generateQuestionFull`. 관리자가 검수한 뒤 `createQuestionWithSeedSet`(문제 + 선택지 세트 + 보기, 한 트랜잭션).
3. **JSON 가져오기** `POST /admin/questions/import/validate` > `QuestionImportExportService.validateBatch` > 항목마다 `QuestionImportItemValidator`(필수 필드 > 고정 보기 > 형식 규칙 > 토픽 > 실행 모드 > Oracle 문법 > 정답 SQL 샌드박스 실행, 결과 OK·SKIP·FAIL) > `POST /admin/questions/import` > `importBatch`(`questionUuid` 있으면 업데이트, 없으면 신규, 보기가 있으면 고정 세트 교체). 내보내기는 `/admin/questions/export`(필터·UUID).
- 형식 관문: 새 문항은 `QuestionFormatGate.requirePassed`(위반 0건), 편집(`QuestionService`)은 `requireNoNewReasons`(저장본에 없던 사유만 거부). 거부는 `QUESTION_FORMAT_VIOLATION`. 같은 `QuestionFormatRule.check`를 모의고사 공개 검사(`MockExamPublishChecker`)와 일괄 점검 화면(`/admin/question-format`)도 쓴다.
- 저장 뒤 `QuestionSavedEvent` > `QuestionVectorIndexService.onQuestionSaved`(커밋 뒤 색인).

### 선택지 세트 관리 (`/admin/choice-sets`)
- 목록·상세·보기 조회, 세트 끄기(`disable`)·올리기(`promote`) 단건·일괄, 무결성 점검(`integrity-audit`), 문제별 재생성(`regenerate/{questionUuid}`).
- 풀이 때 내린 세트(DISABLED·REPORTED·FAILED)는 채점하지 않는다([[DOC-0003-practice-implementation-code-trace]]).

### 삭제·비활성화
- `DELETE /admin/questions/{uuid}`, 일괄 삭제, `deactivate`는 모두 `isActive` 비활성화이고 `restore`로 되돌린다. 비활성화 커밋 뒤 `QuestionsDeactivatedEvent` > `QuestionVectorIndexService.onQuestionsDeactivated`가 벡터를 정리한다.

### 사용자 신고
1. `POST /api/questions/{uuid}/report` > `QuestionReportService.submitReport`: `submissionUuid` 필수, 분류 1개 이상(`WRONG_ANSWER`, `WEIRD_QUESTION`, `WEIRD_CHOICES`, `WEIRD_EXECUTION`, `ETC`), `ETC`면 상세 필수, 같은 제출 재신고는 `REPORT_ALREADY_EXISTS` > `QuestionReport` 저장(선택지 세트 UUID 포함).
2. `GET /api/questions/{uuid}/report/status`: 문제 + 회원 + 제출 3중 조건으로 신고 여부.
3. 관리자 처리(`resolveReport`·`resolveReports`): 미처리 건만 대상 > 상태 `RESOLVED` + 감사 로그 > (선택) 문제 비활성화(문제별 1회) > 소급 보정 범위 `CorrectionScope`(`QUESTION_WIDE`면 `correctAllByQuestionUuid`, `CHOICE_SET_ONLY`면 `correctAllByChoiceSetUuid`, 이 범위는 모든 신고에 선택지 세트 필요) > 신고자 알림.
4. 기각(`DISMISSED`)은 보정·비활성화 없이 종료하고 사유 메모를 남긴다. 일괄 기각은 한 트랜잭션, 이미 처리된 건은 건너뛰고 없는 UUID가 있으면 전체 취소.
5. 신고자 알림 `notifyReporterOfResult`: 설정 `notification.report_resolved.enabled` 꺼짐이면 생략, 처리면 문제 상세로(비활성화한 문제는 홈), 기각이면 문제 상세로 이동([[DOC-0006-notification-implementation-code-trace]]).

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0038(`questionUuid` 유무로 신규·업데이트), DEC-0046·DEC-0225(Oracle 치환 또는 `CONCEPT_ONLY`, 변환기 한 곳), DEC-0127(삭제는 비활성화), DEC-0226(비활성화 커밋 뒤 벡터 정리)과 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다. DEC-0277(서버 `ForbiddenPunctuationCleaner`)은 클리너 코드를 열어 보지 않아 대조하지 않았다.

## 열린 질문
- **소급 보정의 뜻**: `correctAllByQuestionUuid`·`correctAllByChoiceSetUuid`가 제출 기록을 정확히 어떻게 바꾸는지(정답 처리 여부, 통계 반영)는 저장소 쿼리를 읽지 않아 확인하지 않았다. `CorrectionScope` 주석은 "전체 오답 보정"이다.
- **신고 자동 세트 내림**: 신고가 쌓이면 세트가 `REPORTED`로 바뀌는 경로가 있는지는 이번에 따라가지 않았다.
- **AI 생성 문제의 형식 관문**: `generate-full` 결과는 저장(`createQuestionWithSeedSet`) 때 관문을 거친다. 생성 직후 화면 미리보기 단계의 검사는 확인하지 않았다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
