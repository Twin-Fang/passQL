---
type: cluster
topic: ai
created: 2026-10-29
members: 96
status: active
related: []
---

# 클러스터: ai

## 이 주제는
AI 서버·LLM 호출·선택지 생성·해설·프롬프트·임베딩

## 현재 상태 요약
(2026-10-29, 자동 생성) 활성 결정 40개, 열린 이슈 2개. 서술 요약은 아직 작성하지 않았다 — 아래 활성 결정 목록이 현재 기준이다.

## 활성 결정
- [[DEC-0025-redis-shared-app-settings]] — Spring이 `app_setting`을 Redis(`passql:settings:{key}`)에 쓰고 AI 서버가 읽어 설정을 공유
- [[DEC-0040-choice-response-hides-answer]] — 선택지 생성 응답에는 정답·해설을 넣지 않고, 정답 판정은 제출 시 서버가 `choiceSetId`의 선택지 세트로 한다
- [[DEC-0042-ai-comment-cache-evict-on-submit]] — AI 영역 분석 코멘트는 별도 API로 Redis 24시간 캐싱하고, 제출 시 직접 evict한다
- [[DEC-0049-ai-only-redefined-sql-equivalence]] — `AI_ONLY` 정책은 "주어진 SQL과 동일한 실행 결과를 내는 SQL 고르기"로 재정의한다
- [[DEC-0050-result-match-text-choices]] — "실행 결과로 올바른 것은?" 유형은 `RESULT_MATCH` 정책 — 선택지는 결과 JSON(`kind = TEXT`), 검증은 `answerSql` 결과와 비교
- [[DEC-0052-result-match-policy-equivalence-type]] — AI_ONLY EXECUTABLE 문제는 "동일 결과를 내는 SQL 찾기" 유형으로 재정의하고 `RESULT_MATCH` 선택지 정책을 추가
- [[DEC-0055-multiple-correct-ai-fallback-save]] — 3회 재시도 후에도 `MULTIPLE_CORRECT`면 AI의 `isCorrect` 판단으로 fallback 저장 (`sandbox_validation_passed=false`)
- [[DEC-0074-shared-markdowntext-component]] — AI 텍스트·해설·지문은 공용 `MarkdownText`로 렌더링하고 `useAiText`는 쓰지 않는다
- [[DEC-0076-markdown-rules-for-generated-content]] — 문제 콘텐츠(stem·hint·rationale)는 마크다운 활용 규칙을 따른다
- [[DEC-0077-rag-recommendation-with-random-fallback]] — 문제 추천은 Qdrant 벡터 검색 기반 개인화, 신호 집계는 Java·검색은 Python, 실패 시 RANDOM 폴백
- [[DEC-0083-session-scoped-recommendation-exclusion]] — 추천 새로고침은 이번 세션에서 본 문제만 제외하고, 푼 문제 영구 제외는 하지 않는다
- [[DEC-0086-permit-async-dispatch-in-security]] — Spring Security에서 `DispatcherType.ASYNC`는 인증 재검사 없이 `permitAll()`
- [[DEC-0087-choice-generation-practice-real-mode]] — 선택지 생성 모드를 연습(`PRACTICE`, 검증된 선택지 재사용)과 실전(`REAL`, 항상 AI 실시간 생성)으로 나눈다
- [[DEC-0100-explain-prompt-context-in-server]] — AI 해설 프롬프트에 규칙·샘플 데이터·전체 선택지를 서버(`AiExplainService`)가 넣는다
- [[DEC-0113-similar-via-recommend-reuse]] — 유사 문제는 AI 서버를 새로 만들지 않고 기존 `POST /api/ai/recommend`를 Spring에서 조합해 쓴다
- [[DEC-0122-remove-python-ai-stubs]] — Python AI 서버의 미구현 스텁 3개(`explain_error`·`diff_explain`·`similar`)를 삭제하고 문서를 정정한다
- [[DEC-0125-embedding-model-env-only]] — 임베딩 모델은 관리자 설정(DB)이 아니라 `.env` 단일 원본으로 둔다
- [[DEC-0137-pregenerate-choice-explanations-db]] — 선택지 해설은 세트 저장 직후 별도 호출로 미리 생성해 DB에 영구 저장하고, 샌드박스 미검증 세트는 제외
- [[DEC-0146-structured-explanation-once-per-set]] — AI 해설은 고정 섹션 형식으로 선택지 세트당 한 번 만들어 저장하고, 없으면 "생성 중"을 돌려주며 백그라운드에서 만든다
- [[DEC-0154-close-explanation-sheet-on-next]] — 풀이 중 "다음"으로 넘어가면 해설 시트를 닫는다 (해설함·백그라운드 조회는 유지)
- [[DEC-0155-exam-tip-after-answer-reason]] — AI 해설 화면 순서는 판정 → 정답 근거 → 시험 팁 → 핵심 개념 → 헷갈리는 지점 → 보기별 판단
- [[DEC-0158-new-questions-concept-only-curated]] — 2026 경향 신규 문제는 `CONCEPT_ONLY` + `CURATED_ONLY`(고정 보기)로 등록한다
- [[DEC-0159-ai-explanation-grounded-on-execution]] — AI 해설은 실행형 SQL 보기를 샌드박스에서 실행한 실측 결과를 근거로 쓴다
- [[DEC-0160-ai-call-log-tokens-cost-400-days]] — AI 비용은 `ai_call_log`의 모델·토큰 × 앱 설정 단가표로 추정하고, 호출 기록은 요약 테이블 없이 400일 보관한다
- [[DEC-0162-keep-per-feature-gemini-models]] — 해설·오류 설명·개념 선택지는 `gemini-3.5-flash-lite`, SQL·결과표 선택지·AI 코멘트·문제 생성은 `gemini-2.5-flash-lite` 유지
- [[DEC-0164-ai-server-traefik-blue-green]] — AI 서버도 백엔드와 같은 Traefik blue/green으로 배포하고 drain은 75초
- [[DEC-0187-claude-provider-by-model-prefix]] — AI 제공자는 모델 이름으로 고르고(`claude-*` → Claude), 기본 모델은 가장 싼 `claude-haiku-5-5`, Gemini 경로는 유지
- [[DEC-0188-ai-connections-priority-fallback]] — AI 키는 관리자 "AI 연결" 목록(제공자+키+기본 모델+우선순위)으로 관리하고, 한도·키·서버 오류면 다음 연결로 넘어가며 요청 형식 400은 즉시 실패
- [[DEC-0193-choice-set-prompts-benchmarked-adoption]] — 선택지 생성 프롬프트는 운영 문제 x Haiku·Gemini 비교 결과로 채택 — 결과가 다른 것은 #699 v2 유지, `max_tokens` 4096, Gemini 온도 유지
- [[DEC-0194-explanation-working-notes-evidence-priority]] — 선택지 세트 해설은 보이지 않는 풀이 메모(`workingNotes`)를 먼저 쓰게 하고, 근거 우선순위는 실행 결과 > 고정 세트 검증된 풀이 > 생성 근거 > 자체 계산
- [[DEC-0195-targeted-regeneration-without-version-bump]] — 해설 일부만 다시 만들 때는 프롬프트 버전을 올리지 않고 대상 세트만 `explanation_prompt_version`을 낮춰 백필이 재생성하게 한다
- [[DEC-0196-gemini-fallback-3-1-flash-lite]] — 2순위 Gemini 대체 모델은 `gemini-3.1-flash-lite` (1순위 `claude-haiku-5-5` 유지)
- [[DEC-0197-provide-answer-sql-result-in-prompt]] — 일반 SQL(AI_ONLY) 선택지 생성은 기준 SQL을 샌드박스로 실행한 결과를 프롬프트에 주고, 재시도에는 보기별 실제 실행 결과와 "기준과 같음/다름"을 준다

