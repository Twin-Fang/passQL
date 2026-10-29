---
type: issue
id: ISS-0113
created: 2026-04-12
topics: [community]
symptoms: ["건의사항 API", "POST /feedback", "GET /feedback/me", FeedbackStatus, "404 fallback", X-Member-UUID]
root_cause: "설정 화면 건의사항 UI(GitHub #198)는 있는데 백엔드 API가 없었다"
status: resolved
resolution: "[[ISS-0113-feedback-api-implementation-report]]"
related: ["[[DEC-0069-settings-tab-rows-only-subpages]]"]
source: "https://github.com/Twin-Fang/passQL/issues/200"
---

# ISS-0113: 건의사항 API 구현 요청

GitHub #200 (원본: 이슈 본문과 댓글).

## 증상
설정 화면 건의사항 제출·조회 UI(GitHub #198)는 있으나 백엔드 API가 없다. 프론트는 404 시 빈 목록으로 임시 fallback 중.

## 재현 조건
해당 없음 (기능 추가).

## 조사 기록
- 2026-04-12: 이슈 등록. 명세: `POST /feedback`(`content` 1~500자, 400/401), `GET /feedback/me`(`createdAt` 내림차순, 건의사항이 없으면 `404`가 아니라 `200 + { "items": [] }` 필수, 401). FeedbackStatus `PENDING`/`REVIEWED`/`APPLIED`, 상태 변경은 관리자만, 프론트는 읽기 전용.
- 2026-04-13: 댓글 "건의사항은 따로 페이지에서 관리해야될것같습니다" → GitHub #209로 분리([[DEC-0069-settings-tab-rows-only-subpages]]).
- 2026-04-13: 댓글 "GitHub #218 해당 문제가 발견되어 수정중" — feedback UUID 컬럼 타입 불일치 500.
- 2026-04-13: 관리자 `/admin/feedbacks` 화면 확인 요청(스크린샷), 이어서 "개선 완료".

## 근본 원인
백엔드 API 미구현.
