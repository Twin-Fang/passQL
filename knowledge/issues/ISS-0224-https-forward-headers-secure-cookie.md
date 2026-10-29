---
type: issue
id: ISS-0224
created: 2026-10-07
topics: [security, ops-infra]
symptoms: ["HTTPS 전환 누락", X-Forwarded-Proto, "location: http://", JSESSIONID, "Secure 없음", SameSite, forward-headers-strategy, "DSM 리버스 프록시"]
root_cause: "`application.yml`에 `server.forward-headers-strategy`·세션 쿠키 설정이 없었고, DSM 80 항목이 리다이렉트가 아니라 `X-Forwarded-Proto: https`를 붙여 프록시했다"
status: resolved
resolution: "[[ISS-0224-https-forward-headers-secure-cookie-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/389"
---

# ISS-0224: HTTPS 전환 누락으로 관리자 로그인이 평문 제공되고 세션 쿠키에 `Secure`가 없음

GitHub #389 (원본: 이슈 본문과 댓글 2개).

## 증상
- `<API 서버>` 요청이 HTTPS로 넘어가지 않고 관리자 로그인 화면까지 평문으로 응답.
- 앱이 프록시의 `X-Forwarded-Proto`를 반영하지 않아 HTTPS 요청에도 리다이렉트를 `http://`로 만듦(`/admin` → `http://.../admin/login`). 처음 방문한 브라우저는 로그인 직후 세션 쿠키를 평문으로 보낼 수 있다.
- 관리자 세션 쿠키 `JSESSIONID`에 `Secure`·`SameSite` 없음.

## 재현 조건
운영 E2E QA(2026-10-08, passql-back v0.0.245). `curl -sD- -o/dev/null <API 서버>/admin/login` → `HTTP/1.1 200` + 쿠키, `https://.../admin` → `location: <API 서버>/admin/login`.

## 조사 기록
- 2026-10-07: 원인 `server/PQL-Web/src/main/resources/application.yml`에 `server.forward-headers-strategy`·세션 쿠키 설정 없음.
- 2026-10-08: `http://` 직접 접속이 남은 원인 — DSM `passQL-BE 80→443` 항목이 리다이렉트가 아니라 HTTPS 백엔드를 프록시하면서 `X-Forwarded-Proto: https`까지 붙였다.

## 근본 원인
앱의 프록시 헤더 미반영·쿠키 속성 누락과, 리버스 프록시의 80 포트 처리(리다이렉트 대신 https 헤더를 붙인 프록시) 두 가지.
