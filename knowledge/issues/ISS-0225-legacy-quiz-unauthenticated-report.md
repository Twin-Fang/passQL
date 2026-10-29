---
type: completion-report
id: ISS-0225
created: 2026-10-07
topics: [security]
status: resolved
resolves: "[[ISS-0225-legacy-quiz-unauthenticated]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/390"
---

# ISS-0225 완료 리포트: `SecurityConfig` securityMatcher에 `/quiz/**` 추가

GitHub #390 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
`SecurityConfig` securityMatcher에 `/quiz/**` 추가 → JWT 체인에서 인증 필수.

## 근본 원인 (확정)
보안 체인 매처에서 `/quiz/**`가 빠져 있었다.

## 재발 방지
운영 실측: `POST /quiz/start` → HTTP 401 (수정 전 400 `MISSING_PARAMETER`).

## 교훈
(원본에 없음, 볼트 정리) 보안 체인이 `securityMatcher`로 경로를 나눠 덮는 구조에서는, 어느 매처에도 걸리지 않는 경로가 무방비로 남는다. 새 컨트롤러 경로를 만들면 어느 체인에 속하는지 확인한다.
