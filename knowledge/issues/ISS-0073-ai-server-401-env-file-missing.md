---
type: issue
id: ISS-0073
created: 2026-04-11
topics: [ai, ops-infra]
symptoms: ["401 Unauthorized", X-API-Key, AiGatewayClient, "generateChoiceSet fallback 진입", GeminiFallbackClient, AI_SERVER_API_KEY, "config.py", ".env.prod"]
root_cause: "Python AI 서버 config.py가 .env.{env} 파일이 없으면 AI_SERVER_API_KEY를 빈 문자열로 로드 — prod 이미지에는 .env만 복사돼 .env.prod가 없었다"
status: resolved
resolution: "[[ISS-0073-ai-server-401-env-file-missing-report]]"
related: ["[[ISS-0076-ai-metadata-model-field-mismatch]]"]
source: "https://github.com/Twin-Fang/passQL/issues/125"
---

# ISS-0073: Python AI 서버 호출이 매번 401 Unauthorized

GitHub #125 (원본: 이슈 본문과 리포트 댓글).

## 증상
Spring `AiGatewayClient`가 `X-API-Key` 헤더(`passql.ai-server.api-key`)로 Python AI 서버를 부르면 매 요청 `401 Unauthorized`. 로그: `ERROR [AiGateway] Python AI 서버 호출 실패: ... error=401 Unauthorized on POST request`, `WARN [AiGateway] generateChoiceSet fallback 진입`. `GeminiFallbackClient`로 우회돼 서비스는 유지되지만 주 AI 서버가 동작하지 않는 상태.

## 재현 조건
`POST /api/questions/{questionUuid}/generate-choices` 호출 후 서버 로그 확인.

## 조사 기록
- 2026-04-11: 리포트 댓글에서 원인 확정(아래).

## 근본 원인
`ai/src/core/config.py`는 `ENVIRONMENT`(기본 `dev`)로 `.env.{env}`를 읽는다. prod는 Dockerfile이 `COPY .env ./`로 `.env`만 복사해 `.env.prod`가 없고, dev도 로컬에 `.env.dev`가 없으면 같다. 결과 `AI_SERVER_API_KEY`가 `""`로 로드돼 Spring 헤더와 불일치.
