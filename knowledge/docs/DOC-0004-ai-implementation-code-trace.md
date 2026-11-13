---
type: doc
id: DOC-0004
doc_type: design
authority: internal
created: 2026-11-13
reviewed: null
source: "https://github.com/Twin-Fang/passQL/tree/118159a8"
topics: [ai]
topics_ref: [practice, question-bank, admin]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0025-redis-shared-app-settings]]", "[[DEC-0077-rag-recommendation-with-random-fallback]]", "[[DEC-0113-similar-via-recommend-reuse]]", "[[DEC-0122-remove-python-ai-stubs]]", "[[DEC-0137-pregenerate-choice-explanations-db]]", "[[DEC-0146-structured-explanation-once-per-set]]", "[[DEC-0188-ai-connections-priority-fallback]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]", "[[DEC-0251-practice-reuse-random-validated-sets]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0267-ai-retry-fallback-by-error-kind]]", "[[DOC-0003-practice-implementation-code-trace]]"]
---

# DOC-0004: AI 호출(선택지 생성·해설·분석·추천) 구현 코드 추적 — Spring·AI 서버

## 요약
2026-11-13 main(`118159a8`, v1.120.0) 코드를 직접 따라가 정리한 AI 호출 지도다. LLM 호출 경로는 둘이다. (1) Spring > Python AI 서버(`AiGatewayClient`, `X-API-Key`): 문제 생성, 선택지 세트 생성, 프롬프트 테스트, 벡터 색인·추천. (2) Spring > LLM 직접(`AiChatClient`): 선택지 해설, SQL 오류 해설, 통계 AI 분석, 결과 화면 세션 코멘트, 그리고 AI 서버 장애 때의 대체 호출. 두 경로 모두 관리자 "AI 연결" 목록을 우선순위대로 시도하고, 한도·키·서버 오류면 다음 연결로 넘어간다. 앱·웹은 AI 서버를 직접 부르지 않는다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 구성 요소
| 위치 | 역할 | 주요 클래스·파일 |
|---|---|---|
| Spring `PQL-Domain-AI` | AI 서버 호출 단일 진입점, LLM 직접 호출, 연결 목록, 호출 기록 | `client/AiGatewayClient`, `GeminiFallbackClient`, `AiChatClient`, `AiCallAttemptPlanner`, `AiFallbackPolicy`, 제공자 클라이언트(`ClaudeClient`, `GeminiClient`, `OpenAiClient`, `OllamaClient`), `service/AiConnectionRegistry`, `AiCallLogService` |
| Spring 호출부 | 기능별 조립 | `PQL-Domain-Question/.../ChoiceSetGenerationService`·`ChoiceSetResolver`·`QuestionGenerateService`·`QuestionVectorIndexService`, `PQL-Application/.../service/`(`ChoiceGenerationStreamService`, `AiExplainService`, `ChoiceExplanationService`, `explanation/ChoiceSetExplanationGenerator`, `AiExplanationGenerator`, `statsanalysis/StatsAnalysisService`·`SessionCommentService`, `RecommendationService`) |
| Python AI 서버 | LLM 구조화 출력, 임베딩·Qdrant | `ai/src/apis/ai_router.py`(`/api/ai/*`, 전부 `verify_api_key`), `services/question_generation_service.py`, `question_vector_index_service.py`, `question_recommendation_service.py`, `clients/llm_client.py`, `ai_connection_store.py` |

### AI 서버 엔드포인트 8개 (`ai_router.py`)
`/generate-question-full`, `/generate-choice-set`, `/test-prompt`, `/index-question`, `/index-questions-bulk`, `/recommend`, `/index-status`, `/prune-index`. 해설·유사 문제용 엔드포인트는 없다(DEC-0122로 스텁 삭제, 유사 문제는 `/recommend` 재사용 DEC-0113).

### `AiGatewayClient` 호출 규칙
- 메서드마다 `@CircuitBreaker(name = "aiServer")` + `@Retry(name = "aiServer")` > `postToPython(path, request, 응답형)`.
- 대체(fallback) 메서드: AI 서버가 응답 본문 `error_kind`로 알린 실패(입력 오류·LLM 실패)는 대체 없이 그대로 던지고(`rethrowIfReportedByAiServer`), AI 서버 자체 장애일 때만 `GeminiFallbackClient`(이름과 달리 모델 이름으로 Gemini·Claude 선택) > `AiChatClient` 직접 호출.
- `GET /health`(3초 제한)로 연결 상태 확인.

### 연결 목록과 시도 순서
- `AiConnectionRegistry.findCallTargets`: 사용 중 연결(우선순위 순, 키 복호화, 30초 캐시). 변경 시 Redis `passql:ai:connections`에 암호문 키 그대로 동기화해 AI 서버가 같은 목록을 읽는다.
- 시도 순서(`AiCallAttemptPlanner` = Python `llm_client.plan_attempts`): 프롬프트 모델의 제공자 연결이 있으면 그 연결들(프롬프트 모델) > 나머지 연결(각 기본 모델), 없으면 전부 기본 모델.
- 다음 연결로 넘어가는 오류(`AiFallbackPolicy` = Python `is_fallback_error`): 응답 없음(타임아웃·연결·키 미설정), 401·402·403·404·429·5xx, 크레딧·한도·무효 키 문구가 있는 400. 그 외 400은 즉시 실패. 전부 실패면 `AI_UNAVAILABLE`.
- 호출 기록 `AiCallLogService`: 별도 단일 스레드, 과부하 시 버림. 연결별 성공·실패도 `recordSuccess`·`recordFailure`.

