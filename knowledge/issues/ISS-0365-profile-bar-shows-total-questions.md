---
type: issue
id: ISS-0365
created: 2026-10-24
topics: [progress-stats]
symptoms: ["카테고리별 문제 수", "막대가 가득 참", totalQuestionCount, solvedCount, bar_chart_section.dart, "레이더 차트 0%와 어긋남", "내 프로필"]
root_cause: "앱 bar_chart_section.dart가 TopicStat.totalQuestionCount를 막대 길이와 숫자로 쓰고 solvedCount를 쓰지 않았다"
status: resolved
resolution: "[[ISS-0365-profile-bar-shows-total-questions-report]]"
related: ["[[DEC-0174-never-show-total-question-count]]"]
source: "https://github.com/Twin-Fang/passQL/issues/609"
---

# ISS-0365: 내 프로필 카테고리별 막대가 푼 문제가 아닌 전체 문제 수를 보여줌

GitHub #609 (원본: 이슈 본문과 댓글).

## 증상
내 프로필 탭 "카테고리별 문제 수" 막대가 사용자가 푼 문제가 아니라 카테고리별 전체 등록 문제 수(35, 28, 49 …)를 보여 준다. 아무것도 안 푼 계정에서도 막대가 가득 차 있고 레이더 차트(0%)와 어긋난다.

## 재현 조건
아무 문제도 풀지 않은 계정으로 내 프로필 탭을 연다.

## 조사 기록
- 2026-10-24: 원인 `app/lib/presentation/widgets/stats/bar_chart_section.dart`가 `TopicStat.totalQuestionCount` 사용. 웹(`StatsBarChart.tsx`)은 이미 `solvedCount`.
- 2026-10-24 사용자 결정: 막대는 푼 문제 수 기준 상대 비율, 전체 문제 수는 어디에서도 보여 주지 않음.

## 근본 원인
앱 막대 차트가 잘못된 필드(`totalQuestionCount`)를 읽었다.
