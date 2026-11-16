---
type: decision
id: DEC-0334
created: 2026-11-16
reviewed: null
topics: [progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]", "[[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner-report]]", "[[DEC-0259-ai-analysis-server-decides-llm-explains]]", "[[DEC-0260-exam-forecast-score-thresholds]]", "[[DEC-0323-pass-fail-margin-count-single-source]]"]
---

# DEC-0334: 통계 AI 분석 한 줄 요약의 과락 판정은 예상 점수와 같은 원본(`ExamForecastCalculator.failRiskSubjectsOf` > `SqldScoreMargin`)만 따르고, 과락 과목을 예상 정답 수로 말한다

## 문제 정의 (Context)
한 줄 요약은 첫 집중 토픽이 1과목이면 토픽 정답률만 보고 "1과목 정답률 57%, 과락 위험이 커요"라고 했고, 바로 아래 예상 점수는 1과목 6/10 안전, 2과목 과락 위험이라 서로 모순됐다 (GitHub #1136, [[ISS-0539-pro-recheck-fail-risk-headline-exam-answer-owner]]).

## 결정 (Decision)
- 한 줄 요약 순서: 7일 쉼 > **과락 위험 과목** > 모두 안정 > 첫 집중 토픽(약점·불안정·판단 이름).
- 과락 위험 과목은 `ExamForecastCalculator.failRiskSubjectsOf`(과목 예상 정답 수 <-> `SqldScoreMargin` 과락선) 하나로 판정. 문구: 한 과목 "2과목 예상 14/40, 과락 위험이 커요", 두 과목 "두 과목 모두 과락 위험이 커요".
- 집중 토픽 선정은 1과목을 먼저 보는 우선순위만 유지하고(10문항이라 한 문제 비중이 큼) 과락 여부는 말하지 않는다. 1과목 토픽 문장도 약점·불안정 판정 문구로만.

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 같은 화면의 머리 문장과 예상 점수가 구조적으로 어긋날 수 없다.

**부정**
- 예상 점수 표시 조건(1과목 5문제·2과목 20문제, [[DEC-0260-exam-forecast-score-thresholds]])에 못 미치면 과락 문장이 나오지 않는다 — 기존의 "1과목 아직 N문제, 과락 위험" 문장은 없어졌다.

## 영향 범위 (Scope)
서버 `AiAnalysisPlanner.toHeadlineBody`·`toFailRiskHeadlineBody`·`selectFocusTopics` 주석, `ExamForecastCalculator.failRiskSubjectsOf`·`expectedCorrectCountOf`, `AiAnalysisPlannerTest`. 앱·웹은 서버 문구를 그대로 표시.

## 출처 (References)
- GitHub #1136 이슈 본문 1번, PR #1137 커밋 cf096426 메시지, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1136#issuecomment-6909470371
- W4: [[DEC-0259-ai-analysis-server-decides-llm-explains]](서버가 판정·문구, 1과목 우선 집중 토픽)·[[DEC-0260-exam-forecast-score-thresholds]](과목 40% 미만 과락)·[[DEC-0323-pass-fail-margin-count-single-source]](`SqldScoreMargin` 단일 원본)과 같은 방향의 보완 — 충돌 없음, 대체 없음.
