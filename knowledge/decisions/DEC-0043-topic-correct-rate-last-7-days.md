---
type: decision
id: DEC-0043
created: 2026-04-10
reviewed: null
topics: [progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0047-topic-analysis-ai-comment-impl]]", "[[ISS-0047-topic-analysis-ai-comment-impl-report]]", "[[ISS-0044-topic-analysis-ai-comment-api]]"]
---

# DEC-0043: 토픽별 정답률은 최근 7일 제출 중 문제별 최근 1회 기준, 토픽별 문제 수는 전체 활성 문제

## 문제 정의 (Context)
통계 화면 레이더 차트용 토픽별 정답률과 막대 그래프용 문제 수 계산 기준을 정해야 했다 (GitHub #71, #79).

## 결정 (Decision)
- 정답률: 최근 7일 이내 제출만 대상으로, `ROW_NUMBER() OVER (PARTITION BY question_uuid ORDER BY submitted_at DESC)`의 `rn = 1`만 집계해 토픽별 평균.
- 문제 수: `is_active = true` 문제를 토픽별로 센다(기간 제한 없음).
- 토픽 목록은 Topic 테이블의 활성 토픽 전체 — 풀이 이력이 없으면 `correctRate: 0.0`, `solvedCount: 0`.

## 검토한 대안 (Alternatives)
- 단순 전체 제출 평균: #79는 "반복 연습으로 인한 정답률 왜곡을 방지"하려고 문제별 최근 시도만 쓴다고 적었다.
- 7일이라는 기간을 고른 이유: 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 반복 풀이가 정답률을 부풀리지 않는다.

**부정**
- `totalQuestionCount`(전체)와 `solvedCount`(7일)의 기준이 달라 `totalQuestionCount > solvedCount`가 정상이다.

## 영향 범위 (Scope)
`SubmissionRepository.findTopicStatsAfter()`, `QuestionRepository.countActiveByTopic()`, `TopicAnalysisService`. "문제별 최근 시도" 기준은 볼트의 기존 결정 DEC-0024(`correctRate` 문제별 마지막 시도)와 같은 방식이다(#71 본문: "기존 ReadinessCalculator와 동일 방식").

## 출처 (References)
- GitHub #71 이슈 본문 「토픽별 정답률 계산 기준」, GitHub #79 이슈 본문 「토픽별 정답률 계산 방식」
