---
type: issue
id: ISS-0340
created: 2026-10-20
topics: [design-system]
symptoms: ["진행 막대", "가운데서 자람", "회색 트랙 안 보임", PassqlProgressBar, passql_progress_bar.dart, Stack, readiness_card, chapter_app_bar]
root_cause: "PassqlProgressBar의 Stack에 너비가 없어 채움 폭만큼만 잡히고 부모 Column이 가운데 정렬했다"
status: resolved
resolution: "[[ISS-0340-progress-bar-grows-from-center-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/552"
---

# ISS-0340: 진행 막대가 가운데서 자라고 회색 트랙이 안 보임

GitHub #552 (원본: 이슈 본문과 댓글).

## 증상
진행 막대가 왼쪽부터 차지 않고 가운데에서 양쪽으로 자라며 회색 트랙(전체 길이)이 보이지 않는다. 1/10일 때 가운데 짧은 선만 보인다. 사용처: 풀이 상단 `chapter_app_bar`, 홈 `readiness_card`(합격 준비도), `fallback_stats_section`, `exam_trend_sections`(`bar_chart_section`은 Expanded 안이라 정상).

## 재현 조건
앱 홈 > 오늘의 세트 시작 > 상단 진행 막대(1/10, 6/10). 홈 합격 준비도 카드 막대. iOS 18.3 시뮬레이터, main 0e2fda60.

## 조사 기록
- 2026-10-20: 원인 위치 `app/lib/presentation/design/components/passql_progress_bar.dart`.

## 근본 원인
막대가 높이만 고정하고 폭을 정하지 않아, 가운데 정렬 Column 안에서 Stack이 채움 폭만큼만 잡혔다.
