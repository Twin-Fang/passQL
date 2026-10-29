---
type: decision
id: DEC-0108
created: 2026-10-08
reviewed: null
topics: [admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0243-selected-exam-schedule-past-dday-plus]]", "[[ISS-0243-selected-exam-schedule-past-dday-plus-report]]"]
---

# DEC-0108: 시험 일정은 자동 추가하지 않고 관리자가 공식 공고를 보고 넣는다 — 관리자 화면이 확인 시점을 알린다

GitHub #411 (원본: 운영 조치 댓글과 `## 개요` 리포트 댓글).

## 문제 정의 (Context)
선택된 시험 회차가 지난 제61회로 남아 홈 D-day가 D+로 보였다. 2027년 일정은 아직 공고 전이었다.

## 결정 (Decision)
- 매년 날짜가 바뀌어 시험 일정 자동 추가는 하지 않는다. 관리자가 공식 공고를 보고 직접 회차를 추가하고 선택을 바꾼다.
- 대신 관리자 화면이 확인 시점을 알린다: 다가오는 시험이 없으면 오류, 마지막 등록 회차가 60일(`WARN_DAYS`) 이내면 경고, 공고 확인일(`exam.announcement_checked_at`)이 없거나 30일이 넘으면 "확인 필요". 대시보드에 경고·오류 배너.

## 검토한 대안 (Alternatives)
- 자동 추가: 하지 않음. 원본 이유: "매년 날짜가 바뀌어", "자동으로 가져올 수 없어".
- 이슈 본문의 재발 방지 제안 중 "홈에서 '시험 종료 — 다음 일정을 선택하세요' 표시"는 구현 기록이 없다. 채택하지 않은 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 선택 회차 만료와 다음 회차 미등록이 관리자 화면에 드러난다.

**부정 / 조건**
- 관리자가 공고를 확인하고 직접 넣어야 한다. 제63회(2026-11-14)가 끝난 뒤 선택이 다시 지난 회차로 남지 않도록 추가와 선택 변경이 필요하다 (원본 「남은 일」).
- 공고가 평소 더 일찍 나온다면 `WARN_DAYS`(60일)를 늘린다 (원본 「주의사항」).

## 영향 범위 (Scope)
`ExamScheduleCoverageService`·`ExamCoverage`, `AdminExamScheduleController`, `exam-schedules.html`, `AdminDashboardController`·`dashboard.html`, 설정 키 `exam.announcement_checked_at`(Flyway V0_4_2).

## 출처 (References)
- GitHub #411 운영 조치 댓글(2026-10-08), `## 개요` 리포트 댓글(v0.5.0, PR #444)
- [[ISS-0243-selected-exam-schedule-past-dday-plus]]
