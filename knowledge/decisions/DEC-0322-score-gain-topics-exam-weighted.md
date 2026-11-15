---
type: decision
id: DEC-0322
created: 2026-11-16
reviewed: null
topics: [progress-stats, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0525-pass-fail-margin-score-gain-topics]]", "[[ISS-0525-pass-fail-margin-score-gain-topics-report]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]", "[[DEC-0291-free-basic-explanation-pro-detail-shape-only]]"]
---

# DEC-0322: 통계 AI 분석의 「점수 올리기 좋은 영역」은 출제 문항 수 × (안정권 75% − 내 정답률) × 2점으로 서버가 계산해, 5문제 이상 푼 영역 중 0.5점 이상 상위 3개를 프로 전용으로 보여 준다

## 문제 정의 (Context)
예상 점수를 봐도 어느 영역을 공부해야 점수가 가장 많이 오르는지 알 수 없었다. 약점 토픽은 정답률만 봐서 시험 출제 비중(1과목 10문항, 조인 5문항 등)이 빠졌다 (GitHub #1111, [[ISS-0525-pass-fail-margin-score-gain-topics]]). 아이디어 출처는 수험생 공유 학습 사이트 조사.

## 결정 (Decision)
`ScoreGainTopicCalculator` (서버, 통계 AI 분석 판정의 일부):
- 기대 상승 점수 = 영역 출제 문항 수 × (목표 정답률 − 내 정답률) × 문항당 2점. 내 정답률이 목표 이상이면 0.
  - 출제 문항 수: 출제 경향 기반 모의고사 기본 구성 `MockExamComposition`(합계 50).
  - 내 정답률: 통계 AI 분석과 같은 최근 90일·문제별 마지막 시도.
  - 목표 75% = `AiAnalysisPlanner.SHAKY_RATE_THRESHOLD`(안정권 시작), 최소 5문제 = `MIN_SOLVED_FOR_JUDGE`를 참조(별도 값 없음).
- 5문제 이상 푼 영역만, 0.5점 미만 제외, 큰 순 최대 3개. 근거가 없으면 빈 목록 > 앱은 구간을 숨긴다.
- 앱은 예상 점수 바로 아래 목록 행(영역 이름, 정답률·시험 문항 수, 오른쪽 `+N점`, 누르면 그 영역 챕터 풀이)으로 보여 주기만 한다.
- 무료/프로: 통계 AI 분석이 프로 전용(AI_COMMENT)이므로 그 안에 둔다. [[DEC-0291-free-basic-explanation-pro-detail-shape-only]] 표 "통계: 프로는 토픽별 약점"과 같은 경계.

## 검토한 대안 (Alternatives)
- 전체 사용자 오답률 TOP N(같은 조사의 다른 아이디어): 이미 #1080(PR #1108)으로 구현돼 새로 만들지 않음.
- 그 밖의 대안(정답률만으로 순위, 다른 목표 정답률 등): 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 출제 비중이 큰 영역이 먼저 추천돼 "어디를 공부하면 점수가 오르나"에 숫자로 답한다.
- 같은 화면의 약한 토픽 판정과 기준(75%·5문제)이 어긋나지 않는다.

**부정**
- 판정 기준(`AiAnalysisPlanner`)을 바꾸면 추천 순위도 함께 바뀐다.
- `scoreGainTopics`가 없는 예전 Redis 분석 캐시는 빈 목록으로 읽혀 캐시 갱신 전까지 구간이 숨는다. 웹은 아직 표시하지 않는다.

## 영향 범위 (Scope)
서버 `ScoreGainTopicCalculator`, `AiAnalysisPlanner`, `StatsAnalysisDataLoader`, `TopicLearningStat`, `AiScoreGainTopic`·`AiStatsAnalysis` DTO, API 계약·웹 타입. 앱 `ai_analysis_score_gain_block.dart`, `ai_analysis_card.dart`, `ai_stats_analysis.dart`.

## 출처 (References)
- GitHub #1111 이슈 본문 「해결 방안」 2·3, PR #1114 본문, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1111#issuecomment-6898335129
- W4 충돌 검사: [[DEC-0259-ai-analysis-server-decides-llm-explains]](서버가 판정·문구)·[[DEC-0258-ai-comment-pro-only-all-forms]](AI 코멘트 프로 전용)·[[DEC-0291-free-basic-explanation-pro-detail-shape-only]](통계 토픽별 약점 프로)과 같은 방향, [[DEC-0260-exam-forecast-score-thresholds]] 판정 구간은 그대로 — 충돌 없음.
