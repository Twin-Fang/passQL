---
type: completion-report
id: ISS-0047
created: 2026-04-11
topics: [progress-stats, ai]
status: resolved
resolves: "[[ISS-0047-topic-analysis-ai-comment-impl]]"
related: ["[[DEC-0042-ai-comment-cache-evict-on-submit]]", "[[DEC-0043-topic-correct-rate-last-7-days]]"]
source: "https://github.com/Twin-Fang/passQL/issues/79"
---

# ISS-0047 완료 리포트: `/api/progress/topic-analysis`와 `/api/progress/ai-comment`

GitHub #79 이슈 본문(구현 리포트)과 "정상 적용 확인 완료" 댓글(2026-04-11) 기준.

## 해결 방법
- DTO: `TopicStat`, `TopicAnalysisResponse`(PQL-Domain-Submission), `AiCommentResponse`(PQL-Domain-AI).
- `SubmissionRepository.findTopicStatsAfter()`(최근 7일, `ROW_NUMBER() PARTITION BY question_uuid`로 문제별 최근 1회), `QuestionRepository.countActiveByTopic()`.
- `TopicAnalysisService`: 활성 토픽 전체 기준으로 머지해 이력 없는 토픽도 0으로 포함.
- `AiCommentService`(PQL-Application): Redis 조회 → miss 시 `GeminiClient` 호출(system/user 프롬프트 분리) → Redis 저장(TTL 24h). `evictCache(memberUuid)`를 `SubmissionService.submit()` 완료 후 호출.
- `ProgressController`에 두 엔드포인트 추가, `/heatmap` 복구. `AiCommentServiceTest` 통합 테스트 2개.

## 근본 원인 (확정)
기능 미구현.

## 재발 방지
본문 주의사항: `correctRate`는 0~1 소수. `totalQuestionCount`는 전체 활성 문제 수, `solvedCount`는 최근 7일 풀이 수. `/ai-comment` 첫 호출은 Gemini 응답 시간만큼 지연될 수 있어 1·2번 API를 먼저 렌더링하고 비동기로 채우기를 권장.

## 교훈
논의 기록 없음.
