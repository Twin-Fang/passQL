---
type: completion-report
id: ISS-0399
created: 2026-10-26
topics: [notification, admin]
status: resolved
resolves: "[[ISS-0399-auto-notification-preview-days]]"
related: ["[[ISS-0396-duolingo-style-return-notifications]]"]
source: "https://github.com/Twin-Fang/passQL/issues/656"
---

# ISS-0399 완료 리포트: 미리보기가 일수 입력값으로 `{days}` 치환

GitHub #656 리포트 댓글 기준 (커밋 `4a83ea3d`, PR #657, v1.50.1부터 배포).

## 해결 방법
`server/.../static/js/admin/auto-notifications.js`: 미리보기 문구의 `{days}`를 일수 입력값으로 치환하고, 일수 입력의 `input` 이벤트에 미리보기 다시 그리기를 연결.

## 근본 원인 (확정)
미리보기 치환이 규칙의 일수를 쓰지 않고 3으로 바꿨다.

## 재발 방지
미리보기는 화면 안의 치환이고 실제 발송 문구는 서버가 같은 규칙으로 만든다. 템플릿 자리표시자를 늘리면 서버 치환과 이 JS 치환을 함께 고쳐야 한다(리포트 주의할 점).

## 교훈
(원본에 없음, 볼트 정리) 관리자 미리보기와 실제 발송 문구가 다르면 JS 치환과 서버 치환이 같은 자리표시자를 다루는지부터 본다.
