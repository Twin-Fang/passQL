---
type: issue
id: ISS-0282
created: 2026-10-15
topics: [ops-infra]
symptoms: [평문 로그, logback 설정 없음, "--log-opt max-size 없음", 로그 무한 증가, 회원 행동 이벤트 로그 없음]
root_cause: "logback 설정 없이 stdout 평문 로그만 있었고, `docker run`에 로그 크기 제한이 없었으며, 회원 행동 이벤트 로그가 없었다"
status: resolved
resolution: "[[ISS-0282-json-logs-rotation-activity-events-report]]"
related: ["[[DEC-0128-prod-json-logs-activity-events]]"]
source: "https://github.com/Twin-Fang/passQL/issues/476"
---

# ISS-0282: 서버 로그가 평문뿐이고 크기 제한·행동 이벤트 기록이 없음

GitHub #476 (원본: 이슈 본문, 구현 보고서 댓글).

## 증상
- logback 설정 없이 stdout 평문 로그만 있음.
- `docker run`에 `--log-opt max-size`가 없어 배포 사이에 로그가 계속 커질 수 있음.
- 회원 행동 이벤트 로그가 없음.
- 위치: `server/PQL-Web/src/main/resources/application.yml:24`, `.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml:149-155`.

## 재현 조건
해당 없음(기능 개선).

## 조사 기록
- 2026-10-15: 제안 — JSON 로그(`rid`, `mid` 포함)와 로그 로테이션, 주요 행동 이벤트(로그인, 제출, 세트 완료 등) 기록.

## 근본 원인
frontmatter `root_cause`와 같음.
