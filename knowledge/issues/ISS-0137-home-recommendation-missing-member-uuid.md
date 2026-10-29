---
type: issue
id: ISS-0137
created: 2026-04-13
topics: [home, ai]
symptoms: ["추천 항상 랜덤", "/api/questions/recommendations", memberUuid, fetchRecommendations, useRecommendations, "RANDOM fallback", RecommendationService]
root_cause: "프론트 `fetchRecommendations()`가 `memberUuid`를 보내지 않아 백엔드가 항상 RANDOM fallback으로 동작"
status: resolved
resolution: "[[ISS-0137-home-recommendation-missing-member-uuid-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/253"
---

# ISS-0137: 홈 AI 추천이 오답 기록과 무관하게 항상 랜덤

GitHub #253 (원본: 이슈 본문과 리포트 댓글).

## 증상
홈 추천(`/api/questions/recommendations`)이 오답 기록이 있는 사용자에게도 항상 랜덤 문제를 반환한다. Qdrant 기반 개인화 추천(GitHub #248)이 동작하지 않는다.

## 재현 조건
오답을 남긴 사용자로 홈 진입 → 추천 섹션 새로고침 반복 → 오답과 무관한 랜덤 문제. Spring 로그에 `[recommendation] AI 추천 실패` / `AI 추천 결과 없음`이 보이지 않는다(AI 추천 경로 자체를 타지 않음).

## 조사 기록
- 2026-04-13: `client/src/api/questions.ts` `fetchRecommendations()`에 `memberUuid` 파라미터 없음, `client/src/hooks/useHome.ts` `useRecommendations()`가 `memberStore` uuid를 쓰지 않음.

## 근본 원인
프론트가 `memberUuid`를 전달하지 않았다.
