---
type: completion-report
id: ISS-0024
created: 2026-04-08
topics: [admin, ai]
status: resolved
resolves: "[[ISS-0024-admin-pages-ai-redis-settings]]"
related: ["[[DEC-0025-redis-shared-app-settings]]", "[[DEC-0026-sensitive-settings-masked-readonly]]"]
source: "https://github.com/Twin-Fang/passQL/issues/30"
---

# ISS-0024 완료 리포트: 어드민 6개 구현, `th:data-*` 패턴, Redis 공유 설정

GitHub #30 `## 개요` 리포트 댓글(2026-04-08) 기준, 같은 날 "Stable 적용 완료" 댓글.

## 해결 방법
- 어드민 컨트롤러: Topic(subtopics), Prompt(목록 + `/{uuid}` 상세), Concept(태그 목록, 문서 CRUD), Monitor(최근 실행 로그 20건 + 24h 통계), Setting(민감 키 마스킹 조회, PUT 민감 키 403), Question(페이지네이션 + topic/difficulty/executionMode 필터).
- `AppSettingService`: `@Cacheable` 제거 → `StringRedisTemplate` 직접 연동, `passql:settings:{key}`, `isSensitiveKey()`/`maskValue()`.
- `TopicTree`·`SubtopicItem`에 `sortOrder`, `isActive`.
- Thymeleaf: `topics.html`, `exam-schedules.html`을 `th:data-uuid="${item.uuid}"` + `onclick="openModal(this.dataset.uuid)"` 패턴으로 전환.
- `V0_0_23__add_ai_model_settings.sql`: `ai.gemini_model`, `ai.ollama_chat_model`, `ai.ollama_embed_model` 시드(`app_setting_uuid`는 `UUID()`).
- AI 서버: `ai/src/core/config.py`에 `GEMINI_API_KEY`, `GEMINI_MODEL`, `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`, `ENVIRONMENT`에 따라 `.env.dev`/`.env.prod` 선택. `ai/src/services/redis_settings.py` 신규(Redis 우선, 실패 시 `.env` fallback). `redis>=5.0.0`.
- 기타: favicon·로고, `.run/AI-FASTAPI-SERVER.run.xml` SDK_HOME을 공유 venv(`passQL-AI-venv`)로, `.gitignore`에 `.env.dev`/`.env.prod`.

## 근본 원인 (확정)
Thymeleaf 3.1의 `th:onclick` 변수 삽입 제한, `TopicTree` 필드 누락, 서버 간 설정 공유 수단 부재 (리포트).

## 재발 방지
- Thymeleaf 이벤트 핸들러에는 값을 `th:data-*`로 넣고 JS에서 `this.dataset.*`로 읽는다 (리포트 「Thymeleaf 3.1 XSS 버그 패턴」).
- 리포트 주의사항: `V0_0_23` 최초 실행 전 `flyway_schema_history`에 failed 레코드가 있으면 시작 불가 → `DELETE FROM flyway_schema_history WHERE success = 0;`. AI 서버 `.env.dev`/`.env.prod`는 배포 환경에서 별도 생성 필요. `@tailwindcss/browser@4` CDN과 DaisyUI v5 CSS 변수 충돌로 콘솔 TypeError가 나지만 기능 영향 없음.

## 교훈
(원본에 없음, 볼트 정리) 관리자 Thymeleaf 목록이 첫 행만 그려지고 끊기면 `th:onclick`에 문자열/UUID 변수를 직접 넣었는지부터 본다.
