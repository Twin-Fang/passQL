---
type: issue
id: ISS-0506
created: 2026-11-12
topics: [notification, admin, home]
symptoms: ["시험 일정 수동 입력", "접수 기간 없음", "접수 시작 알림 없음", "dataq schedule.do", "table_schdule_all", "ExamScheduleSyncService", "DataqScheduleHtmlParser", "exam_schedule_sync_run", "시험 일정 수집 실패", "지난 일정 더 보기 위치"]
root_cause: "시험 일정을 관리자가 시험일·회차만 손으로 넣어 접수·수험표·발표 일정이 없었고, 그래서 접수·발표 알림과 일정 화면을 만들 수 없었다"
status: resolved
resolution: "[[ISS-0506-sqld-exam-schedule-auto-sync-report]]"
related: ["[[DEC-0293-exam-schedule-rule-based-auto-sync]]", "[[DEC-0108-exam-schedule-manual-entry-with-checks]]", "[[ISS-0019-exam-schedule-domain-api]]", "[[DEC-0190-exam-dday-in-top-bar]]"]
source: "https://github.com/Twin-Fang/passQL/issues/991"
---

# ISS-0506: SQLD 시험 일정 자동 수집과 일정 화면, 접수 알림

GitHub #991. 원본 사본: `_sources/issues/ISS-0506-sqld-exam-schedule-auto-sync.md`(로컬).

## 증상
- 시험 일정은 관리자가 손으로 넣는다(#411). 시험일과 회차만 저장해 접수 기간·수험표 발급·사전점수 공개·합격 발표 일정이 없다.
- 자동 알림은 시험 D-30·D-7·D-1뿐이라 접수 시작·마감 알림을 보낼 수 없다.
- 앱에는 가장 가까운 시험 D-day만 있고 올해 일정 전체나 접수 기간을 볼 곳이 없다.

## 재현 조건
상시. 공식 일정은 데이터자격검정 `https://www.dataq.or.kr/www/accept/schedule.do` HTML 표 하나(`table.table_schdule_all`)에만 있고 JSON API가 없다.

## 조사 기록
- 2026-11-12: 2024·2025·2026 페이지가 같은 표 구조·열 순서. 2024는 열 이름이 다르고 "N년도 일정" 제목이 없음. 날짜에 연도 없음(`2.2~6`, `2.3~2.7`, `3.7(토)`, `-`).
- 2026-11-12: 수집 방식 확정 댓글 — AI(LLM) 해석 없이 규칙 기반 파서만, 3개 연도 원본을 테스트 기준 자료로 고정, 실패하면 덮어쓰지 않고 관리자에 사유 표시.
- 2026-11-12: PR #1025(서버 1eba2c52, 앱 68e4060f), 배포 #1026.

## 근본 원인
일정 데이터 모델이 시험일·회차뿐이었고 공식 일정을 읽는 경로가 없었다.
