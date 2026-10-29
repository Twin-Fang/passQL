---
type: completion-report
id: ISS-0224
created: 2026-10-08
topics: [security, ops-infra]
status: resolved
resolves: "[[ISS-0224-https-forward-headers-secure-cookie]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/389"
---

# ISS-0224 완료 리포트: `forward-headers-strategy: framework`·`Secure; SameSite=Lax` + Traefik HTTP→HTTPS 리다이렉트

GitHub #389 완료 댓글 2개 기준 (PR #407 운영 v0.0.247, PR #430·#431). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 앱(PR #407): `application.yml` `server.forward-headers-strategy: framework`, 세션 쿠키 `secure: true`·`same-site: lax`.
- 서버 밖(PR #430, #431):
  - DSM 80 항목: 대상 `localhost:<내부 포트>`(Traefik), 헤더 `X-Forwarded-Proto: http` (DSM API로 변경, `ReverseProxy.json` 백업 `ReverseProxy.json.bak-20261008-passql`).
  - Traefik 라벨: `Host(api.passql…) && Header(X-Forwarded-Proto, http)` 라우터(우선순위 1000) + `redirectScheme https permanent`.
  - DSM 443 항목도 Traefik(8079)으로 전환 — 무중단 배포(GitHub #423)와 함께.

## 근본 원인 (확정)
앱이 프록시 헤더를 반영하지 않았고 쿠키 속성이 없었다. DSM 80 항목은 리다이렉트가 아니라 `X-Forwarded-Proto: https`를 붙인 프록시라 `http://`로 와도 앱이 https로 알았다.

## 재발 방지
운영 실측: `https://.../admin` → 302 `location: https://.../admin/login`, 쿠키 `Secure; HttpOnly; SameSite=Lax`. `http /admin/login`·`/api/meta/legal/TERMS_OF_SERVICE`·`/actuator/health` → 301 https, `https /actuator/health` → 200.

## 교훈
(원본에 없음, 볼트 정리) 프록시 뒤 앱에서 https 판정이 틀리면 앱 설정과 함께 프록시가 실제로 붙이는 `X-Forwarded-Proto` 값을 확인한다.
