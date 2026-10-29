---
type: issue
id: ISS-0178
created: 2026-10-02
topics: [home, practice]
symptoms: [RecommendationPractice, "추천 단건 풀이", "풀이 후 홈 히트맵 미갱신", "통계 미갱신", refreshLearningData, "캐시 갱신"]
root_cause: "홈·통계 데이터가 한 번 불러온 뒤 앱이 살아 있는 동안 캐시로 남아 풀이 후 갱신되지 않음"
status: resolved
resolution: "[[ISS-0178-app-recommendation-single-solve-report]]"
related: ["[[DEC-0090-app-no-separate-recommendation-screen]]"]
source: "https://github.com/Twin-Fang/passQL/issues/333"
---

# ISS-0178: 앱 추천 문제 단건 풀이 모드

GitHub #333 (원본: 이슈 본문과 댓글 2개). 선행 GitHub #328.

## 증상
(현재 문제점) 웹은 홈 추천에서 진입하는 단건 풀이 모드(`RecommendationPractice`)가 따로 있고, 앱은 일반 문제 상세로 대체하는지 불확실했다.
조사 중 실제 결함 발견: 문제를 풀고 홈이나 통계로 돌아와도 히트맵·준비도·추천·통계가 갱신되지 않았다(웹 GitHub #290, #261과 같은 증상).

## 재현 조건
앱에서 문제 풀이 → 홈/통계 복귀 → 이전 값 그대로.

## 조사 기록
- 2026-10-02: 웹 `RecommendationPractice`는 일반 문제 풀이와 같은 화면에 인라인 피드백을 붙인 것이고, 앱은 홈 추천 카드를 누르면 이미 같은 풀이 화면(결과, 신고, AI 해설 포함)으로 간다고 확인.

## 근본 원인
홈과 통계 데이터를 앱 수명 동안 캐시로 유지하고 풀이 후 무효화하지 않았다.
