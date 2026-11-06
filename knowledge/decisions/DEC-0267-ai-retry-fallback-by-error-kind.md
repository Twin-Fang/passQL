---
type: decision
id: DEC-0267
created: 2026-11-07
reviewed: null
topics: [ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0466-llm-duplicate-billing-retry-fallback]]", "[[ISS-0466-llm-duplicate-billing-retry-fallback-report]]", "[[DEC-0188-ai-connections-priority-fallback]]"]
---

# DEC-0267: LLM 재시도는 연결 실패·429 만 하고, 서버의 직접 LLM 대체 호출·서킷 실패·선택지 재시도는 AI 서버가 돌려준 `error_kind` 로 나눈다

## 문제 정의 (Context)
AI 서버는 응답 시간 초과에도 재시도하고, 서버는 AI 서버의 모든 오류를 사용 불가로 보고 직접 LLM 을 다시 불렀으며, 선택지 생성은 이를 최대 3번 반복해 요청 한 번에 여러 번 과금될 수 있었다 (GitHub #877, [[ISS-0466-llm-duplicate-billing-retry-fallback]]).

## 결정 (Decision)
- **AI 서버 재시도:** 연결 실패와 429 만. 응답 시간 초과·5xx 는 재시도하지 않는다 (서버 `AiServerRetryPredicate` 와 같은 기준).
- **시간 상한:** AI 서버 요청 전체 120초 — 서버 운영 대기 300초보다 짧게.
- **실패 응답:** AI 서버는 `error_kind` 를 담아 돌려준다.
- **서버 판정:**
  - 입력 오류(4xx) · LLM 모두 실패 > 직접 LLM 대체 호출 없음, 서킷 실패로 세지 않음. 입력 오류는 에러 코드 `AI_SERVER_REQUEST_REJECTED`.
  - AI 서버 내부 오류 · 본문 없음 > 직접 LLM 대체 호출.
  - 선택지 생성 재시도도 같은 실패 종류 기준.
- **연결 간 대체와의 관계:** 이 결정은 같은 요청의 재시도와 서버의 직접 LLM 대체 호출을 다룬다. 우선순위 연결 목록 사이의 대체([[DEC-0188-ai-connections-priority-fallback]], "응답 없음"이면 다음 연결)가 응답 시간 초과에서 어떻게 바뀌는지는 원본에 기록 없음 — 확인 필요.
- **AI 서버 입력 상한:** `max_tokens` 16384, temperature 범위 제한, 벡터 정리 요청 삭제 비율 50%, UUID 형식 422. 운영 docs 화면 끔.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 이미 과금됐을 수 있는 요청을 다시 보내지 않고, 입력 오류로 인한 다중 과금이 없어진다. 대기 시간이 서버 대기 안으로 들어온다.

**부정**
- 일시적 시간 초과도 재시도하지 않아 그 요청은 실패로 끝난다 (구조상 결과, 원본에 별도 논의 없음).
- 관리자가 문제의 절반 넘게를 한꺼번에 비활성하면 정리 요청이 거부되어 컬렉션 재생성·재색인이 필요하다.

## 영향 범위 (Scope)
AI 서버 `shared_http_client.py`·`retry.py`·`gemini_client.py`·실패 응답 형태, 서버 `AiGatewayClient`·`AiServerRetryPredicate`·`ChoiceSetAttemptRunner`·`ErrorCode`, 양쪽 계약 스냅샷 테스트.

## 출처 (References)
- GitHub #877 이슈 본문·리포트 댓글 (2026-11-07)
