---
type: decision
id: DEC-0042
created: 2026-04-10
reviewed: null
topics: [progress-stats, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0047-topic-analysis-ai-comment-impl]]", "[[ISS-0047-topic-analysis-ai-comment-impl-report]]", "[[ISS-0044-topic-analysis-ai-comment-api]]"]
---

# DEC-0042: AI 영역 분석 코멘트는 별도 API로 Redis 24시간 캐싱하고, 제출 시 직접 evict한다

## 문제 정의 (Context)
통계 화면의 AI 코멘트는 LLM 호출이라 느리고, 풀이가 바뀌면 코멘트도 갱신돼야 했다 (GitHub #71 제안, #79 구현).

## 결정 (Decision)
- AI 코멘트는 `/api/progress/ai-comment` 별도 엔드포인트로 분리하고 프론트는 비동기로 채운다. #71 본문 이유: LLM 호출 latency.
- `memberUuid` 기준 Redis 캐시, TTL 24시간. `SubmissionService.submit()` 완료 시 `aiCommentService.evictCache(memberUuid)`를 호출해 무효화한다.

## 검토한 대안 (Alternatives)
- Submission count 비교(`lastSubmissionCount` 저장 후 현재 수와 비교, #71 본문 제안): #79는 "Submission count 비교 대신 이벤트 기반 evict 방식을 채택"했고 이유로 "별도 카운트 컬럼 없이 단순하게 무효화할 수 있다"를 적었다.

## 결과 (Consequences)
**긍정**
- 별도 카운트 컬럼이 필요 없다. evict가 누락돼도 TTL 24시간 뒤 자동 갱신된다(#79).

**부정**
- 캐시 cold start 첫 호출은 Gemini 응답 시간만큼 지연된다.

## 영향 범위 (Scope)
`AiCommentService`, `SubmissionService.submit()`, `ProgressController`, 프론트 `PracticeResult.tsx`(GitHub #101에서 `staleTime`을 24시간으로 맞춤).

## 출처 (References)
- GitHub #71 이슈 본문 「AI 코멘트 캐싱 전략」, GitHub #79 이슈 본문 「AI 코멘트 캐싱 전략」
