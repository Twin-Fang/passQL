---
type: issue
id: ISS-0139
created: 2026-04-13
topics: [ai, ci-deploy, ops-infra]
symptoms: ["All connection attempts failed", QDRANT_URL, "localhost:6333", ".env.prod", AI_ENV_FILE, passql-ai, "임베딩 색인 상태 조회 불가"]
root_cause: "CI가 `AI_ENV_FILE`을 `ai/.env`로 만들고 Dockerfile도 `.env`만 복사해 prod에서 `.env.prod` 대신 dev `.env`(`QDRANT_URL=http://localhost:6333`)로 fallback"
status: resolved
resolution: null
related: []
source: "https://github.com/Twin-Fang/passQL/issues/256"
---

# ISS-0139: prod `passql-ai`가 `localhost`로 Qdrant에 접속해 연결 실패

GitHub #256 (원본: 이슈 본문만, 댓글 없음).

## 증상
`passql-ai` 컨테이너가 `QDRANT_URL=http://localhost:6333`으로 Qdrant에 접속을 시도해 `All connection attempts failed` 오류가 난다. 임베딩 색인 상태 조회와 재색인 기능 전체가 동작하지 않는다.

## 재현 조건
prod 배포된 `passql-ai`에서 Qdrant 접근 시.

## 조사 기록
- 2026-04-13: CI/CD가 `AI_ENV_FILE` Secret을 `ai/.env`로 생성하고 Dockerfile도 `.env`만 복사한다. `config.py`는 `ENVIRONMENT=prod`일 때 `.env.prod`를 우선 탐색하지만 이미지에 없어 dev용 `.env`로 fallback.
- 제안: `ai/.env.prod` 신규(`QDRANT_URL=http://qdrant:6333`, `REDIS_HOST=redis` 등 컨테이너 내부 네트워크 기준), `ai/Dockerfile` `COPY .env ./` → `COPY .env.prod .env.prod`, `.github/workflows/PROJECT-PYTHON-AI-CICD.yaml`이 Secret을 `ai/.env.prod`로 생성, `AI_ENV_FILE` 값을 prod 기준으로 갱신, `deploy` 재배포 후 확인.

## 근본 원인
prod 환경 파일이 이미지에 포함되지 않는 빌드·CI 구성. 실제 적용·확인 결과는 원본에 적혀 있지 않다.
