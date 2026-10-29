---
type: cluster
topic: question-bank
created: 2026-10-29
members: 70
status: active
related: []
---

# 클러스터: question-bank

## 이 주제는
문제 등록·품질·검증·신고·토픽·난이도

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 21개, 열린 이슈 0개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0028-realtime-choice-set-with-prefetch]] — 문제는 고정, 선택지 세트는 퀴즈 진입마다 AI로 생성하고 다음 문제 세트는 프리페치 (MVP는 `AI_ONLY`)
- [[DEC-0030-answer-sql-sandbox-ground-truth]] — `answer_sql` 샌드박스 실행 결과를 정답의 진실로, 정답 수가 1이 아니면 최대 3회 재생성 후 `FAILED`
- [[DEC-0037-question-hard-delete-cascade]] — 관리자 문제 삭제는 자식 테이블까지 Hard delete, 진행 중 퀴즈 세션이 쓰는 문제는 409로 거부
- [[DEC-0038-question-json-roundtrip-format]] — 문제 JSON 내보내기·가져오기는 `questionUuid` 유무로 신규/업데이트를 가르고, 토픽은 `topicUuid` 대신 `topicCode`로 쓴다
- [[DEC-0044-bulk-delete-per-item-transaction]] — 문제 일괄삭제는 건별 독립 트랜잭션으로 지우고, 실패한 건은 건너뛴 채 나머지를 계속한다
- [[DEC-0046-oracle-sql-translate-or-concept-only]] — Oracle SQL은 안전한 1:1 치환(`NVL`, `SYSDATE`)만 자동 변환하고, 남는 Oracle 전용 문법은 `CONCEPT_ONLY`로 전환한다
- [[DEC-0049-ai-only-redefined-sql-equivalence]] — `AI_ONLY` 정책은 "주어진 SQL과 동일한 실행 결과를 내는 SQL 고르기"로 재정의한다
- [[DEC-0050-result-match-text-choices]] — "실행 결과로 올바른 것은?" 유형은 `RESULT_MATCH` 정책 — 선택지는 결과 JSON(`kind = TEXT`), 검증은 `answerSql` 결과와 비교
- [[DEC-0056-stem-sql-code-block-rule]] — SQL이 들어간 문제 stem은 ```sql 코드 블록으로 쓴다 — 새 문제 생성 규칙이며 기존 예시는 수동으로 바꾼다
- [[DEC-0067-short-meaningful-table-names]] — 문제 스키마 테이블 이름은 시험 회차·번호 대신 짧고 의미 있는 이름으로
- [[DEC-0075-stem-pattern-choice-set-policy-mapping]] — stem 패턴별 `choiceSetPolicy` 매핑 (`AI_ONLY` / `RESULT_MATCH` / `ODD_ONE_OUT`)
- [[DEC-0076-markdown-rules-for-generated-content]] — 문제 콘텐츠(stem·hint·rationale)는 마크다운 활용 규칙을 따른다
- [[DEC-0127-question-delete-as-deactivation]] — 관리자 문제 삭제(단건·일괄)는 `isActive` 비활성화로 하고 영구 삭제는 없앤다
- [[DEC-0141-curated-only-oracle-verified-choices]] — Oracle 전용 문법 문제는 로컬 Oracle에서 검증한 고정 보기(`CURATED_ONLY`)를 실전·연습 모두 그대로 출제한다
- [[DEC-0142-encrypt-sqld-research-materials]] — 출제 경향 조사 원문은 로컬에만 두고 레포에는 AES-256 암호본만 커밋한다
- [[DEC-0158-new-questions-concept-only-curated]] — 2026 경향 신규 문제는 `CONCEPT_ONLY` + `CURATED_ONLY`(고정 보기)로 등록한다
- [[DEC-0159-ai-explanation-grounded-on-execution]] — AI 해설은 실행형 SQL 보기를 샌드박스에서 실행한 실측 결과를 근거로 쓴다
- [[DEC-0163-harness-oracle-xe-21c]] — 문제 검증 도구의 Oracle은 XE 21c로 고정하고, 23ai 전용 문법은 warning으로 점검한다
- [[DEC-0165-numeric-choices-ascending]] — 보기가 모두 숫자면 섞지 않고 오름차순으로 보여 준다
- [[DEC-0193-choice-set-prompts-benchmarked-adoption]] — 선택지 생성 프롬프트는 운영 문제 x Haiku·Gemini 비교 결과로 채택 — 결과가 다른 것은 #699 v2 유지, `max_tokens` 4096, Gemini 온도 유지
- [[DEC-0197-provide-answer-sql-result-in-prompt]] — 일반 SQL(AI_ONLY) 선택지 생성은 기준 SQL을 샌드박스로 실행한 결과를 프롬프트에 주고, 재시도에는 보기별 실제 실행 결과와 "기준과 같음/다름"을 준다

## 대체된 결정 (역사)
- 없음

## 관련 이슈
- [[ISS-0029-realtime-ai-choice-set-prefetch]] (resolved, GitHub #39) — 실시간 AI 선택지 세트 생성 및 프리페치 아키텍처
- [[ISS-0032-admin-direct-question-register]] (resolved, GitHub #46) — 관리자 퀴즈 문제 직접 등록
- [[ISS-0034-register-form-json-import-guide]] (resolved, GitHub #49) — 문제 직접 등록 폼 JSON 불러오기와 등록 가이드
- [[ISS-0038-admin-question-delete-json-loader]] (resolved, GitHub #58) — 관리자 문제 삭제와 수정 폼 JSON 불러오기 기능 누락
- [[ISS-0039-bulk-question-json-import-export]] (resolved, GitHub #60) — 질문 관리에 대량 JSON 내보내기·가져오기와 Sandbox 일괄 검증이 없음
- [[ISS-0041-question-topic-grid-api]] (resolved, GitHub #68) — 문제 탭 카테고리 선택이 Topic API 대신 Mock 코드를 써서 BE와 불일치
- [[ISS-0048-execution-mode-choice-policy-mismatch]] (resolved, GitHub #88) — `executionMode`·`choiceSetPolicy` 분기 누락으로 인한 4가지 버그
- [[ISS-0049-question-register-guide-ai-prompt]] (resolved, GitHub #89) — 문제 등록 가이드라인과 AI 변환 프롬프트가 부실해 생성 JSON 품질이 들쭉날쭉
- [[ISS-0053-admin-question-bulk-delete]] (resolved, GitHub #96) — 관리자 문제 관리에 선택 일괄삭제가 없고 툴바가 과밀
- [[ISS-0056-oracle-dialect-bulk-import-sandbox-fail]] (resolved, GitHub #100) — SQLD 기출 벌크 임포트가 Oracle 방언과 Sandbox URL 파싱 버그로 대량 FAIL
- [[ISS-0061-schema-display-required-guide]] (resolved, GitHub #107) — 문제 풀이 화면 스키마 미표시와 가이드라인 `schemaDisplay` 필수화
- [[ISS-0062-ai-only-choices-mismatch-question-type]] (resolved, GitHub #108) — `AI_ONLY` 문제의 선택지가 SQL이라 "실행 결과로 올바른 것은?" 지문과 맞지 않음
- [[ISS-0063-result-match-policy]] (resolved, GitHub #110) — "실행 결과로 올바른 것은?" 유형을 위한 `RESULT_MATCH` 정책 부재
- [[ISS-0080-stem-markdown-schema-toggle]] (resolved, GitHub #140) — 문제 지문 마크다운 렌더링 및 스키마 접기/펼치기
- [[ISS-0093-admin-topic-edit-button-noop]] (resolved, GitHub #168) — 관리자 토픽 편집 버튼 클릭 시 동작 없음
- [[ISS-0094-topic-category-card-ui]] (resolved, GitHub #169) — AI문제 풀기 카테고리 카드 UI 개선
- [[ISS-0108-admin-guide-table-naming-rule]] (resolved, GitHub #193) — 문제 등록 가이드에 테이블 이름 작성 규칙 추가
- [[ISS-0121-question-report-feature]] (resolved, GitHub #222) — 문제 신고 기능 (신고 API, 관리자 관리 화면)
- [[ISS-0125-question-report-api-quality-fixes]] (resolved, GitHub #227) — 문제 신고 API 코드 품질 버그
- [[ISS-0128-report-button-in-feedback-bar]] (resolved, GitHub #234) — 제출 직후 피드백 바에서 문제를 신고할 수 없음
- [[ISS-0132-result-match-registered-as-ai-only]] (resolved, GitHub #242) — "실행 결과로 올바른 것은?" 문제가 `AI_ONLY`로 등록돼 선택지가 SQL 쿼리로 생성됨
- [[ISS-0133-markdown-guide-for-ai-content]] (resolved, GitHub #243) — AI 생성 콘텐츠가 마크다운을 쓰지 않아 가독성이 떨어짐
- [[ISS-0138-admin-report-resolve-uuid-optional]] (resolved, GitHub #254) — 관리자 신고 처리(resolve)가 UUID 없으면 막힘
- [[ISS-0157-star-rating-shows-three-stars]] (resolved, GitHub #292) — `StarRating` 컴포넌트가 난이도 5점 만점을 별 3개로만 표시
- [[ISS-0176-app-question-flagging-feature]] (resolved, GitHub #331) — 앱 문제 신고 기능
- [[ISS-0208-concept-choice-prompt-v2-quality]] (resolved, GitHub #363) — 개념 문제 AI 선택지 품질 개선 — 정확하고 변별력 있게
- [[ISS-0244-qdrant-orphan-vectors-index-mismatch]] (resolved, GitHub #412) — 임베딩 색인 불일치 — Qdrant 237 vs 활성 문제 192, 미색인 2
- [[ISS-0277-admin-bulk-delete-partial-hard-delete]] (resolved, GitHub #471) — 관리자 문제 일괄 삭제가 부분 실패하고 회원 기록까지 영구 삭제
- [[ISS-0305-sqld-mock-exam-50q-90min]] (resolved, GitHub #500) — SQLD 실전 모의고사 (50문항 90분, 과목별 과락)
- [[ISS-0307-app-quality-roadmap]] (resolved, GitHub #502) — 앱 품질 고도화 로드맵 (모션, AI 해설, 성능, 크레딧, 광고, 모의고사)
- [[ISS-0309-topic-system-hard-question-bank]] (resolved, GitHub #504) — 주제 체계 보강과 실전 난이도 문제 은행 확장
- [[ISS-0313-sqld-2026-trend-curated-choices]] (resolved, GitHub #511) — SQLD 2026 출제 경향 반영 — 문제 풀 정리, 보기 고정, 수집 자료 암호화
- [[ISS-0321-latest-trend-notice-badge]] (resolved, GitHub #523) — 2026 출제 경향 반영 업데이트 공지와 최신 경향 표시
- [[ISS-0322-question-harness-restructure]] (resolved, GitHub #524) — 문제 생성 하네스 구조 개편
- [[ISS-0336-sqld-2026-trend-question-pool-refresh]] (resolved, GitHub #548) — SQLD 2026 출제 경향 재수집, 신규 문제 양산, 기존 문제 풀 보강
- [[ISS-0341-app-difficulty-three-level-display]] (resolved, GitHub #553) — 앱 난이도 표시가 3단계 기준이라 4, 5 문제가 4 / 3으로 표시
- [[ISS-0343-daily-set-question-quality-audit]] (resolved, GitHub #555) — 오늘의 세트 문제 품질 점검 — 동일 보기, 해설 오류, 보기 순서
- [[ISS-0346-harness-env-setup-oracle-21c]] (resolved, GitHub #559) — 문제 검증 도구 환경 준비 자동화, Oracle 버전 호환 점검
- [[ISS-0350-public-question-full-audit]] (resolved, GitHub #565) — 공개 문제 전수 점검 — 보기 중복, 바로 지워지는 오답, 숫자 보기 순서
- [[ISS-0366-admin-question-quality-metrics]] (resolved, GitHub #611) — 관리자 문제 목록·상세에 정답률·풀이 수·신고 수가 없고 정렬이 최신순 고정
- [[ISS-0367-admin-question-bulk-actions-csv]] (resolved, GitHub #612) — 관리자 문제 일괄 처리(활성화·토픽·난이도)와 CSV 내보내기가 없음
- [[ISS-0368-admin-report-bulk-api-filters]] (resolved, GitHub #613) — 신고 처리 서버 일괄 API가 없고 사유 집계가 하드코딩·필터 없음
- [[ISS-0369-admin-topic-subtopic-management-incomplete]] (resolved, GitHub #614) — 관리자 토픽·서브토픽 관리 미완성 — 서브토픽 수정 버튼이 동작하지 않음 (버그)
- [[ISS-0373-admin-concept-exam-choiceset-tools]] (resolved, GitHub #618) — 관리자 개념 문서·시험 일정·선택지 세트 화면의 미리보기·일괄 처리·필터 부족
- [[ISS-0401-hide-question-counts-exam-trend]] (resolved, GitHub #660) — 최신 경향 화면에서 문제 수·표본 크기 숨기기
- [[ISS-0414-odd-one-out-choice-generation-fails]] (resolved, GitHub #704) — '결과가 다른 것' 유형 선택지 생성이 항상 실패
- [[ISS-0416-choice-set-prompts-claude-gemini]] (resolved, GitHub #710) — 선택지 생성 프롬프트 Claude·Gemini 공통 개선
- [[ISS-0419-ai-only-choice-answer-result-feedback]] (resolved, GitHub #720) — 일반 SQL 선택지 생성 — 기준 실행 결과 제공, 재시도 실행 결과 피드백
- [[ISS-0420-questions-tab-trend-section-layout]] (resolved, GitHub #726) — 문제 탭 경향 화면 구간 개편 (앱)
