---
type: decision
id: DEC-0164
created: 2026-10-21
reviewed: null
topics: [ci-deploy, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0349-ai-server-blue-green-deploy]]", "[[ISS-0349-ai-server-blue-green-deploy-report]]"]
---

# DEC-0164: AI 서버도 백엔드와 같은 Traefik blue/green으로 배포하고 drain은 75초

## 문제 정의 (Context)
AI 서버 배포가 컨테이너를 지운 뒤 새로 띄워 배포마다 AI 기능이 끊겼다. 백엔드는 이미 Traefik blue/green 무중단이었다 (GitHub #564).

## 결정 (Decision)
- `passql-ai-blue|green` 두 슬롯, healthy + Traefik 경유 200 확인 후 전환, 구 슬롯 drain 후 제거. 백엔드 워크플로우를 Python 서버(<내부 포트>, `/health`)에 맞춰 옮긴다.
- 공개 주소 `<AI 서버 도메인>`는 DSM 리버스 프록시에서 Traefik(`localhost:<내부 포트>`)을 가리킨다.
- drain 대기는 백엔드(25초)보다 긴 75초. 리포트가 적은 이유: "AI 호출 중 가장 긴 해설 생성(약 50초)이 끝날 시간을 둔다."

## 검토한 대안 (Alternatives)
논의 기록 없음. (projectops 무중단 템플릿은 Spring용이라 쓰지 않고 백엔드 워크플로우를 옮겼다고만 적었다.)

## 결과 (Consequences)
**긍정**
- 배포 중 0.5초 간격 요청 414건 전부 200.

**부정**
- 이미지 태그가 `deploy`라 롤백은 이전 이미지를 다시 푸시해야 한다.
- 긴 bulk 색인 도중 배포하면 색인이 끊길 수 있다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-PYTHON-AI-CICD.yaml`, DSM 리버스 프록시 설정(코드 밖), 시놀로지 Traefik(`traefik-network`).

## 출처 (References)
- GitHub #564 리포트 댓글(2026-10-21)
- 관련 기존 결정: DEC-0111(백엔드 Traefik Blue-Green 무중단) — 같은 방식을 AI 서버로 넓힌 것.
- [[ISS-0349-ai-server-blue-green-deploy]]
