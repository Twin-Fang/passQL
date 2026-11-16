---
type: decision
id: DEC-0335
created: 2026-11-16
reviewed: null
topics: [progress-stats, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]", "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]", "[[DEC-0042-ai-comment-cache-evict-on-submit]]", "[[DEC-0322-score-gain-topics-exam-weighted]]"]
---

# DEC-0335: 통계 AI 분석 캐시 키에 응답 형식 버전(`STATS_ANALYSIS_SCHEMA_VERSION`, 현재 v3)을 넣고, 응답 필드·판정 규칙이 바뀌면 버전을 올려 옛 캐시를 읽지 않게 한다

## 문제 정의 (Context)
점수 올리기 좋은 영역(`scoreGainTopics`, #1111)이 프로 계정에서 보이지 않았다. 캐시 키가 날짜 + 풀이 수 10문제 구간(`2026-11-16:guide-N`)뿐이라 기능 배포 전에 만든 캐시가 같은 키로 재사용돼 빈 목록으로 읽혔다 (GitHub #1136, [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]). [[DEC-0322-score-gain-topics-exam-weighted]] 「결과·부정」에 예상돼 있던 현상.

## 결정 (Decision)
- 갱신 구간 키 = 날짜 + `:guide-` + 형식 버전 + `-` + (최근 풀이 수 / 10). 예: `2026-11-16:guide-v3-2`.
- 버전 상수는 `AiCommentService.STATS_ANALYSIS_SCHEMA_VERSION` 한 곳. v3 = `scoreGainTopics`(#1111) + 한 줄 요약 과락 판정 통일(#1136, [[DEC-0334-ai-analysis-fail-risk-single-source]]).
- 응답 필드 추가·삭제나 서버 판정 규칙 변경을 배포할 때 버전을 올린다.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 형식이 바뀐 배포 직후에도 새 형식 분석이 바로 나온다. 옛 키(`analysis-`, `guide-N`)와 겹치지 않는다.

**부정**
- 버전을 올리면 모든 사용자의 그날 캐시가 한 번씩 다시 만들어진다(LLM 호출 증가). 올리는 것을 잊으면 같은 문제가 최대 24시간 재발한다 — 강제하는 테스트는 없다.

## 영향 범위 (Scope)
서버 `AiCommentService.toStatsRefreshBucket`·`STATS_ANALYSIS_SCHEMA_VERSION`.

## 출처 (References)
- GitHub #1136 이슈 본문 3번, PR #1137 커밋 cf096426 메시지, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1136#issuecomment-6909470371
- W4: [[DEC-0042-ai-comment-cache-evict-on-submit]](Redis 24시간 캐시, 제출 시 evict)은 그대로이고 키 구성만 보완 — 충돌 없음. [[DEC-0322-score-gain-topics-exam-weighted]]의 부정 결과를 해소.
