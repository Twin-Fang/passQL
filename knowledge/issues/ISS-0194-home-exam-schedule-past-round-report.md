---
type: completion-report
id: ISS-0194
created: 2026-10-06
topics: [home]
status: resolved
resolves: "[[ISS-0194-home-exam-schedule-past-round]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/349"
---

# ISS-0194 완료 리포트: 선택된 시험이 지났으면 다가오는 가장 가까운 시험을 쓴다

GitHub #349 완료 댓글 기준 (커밋 `6804833`). `## 개요` 형식 리포트는 없음.

## 해결 방법
`ExamScheduleService.findEffectiveSchedule()` 추가 — 선택된 시험이 지났으면 다가오는 가장 가까운 시험을 쓴다. 시험 카드와 인사말이 같은 기준을 쓴다.

## 근본 원인 (확정)
선택된 일정을 날짜 확인 없이 반환.

## 재발 방지
단위 테스트 5개(`ExamScheduleEffectiveTest`), 서버 테스트 전부 통과. 배포 후 실제 앱: D+129 / 61회 → D-38 / SQLD 63회(2026-11-14).

## 교훈
(원본에 없음, 볼트 정리) 관리자가 고른 값에 시간 조건이 걸려 있으면, 운영자가 바꾸기 전까지의 기본 동작을 서버가 정해 둔다.
