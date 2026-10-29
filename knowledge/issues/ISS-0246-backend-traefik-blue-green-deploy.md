---
type: issue
id: ISS-0246
created: 2026-10-08
topics: [ci-deploy, ops-infra]
symptoms: [배포 중 502, "docker rm -f", 무중단 배포, Traefik, Blue-Green, "8097 직결"]
root_cause: "백엔드 배포가 `docker rm -f` → `docker run` 순서라 새 서버 기동(약 45초) 동안 API가 502를 반환"
status: resolved
resolution: "[[ISS-0246-backend-traefik-blue-green-deploy-report]]"
related: ["[[DEC-0111-traefik-blue-green-zero-downtime]]"]
source: "https://github.com/Twin-Fang/passQL/issues/423"
---

# ISS-0246: 백엔드 배포 중 약 45초 502 — Traefik Blue-Green 무중단 배포 전환

GitHub #423 (원본: 이슈 본문과 완료 댓글).

## 증상
백엔드 배포가 `docker rm -f` → `docker run` 순서라 새 서버 기동(약 45초) 동안 API가 502를 반환한다. 2026-10-08 하루 배포 4회 모두 해당. 시놀로지에는 이미 Traefik(8079, `traefik-network`)으로 RomRom·suh-project-utility가 Blue-Green 운영 중인데 passQL만 8097 직결이었다.

## 재현 조건
백엔드 배포가 돌 때마다 발생 (컨테이너 교체 구간).

## 조사 기록
- 2026-10-08: 이슈 본문에 projectops `PROJECT-SPRING-NONSTOP-TRAEFIK-CICD` 흐름으로 교체, DSM 리버스 프록시 `<API 서버>` 대상 내부 포트 전환 전환, DSM HTTP→HTTPS 리다이렉트(#389 잔여) 확인을 제안.

## 근본 원인
구 컨테이너를 먼저 지우고 새 컨테이너를 띄우는 배포 순서, Traefik을 거치지 않는 8097 직결 구성.