### 선택지 세트 생성
1. 풀이 화면 SSE([[DOC-0003-practice-implementation-code-trace]]) > `ChoiceSetResolver.resolveForUser`: 비활성 문제 거부 > 고정 보기면 관리자 세트(AI 호출 없음) > 연습 모드는 본인 프리페치 > 검증 통과 세트 > 생성, 실전 모드는 생성.
2. `ChoiceSetGenerationService`(비트랜잭션): 정책별 `generateConcept`(샌드박스 없이 텍스트 보기), `generate`(SQL 보기), `generateResultMatch`(결과 표 보기) > `ChoiceSetAttemptRunner`로 최대 `MAX_ATTEMPTS` 재시도.
3. 시도마다 `aiGatewayClient.generateChoiceSet` > 샌드박스 검증(`SandboxValidator`). 재시도에는 직전 실행 결과·동치 SQL 피드백을 넣어 요청을 새로 만든다.
4. 재시도 불가 오류: AI 경로 3개(대체까지 실패, LLM 연결 전부 실패·시간 초과, AI 서버 요청 거부 = 같은 요청 반복은 중복 과금), 샌드박스 2개(준비 실패, 기준 SQL 실패).
5. 저장은 검증 통과 세트만(`ChoiceSetSaveService`, 별도 빈). 개념 문제만 AI가 준 정답 표시를 쓴다.

### 선택지 해설 (구조화 해설)
- `ChoiceExplanationService`: 세트당 1회 생성·저장. 조회는 저장본을 바로 주고, 없으면 상태를 돌려준 뒤 백그라운드에서 만든다. 생성 담당은 DB 조건부 UPDATE 1건에 성공한 요청만(서버 여러 대 중복 방지).
- `ChoiceSetExplanationGenerator.generate`: 프롬프트 조립(보기별 실행 결과·메모 근거) > `aiChatClient.chatStructured` > 파싱 > 검증 > 위반 있으면 위반 목록을 붙여 1회 재시도. 모델·온도는 `PromptKey.DIFF_EXPLAIN` 활성 프롬프트 설정, 문구는 리소스 파일.
- API: `GET /api/ai/choice-explanation`(`AiExplainService.getChoiceExplanation` > `ProResponseRedactor.redactChoiceExplanation`), 출시 앱용 동기 해설 `POST /api/ai/diff-explain`.

### SQL 오류 해설
- `POST /api/ai/explain-error` > `AiExplainService.explainError`: (문제, 정규화 SQL, 오류) 단위로 저장본 재사용, 없으면 `AiExplanationGenerator.generateErrorExplanation`(프롬프트 `PromptKey.EXPLAIN_ERROR`) > 저장. LLM 호출은 트랜잭션 밖.

### 통계 분석·세션 코멘트
- `StatsAnalysisService.analyze`: 데이터 조회 > 서버 판정 > 집중 토픽이 있으면 LLM 한 문장. LLM 실패면 insight 없이 응답하고 캐시하지 않는다.
- `SessionCommentService.comment`: 세션 결과 > 서버 문장(점수·놓친 토픽) > 오답이 있으면 LLM 한 문장. 남의 세션·없는 세션은 고정 문장.

### 추천·유사 문제·색인
- `RecommendationService.recommend`: 신호 집계(제출 기록, Java) > `aiGatewayClient.recommend`(Qdrant 검색, Python) > 문제 변환. `findSimilar`도 같은 `/recommend`를 쓴다(`GET /api/ai/similar/{uuid}`).
- 색인: 문제 저장 커밋 뒤 `QuestionSavedEvent` > `QuestionVectorIndexService`가 `/index-question`. 관리자 전체·선택 재색인, `/prune-index`(Python `is_prune_deletion_allowed`: 삭제 수 상한 max(20, 포인트 수 x 50%)).

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0077(추천 신호는 Java·검색은 Python), DEC-0113(유사 문제는 `/recommend` 재사용), DEC-0122(Python 해설 스텁 삭제), DEC-0146(세트당 1회 구조화 해설, 없으면 생성 중), DEC-0188(연결 우선순위 대체, 요청 형식 400 즉시 실패), DEC-0250(검증 통과 세트만 저장), DEC-0251(연습 모드 재사용), DEC-0259(서버 판정, LLM은 한 문장), DEC-0267(대체·재시도는 `error_kind`로 판정)과 코드가 일치했다. 충돌 없음. 결정 본문은 읽지 않고 클러스터 한 줄 요약과 대조했다.

## 열린 질문
- **문서와 실제 경로 차이**: 레포 루트 `CLAUDE.md`의 통신 구조는 server > ai만 그리지만, 해설·오류 해설·통계 분석·세션 코멘트는 Spring이 LLM을 직접 부른다(`AiChatClient`). 의도된 구조인지 정리한 결정 노트는 찾지 못했다(DEC-0122는 스텁 삭제만 기록).
- **대체 클라이언트 이름**: `GeminiFallbackClient`는 모델 이름으로 Claude도 고른다. 이름이 동작과 다르다.
- **`@Retry` + 재시도 불가 판정**: `AiGatewayClient`의 Resilience4j 재시도 설정이 `error_kind` 판정과 어떻게 겹치는지는 설정 파일을 읽지 않아 확인하지 않았다.

## 원본 참조
- 코드 기준: main `118159a8` (2026-11-13, v1.120.0). 원문은 코드 자체이며 별도 텍스트 원본은 없다.
