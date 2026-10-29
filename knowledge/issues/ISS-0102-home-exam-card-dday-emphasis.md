---
type: issue
id: ISS-0102
created: 2026-04-12
topics: [home]
symptoms: ["시험 일정 카드", D-day, Home.tsx, "카드 배치 순서", "선택된 일정 없음"]
root_cause: "홈 시험 일정 카드가 날짜 텍스트만 표시해 정보 전달력이 낮았다"
status: resolved
resolution: "[[ISS-0102-home-exam-card-dday-emphasis-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/184"
---

# ISS-0102: 홈 시험 일정 카드 D-day 강조와 배치 순서 변경

GitHub #184 (원본: 이슈 본문, 스크린샷·리포트 댓글).

## 증상
홈 시험 일정 카드(`SQLD 61회 / 2026-05-31`)가 날짜 텍스트만 표시되어 허전하고 정보 전달력이 낮다. 오늘의 문제 카드보다 뒤에 배치되어 있다.

## 재현 조건
해당 없음 (기능 개선).

## 조사 기록
- 2026-04-12: 이슈 등록. 기대: `D-49`/`D-Day`/`D+N` 크게, 시험 이름 상단·날짜 하단, `bg-brand` 카드에 반투명 장식 원 2개, 순서 시험 일정 → 오늘의 문제, 일정 없으면 기존 fallback 카드 유지.

## 근본 원인
원본에 적혀 있지 않다 (UI 개선 요청).
