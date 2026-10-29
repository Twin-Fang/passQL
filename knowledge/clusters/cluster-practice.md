---
type: cluster
topic: practice
created: 2026-10-29
members: 147
status: active
related: []
---

# 클러스터: practice

## 이 주제는
문제 풀이·제출·실행 결과·오늘의 세트·데일리 챌린지·실전 모드

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 40개, 열린 이슈 1개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0016-auto-execute-on-choice-click]] — 선택지 라디오를 클릭하면 그 선택지 SQL을 자동 execute, 같은 선택지 재클릭은 클라 캐시
- [[DEC-0017-fullscreen-result-screen]] — 제출 결과 화면은 풀스크린 1종으로 통일 (bottom sheet 변형 미채택)
- [[DEC-0028-realtime-choice-set-with-prefetch]] — 문제는 고정, 선택지 세트는 퀴즈 진입마다 AI로 생성하고 다음 문제 세트는 프리페치 (MVP는 `AI_ONLY`)
- [[DEC-0030-answer-sql-sandbox-ground-truth]] — `answer_sql` 샌드박스 실행 결과를 정답의 진실로, 정답 수가 1이 아니면 최대 3회 재생성 후 `FAILED`
- [[DEC-0040-choice-response-hides-answer]] — 선택지 생성 응답에는 정답·해설을 넣지 않고, 정답 판정은 제출 시 서버가 `choiceSetId`의 선택지 세트로 한다
- [[DEC-0041-result-screen-by-execution-mode]] — 제출 결과는 `executionMode`로 나눈다 — EXECUTABLE은 SQL과 실행 결과 비교, CONCEPT_ONLY는 텍스트 비교만
- [[DEC-0047-execute-uses-temp-sandbox-db]] — `sandboxDbName`이 없는 문제의 `/execute`는 호출마다 `SandboxPool` 임시 DB를 만들어 실행하고 지운다
- [[DEC-0048-daily-challenge-wrong-answer-not-submitted]] — 데일리 챌린지는 정답일 때만 서버에 제출하고, 오답은 로컬 피드백 후 다시 풀게 한다
- [[DEC-0049-ai-only-redefined-sql-equivalence]] — `AI_ONLY` 정책은 "주어진 SQL과 동일한 실행 결과를 내는 SQL 고르기"로 재정의한다
- [[DEC-0050-result-match-text-choices]] — "실행 결과로 올바른 것은?" 유형은 `RESULT_MATCH` 정책 — 선택지는 결과 JSON(`kind = TEXT`), 검증은 `answerSql` 결과와 비교
- [[DEC-0051-no-auto-execute-review-after-submit]] — 선택지 클릭 시 SQL 자동 실행을 없애고, 제출 후 `ChoiceReview`에서 각 선택지를 실행해 비교한다
- [[DEC-0052-result-match-policy-equivalence-type]] — AI_ONLY EXECUTABLE 문제는 "동일 결과를 내는 SQL 찾기" 유형으로 재정의하고 `RESULT_MATCH` 선택지 정책을 추가
- [[DEC-0053-spa-only-leave-blocker]] — 풀이 이탈 경고는 `useBlocker`로 SPA 내 이동만 막고 `beforeunload`(탭 닫기·새로고침)는 막지 않는다
- [[DEC-0054-postgresql-sandbox-engine]] — Sandbox(와 앱 datasource) DB 엔진을 MariaDB에서 PostgreSQL로 전면 전환
- [[DEC-0055-multiple-correct-ai-fallback-save]] — 3회 재시도 후에도 `MULTIPLE_CORRECT`면 AI의 `isCorrect` 판단으로 fallback 저장 (`sandbox_validation_passed=false`)
- [[DEC-0056-stem-sql-code-block-rule]] — SQL이 들어간 문제 stem은 ```sql 코드 블록으로 쓴다 — 새 문제 생성 규칙이며 기존 예시는 수동으로 바꾼다
- [[DEC-0057-confirm-modal-bottom-sheet-all-sizes]] — `ConfirmModal`은 데스크톱도 화면 너비 100% 바텀시트 단일 레이아웃
- [[DEC-0058-on-demand-choice-execution-after-submit]] — EXECUTABLE 제출 후 실행 결과는 선택지 카드별 실행 버튼으로 골라 보게 한다 (전체 자동 노출 폐기, 풀이 중에는 실행 버튼 없음)
- [[DEC-0062-separate-recommendation-practice-page]] — 홈 추천 문제는 QuestionDetail 직접 링크 대신 전용 `RecommendationPractice` 페이지로 풀고, 정답·오답 모두 제출 기록한다
- [[DEC-0073-session-result-fixed-at-first-submit]] — 세션 결과는 최초 제출 기준으로 고정하고, 복습은 통계에만 반영한다
- [[DEC-0085-daily-set-ten-questions-daily]] — 데일리 세트는 기획한 5문제가 아니라 매일 10문제 세트로 한다
- [[DEC-0087-choice-generation-practice-real-mode]] — 선택지 생성 모드를 연습(`PRACTICE`, 검증된 선택지 재사용)과 실전(`REAL`, 항상 AI 실시간 생성)으로 나눈다
- [[DEC-0089-shared-question-flow-for-solving]] — 앱 풀이 화면은 하나로 두고, 풀이 방식마다 `QuestionFlow`만 구현한다
- [[DEC-0090-app-no-separate-recommendation-screen]] — 앱은 추천 문제 전용 풀이 화면을 만들지 않고 일반 문제 풀이 화면을 그대로 쓴다
- [[DEC-0113-similar-via-recommend-reuse]] — 유사 문제는 AI 서버를 새로 만들지 않고 기존 `POST /api/ai/recommend`를 Spring에서 조합해 쓴다
- [[DEC-0114-topic-card-option-a]] — 앱 토픽 선택 카드는 별도 시안 없이 보드의 A안(토픽별 색 + 큰 칩)으로 간다
- [[DEC-0137-pregenerate-choice-explanations-db]] — 선택지 해설은 세트 저장 직후 별도 호출로 미리 생성해 DB에 영구 저장하고, 샌드박스 미검증 세트는 제외
- [[DEC-0138-solving-detail-hides-answers]] — 사용자용 문제 상세는 응답 형태를 유지한 채 정답 필드를 비우고 최신 OK 세트 1개만 보낸다
- [[DEC-0141-curated-only-oracle-verified-choices]] — Oracle 전용 문법 문제는 로컬 Oracle에서 검증한 고정 보기(`CURATED_ONLY`)를 실전·연습 모두 그대로 출제한다
- [[DEC-0146-structured-explanation-once-per-set]] — AI 해설은 고정 섹션 형식으로 선택지 세트당 한 번 만들어 저장하고, 없으면 "생성 중"을 돌려주며 백그라운드에서 만든다
- [[DEC-0147-keep-explanation-sheet-while-solving]] — 해설은 비모달 시트·패널로 열어 해설을 보면서 계속 풀게 하고, 다음 문제로 넘어가도 조회를 잇는다
- [[DEC-0154-close-explanation-sheet-on-next]] — 풀이 중 "다음"으로 넘어가면 해설 시트를 닫는다 (해설함·백그라운드 조회는 유지)
- [[DEC-0155-exam-tip-after-answer-reason]] — AI 해설 화면 순서는 판정 → 정답 근거 → 시험 팁 → 핵심 개념 → 헷갈리는 지점 → 보기별 판단
- [[DEC-0165-numeric-choices-ascending]] — 보기가 모두 숫자면 섞지 않고 오름차순으로 보여 준다
- [[DEC-0166-tab-roles-home-read-questions-solve]] — 탭마다 역할 하나 — 홈은 읽을 것, 문제 탭은 풀 것 전부, 설정은 설정만 (출제 경향 전용 화면 폐지)
- [[DEC-0178-daily-set-five-questions]] — 오늘의 세트는 하루 5문제, 값은 서버 상수 한 곳에서 정한다 (무료 하루 한도 10은 별개)
- [[DEC-0184-new-member-onboarding-to-first-question]] — 앱 온보딩은 신규 가입자에게만 계정당 한 번, 4장 뒤 오늘의 세트 첫 문제로 이어지고 알림 권한은 묻지 않는다
- [[DEC-0194-explanation-working-notes-evidence-priority]] — 선택지 세트 해설은 보이지 않는 풀이 메모(`workingNotes`)를 먼저 쓰게 하고, 근거 우선순위는 실행 결과 > 고정 세트 검증된 풀이 > 생성 근거 > 자체 계산
- [[DEC-0199-choice-execution-only-after-submit]] — 앱 실행형 문제의 보기 실행은 제출 뒤에만 연다 (고르기와 실행 분리, 제출 전에는 안내 문구만)
- [[DEC-0200-shared-sandbox-result-cache]] — 샌드박스 실행 결과는 `CachedSandboxExecutor` 한 곳에서 회원 간 공유 캐시(메모리 30분 > Redis 7일)로 재사용한다

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0412-ai-explanation-quality-cost-optimization]] (open, GitHub #699) — AI 해설 품질, 호출 빈도, 비용 최적화와 해설 시트 정리
- [[ISS-0022-daily-challenge-domain-api]] (resolved, GitHub #26) — Daily Challenge 도메인, 오늘의 챌린지 API, 관리자 화면
- [[ISS-0023-random-question-recommendations-api]] (resolved, GitHub #27) — 랜덤 추천 문제 API (Question Recommendations)
- [[ISS-0029-realtime-ai-choice-set-prefetch]] (resolved, GitHub #39) — 실시간 AI 선택지 세트 생성 및 프리페치 아키텍처
- [[ISS-0030-frontend-api-field-mismatch]] (resolved, GitHub #41) — 프론트-백엔드 API 매핑 불일치 프론트 수정
- [[ISS-0037-submit-404-execution-mode-null]] (resolved, GitHub #57) — submit 엔드포인트 404와 `executionMode` null
- [[ISS-0041-question-topic-grid-api]] (resolved, GitHub #68) — 문제 탭 카테고리 선택이 Topic API 대신 Mock 코드를 써서 BE와 불일치
- [[ISS-0042-sse-choice-generation-submit-flow]] (resolved, GitHub #69) — 선택지 생성 SSE 엔드포인트 부재와 제출 플로우의 구 테이블 참조
- [[ISS-0043-question-screen-result-compare-redesign]] (resolved, GitHub #70) — 문제 풀이 화면 — 스키마 텍스트 덤프, 결과 비교 부재, 자유 SQL 실행 부재
- [[ISS-0046-sse-submit-fe-integration-guide]] (resolved, GitHub #78) — SSE 선택지 생성·제출 플로우(#69) FE 연동 가이드 — FE/BE 불일치
- [[ISS-0048-execution-mode-choice-policy-mismatch]] (resolved, GitHub #88) — `executionMode`·`choiceSetPolicy` 분기 누락으로 인한 4가지 버그
- [[ISS-0050-sse-complete-hikaripool-self-invocation]] (resolved, GitHub #91) — 선택지 생성은 성공하는데 두 번째 문제부터 SSE `complete`가 오지 않아 화면 멈춤
- [[ISS-0051-vercel-generate-choices-405]] (resolved, GitHub #94) — Vercel 프로덕션에서 `generate-choices`가 405
- [[ISS-0052-sse-complete-controller-repository]] (resolved, GitHub #95) — CONCEPT_ONLY 선택지 생성 성공 후 SSE `complete` 미전송 — Controller의 Repository 직접 주입
- [[ISS-0057-fe-hardcoded-analysis-to-api]] (resolved, GitHub #101) — 프론트 분석 데이터 하드코딩과 UI 개선 필요
- [[ISS-0058-ai-choice-body-result-text]] (resolved, GitHub #103) — AI 선택지 body에 SQL 대신 실행 결과 텍스트가 와서 검증 전체 실패, 화면은 스피너 고착
- [[ISS-0059-execute-sandbox-db-access-denied]] (resolved, GitHub #104) — `/execute`가 `questionUuid`를 DB명으로 폴백해 Access Denied — 모든 문제의 실행 버튼 불능
- [[ISS-0060-daily-challenge-result-ux]] (resolved, GitHub #106) — 오늘의 문제 풀이·결과 화면 UX — 정답 오표시, 부적절한 버튼, 완료 카드 미반영
- [[ISS-0061-schema-display-required-guide]] (resolved, GitHub #107) — 문제 풀이 화면 스키마 미표시와 가이드라인 `schemaDisplay` 필수화
- [[ISS-0062-ai-only-choices-mismatch-question-type]] (resolved, GitHub #108) — `AI_ONLY` 문제의 선택지가 SQL이라 "실행 결과로 올바른 것은?" 지문과 맞지 않음
- [[ISS-0063-result-match-policy]] (resolved, GitHub #110) — "실행 결과로 올바른 것은?" 유형을 위한 `RESULT_MATCH` 정책 부재
- [[ISS-0064-recommended-flow-ui-unify]] (resolved, GitHub #112) — 추천 문제 풀기 플로우 UI가 PracticeSet·DailyChallenge와 불일치
- [[ISS-0066-ai-only-equivalent-sql-multiple-correct]] (resolved, GitHub #114) — AI_ONLY 정책의 SQL 동치 유형 문제에서 MULTIPLE_CORRECT가 3회 재시도 내내 반복
- [[ISS-0067-choice-sse-error-infinite-loading]] (resolved, GitHub #115) — 선택지 생성 SSE에서 에러를 못 받으면 UI가 "선택지 생성 중..."으로 영구 멈춤
- [[ISS-0068-submit-null-sandbox-db-internal-error]] (resolved, GitHub #117) — sandboxDbName이 null인 EXECUTABLE 문제 제출 시 INTERNAL_SERVER_ERROR
- [[ISS-0069-questions-detail-page-ui-polish]] (resolved, GitHub #120) — Questions / QuestionDetail 페이지 UI 개선
- [[ISS-0070-leave-warning-modal-during-solving]] (resolved, GitHub #121) — 문제 풀이 중 이탈 시 경고 모달 구현
- [[ISS-0071-sandbox-mariadb-to-postgresql]] (resolved, GitHub #122) — Sandbox DB 엔진 MariaDB → PostgreSQL 전면 전환
- [[ISS-0075-fixed-bottom-action-buttons]] (resolved, GitHub #131) — 제출·액션 버튼 fixed bottom 전 화면 통일
- [[ISS-0077-home-today-recommend-stale-after-submit]] (resolved, GitHub #134) — 문제 풀이 후 홈의 오늘의 문제·추천 문제 상태가 즉시 갱신되지 않음
- [[ISS-0078-schema-viewer-ui-rounded-unify]] (resolved, GitHub #135) — SchemaViewer UI 개선 및 전체 rounded 통일
- [[ISS-0079-sse-stream-closed-after-complete]] (resolved, GitHub #136) — SSE complete 이벤트를 받은 뒤에도 STREAM_CLOSED 에러가 트리거
- [[ISS-0080-stem-markdown-schema-toggle]] (resolved, GitHub #140) — 문제 지문 마크다운 렌더링 및 스키마 접기/펼치기
- [[ISS-0081-confirm-modal-desktop-layout-broken]] (resolved, GitHub #142) — "풀이를 그만할까요?" 확인 모달이 데스크톱에서 깨짐
- [[ISS-0082-executable-result-compare-ui]] (resolved, GitHub #144) — EXECUTABLE 문제 제출 후 SQL 실행 비교 화면 UI/UX 개선
- [[ISS-0083-daily-challenge-submit-false-leave-modal]] (resolved, GitHub #146) — 데일리 챌린지 정답 제출 시 이탈 확인 모달이 잘못 표시
- [[ISS-0084-sse-stream-closed-strictmode-recurrence]] (resolved, GitHub #147) — SSE complete 수신 후 STREAM_CLOSED 재발 (StrictMode cancelled 패턴 미동작)
- [[ISS-0089-apply-144-pattern-daily-recommend]] (resolved, GitHub #159) — 데일리 챌린지·추천 문제에 #144 UI/UX 패턴 적용
- [[ISS-0090-practice-result-screen-redesign]] (resolved, GitHub #161) — 문제 풀이 결과 화면 UI 전면 개선
- [[ISS-0100-ai-comment-session-feedback-step-merge]] (resolved, GitHub #181) — 퀴즈 결과 AI 분석 — 세션 단위 피드백과 Step 통합
- [[ISS-0103-submission-session-fk-violation-409]] (resolved, GitHub #186) — 답안 제출 시 `fk_submission_session` FK 위반으로 409
- [[ISS-0105-answer-feedback-screen-ui-overhaul]] (resolved, GitHub #189) — 단일 문제 결과 화면(AnswerFeedback) UI 전면 개선
- [[ISS-0107-execute-ui-sample-data-parsing-fix]] (resolved, GitHub #191) — 실행 UI 통일 · 샘플 데이터 파싱 버그 · 결과 테이블 가독성
- [[ISS-0110-result-match-table-click-invert-bug]] (resolved, GitHub #195) — RESULT_MATCH 선택지 테이블 클릭 불가 · 선택 시 텍스트 미반전
- [[ISS-0111-choice-generation-loading-sparkles]] (resolved, GitHub #196) — 선택지 생성 중 로딩 UI를 Sparkles 아이콘·문구로 개선
- [[ISS-0114-ai-report-padding-button-unify]] (resolved, GitHub #205) — AI 리포트 화면 좌우 패딩 이상과 버튼 스타일 공통화
- [[ISS-0122-per-choice-execute-state-bug]] (resolved, GitHub #223) — 선택지별 쿼리 실행 버튼이 독립적으로 동작하지 않음
- [[ISS-0123-stem-card-choice-card-distinction]] (resolved, GitHub #224) — 지문 카드와 선택지 카드 시각적 구분
- [[ISS-0124-schema-viewer-table-layout]] (resolved, GitHub #225) — SchemaViewer 테이블 레이아웃과 시각성 개선
- [[ISS-0128-report-button-in-feedback-bar]] (resolved, GitHub #234) — 제출 직후 피드백 바에서 문제를 신고할 수 없음
- [[ISS-0129-review-overwrites-original-result]] (resolved, GitHub #235) — 복습에서 맞추면 결과 화면의 틀린 문제가 맞은 문제로 바뀜
- [[ISS-0130-executable-grading-db-microcopy]] (resolved, GitHub #236) — EXECUTABLE 문제 채점 시 실제 DB 실행 사실이 드러나지 않음
- [[ISS-0136-result-card-correct-wrong-colors]] (resolved, GitHub #251) — 결과 화면 정답/오답 카드 구분이 불분명
- [[ISS-0141-daily-challenge-fallback-persist-scheduler]] (resolved, GitHub #260) — 폴백 오늘의 문제가 DB에 저장되지 않아 달력이 비고 이력이 흔들림
- [[ISS-0160-ai-practice-set-epic-cancelled]] (resolved, GitHub #303) — AI 문제 풀기 고도화 에픽 (문제 세트·모의고사·복습·게임화)
- [[ISS-0161-daily-set-feature]] (resolved, GitHub #304) — 오늘의 데일리 세트 기능 추가
- [[ISS-0162-mini-mock-exam-cancelled]] (resolved, GitHub #305) — 미니 모의고사 기능 추가
- [[ISS-0163-retry-wrong-questions-mypage]] (resolved, GitHub #306) — 마이페이지 틀린 문제 다시 풀기
- [[ISS-0167-choice-generation-practice-real-mode]] (resolved, GitHub #313) — 문제풀이 선택지 생성 모드를 연습/실전으로 분리
- [[ISS-0174-app-wrong-notes-nickname-choice-mode]] (resolved, GitHub #329) — 앱 마이페이지 오답 목록, 닉네임 변경, 선택지 생성 모드
- [[ISS-0176-app-question-flagging-feature]] (resolved, GitHub #331) — 앱 문제 신고 기능
- [[ISS-0177-app-daily-set-result-leaderboard]] (resolved, GitHub #332) — 앱 데일리 세트, 결과, 리더보드
- [[ISS-0178-app-recommendation-single-solve]] (resolved, GitHub #333) — 앱 추천 문제 단건 풀이 모드
- [[ISS-0187-daily-set-score-client-trusted]] (resolved, GitHub #342) — 데일리 세트 리더보드 점수를 클라이언트 값 그대로 저장해 조작 가능
- [[ISS-0188-app-sse-parse-login-dead-ends]] (resolved, GitHub #343) — 출시 전 리뷰에서 확인된 SSE 파싱, 로그인 유지, 막다른 화면 문제
- [[ISS-0200-result-match-choices-json-string]] (resolved, GitHub #355) — 실행 결과형 선택지가 표 대신 JSON 문자열로 표시됨
- [[ISS-0203-odd-one-out-choice-gen-fails]] (resolved, GitHub #358) — 추천 문제 ODD_ONE_OUT 선택지 생성이 37초 뒤 실패함
- [[ISS-0205-stem-sql-code-fence-exposed]] (resolved, GitHub #360) — 문제 지문의 SQL 코드 펜스(```)가 그대로 노출됨
- [[ISS-0206-inline-code-backticks-exposed]] (resolved, GitHub #361) — 문제 지문·선택지의 인라인 코드 백틱(`)이 그대로 노출됨
- [[ISS-0207-ai-explain-sheet-markdown-symbols]] (resolved, GitHub #362) — AI 해설 시트에 마크다운 기호(**, `, *)가 그대로 노출됨
- [[ISS-0213-topic-card-zero-subtopics]] (resolved, GitHub #368) — 문제 탭 토픽 카드마다 "0개 서브토픽"이 표시됨
- [[ISS-0214-execute-result-card-narrow]] (resolved, GitHub #369) — SQL 실행 결과 카드가 선택지 카드보다 좁고 표 오른쪽이 빔
- [[ISS-0215-qa-observation-candidates]] (resolved, GitHub #370) — QA 관찰 사항 — 이탈 확인·세트 재진입 결과·신규 준비도 등 개선 후보
- [[ISS-0216-practice-exit-confirm-dialog]] (resolved, GitHub #371) — 풀이 중 홈·뒤로가기를 누르면 확인 없이 나가 진행 흐름을 잃음 (앱)
- [[ISS-0217-daily-set-revisit-per-question-results]] (resolved, GitHub #372) — 완료한 오늘의 세트 재진입 시 문제별 결과가 안 보임
- [[ISS-0251-similar-questions-api-todo-500]] (resolved, GitHub #442) — 유사 문제 API가 미구현(TODO)이라 매번 500 — 결과 화면 유사 문제 섹션이 항상 숨겨짐
- [[ISS-0252-app-topic-card-icons]] (resolved, GitHub #446) — 앱 토픽 선택 카드에 토픽별 아이콘이 없음
- [[ISS-0253-topic-card-design-request]] (resolved, GitHub #447) — 앱 문제 탭 토픽 선택 카드 디자인 요청
- [[ISS-0287-chapter-result-back-shows-placeholder]] (resolved, GitHub #481) — 앱 챕터 결과 화면에서 뒤로 가면 미구현 자리표시 화면 표시
- [[ISS-0288-sql-execute-failure-not-shown]] (resolved, GitHub #482) — 앱에서 SQL 실행 실패가 표시되지 않고 제출 실패 문구가 원인과 무관
- [[ISS-0289-refresh-home-daily-set-on-resume]] (resolved, GitHub #483) — 앱 복귀나 날짜 변경 시 홈·오늘의 세트가 갱신되지 않음
- [[ISS-0301-ai-explanation-persist-pregenerate]] (resolved, GitHub #496) — AI 해설이 영구 저장되지 않고 오답 해설을 매번 기다려야 함
- [[ISS-0302-app-server-web-performance]] (resolved, GitHub #497) — 앱·서버·웹 전반의 성능 저하 (감사 결과)
- [[ISS-0305-sqld-mock-exam-50q-90min]] (resolved, GitHub #500) — SQLD 실전 모의고사 (50문항 90분, 과목별 과락)
- [[ISS-0308-question-api-exposes-answers]] (resolved, GitHub #503) — 문제 조회 API가 정답, 해설, 정답 SQL을 사용자에게 노출
- [[ISS-0313-sqld-2026-trend-curated-choices]] (resolved, GitHub #511) — SQLD 2026 출제 경향 반영 — 문제 풀 정리, 보기 고정, 수집 자료 암호화
- [[ISS-0314-curated-choice-display-label]] (resolved, GitHub #512) — 고정 보기 문제 보기 라벨을 표시 순번 기준으로 표시
- [[ISS-0318-schema-preview-sample-data-missing]] (resolved, GitHub #520) — 문제 화면 스키마 보기가 펼쳐지지 않고 샘플 데이터가 보이지 않음
- [[ISS-0319-ai-explanation-format-speed-ux]] (resolved, GitHub #521) — AI 해설 형식, 품질, 속도와 해설 화면 UX 개편
- [[ISS-0330-stale-explanation-sheet-empty-result]] (resolved, GitHub #538) — 풀이 중 이전 문제 해설 시트가 남고, 빈 결과 보기가 오류처럼 보임
- [[ISS-0337-result-choice-null-shown-blank]] (resolved, GitHub #549) — 결과형 보기에서 NULL 값이 빈칸으로 표시
- [[ISS-0338-stem-markdown-table-raw-pipes]] (resolved, GitHub #550) — 문제 지문의 마크다운 표가 원문 그대로 노출
- [[ISS-0339-feedback-bar-covers-choices]] (resolved, GitHub #551) — 제출 후 하단 피드백 바가 보기와 실행 결과를 가림
- [[ISS-0341-app-difficulty-three-level-display]] (resolved, GitHub #553) — 앱 난이도 표시가 3단계 기준이라 4, 5 문제가 4 / 3으로 표시
- [[ISS-0342-choice-card-layout-jump-table-font]] (resolved, GitHub #554) — 채점 후 보기 카드 레이아웃 점프와 결과 표 글꼴 다듬기
- [[ISS-0348-daily-set-rescore-after-restart]] (resolved, GitHub #561) — 앱을 다시 켜면 1번부터 다시 풀려 앞에서 본 정답으로 점수를 다시 낼 수 있음
- [[ISS-0351-daily-set-resume-preview-table]] (resolved, GitHub #566) — 오늘의 세트 앱 재실행 시 이어 풀기, 목록 미리보기의 표 원문 정리
- [[ISS-0356-home-questions-tab-restructure]] (resolved, GitHub #574) — 홈, 문제 탭 재구성 — 출제 경향 분리 및 오답 노트 이동 (이후 앱 전체 발견성·접근성 개편으로 확장)
- [[ISS-0363-app-wide-ui-ux-cleanup]] (resolved, GitHub #602) — 앱 전체 UI/UX 정리 — 화면별 검수 결과와 개선안(기기 크기 대응 포함)
- [[ISS-0364-result-table-choice-executed-as-sql]] (resolved, GitHub #607) — 결과표 보기 문제 채점 시 실행 오류가 뜨는 문제와 SQL 실행 배지 오해
- [[ISS-0372-admin-daily-challenge-assignment]] (resolved, GitHub #617) — 관리자 일일 챌린지 배정 — 후보가 최신 200개로 고정되고 날짜 한 건씩만 배정
- [[ISS-0390-sql-validator-silent-default-fallback]] (resolved, GitHub #640) — `SqlSafetyValidator` 설정 조회 실패를 로그 없이 기본값으로 대체함
- [[ISS-0392-daily-set-ten-to-five-questions]] (resolved, GitHub #644) — 오늘의 세트를 하루 10문제에서 5문제로 줄이기
- [[ISS-0407-new-member-onboarding-screens]] (resolved, GitHub #683) — 신규 가입자 온보딩 화면 추가 (앱)
- [[ISS-0414-odd-one-out-choice-generation-fails]] (resolved, GitHub #704) — '결과가 다른 것' 유형 선택지 생성이 항상 실패
- [[ISS-0417-sequential-execution-explanation-errors]] (resolved, GitHub #716) — AI 해설 차례 실행 문제 근거 오류와 재발 방지
- [[ISS-0421-surface-direct-sql-execution]] (resolved, GitHub #727) — 직접 실행 경험 드러내기 — 실행 버튼·결과 비교·실습 칸·입력 보조
