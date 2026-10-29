---
type: completion-report
id: ISS-0246
created: 2026-10-08
topics: [ci-deploy, ops-infra]
status: resolved
resolves: "[[ISS-0246-backend-traefik-blue-green-deploy]]"
related: ["[[DEC-0111-traefik-blue-green-zero-downtime]]"]
source: "https://github.com/Twin-Fang/passQL/issues/423"
---

# ISS-0246 완료 리포트: Traefik Blue-Green 전환, 배포 중 non-200 0건

GitHub #423 완료 댓글 기준 (PR #424, #430, #431, #432). `## 개요` 형식 리포트는 없음.

## 해결 방법
- 배포 job을 Blue-Green으로 교체: `passql-back-blue|green`, `--restart unless-stopped`, 배포 동시 실행 방지. 새 색 기동 → healthy + Traefik 경유 200 확인(4분 초과 시 실패, 구 색 유지) → 구 색 drain 표식 25초 대기 → 구 색 제거.
- DSM 443 항목 `localhost:<내부 포트>` → `localhost:<내부 포트>`(Traefik), 구 `passql-back`(8097) 컨테이너 삭제.
- DSM 80 항목도 Traefik으로 → HTTP는 301로 https 리다이렉트 (#389).

## 근본 원인 (확정)
이슈 본문과 같음. 전환 중 겪은 문제 두 가지:
- 배포 헬스체크 타임아웃(#430 배포): Traefik이 헤더 없는 평문 요청에 `X-Forwarded-Proto: http`를 붙여 리다이렉트 라우터(301)에 걸림 → 헬스체크에 `X-Forwarded-Proto: https` (#431).
- 전환 순간 요청 1건 실패: drain 후 구 컨테이너가 unhealthy(약 15초)로 빠지기 전 10초에 제거 → drain 대기 25초 (#432).

## 재발 방지
운영 가용성 실측(배포 중 1초 간격 `GET /actuator/health`): 첫 전환 + 실패한 배포 600 프로브 non-200 0, drain 10초 210 프로브 중 1 (`000`), drain 25초(최종) 220 프로브 non-200 **0**. 이전 방식은 배포마다 약 45초 502.

## 교훈
(원본에 없음, 볼트 정리) Traefik 뒤 헬스체크가 타임아웃이면 `X-Forwarded-Proto` 헤더로 리다이렉트 라우터에 걸리는지, 전환 순간 실패가 있으면 drain 대기가 unhealthy 전환 시간보다 짧은지 먼저 본다.
