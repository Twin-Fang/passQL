---
type: completion-report
id: ISS-0243
created: 2026-10-16
topics: [admin, home]
status: resolved
resolves: "[[ISS-0243-selected-exam-schedule-past-dday-plus]]"
related: ["[[DEC-0108-exam-schedule-manual-entry-with-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/411"
---

# ISS-0243 완료 리포트: 선택 회차 제63회로 변경 + 공식 공고 확인 패널·대시보드 경고

GitHub #411 운영 조치 댓글, `## 개요` 리포트 댓글(2026-10-08), 완료 처리 댓글(2026-10-16) 기준.

## 해결 방법
- 운영 조치(2026-10-08): 선택 회차 제61회(2026-05-31) → 제63회(2026-11-14).
- 재발 방지 기능 v0.5.0(PR #444):
  - `ExamScheduleCoverageService`·`ExamCoverage`(신규): 자격증별 다가오는 시험, 마지막 등록 회차, 선택 회차가 지났는지 계산. SQLD는 일정이 없어도 평가, 다른 자격증은 일정이 있을 때만.
  - 판단 기준: 다가오는 시험이 없으면 오류, 마지막 등록 회차가 60일 이내면 경고, 그 외 정상.
  - 공고 확인일: 설정 키 `exam.announcement_checked_at`(Flyway V0_4_2, 카테고리 `EXAM`). 기록이 없거나 30일이 넘으면 "확인 필요".
  - `AdminExamScheduleController`: 패널 데이터와 `POST /admin/exam-schedules/announcement-checked`.
  - `exam-schedules.html`: "공식 공고 확인" 패널(상태, 다가오는 시험·D-day, 선택 회차 만료 안내, 공식 일정 링크, 공고 확인함 버튼).
  - `AdminDashboardController`·`dashboard.html`: 경고·오류가 있을 때만 상단 알림 배너.

## 근본 원인 (확정)
시험 날짜는 매년 바뀌고 자동으로 가져올 수 없어 관리자가 직접 넣어야 하는데, 언제 확인해야 하는지 알려 주는 장치가 없었다.

## 재발 방지
- `ExamScheduleCoverageServiceTest` 7/7, 기존 `ExamScheduleEffectiveTest` 5/5, `compileTestJava` 통과.
- 운영(v0.5.0): 패널에 SQLD 경고 "마지막 등록 회차 제63회(2026-11-14)가 37일 남았습니다", D-37 표시, 공식 링크 `rel="noopener noreferrer"`, 대시보드 경고 배너 1건, 390px 가로 넘침 없음.
- 주의: "공고 확인함" 버튼은 운영 설정값을 바꾸므로 검증에서 누르지 않았다. 경고 기준(60일)은 상수 `WARN_DAYS`. 2027년 일정은 공고 후 추가.
- 2026-10-16 완료 댓글: 운영 관리자 화면에서 제63회가 선택돼 있는지는 이번에 확인하지 않았다.

## 교훈
(원본에 없음, 볼트 정리) 웹 홈 D-day는 관리자가 고른 선택 회차를 따른다. D+가 보이면 데이터(선택 회차)부터 확인한다.
