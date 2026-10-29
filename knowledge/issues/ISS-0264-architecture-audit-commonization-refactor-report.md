---
type: completion-report
id: ISS-0264
created: 2026-10-16
topics: [dev-workflow, design-system]
status: resolved
resolves: "[[ISS-0264-architecture-audit-commonization-refactor]]"
related: ["[[DEC-0118-single-source-commonization-rules]]", "[[DEC-0123-openapi-contract-single-source]]", "[[ISS-0265-brand-assets-single-source]]", "[[ISS-0266-server-error-code-unify-archunit]]", "[[ISS-0267-app-component-layer-passql-rename]]", "[[ISS-0268-web-brand-color-token-lint]]", "[[ISS-0269-ai-stub-removal-settings-unify]]"]
source: "https://github.com/Twin-Fang/passQL/issues/458"
---

# ISS-0264 완료 리포트: 하위 5개 통합 배포(0.10.0), 서버·웹 분리와 API 계약 단일 원본(1.2.0)

GitHub #458 구현 보고서(2026-10-15 "모노레포 리팩터링 통합·배포")와 구현 보고서(2026-10-16 "서버 큰 클래스 분리, 웹 페이지 분리, API 계약") 기준.

## 해결 방법
- 1차(2026-10-15): 하위 브랜치 5개(#459 브랜드, #460 서버, #461 앱, #462 웹, #463 AI)를 통합 브랜치에 `--no-ff` 병합, main push → 버전 0.10.0 → deploy. 브랜드 `--check` 27개 일치, 서버 78개 중 77개 통과(실패 1개는 main에서도 실패하던 dev DB 외래키 테스트), 앱 235개, 웹 vitest 21개·eslint 오류 0, AI pytest 21개. 배포 run 모두 성공, 약관 308 리다이렉트, 관리자 라이트·다크 로고 전환.
- 2026-10-16(main `068d711`, 1.2.0, deploy `afa7679`), 동작은 그대로 구조만:
  - 서버 큰 클래스 분리: `ChoiceSetGenerationService` 527 → 279(`ChoiceSetGenerationRequestFactory`), `SandboxValidator` 332 → 209(`ResultMatchChoiceValidator`), `QuestionImportExportService` 471 → 284(`QuestionImportItemValidator`, `OracleSqlCompatibilityConverter`), `QuestionGenerateService` 381 → 220(`QuestionVectorIndexService`), `AdminQuestionController` 312 → 257(`AdminQuestionImportExportController`). 분리 전 동작 고정 테스트 9건. 나누지 않은 것: `QuestionService`(내부 호출 `resolveTodayQuestion`이 REQUIRES_NEW라 분리하면 트랜잭션이 켜져 동작이 바뀜), `SubmissionRepository`.
  - 웹 페이지 분리: AnswerFeedback 511 → 119, QuestionDetail 509 → 198, Home 435 → 141, PracticeResult 354 → 99, PracticeSet 308 → 171. 3곳 이상 반복 조각 공통화(`PlayIcon`, `ExitPracticeConfirmModal`, `PracticeTopBar`·`PracticeQuestionScrollArea`, `HomeRetryButton`). 분리 전후 화면 21개 픽셀 비교 동일.
  - API 계약: `api-contract/openapi.json`(`/api/**` 42개 경로), 서버 `OpenApiContractTest`, 웹 `openapi-typescript`(7.13.0 고정) `npm run gen:api`, 앱 `error_code_contract_test`, CI 3개가 `api-contract/**` 변경에도 실행. `@AuthMember` 파라미터가 26개 API에 필수 query로 잘못 나오던 것 수정.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 원본: 규칙 테스트(앱 `test/architecture`, 서버 ArchUnit, AI import 규칙, 웹 ESLint, 브랜드 `--check`)가 구조를 지킨다. 실패하면 예외를 늘리기 전에 공통 지점을 먼저 쓴다.
- API를 바꿀 때(원본): `cd server && ./gradlew :PQL-Web:test --tests '*OpenApiContractTest*' -PupdateApiContract` → `cd client && npm run gen:api` → 두 변경을 같은 커밋에.
- 남은 것(원본): `DDL + 샘플 데이터` 조립 6곳 공통화, 앱 Dart 모델 코드 생성은 범위 밖, 서버·웹 타입 어긋남(FeedbackItem `status`, NotificationItem `type`·`linkTarget`, DailySetTodayResponse `results`, SubmitResult `submissionUuid`, 웹 `/questions/today` 경로, null 표시 없음).
- 이 이슈의 진행 댓글에는 운영 후속 #464~#493, App Store 1.0 출시 후 `version.yml` 1.1.0 상향도 기록돼 있다.

## 교훈
(원본에 없음, 볼트 정리) 같은 값이 여러 스택에 있으면 원본 하나 + 생성 + CI 검사로 묶어야 수정 누락이 구조적으로 막힌다.
