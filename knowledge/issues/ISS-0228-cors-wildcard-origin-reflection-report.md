---
type: completion-report
id: ISS-0228
created: 2026-10-07
topics: [security]
status: resolved
resolves: "[[ISS-0228-cors-wildcard-origin-reflection]]"
related: ["[[DEC-0103-cors-service-domain-allowlist]]"]
source: "https://github.com/Twin-Fang/passQL/issues/394"
---

# ISS-0228 완료 리포트: 허용 Origin을 `cors.allowed-origin-patterns` 설정으로

GitHub #394 완료 댓글 기준 (PR #407, 운영 v0.0.247). `## 개요` 형식 리포트는 없음.

## 해결 방법
`SecurityConfig.corsConfigurationSource()` 허용 Origin을 설정(`cors.allowed-origin-patterns`)에서 읽도록 변경. 기본값: passql.vercel.app, passql-*.vercel.app, localhost.

## 근본 원인 (확정)
와일드카드 Origin + credentials 허용.

## 재발 방지
운영 실측: `Origin: https://evil.example` → 403, `Origin: https://passql.vercel.app` → 200 + `access-control-allow-origin: https://passql.vercel.app`.

## 교훈
원본에 적혀 있지 않다.
