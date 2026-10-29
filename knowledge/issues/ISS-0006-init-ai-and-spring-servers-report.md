---
type: completion-report
id: ISS-0006
created: 2026-04-06
topics: [ci-deploy, ops-infra]
status: resolved
resolves: "[[ISS-0006-init-ai-and-spring-servers]]"
related: ["[[DEC-0009-main-verify-deploy-branch-release]]", "[[DEC-0010-spring-multimodule-layering]]"]
source: "https://github.com/Twin-Fang/passQL/issues/1"
---

# ISS-0006 완료 리포트: FastAPI AI 서버·Spring Boot 멀티모듈 서버와 CI/CD 구성

GitHub #1 `## 개요` 리포트 댓글(2026-04-06) 기준.

## 해결 방법
- AI 서버(`ai/`): `ai/pyproject.toml`(Python 3.13 / uv, FastAPI·uvicorn·pydantic-settings·httpx·qdrant-client), `ai/src/main.py`(lifespan, 요청 처리 시간 미들웨어, Swagger `/docs/swagger`·Redoc `/docs/redoc`), AI 라우터(SQL 오류 설명, diff 해설, 유사 문제 검색), 헬스체크, Ollama·Qdrant 클라이언트, API 키 인증 유틸(`ai/src/utils/auth.py`), `ai/Dockerfile`(Python 3.13-slim, <내부 포트>).
- Spring 서버(`server/`): `server/settings.gradle`에 7개 서브모듈(`PQL-Common`, `PQL-Domain-*` 4개, `PQL-Application`, `PQL-Web`). Spring Boot 3.4.4, Java 21. `PQL-Web`이 실행 모듈(`app.jar`). `server/Dockerfile`(Temurin 21 JRE Alpine, 헬스체크).
- 워크플로우: `PROJECT-PYTHON-AI-CI.yaml`(`ai/**` Docker 빌드 검증), `PROJECT-SPRING-PASSQL-CI.yaml`(`server/**` Gradle 빌드 검증, `-x test`), `PROJECT-PYTHON-AI-CICD.yaml`·`PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`(`deploy` 브랜치 기준 시놀로지 NAS 배포). 환경 변수(`AI_ENV_FILE`, `APPLICATION_PROD_YML`)는 GitHub Secrets에서 주입.

## 근본 원인 (확정)
해당 없음 (기능 이슈).

## 재발 방지
리포트의 주의사항:
- `server/PQL-Web/src/main/resources/application-dev.yml`에 Ollama API 키가 평문으로 포함되어 있어 `.gitignore` 처리 또는 환경변수 분리가 필요하다고 적었다.
- Spring CI는 `-x test`로 테스트를 건너뛴다 — 통합 테스트 환경(MariaDB, Redis 컨테이너) 연동이 필요하다고 적었다.
- `ai/.env`가 Dockerfile COPY 대상이라 이미지에 환경 파일이 들어간다 — 프로덕션은 Docker secret 또는 환경변수 주입 검토를 권장했다.

## 교훈
(원본에 없음, 볼트 정리) `deploy` 브랜치에 push했는데 배포가 안 돌면 먼저 워크플로우 `paths` 필터(`server/**`, `ai/**`)에 해당 변경이 있었는지 본다.
