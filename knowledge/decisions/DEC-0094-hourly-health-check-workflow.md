---
type: decision
id: DEC-0094
created: 2026-10-02
reviewed: null
topics: [ops-infra]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0184-production-launch-criteria]]", "[[ISS-0184-production-launch-criteria-report]]", "[[ISS-0182-prod-container-down-restart-policy]]"]
---

# DEC-0094: 운영 감시는 별도 서버 없이 1시간 주기 GitHub 워크플로우 헬스체크(`PASSQL-HEALTH-CHECK`)로 한다

## 문제 정의 (Context)
NAS 재부팅 장애를 7주간 인지하지 못했다(GitHub #337). 출시 기준에 헬스 모니터링과 장애 알림이 필요했다 (GitHub #339).

## 결정 (Decision)
`PASSQL-HEALTH-CHECK` 워크플로우가 1시간마다 `/actuator/health`와 `/api/meta/topics`(DB 조회)를 확인한다. 일시적 502에 대비해 3회 재시도 후 실패하면 워크플로우가 실패 처리되어 GitHub 알림이 간다. 원본: "이번 NAS 재부팅 장애(7주간 미인지)와 같은 일을 막기 위한 최소 감시. 별도 서버 불필요".

## 검토한 대안 (Alternatives)
논의 기록 없음. (별도 모니터링 서버를 두지 않는다는 점만 원본에 있다.)

## 결과 (Consequences)
**긍정**
- 별도 서버 없이 다운을 1시간 단위로 감지한다(원본).

**부정**
- 2026-10-07 진행 댓글에 "장애 알림(헬스 실패 시 알림 채널 연결)"이 남은 항목으로 적혀 있다 — 알림은 GitHub 워크플로우 실패 알림에 의존.

## 영향 범위 (Scope)
`.github/workflows/`의 `PASSQL-HEALTH-CHECK`, 운영 `/actuator/health`, `/api/meta/topics`.

## 출처 (References)
- GitHub #339 진행 댓글(2026-10-02, 2026-10-07)
