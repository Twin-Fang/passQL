---
type: decision
id: DEC-0090
created: 2026-10-02
reviewed: null
topics: [home, practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0178-app-recommendation-single-solve]]", "[[ISS-0178-app-recommendation-single-solve-report]]", "[[DEC-0062-separate-recommendation-practice-page]]"]
---

# DEC-0090: 앱은 추천 문제 전용 풀이 화면을 만들지 않고 일반 문제 풀이 화면을 그대로 쓴다

## 문제 정의 (Context)
웹은 홈 추천 진입용 단건 풀이 화면 `RecommendationPractice`가 따로 있다. 앱도 같은 흐름이 필요한지 확인해야 했다 (GitHub #333).

## 결정 (Decision)
별도 화면은 만들지 않는다. 앱은 홈 추천 카드를 누르면 이미 같은 문제 풀이 화면으로 이동해 결과 화면·신고·AI 해설을 제공한다. 실제로 빠진 부분(풀이 후 홈·통계 갱신)만 보완한다.

## 검토한 대안 (Alternatives)
- 웹처럼 전용 화면 신설: 웹 `RecommendationPractice`가 "일반 문제 풀이와 같은 화면에 인라인 피드백을 붙인 것"이고 앱은 이미 같은 기능을 제공해 만들지 않음(원본).

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
Flutter 앱 홈 추천 카드 → 문제 풀이 화면 흐름. 웹 `RecommendationPractice`는 그대로.

## 출처 (References)
- GitHub #333 구현 댓글(2026-10-02) "확인한 내용"
