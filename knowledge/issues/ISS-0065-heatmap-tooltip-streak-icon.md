---
type: issue
id: ISS-0065
created: 2026-04-11
topics: [home, progress-stats]
symptoms: ["학습 현황 툴팁 없음", HeatmapCalendar, "연속 N일", Flame, "빈 불꽃 아이콘", "타임존 하루 밀림", "new Date(\"YYYY-MM-DD\")", toISOString]
root_cause: "학습 현황에 hover 정보가 없고 연속 학습일 불꽃 아이콘이 외곽선뿐이었다. 구현 중 new Date(\"YYYY-MM-DD\") UTC 파싱으로 UTC+9에서 날짜가 하루 밀리는 버그도 발견"
status: resolved
resolution: "[[ISS-0065-heatmap-tooltip-streak-icon-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/113"
---

# ISS-0065: 홈 학습 현황 툴팁 부재와 연속 N일 불꽃 아이콘 강조 부족

GitHub #113 (원본: 이슈 본문과 댓글).

## 증상
홈 "학습 현황"에 마우스를 올려도 총 풀이 수·정답률·streak 같은 추가 정보를 볼 수 없다. "연속 N일" 배지의 lucide-react `Flame` 아이콘이 속이 빈 형태라 강조가 약하다.

## 재현 조건
홈 학습 현황 섹션 hover.

## 조사 기록
- 2026-04-11: 이슈 본문은 `🔥` 이모지 또는 `FlameKindling` 계열로 교체를 제안. 리포트 댓글은 `Flame`에 `fill="currentColor"`로 해결.

## 근본 원인
기능 부재와 아이콘 스타일. 구현 중 날짜 처리의 타임존 버그.
