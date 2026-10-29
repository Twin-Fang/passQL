---
type: issue
id: ISS-0026
created: 2026-04-08
topics: [dev-workflow]
symptoms: ["API 스펙 변경", "Long ID", UUID, X-User-UUID, X-Member-UUID, "be-api-docs.json v0.0.3", "breaking change"]
root_cause: "백엔드 Entity UUID 통일(GitHub #22)로 API 스펙이 바뀌었는데 프론트는 구 스펙(Long ID, `X-User-UUID`)으로 동작했다"
status: resolved
resolution: "[[ISS-0026-frontend-sync-api-v003-report]]"
related: ["[[DEC-0023-uuid-primary-keys-all-tables]]"]
source: "https://github.com/Twin-Fang/passQL/issues/35"
---

# ISS-0026: be-api-docs.json v0.0.3 API 스펙 변경 프론트 반영

GitHub #35 (원본: 이슈 본문과 댓글).

## 증상
GitHub #22(Entity UUID 통일)로 API 스펙이 크게 바뀌었으나 프론트(`src/api/`, `src/types/`, `src/stores/`)는 구 스펙으로 동작했다. 변경: 모든 Entity ID Long → UUID, 인증 헤더 `X-User-UUID` → `X-Member-UUID`, submit body 필드명 변경(`selectedKey` → `selectedChoiceKey`). 신규 API 4개(today, recommendations, home/greeting, exam-schedules) 미반영.
제안: `api-guide.md`(이미 v0.0.3 동기화, 커밋 `10223aa`)를 single source of truth로 삼아 타입 → API 함수 → 스토어/훅 → 페이지 → 라우팅(`/questions/:id` → `/questions/:questionUuid`) 순서로 반영.

## 재현 조건
구 스펙 프론트로 UUID 기반 백엔드 API를 호출 (이슈 본문).

## 조사 기록
- 2026-04-09: 담당자 변경 댓글.
- 2026-04-11: "Stable 적용 완료. 작업완료로 변경합니다" 댓글.

## 근본 원인
백엔드 스펙의 breaking change가 프론트에 반영되지 않았다 (이슈 본문).
