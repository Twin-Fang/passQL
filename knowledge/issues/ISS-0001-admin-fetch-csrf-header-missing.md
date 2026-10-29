---
type: issue
id: ISS-0001
created: 2026-10-07
topics: [admin, security]
symptoms: [CSRF, 403, "관리자 fetch", X-CSRF-TOKEN, _csrf 메타, "상태 변경 실패"]
root_cause: "관리자 화면 fetch(PUT/POST/DELETE)가 CSRF 헤더를 보내지 않음 — #283에서 legal.html만 고쳐 나머지 화면이 남아 있었다"
status: resolved
resolution: "[[ISS-0001-admin-fetch-csrf-header-missing-report]]"
related: ["[[DEC-0008-admin-csrf-common-fetch-wrapper]]"]
source: "https://github.com/Twin-Fang/passQL/issues/391"
---

# ISS-0001: 관리자 화면 fetch 요청에 CSRF 헤더가 없어 상태 변경이 403으로 실패

GitHub #391 (원본: 이슈 본문과 댓글).

## 증상
관리자 체인은 CSRF 보호가 켜져 있는데, 화면 대부분의 `fetch`가 CSRF 헤더를 보내지 않는다. `layout.html`에 `_csrf` 메타는 있지만 헤더를 실제로 넣는 화면은 `legal.html`뿐. 피드백 처리, 토픽·설정·개념 수정, 시험 일정, 데일리 챌린지, 회원·신고 처리, 문제 등록·가져오기 등에서 403. `choice-set-detail.html`은 응답을 보지 않고 새로고침만 해서 실패가 화면에 드러나지 않았다.

## 재현 조건
관리자 로그인 → 피드백 화면 상태 변경 → 403. 비인증 상태에서도 변경 요청이 302가 아니라 403(CSRF 필터가 먼저 막음). 헤더 누락 위치 18곳(`feedbacks.html`, `topics.html`, `settings.html`, `concepts.html`, `question-import-export.js` 등).

## 조사 기록
- 2026-10-08: 운영 E2E QA에서 curl로 비인증 PUT → 403 확인. 로그인 후 실측은 자격증명이 없어 보류.

## 근본 원인
화면별로 fetch를 직접 쓰고 헤더 부착을 각자에게 맡긴 구조. 한 화면(#283)만 고치고 공통 처리가 없었다.
