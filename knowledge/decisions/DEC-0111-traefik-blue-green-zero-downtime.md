---
type: decision
id: DEC-0111
created: 2026-10-08
reviewed: null
topics: [ci-deploy, ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0246-backend-traefik-blue-green-deploy]]", "[[ISS-0246-backend-traefik-blue-green-deploy-report]]"]
---

# DEC-0111: 백엔드 배포는 시놀로지 기존 Traefik(8079) 경유 Blue-Green 무중단 방식으로 한다

## 문제 정의 (Context)
`docker rm -f` → `docker run` 배포로 매 배포 약 45초 502가 났다 (GitHub #423).

## 결정 (Decision)
시놀로지에 이미 있던 Traefik(8079, `traefik-network`) 구성을 그대로 따라(RomRom·suh-project-utility와 같은 방식) `passql-back-blue|green` Blue-Green으로 배포한다. 새 색이 healthy + Traefik 경유 200일 때만 구 색을 drain(25초) 후 제거하고, 실패하면 구 색이 계속 서비스한다. DSM 리버스 프록시는 8079(Traefik)를 가리킨다.

## 검토한 대안 (Alternatives)
논의 기록 없음. (이전 방식은 `docker rm -f` → `docker run` 직결 8097.)

## 결과 (Consequences)
**긍정**
- 배포 중 non-200 0건 (drain 25초 기준 220 프로브).
- 실패한 배포에서도 구 색이 그대로 서비스.

**부정**
- 논의 기록 없음. (원본의 주의점: 헬스체크에 `X-Forwarded-Proto: https`가 필요, drain 대기가 짧으면 전환 순간 요청 실패.)

## 영향 범위 (Scope)
백엔드 배포 워크플로(`PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`, #436 원본 표기), DSM 리버스 프록시 443/80 항목, 컨테이너 `passql-back-blue|green`.

## 출처 (References)
- GitHub #423 완료 댓글 (PR #424, #430, #431, #432)
- [[ISS-0246-backend-traefik-blue-green-deploy]]
