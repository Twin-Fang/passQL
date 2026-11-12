---
type: completion-report
id: ISS-0506
created: 2026-11-12
topics: [notification, admin, home]
status: resolved
resolves: "[[ISS-0506-sqld-exam-schedule-auto-sync]]"
related: ["[[DEC-0293-exam-schedule-rule-based-auto-sync]]"]
source: "https://github.com/Twin-Fang/passQL/issues/991"
---

# ISS-0506 완료 리포트: 공식 일정 규칙 기반 매일 수집, 일정 화면, 자동 알림 5종 운영 켬

## 해결 방법
- 서버 수집: `DataqSchedulePageClient` > `DataqScheduleHtmlParser`(열 위치로 읽기, 연도 결정·연도 넘김, 날짜 표기 변형) > `ExamScheduleSyncService` > `ExamScheduleSyncWriter`(pg advisory lock, 회차 감소 검사, 회차 기준 upsert, 수동 고정 행 건너뜀, 다른 칸만 교체·감사 로그, 공식 칸 `-`면 유지). 매일 06:05 KST `ExamScheduleSyncScheduler`.
- 실패 사유 9종 `ExamScheduleSyncFailureReason`(이름이 DB 저장값). 실패하면 일정은 그대로, `exam_schedule_sync_run`에 사유·원문 일부.
- Flyway `V1_110_1__exam_schedule_sync.sql`: 접수 시작·마감·수험표·사전점수·발표·출처·수동 고정 칸, 수집 기록 테이블.
- 관리자 `exam-schedules.html`: 수집 상태 카드, 지금 수집, 실패 안내, 대시보드 경고 통합.
- 자동 알림 5종 `EXAM_SCHEDULE_PUBLISHED`, `EXAM_APPLICATION_OPEN`, `EXAM_APPLICATION_CLOSING`, `EXAM_ADMISSION_TICKET`, `EXAM_RESULT_ANNOUNCED`(배포 시 기본 꺼짐, 이동 대상 `EXAM_SCHEDULE`).
- API `GET /api/exam-schedules/sqld` + 단계 `ExamSchedulePhase`. 앱 시험 일정 화면(다음 시험 카드·세로 타임라인·시험 정보), 홈 D-day 배지 단계 한 줄·이동.
- PR #1025, 배포 #1026. 보고서 댓글: https://github.com/Twin-Fang/passQL/issues/991#issuecomment-6825818892

## 근본 원인 (확정)
일정 모델과 수집 경로가 없었다. 수동 입력은 수동 고정 행으로 대체 수단에 남았다.

## 재발 방지
- 3개 연도 원본 HTML 테스트(`src/test/resources/dataq/`)가 파서를 고정한다. 표 구조가 바뀌면 수집은 실패 기록으로 멈추고 관리자 경고가 뜬다.
- 검증: server build, app analyze·test 170건, client tsc. 운영 수집 성공(2026년 60~63회 4개 updated), 알림 5종 운영 켬, 실기기 QA(v1.114.0) 통과.
- 남은 결함: [Low] `지난 일정 N건 더 보기` 버튼은 아래, 펼친 일정은 위(QA 세션에서 별건 수정 중). QA 정적 점검 위험(미실행): 발표 전 `nextSchedule` null이면 다음 시험 카드 사라짐, 단계 KST·D-day 기기 날짜 차이, 자정 넘긴 홈 단계 미갱신.

## 교훈
- 외부 HTML을 읽을 때는 열 이름이 아니라 위치로 읽고, 과거 원본을 테스트 자료로 남긴다. 해석이 이상하면 덮어쓰지 말고 기록만 남긴다.
