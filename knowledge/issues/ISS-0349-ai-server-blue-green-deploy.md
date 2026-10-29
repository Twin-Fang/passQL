---
type: issue
id: ISS-0349
created: 2026-10-21
topics: [ci-deploy, ai]
symptoms: ["AI 서버 배포 중 끊김", "docker rm -f", PROJECT-PYTHON-AI-CICD.yaml, "blue/green", Traefik, "무중단", "AI 기능 실패", passql-ai]
root_cause: "AI 서버 배포가 기존 컨테이너를 docker rm -f로 지운 뒤 새로 띄워 그 사이 AI 기능이 끊겼다"
status: resolved
resolution: "[[ISS-0349-ai-server-blue-green-deploy-report]]"
related: ["[[DEC-0164-ai-server-traefik-blue-green]]"]
source: "https://github.com/Twin-Fang/passQL/issues/564"
---

# ISS-0349: AI 서버 배포를 백엔드와 같은 무중단(blue/green)으로 전환

GitHub #564 (원본: 이슈 본문과 댓글).

## 증상
- AI 서버 배포(`PROJECT-PYTHON-AI-CICD.yaml`)가 기존 컨테이너를 `docker rm -f`로 지운 뒤 새로 띄운다. 그 사이 수 초~수십 초 AI 기능(해설 생성, 유사 문제, 선택지 생성)이 실패한다.
- 백엔드는 Traefik blue/green 무중단(`PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`)인데 AI 서버만 끊긴다.

## 재현 조건
2026-10-21 배포(GitHub #555 배포 중)에서 확인.

## 조사 기록
- 2026-10-21 제안: `passql-ai-blue|green` 두 슬롯, `GET /health` 통과 후 전환, 구 컨테이너 drain 후 종료. projectops 무중단 템플릿은 Spring용(NGINX·TRAEFIK)만 있어 Python용으로 옮김.

## 근본 원인
AI 서버 배포 워크플로우가 정지 후 기동 방식이었다.
