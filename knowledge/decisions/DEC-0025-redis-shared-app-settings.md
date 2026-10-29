---
type: decision
id: DEC-0025
created: 2026-04-08
reviewed: null
topics: [ai, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0024-admin-pages-ai-redis-settings]]", "[[ISS-0024-admin-pages-ai-redis-settings-report]]", "[[DEC-0032-gemini-key-runtime-from-settings]]", "[[DEC-0125-embedding-model-env-only]]"]
---

# DEC-0025: Spring이 `app_setting`을 Redis(`passql:settings:{key}`)에 쓰고 AI 서버가 읽어 설정을 공유

## 문제 정의 (Context)
Spring 서버와 AI 서버 사이에 설정값(모델명 등)을 공유할 수단이 없어 각자 하드코딩하거나 별도 `.env`로 관리했다 (GitHub #30).

## 결정 (Decision)
Spring이 `app_setting` 테이블에 값을 저장하고 `passql:settings:{key}` Redis 키로 동기화한다. AI 서버는 Redis에서 먼저 조회하고 연결 실패 시 `.env` 기본값으로 fallback한다. 모델명 등 런타임 변경이 필요한 설정은 어드민 UI에서 수정하면 즉시 Redis에 반영된다. `AppSettingService`는 `@Cacheable`을 제거하고 `StringRedisTemplate`을 직접 쓴다.

## 검토한 대안 (Alternatives)
- 각 서버 하드코딩 또는 별도 `.env` 관리(기존 상태): 공유 수단이 없다는 문제로 대체.
- `@Cacheable`: 제거하고 Redis 직접 연동으로 전환. 제거 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 리포트: 어드민에서 수정하면 즉시 Redis에 반영.

**부정**
- AI 서버는 Redis 장애 시 `.env` 기본값으로 동작한다 (fallback 설계).

## 영향 범위 (Scope)
`AppSettingService`, `ai/src/services/redis_settings.py`, `ai/src/core/config.py`, `app_setting` 시드(`V0_0_23`). 이후 GitHub #47이 Gemini API 키도 같은 경로로 관리하도록 확장했다.

## 출처 (References)
- GitHub #30 이슈 본문, `## 개요` 리포트 댓글 「Redis 공유 설정 구조」 (2026-04-08)
