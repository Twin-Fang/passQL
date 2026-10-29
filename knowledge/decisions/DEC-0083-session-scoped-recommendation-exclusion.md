---
type: decision
id: DEC-0083
created: 2026-04-24
reviewed: null
topics: [home, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0153-recommendation-refresh-session-dedupe]]", "[[ISS-0153-recommendation-refresh-session-dedupe-report]]", "[[DEC-0077-rag-recommendation-with-random-fallback]]", "[[DEC-0084-recommendation-exclusion-post-body-fifo]]"]
---

# DEC-0083: 추천 새로고침은 이번 세션에서 본 문제만 제외하고, 푼 문제 영구 제외는 하지 않는다

## 문제 정의 (Context)
같은 쿼리 벡터에서 Qdrant가 같은 Top-K를 돌려줘 새로고침해도 같은 추천이 나왔다(GitHub #284).

## 결정 (Decision)
새로고침마다 이번 세션에서 이미 추천된 문제를 `excludeQuestionUuids`로 보내 제외한다. 세션은 React state(`seenUuids`)라 브라우저 새로고침 시 초기화된다. 이미 푼 문제 전체의 영구 제외는 범위 밖으로 둔다.

## 검토한 대안 (Alternatives)
- 이미 푼 문제 전체 영구 제외: "문제 고갈 방지"를 이유로 범위 밖(이슈 본문).
- 그 밖의 대안: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 새로고침이 "다른 문제 보고 싶다"는 목적과 맞는다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`QuestionController`, `QuestionService`, `QuestionRepository`, `RecommendationService`, 클라이언트 `src/api/questions.ts`, `src/hooks/useHome.ts`, `src/pages/Home.tsx`.

## 출처 (References)
- GitHub #284 이슈 본문 「해결 방안」, 구현 완료 리포트(2026-04-24, PR #286)
