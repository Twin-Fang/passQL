---
type: decision
id: DEC-0260
created: 2026-11-07
reviewed: null
topics: [progress-stats, ai]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0460-ai-analysis-forecast-concept-links]]", "[[ISS-0460-ai-analysis-forecast-concept-links-report]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0078-readiness-multiplicative-core-with-bonus]]"]
---

# DEC-0260: 통계 AI 분석의 과목별 예상 점수는 서버가 토픽 정답률로 계산하고, 과목 40% 미만 과락·70점 합격권·54~68점 합격선 근처로 판정한다

## 문제 정의 (Context)
통계 AI 분석이 수험생이 가장 궁금한 "지금 합격선인지"를 보여 주지 않았다 (GitHub #862, [[ISS-0460-ai-analysis-forecast-concept-links]]).

## 결정 (Decision)
`ExamForecastCalculator` (서버):
- 1과목: `data_modeling` 토픽 정답률 × 10문항.
- 2과목: 나머지 8개 토픽을 같은 비중으로 평균 낸 정답률 × 40문항. 풀이가 적은 토픽은 2과목 전체 정답률 쪽으로 당긴다.
- 점수 = 맞힌 문항 수 × 2 (100점 만점).
- 판정: 과목별 40% 미만이면 과락 위험. 그 밖에는 70점 이상 합격권, 54~68점 합격선 근처, 54점 미만 합격선 아래.
- 표시 조건: 1과목 5문제 이상, 2과목 20문제 이상 풀었을 때만.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 합격 가능성과 과락 위험을 과목 단위로 보여 준다. 판정은 서버 숫자 규칙이라 LLM 오류가 끼지 않는다 ([[DEC-0259-ai-analysis-server-decides-llm-explains]]).

**부정**
- 논의 기록 없음. (판정 기준을 바꾸려면 서버 배포가 필요하다는 점은 DEC-0259 와 같다.)

## 영향 범위 (Scope)
서버 `ExamForecastCalculator`, 통계 AI 분석 응답, 앱·웹 AI 분석 카드.

## 출처 (References)
- GitHub #862 이슈 본문·리포트 댓글 (2026-11-07)
