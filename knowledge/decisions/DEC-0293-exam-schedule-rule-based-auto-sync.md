---
type: decision
id: DEC-0293
created: 2026-11-12
reviewed: null
topics: [admin, notification]
status: active
supersedes: DEC-0108
superseded_by: null
related: ["[[DEC-0108-exam-schedule-manual-entry-with-checks]]", "[[ISS-0506-sqld-exam-schedule-auto-sync]]", "[[ISS-0506-sqld-exam-schedule-auto-sync-report]]"]
---

# DEC-0293: SQLD 시험 일정은 공식 일정 페이지를 규칙 기반으로 매일 자동 수집하고, 해석이 이상하면 덮어쓰지 않는다 — 수동 입력은 대체 수단

GitHub #991 (이슈 본문, 「수집 방식 확정」 댓글).

## 문제 정의 (Context)
[[DEC-0108-exam-schedule-manual-entry-with-checks]]는 "매년 날짜가 바뀌어 자동으로 가져올 수 없어" 관리자 수동 입력을 택했다. 수동 입력은 시험일·회차뿐이라 접수·수험표·발표 일정이 없고, 접수 시작·마감 알림을 보낼 수 없었다. 이슈 #991 본문이 공식 페이지 자동 갱신과 "수동 입력은 대체 수단으로 남긴다"를 명시했다.

## 결정 (Decision)
- 공식 페이지 `dataq.or.kr/www/accept/schedule.do`의 `table.table_schdule_all`을 서버가 하루 1번(06:05 KST) 읽는다.
- AI(LLM) 해석은 쓰지 않고 규칙 기반 파서만 쓴다. 열 이름이 아닌 열 위치로 읽고, 연도는 "N년도 일정" 제목과 현재 날짜로 정한다.
- 2024·2025·2026 원본을 테스트 기준 자료로 고정한다.
- 해석 실패·결과 이상(표 없음, 열 개수 다름, SQL 개발자 행 없음, 날짜 해석 실패, 회차 줄어듦 등)이면 일정은 덮어쓰지 않고 관리자 화면에 사유·원문 일부·마지막 성공 시각을 보여 준다.
- 수동 입력은 대체 수단(수동 고정 행은 수집이 건너뜀). 바뀐 값은 변경 이력에 남긴다.

## 검토한 대안 (Alternatives)
- AI(LLM) 해석: 쓰지 않음(「수집 방식 확정」 댓글). 이유는 원본에 적혀 있지 않다.
- 관리자 수동 입력 유지([[DEC-0108-exam-schedule-manual-entry-with-checks]]): 접수·발표 일정이 없어 알림·일정 화면을 만들 수 없음(이슈 본문 현재 문제점).

## 결과 (Consequences)
**긍정**
- 접수·수험표·발표 일정과 그 자동 알림 5종, 앱 시험 일정 화면이 가능해졌다.
- 공식 페이지가 바뀌어도 잘못된 값으로 덮어쓰지 않는다.

**부정**
- 공식 페이지 표 구조가 바뀌면 수집이 멈추고 파서를 고쳐야 한다(그동안 수동 입력).

## 영향 범위 (Scope)
`server/PQL-Domain-Meta` 수집(`DataqScheduleHtmlParser`, `ExamScheduleSyncService`, `ExamScheduleSyncWriter`), `ExamScheduleSyncScheduler`, 관리자 `/admin/exam-schedules`, 자동 알림 규칙, `GET /api/exam-schedules/sqld`, 앱 시험 일정 화면.

## 출처 (References)
- GitHub #991 이슈 본문·「수집 방식 확정」 댓글(2026-11-12), PR #1025
