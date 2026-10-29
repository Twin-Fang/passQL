---
type: completion-report
id: ISS-0065
created: 2026-04-11
topics: [home, progress-stats]
status: resolved
resolves: "[[ISS-0065-heatmap-tooltip-streak-icon]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/113"
---

# ISS-0065 완료 리포트: 히트맵 셀 툴팁(hover·long press)과 채워진 불꽃 아이콘

GitHub #113 `## 개요` 리포트 댓글(2026-04-11) 기준.

## 해결 방법
- `Home.tsx`: 연속 N일 배지 `<Flame>`에 `fill="currentColor"`.
- `HeatmapCalendar.tsx`: 셀별 커스텀 툴팁(날짜·풀이 수·정답률). 데스크톱 `onMouseEnter/Leave`, 모바일 500ms long press(`onTouchMove`로 취소해 스크롤 오인 방지). `getBoundingClientRect()` 차이로 컨테이너 기준 위치 계산. `buildDayMap`을 `Map<string, HeatmapEntry>`로 바꿔 `correctCount` 사용. `formatDateKo`·`dayLabel`은 문자열 슬라이싱, `getLast30Days`는 로컬 타임존 기준 생성. `useMemo` 적용.

## 근본 원인 (확정)
툴팁 기능 부재. 날짜 버그는 `new Date("YYYY-MM-DD")`가 UTC 자정으로 파싱돼 UTC+9에서 하루 밀린 것.

## 재발 방지
리포트 주의사항: 툴팁은 `pointer-events-none`. 풀이가 없는 날은 "풀이 없음"으로 0 나누기 방지.

## 교훈
(원본에 없음, 볼트 정리) 날짜 문자열을 `new Date()`나 `toISOString()`으로 다루면 KST에서 하루 밀릴 수 있다 — 표시는 문자열 슬라이싱, 생성은 로컬 타임존 기준으로.