## 대체된 결정 (역사)
- [[DEC-0020-gemini-flash-lite-primary-llm]] → DEC-0029
- [[DEC-0028-realtime-choice-set-with-prefetch]] → DEC-0087
- [[DEC-0029-python-ai-server-primary-gemini-fallback]] → DEC-0187
- [[DEC-0032-gemini-key-runtime-from-settings]] → DEC-0133
- [[DEC-0099-explain-model-gemini-3-5-flash-lite]] → null
- [[DEC-0133-encrypted-gemini-key-single-source]] → DEC-0188
- [[DEC-0147-keep-explanation-sheet-while-solving]] → DEC-0154

## 관련 이슈
- [[ISS-0357-choice-set-ai-server-half-failing]] (open, GitHub #575) — 선택지 생성 AI 서버 호출 절반 실패, 원인 조사
- [[ISS-0412-ai-explanation-quality-cost-optimization]] (open, GitHub #699) — AI 해설 품질, 호출 빈도, 비용 최적화와 해설 시트 정리
- [[ISS-0015-gemini-primary-ollama-fallback]] (resolved, GitHub #16) — AI 클라이언트를 Gemini 2.0 Flash-Lite 기반으로 전환, Ollama Fallback 구조
- [[ISS-0024-admin-pages-ai-redis-settings]] (resolved, GitHub #30) — 관리자 페이지 전체 구현 및 AI 서버 Redis 설정 연동
- [[ISS-0029-realtime-ai-choice-set-prefetch]] (resolved, GitHub #39) — 실시간 AI 선택지 세트 생성 및 프리페치 아키텍처
- [[ISS-0033-gemini-key-dynamic-db-redis]] (resolved, GitHub #47) — Gemini API Key를 DB·Redis에서 동적 관리
- [[ISS-0042-sse-choice-generation-submit-flow]] (resolved, GitHub #69) — 선택지 생성 SSE 엔드포인트 부재와 제출 플로우의 구 테이블 참조
- [[ISS-0044-topic-analysis-ai-comment-api]] (resolved, GitHub #71) — 통계 화면용 토픽별 분석·AI 코멘트 API 부재
- [[ISS-0046-sse-submit-fe-integration-guide]] (resolved, GitHub #78) — SSE 선택지 생성·제출 플로우(#69) FE 연동 가이드 — FE/BE 불일치
- [[ISS-0047-topic-analysis-ai-comment-impl]] (resolved, GitHub #79) — "내 실력, 한눈에" 통계 화면용 토픽별 분석·AI 코멘트 API 구현
- [[ISS-0058-ai-choice-body-result-text]] (resolved, GitHub #103) — AI 선택지 body에 SQL 대신 실행 결과 텍스트가 와서 검증 전체 실패, 화면은 스피너 고착
- [[ISS-0062-ai-only-choices-mismatch-question-type]] (resolved, GitHub #108) — `AI_ONLY` 문제의 선택지가 SQL이라 "실행 결과로 올바른 것은?" 지문과 맞지 않음
- [[ISS-0063-result-match-policy]] (resolved, GitHub #110) — "실행 결과로 올바른 것은?" 유형을 위한 `RESULT_MATCH` 정책 부재
- [[ISS-0066-ai-only-equivalent-sql-multiple-correct]] (resolved, GitHub #114) — AI_ONLY 정책의 SQL 동치 유형 문제에서 MULTIPLE_CORRECT가 3회 재시도 내내 반복
- [[ISS-0073-ai-server-401-env-file-missing]] (resolved, GitHub #125) — Python AI 서버 호출이 매번 401 Unauthorized
- [[ISS-0074-anti-equivalence-prompt-v4]] (resolved, GitHub #126) — generate_choice_set 동치 SQL 패턴 금지 프롬프트 개선
- [[ISS-0076-ai-metadata-model-field-mismatch]] (resolved, GitHub #132) — Python AI 서버 GenerationMetadata `model` 필드명 불일치로 파싱 오류
- [[ISS-0100-ai-comment-session-feedback-step-merge]] (resolved, GitHub #181) — 퀴즈 결과 AI 분석 — 세션 단위 피드백과 Step 통합
- [[ISS-0111-choice-generation-loading-sparkles]] (resolved, GitHub #196) — 선택지 생성 중 로딩 UI를 Sparkles 아이콘·문구로 개선
- [[ISS-0131-markdown-rendering-ai-text]] (resolved, GitHub #237) — AI 피드백·해설·지문의 Markdown 서식이 깨져 보임
- [[ISS-0132-result-match-registered-as-ai-only]] (resolved, GitHub #242) — "실행 결과로 올바른 것은?" 문제가 `AI_ONLY`로 등록돼 선택지가 SQL 쿼리로 생성됨
- [[ISS-0133-markdown-guide-for-ai-content]] (resolved, GitHub #243) — AI 생성 콘텐츠가 마크다운을 쓰지 않아 가독성이 떨어짐
- [[ISS-0134-rag-personalized-recommendation]] (resolved, GitHub #248) — 문제 추천이 완전 랜덤이라 풀이 기록이 반영되지 않음
- [[ISS-0135-admin-qdrant-embedding-index-page]] (resolved, GitHub #250) — Qdrant 임베딩 색인 상태를 관리자가 확인·재색인할 수 없음
- [[ISS-0137-home-recommendation-missing-member-uuid]] (resolved, GitHub #253) — 홈 AI 추천이 오답 기록과 무관하게 항상 랜덤
- [[ISS-0139-ai-qdrant-env-prod-config]] (resolved, GitHub #256) — prod `passql-ai`가 `localhost`로 Qdrant에 접속해 연결 실패
- [[ISS-0153-recommendation-refresh-session-dedupe]] (resolved, GitHub #284) — 홈 AI 추천 새로고침을 눌러도 같은 문제가 나옴
- [[ISS-0166-sse-async-dispatch-access-denied]] (resolved, GitHub #310) — SSE async dispatch에서 Spring Security Access Denied로 선택지 생성 실패
- [[ISS-0167-choice-generation-practice-real-mode]] (resolved, GitHub #313) — 문제풀이 선택지 생성 모드를 연습/실전으로 분리
- [[ISS-0199-ai-explain-always-unavailable]] (resolved, GitHub #354) — AI 해설이 항상 '일시적으로 사용 불가'로 표시됨 (기능 미구현)
- [[ISS-0201-ai-explain-model-compare-prompt]] (resolved, GitHub #356) — AI 해설 모델 비교(lite 3종)와 프롬프트 보완
- [[ISS-0203-odd-one-out-choice-gen-fails]] (resolved, GitHub #358) — 추천 문제 ODD_ONE_OUT 선택지 생성이 37초 뒤 실패함
- [[ISS-0207-ai-explain-sheet-markdown-symbols]] (resolved, GitHub #362) — AI 해설 시트에 마크다운 기호(**, `, *)가 그대로 노출됨
- [[ISS-0208-concept-choice-prompt-v2-quality]] (resolved, GitHub #363) — 개념 문제 AI 선택지 품질 개선 — 정확하고 변별력 있게
- [[ISS-0210-stats-ai-analysis-backticks]] (resolved, GitHub #365) — 통계 AI 영역 분석에 마크다운 백틱이 그대로 노출됨
- [[ISS-0244-qdrant-orphan-vectors-index-mismatch]] (resolved, GitHub #412) — 임베딩 색인 불일치 — Qdrant 237 vs 활성 문제 192, 미색인 2
- [[ISS-0251-similar-questions-api-todo-500]] (resolved, GitHub #442) — 유사 문제 API가 미구현(TODO)이라 매번 500 — 결과 화면 유사 문제 섹션이 항상 숨겨짐
- [[ISS-0269-ai-stub-removal-settings-unify]] (resolved, GitHub #463) — AI 서버 미사용 스텁·설정 경로 혼재·문서 불일치
- [[ISS-0298-gemini-key-single-source-encrypted]] (resolved, GitHub #492) — Gemini API 키 원본이 두 곳이고 DB·Redis에 평문 저장
- [[ISS-0301-ai-explanation-persist-pregenerate]] (resolved, GitHub #496) — AI 해설이 영구 저장되지 않고 오답 해설을 매번 기다려야 함
- [[ISS-0319-ai-explanation-format-speed-ux]] (resolved, GitHub #521) — AI 해설 형식, 품질, 속도와 해설 화면 UX 개편
- [[ISS-0330-stale-explanation-sheet-empty-result]] (resolved, GitHub #538) — 풀이 중 이전 문제 해설 시트가 남고, 빈 결과 보기가 오류처럼 보임
- [[ISS-0343-daily-set-question-quality-audit]] (resolved, GitHub #555) — 오늘의 세트 문제 품질 점검 — 동일 보기, 해설 오류, 보기 순서
- [[ISS-0344-admin-dashboard-stats-ai-cost]] (resolved, GitHub #557) — 관리자 대시보드 통계 그래프, 접속자 집계, AI 사용량과 비용
- [[ISS-0345-cheapest-model-per-feature-benchmark]] (resolved, GitHub #558) — 기능별 최저가 모델 실측 비교
- [[ISS-0349-ai-server-blue-green-deploy]] (resolved, GitHub #564) — AI 서버 배포를 백엔드와 같은 무중단(blue/green)으로 전환
- [[ISS-0352-ai-stats-comment-no-activity-today]] (resolved, GitHub #567) — AI 영역 분석이 오늘 푼 기록을 두고 '10월 21일 이후 활동이 없다'고 서술
- [[ISS-0370-admin-prompt-version-management]] (resolved, GitHub #615) — 관리자 프롬프트 삭제·버전 diff·롤백·변경 이력·테스트 결과 보관이 없음
- [[ISS-0371-admin-embedding-index-management]] (resolved, GitHub #616) — 관리자 임베딩 색인 관리 — 재색인이 동기 호출이라 진행률이 없고 실패 재시도·이력이 없음
- [[ISS-0410-claude-api-provider-switch]] (resolved, GitHub #688) — Claude API provider 전환 지원 (AI)
- [[ISS-0411-ai-connections-multi-key-fallback]] (resolved, GitHub #695) — AI 연결 관리 — 다중 API 키, 우선순위, fallback
- [[ISS-0414-odd-one-out-choice-generation-fails]] (resolved, GitHub #704) — '결과가 다른 것' 유형 선택지 생성이 항상 실패
- [[ISS-0416-choice-set-prompts-claude-gemini]] (resolved, GitHub #710) — 선택지 생성 프롬프트 Claude·Gemini 공통 개선
- [[ISS-0417-sequential-execution-explanation-errors]] (resolved, GitHub #716) — AI 해설 차례 실행 문제 근거 오류와 재발 방지
- [[ISS-0418-gemini-fallback-model-3-1-flash-lite]] (resolved, GitHub #719) — Gemini 대체 모델 `gemini-3.1-flash-lite`로 변경
- [[ISS-0419-ai-only-choice-answer-result-feedback]] (resolved, GitHub #720) — 일반 SQL 선택지 생성 — 기준 실행 결과 제공, 재시도 실행 결과 피드백
