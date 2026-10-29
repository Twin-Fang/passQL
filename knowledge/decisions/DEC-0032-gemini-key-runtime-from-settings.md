---
type: decision
id: DEC-0032
created: 2026-04-09
reviewed: null
topics: [ai, security]
status: superseded
supersedes: null
superseded_by: DEC-0133
related: ["[[ISS-0033-gemini-key-dynamic-db-redis]]", "[[DEC-0025-redis-shared-app-settings]]", "[[DEC-0026-sensitive-settings-masked-readonly]]", "[[DEC-0133-encrypted-gemini-key-single-source]]"]
---

# DEC-0032: Gemini API Key를 `app_setting`(`ai.gemini_api_key`)·Redis로 관리하고 AI 서버는 호출마다 동적 조회

## 문제 정의 (Context)
키 변경 시 재시작이 필요했고, AI 서버가 시작 시 키를 고정 주입받았으며, 로그 평문 노출 위험이 있었다 (GitHub #47).

## 결정 (Decision)
- `app_setting`에 `ai.gemini_api_key`를 추가한다(`V0_0_29__add_gemini_api_key_setting.sql`). 이슈 본문은 "관리자 페이지에서 키를 관리할 수 있도록" 한다고 적었다.
- `AppInitializer`가 서버 시작 시 `application.yml`의 키를 DB/Redis로 초기 적재한다 (값이 이미 있으면 스킵).
- AI 서버 `GeminiClient`는 `__init__` 고정 주입 대신 `_get_client()`에서 호출마다 `redis_settings.get_gemini_api_key()`로 키를 조회한다.
- Redis 설정 로그에서 `key`, `secret`, `password`, `token` 포함 키는 `***`로 마스킹한다.

## 검토한 대안 (Alternatives)
- 환경변수 고정 + 시작 시 주입(기존): 재시작 필요·런타임 교체 불가로 대체.

## 결과 (Consequences)
**긍정**
- 이슈 본문: 재시작 없이 키 교체.

**부정**
- 논의 기록 없음.
- (원본 기록) GitHub #30은 `key`가 들어간 설정을 어드민 UI에서 마스킹하고 PUT을 403으로 막는다고 했다 — [[DEC-0026-sensitive-settings-masked-readonly]]. "관리자 페이지에서 키를 관리"와의 조정 방식은 원본에 적혀 있지 않다.

## 영향 범위 (Scope)
`V0_0_29__add_gemini_api_key_setting.sql`, `AppInitializer.java`, `ai/src/services/redis_settings.py`, `ai/src/services/gemini_client.py`.

## 출처 (References)
- GitHub #47 이슈 본문
