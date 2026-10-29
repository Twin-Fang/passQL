---
type: issue
id: ISS-0399
created: 2026-10-25
topics: [notification, admin]
symptoms: ["자동 알림 미리보기", "{days}", "3일 만이에요", auto-notifications.js, "미리보기와 실제 발송 문구 다름"]
root_cause: "관리자 미리보기가 {days}를 규칙의 일수 입력값이 아닌 고정값 3으로 치환했다"
status: resolved
resolution: "[[ISS-0399-auto-notification-preview-days-report]]"
related: ["[[ISS-0396-duolingo-style-return-notifications]]"]
source: "https://github.com/Twin-Fang/passQL/issues/656"
---

# ISS-0399: 자동 알림 관리자 미리보기가 규칙의 일수를 반영하지 않음

GitHub #656 (원본: 이슈 본문과 댓글).

## 증상
관리자 자동 알림 화면의 잠금 화면 미리보기가 `{days}`를 항상 3으로 바꿔 보여준다. 긴 미접속(7일) 규칙도 "3일 만이에요"로 보인다(실제 발송 문구와 다름).

## 재현 조건
관리자 > 자동 알림 > 긴 미접속(7일) 규칙 카드의 미리보기 확인.

## 조사 기록
- 2026-10-26: `auto-notifications.js` 미리보기 치환 수정 (PR #657).

## 근본 원인
미리보기 치환이 일수 입력칸 값을 쓰지 않았다.
