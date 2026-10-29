---
type: completion-report
id: ISS-0002
created: 2026-10-08
topics: [security]
status: resolved
resolves: "[[ISS-0002-auth-response-body-logged-plaintext]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/396"
---

# ISS-0002 완료 리포트: 인증 엔드포인트 본문 로그 기록 중단

GitHub #396 완료 댓글 기준 (PR #407, 운영 v0.0.247, 2026-10-08). `## 개요` 형식 리포트는 없음.

## 해결 방법
원본 완료 댓글에는 변경 방식이 적혀 있지 않다(PR #407 참고). 이슈의 예상 동작은 인증 엔드포인트(`auth/login`, `auth/reissue`, `admin/login`)의 요청·응답 본문을 로그에 남기지 않는 것이고, 수정 후 실측(아래)으로 확인됐다.

## 근본 원인 (확정)
원본 완료 댓글에 원인 서술은 없음. 이슈 본문 기준: 응답 본문 평문 기록 + 제외 패턴에 인증 엔드포인트 없음.

## 재발 방지
운영 실측(수정 후): admin/login 응답 CSRF 기록 0, auth/login 요청 본문(idToken) 기록 0. 수정 전에는 같은 요청에 `_csrf` 토큰 2줄.

## 교훈
(원본에 없음, 볼트 정리) 새 인증·결제 엔드포인트를 추가하면 로깅 제외 목록에 넣었는지 확인한다. 로그에 토큰·idToken이 찍히는지 운영 로그 grep으로 검증한다.
