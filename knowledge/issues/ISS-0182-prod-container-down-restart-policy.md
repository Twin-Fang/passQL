---
type: issue
id: ISS-0182
created: 2026-10-02
topics: [ops-infra, ci-deploy]
symptoms: ["502", "운영 API 다운", passql-back, passql-ai, "재시작 정책 no", unless-stopped, "NAS 재부팅", "7주간 미인지", "/actuator/health"]
root_cause: "NAS 재부팅으로 컨테이너가 graceful shutdown 된 뒤 백엔드 재시작 정책이 `no`라 기동되지 않음 — Spring 배포 워크플로우가 `--restart` 없이 컨테이너를 다시 만들어 정책이 매 배포 초기화"
status: resolved
resolution: "[[ISS-0182-prod-container-down-restart-policy-report]]"
related: ["[[DEC-0092-container-restart-unless-stopped-in-workflow]]", "[[ISS-0184-production-launch-criteria]]"]
source: "https://github.com/Twin-Fang/passQL/issues/337"
---

# ISS-0182: 운영 서버 컨테이너 중단 복구 및 자동 재시작 설정

GitHub #337 (원본: 이슈 본문, 복구 댓글, 재발 방지 리포트 댓글).

## 증상
운영 API(`<API 서버>`)가 502. 2026-10-02 점검: 백엔드(`passql-back`)와 AI(`passql-ai`) 컨테이너가 2026-08-13 19:30경 graceful shutdown 후 약 7주간 종료 상태(크래시·OOM 아님). NAS 부팅 시점과 일치. DB(`postgres`)만 가동. 백엔드 재시작 정책 `no`, AI는 `unless-stopped`인데도 종료 상태였다.

## 재현 조건
`<API 서버>/actuator/health` 호출 → 502. 서버: 시놀로지 NAS(Container Manager).

## 조사 기록
- 2026-10-02: GitHub #324(Flyway 문법)는 수정 커밋이 이미 main에 있어 이번 502 원인이 아님.
- 2026-10-02: 재시작 정책 `unless-stopped`로 변경 후 두 컨테이너 기동, 재배포는 하지 않음(운영 이미지와 main 사이 버전 번호 외 차이 없음).
- 2026-10-07 댓글: deploy 배포(v0.0.245) 직후 `passql-back` 정책이 다시 `no`로 확인됨(원본 본문 표기는 "2026-10-08 deploy 배포"). 배포 워크플로우가 매번 컨테이너를 지우고 `--restart` 없이 다시 만들어 정책이 초기화되고 있었다.

## 근본 원인
`docker update`는 떠 있는 컨테이너에만 적용되고, Spring 배포 워크플로우의 `docker rm -f` → `docker run`(`--restart` 없음)이 다음 배포에서 기본값 `no`로 되돌렸다. AI 워크플로우는 원래 `--restart unless-stopped`를 지정하고 있었다.
