# passQL AI Server (Python / FastAPI)

passQL의 AI 기능 전담 서버. 문제·선택지 생성, 관리자 프롬프트 테스트, RAG 문제 색인·추천·정리를 담당한다.
SQL 오류 설명·오답 해설은 Spring(`AiExplainService`)이 Gemini를 직접 호출해 처리한다 (이 서버에 없음).
**프론트(client/app)는 이 서버를 직접 호출하지 않는다** — 반드시 Spring 서버(`server/`)가
`x-api-key`로 프록시한다.

## Tech Stack

- **Python** >= 3.13
- **FastAPI** + **Uvicorn** (ASGI)
- **LLM**: Gemini (`gemini_client`) — 문제·선택지 생성, 프롬프트 테스트
- **임베딩**: Ollama (`ollama_client`) — 임베딩 전용 (채팅·fallback 없음)
- **벡터 검색**: Qdrant (`qdrant_search_client`) — 문제 색인·개인화 추천
- **동적 설정**: Redis (`redis_app_setting_client`) — Spring 관리자 설정(`passql:settings:*`) 읽기
- **패키지 관리**: `pyproject.toml` (uv/pip)

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
│   ├── gemini_client.py
│   ├── ollama_client.py          # 임베딩
│   ├── qdrant_search_client.py
│   └── redis_app_setting_client.py
├── core/
│   ├── config.py                 # 환경변수 설정 단일 원본 (컬렉션 이름·임베딩 차원 포함)
│   ├── exception_handlers.py     # CustomError·예기치 않은 예외 > 500 공통 응답
│   ├── exceptions.py
│   └── logging.py
├── models/                       # 요청/응답 스키마 (Pydantic)
│   ├── ai_request.py
│   └── ai_response.py
└── utils/
    └── auth.py                   # x-api-key 인증
tests/                            # pytest (계약 스냅샷·엔드포인트·계층 규칙)
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

## 설정 우선순위

- 모든 설정은 `src/core/config.py`의 `settings` 한 곳에서 읽는다 (시스템 환경변수 > `.env.{ENVIRONMENT}` > `.env`).
- 관리자 화면에서 바꾸는 값(Redis `passql:settings:*`)은 `redis_app_setting_client`만 읽는다:
  `ai.gemini_api_key`. 없으면 `settings` 값.
- 임베딩 모델은 `.env`의 `OLLAMA_EMBED_MODEL` 하나만 쓴다(관리자 설정 `ai.ollama_embed_model`은 읽지 않음, 운영 DB 값 `bge-m3`는 미사용 잔재).
- Gemini 모델·프롬프트는 Spring이 요청마다 `llm_config`로 내려준다.
- `EMBEDDING_VECTOR_DIMENSION`은 임베딩 모델에 묶여 있다. 모델을 바꾸면 차원도 바꾸고 Qdrant 컬렉션을 재생성·재색인한다.

## 환경 변수

- `.env.dev`, `.env.prod` — **gitignore 처리됨. 절대 커밋 금지.**
- API 키(Gemini), Redis/Qdrant 접속 정보, `x-api-key` 등 민감 정보 포함.
- 설정 로딩은 `src/core/config.py` 경유.

## 인증

- 모든 AI 엔드포인트는 `x-api-key` 헤더 필수 (`src/utils/auth.py`).
- 이 키는 Spring 서버만 알고 있다. 외부 직접 호출 차단.

## Commands

```bash
# 로컬 실행 (dev)
uvicorn src.main:app --reload

# 테스트
uv sync --group dev   # 또는 uv pip install . pytest
pytest

# Docker 빌드/실행
docker build -t passql-ai .
docker run --env-file .env.dev -p 8000:8000 passql-ai
```

## 금지 규칙

- **민감 정보 커밋 금지** — `.env*`, API 키, 토큰을 git에 올리지 않는다.
- **답변은 항상 한국어로** — 코드/커맨드 제외.
- **모르면 모른다고 말하기** — 확실하지 않은 내용 추측 금지.
