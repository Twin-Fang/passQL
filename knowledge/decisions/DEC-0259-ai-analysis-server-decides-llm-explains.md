---
type: decision
id: DEC-0259
created: 2026-11-07
reviewed: null
topics: [ai, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0459-structured-ai-stats-analysis]]", "[[DEC-0258-ai-comment-pro-only-all-forms]]"]
---

# DEC-0259: 통계 AI 분석은 서버가 판정·우선순위·문구를 정하고, LLM 은 토픽별 "헷갈리는 개념" 한 문장만 쓴다

## 문제 정의 (Context)
통계 AI 코멘트 품질이 낮다는 피드백 (GitHub #861). 구조화 출력까지 LLM 에 맡기자 운영 AI 에서 판정 규칙 위반이 반복됐다 ([[ISS-0459-structured-ai-stats-analysis]]).

## 결정 (Decision)
- 서버(`AiAnalysisPlanner`): 판정(5문제 미만 판단 이름, 60% 미만 약점, 75% 미만 불안정), 집중 토픽 최대 2개(1과목 우선 > 약점 > 불안정 > 판단 이른 토픽, 틀린 수 많은 순), 강점(10문제·85%), 한 줄 진단·추세 문구, 버튼(토픽 5문제, 오답 최대 5문제).
- 판정 수치는 최근 90일 누적 (통계 화면 토픽 표 7일과 별개).
- LLM: 집중 토픽마다 세부 주제 정답률·최근 오답 제목을 근거로 무엇을 헷갈리는지 한 문장, 근거 없으면 null. 지시문은 운영 DB `ai_analysis_stats` 에만.
- 버튼 문제 수 5문제 (사용자: "10문제 부담이 크긴해").

## 검토한 대안 (Alternatives)
- 지시문만 개선한 글 코멘트: 화면 숫자 반복이 남아 탈락.
- LLM 구조화 출력(판정 포함): 운영 AI 에서 규칙 위반 다수로 탈락.

## 결과 (Consequences)
**긍정**
- 판정 오류 없음, LLM 은 개인화 서술에 집중, 실패해도 분석 나머지는 응답.

**부정**
- 판정 기준을 바꾸려면 서버 배포 필요, 통계 표와 기간이 달라 숫자가 달라 보일 수 있음 (#862 표기).

## 영향 범위 (Scope)
서버 `statsanalysis/*`·`AiCommentService`·`StatsAnalysisQueryRepository`, 앱 `ai_analysis_card.dart` 외, 웹 `StatsAiAnalysis*`, 운영 DB `prompt_template` `ai_analysis_stats`.

## 출처 (References)
- GitHub #861 이슈·리포트, 2026-11-07 대화 (실험·사용자 결정)
