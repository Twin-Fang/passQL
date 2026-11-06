---
type: issue
id: ISS-0466
created: 2026-11-07
topics: [ai, security]
symptoms: ["LLM 중복 과금", "응답 시간 초과 재시도", "대체 호출 중복", "선택지 생성 3번 반복", "사용량 통계 여러 번 기록", "AI 서버 공유 키", "max_tokens 상한 없음", "Qdrant UUID 500", AiServerRetryPredicate, AiGatewayClient, ChoiceSetAttemptRunner, shared_http_client.py, retry.py]
root_cause: "AI 서버는 LLM 응답 시간 초과에도 재시도했고, 서버는 AI 서버의 모든 4xx·5xx 를 사용 불가로 보고 직접 LLM 대체 호출을 했으며 선택지 생성이 이를 최대 3번 반복했다"
status: resolved
resolution: "[[ISS-0466-llm-duplicate-billing-retry-fallback-report]]"
related: ["[[DEC-0267-ai-retry-fallback-by-error-kind]]", "[[DEC-0188-ai-connections-priority-fallback]]"]
source: "_sources/issues/ISS-0466-llm-duplicate-billing-retry-fallback.md"
---

# ISS-0466: LLM 호출 중복 과금 (응답 시간 초과 재시도와 서버 대체 호출 겹침), AI 서버 키 보호

GitHub #877 (https://github.com/Twin-Fang/passQL/issues/877). 2026-11-07 AI 서버 전체 점검에서 확인.

## 증상
- AI 서버가 LLM 응답 시간 초과에도 재시도 (`shared_http_client.py`, `retry.py`, `gemini_client.py`). 서버(Spring)는 같은 이유로 이 경우를 일부러 재시도하지 않아(`AiServerRetryPredicate`) 정책이 어긋남. 이미 과금된 요청을 다시 보내고 대기가 수 분까지 늘 수 있음.
- 서버가 AI 서버 4xx·5xx 를 모두 사용 불가로 감싸 직접 LLM 호출로 넘어가고(`AiGatewayClient`), 선택지 생성은 이를 최대 3번 반복(`ChoiceSetAttemptRunner`). 입력 오류도 한 번에 여러 번 과금.
- AI 서버 보호가 공유 키 하나뿐. 운영 문서 화면 공개, `max_tokens` 상한 없음, 벡터 정리 요청의 삭제 비율 상한 없음.
- 그 밖에: UUID 검증 없이 Qdrant 경로에 넣어 500, 벡터를 하나씩 전체 차원으로 조회, 의존성 버전 고정 없음, 템플릿 이중 치환, Redis 첫 연결 경쟁.

## 재현 조건
선택지 생성 요청이 LLM 응답 30초를 넘기면 AI 서버가 같은 요청을 다시 보내고, 서버는 실패 시 직접 LLM 을 다시 부름 > 사용량 통계에 한 번의 요청이 여러 번 기록.

## 조사 기록
- 2026-11-07: AI 서버 감사(내부)에서 발견.

## 근본 원인
재시도·대체 호출 판단이 실패 종류(시간 초과, 입력 오류, 내부 오류)를 구분하지 않았고, AI 서버와 서버의 재시도 정책이 따로 정해져 겹쳤다.
