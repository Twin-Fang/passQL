---
type: completion-report
id: ISS-0153
created: 2026-04-24
topics: [home, ai]
status: resolved
resolves: "[[ISS-0153-recommendation-refresh-session-dedupe]]"
related: ["[[DEC-0083-session-scoped-recommendation-exclusion]]"]
source: "https://github.com/Twin-Fang/passQL/issues/284"
---

# ISS-0153 완료 리포트: `excludeQuestionUuids` 복수 파라미터로 세션 내 중복 제외

GitHub #284 구현 완료 리포트(2026-04-24, PR #286) 기준. "동작 방식" 절은 비어 있다.

## 해결 방법
- `QuestionRepository`: `findRandomActiveExcludingList()` — `CAST(question_uuid AS varchar) NOT IN (:excludeUuids)` 패턴.
- `QuestionService`: `getRecommendations()` 시그니처 `UUID` → `List<UUID>`, DailyChallenge 자동 제외 유지.
- `RecommendationService`: `recommend()`/`tryAiRecommend()` 시그니처 변경, AI mustNotIds에 리스트 전체 추가.
- `QuestionController`: `@RequestParam` 단수 → 복수 List, String→UUID 변환.
- 프론트 `src/api/questions.ts`: `excludeQuestionUuids?: string[]`, 같은 키 반복 append 직렬화. `src/hooks/useHome.ts`: `useRecommendations(excludeUuids)`, queryKey 포함. `src/pages/Home.tsx`: `seenUuids` state 누적, 새로고침 시 전달.

## 근본 원인 (확정)
세션 내 이미 본 문제를 제외하는 경로가 없었다.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
논의 기록 없음.
