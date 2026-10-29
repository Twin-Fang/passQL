---
type: completion-report
id: ISS-0231
created: 2026-10-07
topics: [auth-member]
status: resolved
resolves: "[[ISS-0231-web-invalid-access-token-stuck-home]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/398"
---

# ISS-0231 완료 리포트: 리프레시 토큰 없는 401도 토큰 정리 후 `/login`

GitHub #398 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
401인데 리프레시 토큰이 없으면 토큰을 정리하고 로그인 화면으로 이동(이슈 「예상 동작」). 구체적인 코드 변경은 원본에 적혀 있지 않다.

## 근본 원인 (확정)
`if (!refreshToken) throw err;` 분기에 정리·이동이 없었다.

## 재발 방지
운영 실측: 무효 액세스 토큰만 넣고 `/` 접속 → URL `https://passql.vercel.app/login`, localStorage 토큰 `null`.

## 교훈
(원본에 없음, 볼트 정리) 인증 실패 처리는 리프레시 토큰이 있는 경로와 없는 경로를 모두 확인한다.
