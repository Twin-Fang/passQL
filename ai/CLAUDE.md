# passQL AI Server (Python / FastAPI)

passQL의 AI 기능 전담 서버. 문제·선택지 생성, 관리자 프롬프트 테스트, RAG 문제 색인·추천·정리를 담당한다.
SQL 오류 설명·오답 해설은 Spring(`AiExplainService`)이 `AiChatClient`로 LLM을 직접 호출해 처리한다 (이 서버에 없음).
**프론트(client/app)는 이 서버를 직접 호출하지 않는다** — 반드시 Spring 서버(`server/`)가
`x-api-key`로 프록시한다.

## Tech Stack

- **Python** >= 3.13
- **FastAPI** + **Uvicorn** (ASGI)
- **LLM**: Gemini·Claude·OpenAI (`llm_client` 단일 진입점) — 문제·선택지 생성, 프롬프트 테스트
  - 연결 목록: Spring 관리자 "AI 연결"이 Redis `passql:ai:connections`에 우선순위 순으로 기록 (키 암호문, AAD `ai_connection:{uuid}`), 비면 env `CLAUDE_API_KEY` > `GEMINI_API_KEY` 비상 연결 (#695)
  - 시도 순서: 프롬프트 모델 제공자(`claude-` `gemini-` `gpt-`·`o*`) 연결 먼저 > 나머지 연결(각 기본 모델)
  - fallback: 429·401·402·403·404·5xx·전송 오류·크레딧 부족 400 > 다음 연결, 그 외 즉시 실패
  - 재시도(같은 연결): 요청 미전송(연결 실패·연결 시간 초과)·429만. 읽기 시간 초과·5xx 는 과금됐을 수 있어 재시도 안 함 (#877)
  - 요청 전체 상한 `LLM_REQUEST_DEADLINE_SECONDS`(120초) — Spring `passql.ai-server.timeout-ms`(운영 300초)보다 짧게
- **임베딩**: Ollama (`ollama_client`) — 임베딩 전용 (채팅·fallback 없음)
- **벡터 검색**: Qdrant (`qdrant_search_client`) — 문제 색인·개인화 추천
- **공유 Redis 읽기**: `redis_app_setting_client` — AI 연결 목록(`passql:ai:connections`) 읽기
- **패키지 관리**: `pyproject.toml` + `uv.lock`(고정 버전·해시, Dockerfile·CI 가 `--frozen` 으로 설치)

## Project Structure

의존 방향: `apis` > `services` > `clients`. `tests/test_layer_import_rules.py`가 강제한다.

```
src/
├── main.py                       # FastAPI 앱 진입점 (버전 = passql-ai 패키지 메타데이터)
├── apis/                         # 라우터 (clients 직접 import 금지)
│   ├── ai_router.py              # /api/ai/* — Spring AiGatewayClient 전용 8개
│   └── health_router.py          # /health
├── services/                     # 업무 로직
│   ├── question_generation_service.py      # 문제·선택지 생성, 프롬프트 테스트
│   ├── question_vector_index_service.py    # 색인 적재·상태 비교·고아 벡터 정리
│   └── question_recommendation_service.py  # 오답 벡터 기반 추천
├── clients/                      # 외부 시스템 호출
│   ├── llm_client.py             # LLM 단일 진입점 (시도 순서 > 연결별 호출 > fallback)
│   ├── ai_connection_store.py    # Redis AI 연결 목록 읽기·키 복호화·비상 연결
│   ├── llm_schema.py             # Gemini 스키마 > JSON Schema
│   ├── gemini_client.py
│   ├── claude_client.py          # Messages API (JSON 강제 응답 = 도구 강제 호출)
│   ├── openai_client.py          # Chat Completions (json_object + 스키마 지시)
│   ├── ollama_client.py          # 임베딩
│   ├── qdrant_search_client.py
│   ├── redis_app_setting_client.py   # redis.asyncio (동기 redis import 금지)
│   ├── setting_secret_cipher.py      # Spring 과 같은 AES-GCM 설정 비밀값 복호화
│   ├── token_usage.py                # 호출 1건 토큰 수 전달 (ContextVar)
│   └── shared_http_client.py         # 공유 httpx 클라이언트(lifespan) + 재시도(과금 호출은 미전송·429만) + CustomError 변환
├── core/
│   ├── config.py                 # 환경변수 설정 단일 원본 (컬렉션 이름·임베딩 차원 포함)
│   ├── exception_handlers.py     # 실패 응답 {"detail", "error_kind"} (아래 「실패 응답」)
│   ├── exceptions.py             # CustomError + ErrorKind, InvalidRequestError(400), LlmUnavailableError(503), LlmResponseInvalidError(502)
│   ├── external_call_limits.py   # LLM 호출 1회 30초, 요청 전체 120초, 로그 응답 길이
│   ├── retry.py                  # 외부 호출 재시도 최대 2회 (판정은 호출하는 쪽이 넘김)
│   └── logging.py
├── models/                       # 요청/응답 스키마 (Pydantic)
│   ├── ai_request.py
│   └── ai_response.py
└── utils/
    └── auth.py                   # x-api-key 인증
tests/                            # pytest (계약 스냅샷·계층 규칙·판정)
├── snapshots/                    # Spring 계약 원본 2개 (Spring AiServerContractSnapshotTest 도 같은 파일 검사)
└── architecture/                 # docs/architecture/rules 규칙 테스트
```

## 엔드포인트 (호출처: `server/PQL-Domain-AI/.../AiGatewayClient.java`)

| 경로 | 기능 |
|------|------|
| `POST /api/ai/generate-question-full` | 관리자 문제 등록용 문제·정답·선택지 생성 |
| `POST /api/ai/generate-choice-set` | 사용자 풀이용 선택지 4개 생성 |
| `POST /api/ai/test-prompt` | 관리자 프롬프트 테스트 |
| `POST /api/ai/index-question` | 문제 1개 임베딩 > Qdrant 적재 |
| `POST /api/ai/index-questions-bulk` | 일괄 재색인 |
| `POST /api/ai/recommend` | 개인화 추천 |
| `POST /api/ai/index-status` | DB <-> Qdrant 색인 비교 |
| `POST /api/ai/prune-index` | 고아 벡터 삭제 |

경로·요청/응답 스키마는 `tests/snapshots/spring_called_endpoints_openapi.json`으로 고정. 바꾸면 Spring DTO도 함께 바꾼다.
Spring 쪽 `server/PQL-Domain-AI/.../AiServerContractSnapshotTest`가 같은 파일로 DTO 필드를 검사한다.

## 실패 응답 (`error_kind`, 원본 `tests/snapshots/error_kinds.json`)

| error_kind | 상태 | 뜻 | Spring 처리 |
|---|---|---|---|
| `INVALID_REQUEST` | 400·422 | 요청 형식 오류 (UUID 형식 등) | 대체 호출·서킷 실패 없음, `AI_SERVER_REQUEST_REJECTED` |
| `LLM_UNAVAILABLE` | 503 | LLM 연결 전부 실패·시간 상한 초과 | 대체 호출·서킷 실패 없음, `AI_UNAVAILABLE` |
| `LLM_RESPONSE_INVALID` | 502 | LLM 응답 빈 값·JSON·스키마 위반 | 대체 호출·서킷 실패 없음, `AI_STRUCTURED_SCHEMA_VIOLATION` |
| `INTERNAL_ERROR` | 500 | 그 외 내부 오류 | AI 서버 장애로 보고 Spring 직접 호출 |

인증 401 과 본문 없는 오류(프록시 502 등)는 AI 서버 장애로 본다.

## 설정 우선순위

- 모든 설정은 `src/core/config.py`의 `settings` 한 곳에서 읽는다 (시스템 환경변수 > `.env.{ENVIRONMENT}` > `.env`).
- AI 연결 목록(Redis `passql:ai:connections`)은 `ai_connection_store`만 읽는다 (Redis 접근은 `redis_app_setting_client`).
- 임베딩 모델은 `.env`의 `OLLAMA_EMBED_MODEL` 하나만 쓴다(관리자 설정 `ai.ollama_embed_model`은 읽지 않음, 운영 DB 값 `bge-m3`는 미사용 잔재).
- Gemini 모델·프롬프트는 Spring이 요청마다 `llm_config`로 내려준다.
- `EMBEDDING_VECTOR_DIMENSION`은 임베딩 모델에 묶여 있다. 모델을 바꾸면 차원도 바꾸고 Qdrant 컬렉션을 재생성·재색인한다.
- `ENVIRONMENT=prod` 면 문서 화면(`/docs/*`, `/openapi.json`)을 끈다.

## 환경 변수

- `.env.dev`, `.env.prod` — **gitignore 처리됨. 절대 커밋 금지.**
- API 키(Gemini), Redis/Qdrant 접속 정보, `x-api-key` 등 민감 정보 포함.
- 설정 로딩은 `src/core/config.py` 경유.

## 인증

- 모든 AI 엔드포인트는 `x-api-key` 헤더 필수 (`src/utils/auth.py`, 상수 시간 비교).
- 이 키는 Spring 서버만 알고 있다. 외부 직접 호출 차단.
- 키가 새도 피해를 줄이는 상한: `max_tokens` 16384, temperature 0~2, 정리(prune) 1회 삭제 포인트의 50%(최소 20개) 이하.

## Commands

```bash
# 로컬 환경 (uv.lock 그대로, 프로젝트 메타데이터까지 설치 — 버전 테스트에 필요)
uv venv && uv export --quiet --frozen --group dev --no-emit-project -o /tmp/requirements-dev.txt \
  && uv pip install --require-hashes -r /tmp/requirements-dev.txt && uv pip install --no-deps .

# 로컬 실행 (dev, Spring 기본 base-url 이 localhost:8001)
.venv/bin/uvicorn src.main:app --reload --port 8001

# 테스트
.venv/bin/python -m pytest

# 의존성 변경: pyproject.toml 수정 > uv lock > uv.lock 함께 커밋

# Docker 빌드/실행 (컨테이너 포트 8093)
docker build -t passql-ai .
docker run -e ENVIRONMENT=dev -v "$PWD/.env.dev:/app/.env.dev:ro" -p 8093:8093 passql-ai
```

## 금지 규칙

- **민감 정보 커밋 금지** — `.env*`, API 키, 토큰을 git에 올리지 않는다.
- **답변은 항상 한국어로** — 코드/커맨드 제외.
- **모르면 모른다고 말하기** — 확실하지 않은 내용 추측 금지.
- **로그 문구 한글 금지** — 영어 + 기능 접두사(`[feature] ...`). `docs/architecture/rules/ai-no-korean-log.rule` 이 판정한다 (#789).
