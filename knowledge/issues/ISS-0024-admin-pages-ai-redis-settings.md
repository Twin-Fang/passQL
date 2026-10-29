---
type: issue
id: ISS-0024
created: 2026-04-08
topics: [admin, ai]
symptoms: ["어드민 컨트롤러 TODO", "th:onclick", "Thymeleaf 3.1 XSS", "1행만 렌더링", "TopicTree SpEL 예외", "AI 서버 Gemini 키 없음", "설정 공유 수단 없음"]
root_cause: "어드민 컨트롤러가 TODO 상태였고, Thymeleaf 3.1이 `th:onclick`의 String/UUID 변수 삽입을 막아 루프가 중단됐으며, Spring·AI 서버 간 설정 공유 수단이 없었다"
status: resolved
resolution: "[[ISS-0024-admin-pages-ai-redis-settings-report]]"
related: ["[[DEC-0025-redis-shared-app-settings]]", "[[DEC-0026-sensitive-settings-masked-readonly]]"]
source: "https://github.com/Twin-Fang/passQL/issues/30"
---

# ISS-0024: 관리자 페이지 전체 구현 및 AI 서버 Redis 설정 연동

GitHub #30 (원본: 이슈 본문과 댓글).

## 증상
- 어드민 6개(topics, prompts, concepts, monitor, settings, questions) 컨트롤러가 TODO라 실제 데이터를 조회하지 못했다.
- Thymeleaf 3.1 XSS 정책 때문에 `th:onclick`에 UUID/String 변수를 쓰면 루프가 중단되어 페이지가 1행만 렌더링됐다.
- `TopicTree` record에 `sortOrder`, `isActive`가 없어 Thymeleaf SpEL 예외가 났다.
- AI 서버가 Gemini API key와 모델명을 갖고 있지 않아 LLM 호출이 불가했다.
- Spring 서버와 AI 서버 간 설정값(모델명 등) 공유 수단이 없었다 — 각자 하드코딩 또는 별도 `.env`.

## 재현 조건
`th:onclick`에 `${item.uuid}`를 문자열로 이어 붙인 목록 화면을 열면 1행만 렌더링 (이슈 본문·리포트).

## 조사 기록
- 2026-04-08: `## 개요` 리포트 댓글 (아래 리포트).
- 2026-04-08: "Stable 적용 완료" 댓글.

## 근본 원인
- 화면: Thymeleaf 3.1부터 `th:onclick`에 String/UUID 변수를 직접 삽입하면 XSS 정책으로 루프 전체가 중단된다 (리포트).
- `TopicTree` record 필드 누락.
- 설정: 공유 저장소 부재.
