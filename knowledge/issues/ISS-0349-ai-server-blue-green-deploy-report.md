---
type: completion-report
id: ISS-0349
created: 2026-10-21
topics: [ci-deploy, ai]
status: resolved
resolves: "[[ISS-0349-ai-server-blue-green-deploy]]"
related: ["[[DEC-0164-ai-server-traefik-blue-green]]"]
source: "https://github.com/Twin-Fang/passQL/issues/564"
---

# ISS-0349 완료 리포트: AI 서버 Traefik blue/green, 배포 중 요청 414건 전부 200

GitHub #564 리포트 댓글(`## 개요`, 2026-10-21) 기준.

## 해결 방법
- `.github/workflows/PROJECT-PYTHON-AI-CICD.yaml`: 배포 단계를 blue/green으로 교체(헬스 `curl /health`, Traefik 경유 확인, drain 75초, 로그 보관, concurrency로 동시 배포 차단). 실패 시 새 색 제거, 구 색 계속 서비스.
- 운영 설정(코드 밖): DSM 리버스 프록시 `<AI 서버 도메인>`(443) 백엔드 `localhost:<내부 포트>` > `localhost:<내부 포트>`(Traefik). 전환 전 설정 백업 `(NAS 경로 생략)`.
- 구 단일 컨테이너 `passql-ai`(8098) 로그 보관(`(NAS 경로 생략)`) 후 제거.
- 순서: 새 슬롯을 Traefik에 먼저 띄움 > DSM을 Traefik으로 전환 > 구 컨테이너로 가는 요청 0건 확인 > 구 컨테이너 제거.

## 근본 원인 (확정)
정지 후 기동 배포 방식.

## 재발 방지
- 검증: 첫 실행 `passql-ai-green` healthy·Traefik 경유 200·공개 주소 200. 두 번째 실행(green > blue) 동안 0.5초 간격 공개 주소 요청 414건 전부 200. 백엔드 로그 AI 관련 ERROR/WARN 없음.
- 주의: 이미지 태그가 브랜치 이름(`deploy`)이라 롤백은 이전 이미지를 다시 푸시해야 한다(sha 태그 롤백 입력 없음). DSM 프록시를 8098로 되돌리면 구 컨테이너가 없어 장애. 긴 bulk 색인(수 분) 도중 배포하면 75초 뒤 구 슬롯이 내려가 색인이 끊길 수 있어 색인 중에는 배포하지 않는다.

## 교훈
(원본에 없음, 볼트 정리) 무중단 전환의 drain 시간은 그 서버의 가장 긴 요청 시간 기준으로 잡는다.
