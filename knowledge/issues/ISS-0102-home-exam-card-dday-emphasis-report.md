---
type: completion-report
id: ISS-0102
created: 2026-04-12
topics: [home]
status: resolved
resolves: "[[ISS-0102-home-exam-card-dday-emphasis]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/184"
---

# ISS-0102 완료 리포트: 인디고 D-day 카드와 시험 일정 우선 배치

GitHub #184 `## 개요` 리포트 댓글 기준 (2026-04-12).

## 해결 방법
`client/src/pages/Home.tsx`:
- 시험 일정 카드를 `bg-brand` 배경 카드로 교체, D-day `text-3xl font-bold`, 시험 이름 상단·날짜 하단, 우상단/우하단 반투명 원(`bg-white/10`, `bg-white/5`).
- D-day 계산: 오늘과 시험일을 `setHours(0, 0, 0, 0)`으로 정규화 후 밀리초 차이 / 86400000. 양수 `D-N`, 당일 `D-Day`, 이후 `D+N`. 클라이언트에서 계산한다.
- 배치: 시험 일정(왼쪽/위) → 오늘의 문제(오른쪽/아래).

## 근본 원인 (확정)
원본에 적혀 있지 않다 (UI 개선).

## 재발 방지
리포트 주의사항: `schedule === null`이면 기존 fallback 카드 유지. D-day는 클라이언트 로컬 시간 기준이라 타임존 차이 환경에서 하루 오차 가능.

## 교훈
(원본에 없음, 볼트 정리) D-day 계산을 프론트에서 하고 있다 — 백엔드가 계산해 내려준다는 기존 원칙(DEC-0015)과 어긋나 보이므로 manifest `conflicts`에 올렸다.
