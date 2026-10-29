---
type: issue
id: ISS-0194
created: 2026-10-06
topics: [home]
symptoms: [D+129, 지난 시험 표시, is_selected, exam_schedule, 시험 일정 카드, 인사말 D-day]
root_cause: "서버가 관리자가 선택한 일정(`is_selected = true`)을 날짜와 무관하게 그대로 돌려주고, 시험 후 다음 회차로 바꾸는 운영 절차가 없었다"
status: resolved
resolution: "[[ISS-0194-home-exam-schedule-past-round-report]]"
related: ["[[ISS-0202-top-level-qa-real-account-e2e]]"]
source: "https://github.com/Twin-Fang/passQL/issues/349"
---

# ISS-0194: 홈 시험 일정에 지난 회차(D+129)가 표시됨

GitHub #349 (원본: 이슈 본문과 댓글).

## 증상
홈 시험 일정 카드에 이미 지난 시험이 "D+129 / SQLD 61회 2026년 05월 31일"로 표시된다. 실계정 E2E(iPhone 16 Pro 시뮬레이터, 2026-10-07)에서 발견.

## 재현 조건
로그인 → 홈 시험 일정 카드. 운영 DB `exam_schedule`: 60회 2026-03-07, 61회 2026-05-31(선택됨), 62회 2026-08-22, 63회 2026-11-14.

## 조사 기록
- 2026-10-06: 서버가 `is_selected = true` 일정을 그대로 반환함을 확인.

## 근본 원인
선택된 일정이 지나도 그대로 쓰는 로직과, 다음 회차로 바꾸는 운영 절차 부재.
