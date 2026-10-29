---
type: issue
id: ISS-0395
created: 2026-10-25
topics: ["home"]
symptoms: ["시험까지 카운트다운 중이에요", "COUNTDOWN", "greeting_section.dart", "exam_schedule_card.dart", "D-일수 중복"]
root_cause: "홈 인사 아래 `COUNTDOWN` 보조 문구가 바로 밑 시험 일정 카드의 D-일수와 같은 정보를 두 번 보여 줬다"
status: resolved
resolution: "[[ISS-0395-home-countdown-badge-cleanup-report]]"
related: ["[[DEC-0179-remove-countdown-keep-exam-day-urgent]]"]
source: "https://github.com/Twin-Fang/passQL/issues/648"
---

# ISS-0395: 홈 첫 화면 인사 아래 시험 카운트다운 보조 문구가 시험 일정 카드와 겹침 (앱)

GitHub #648 (원본: 이슈 본문과 완료 리포트 댓글).

## 증상
홈 첫 화면 인사 아래에 "시험까지 카운트다운 중이에요"가 뜬다(`greeting_section.dart`의 `COUNTDOWN` 문구). 같은 화면에 D-일수가 있는 시험 일정 카드(`exam_schedule_card.dart`)가 이미 있어 정보가 겹치고, 무엇을 세는지 모르는 문장이라 어색하다(사용자 지적).

## 재현 조건
시험 일정이 있는 상태에서 홈 첫 화면 진입 시(원본 서술 기준).

## 조사 기록
- 2026-10-25: 작업 범위 — 앱 홈 인사 보조 문구 정리와 위젯 스모크 테스트 확인. 서버 인사 응답(`messageType`)은 구버전 앱이 읽어 호환을 위해 그대로. `EXAM_DAY`("오늘 시험이에요!")·`URGENT` 유지 여부는 같이 정하기로 함.
- 2026-10-26: 완료 리포트(근거 커밋 `384e7b05`).

## 근본 원인
앱 인사 배지 표시 조건에 `COUNTDOWN`이 포함돼 시험 일정 카드와 같은 정보를 중복 표시했다.
