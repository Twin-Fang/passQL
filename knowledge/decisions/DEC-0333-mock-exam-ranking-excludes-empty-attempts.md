---
type: decision
id: DEC-0333
created: 2026-11-16
reviewed: null
topics: [practice, progress-stats]
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]", "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]", "[[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking-report]]", "[[DEC-0264-mock-exam-fixed-rounds-server-judged]]"]
---

# DEC-0333: 모의고사 순위에서 한 문항도 고르지 않은 빈 답안(시간 종료·바로 제출)은 응시자로 세지 않고, 내 응시가 빈 답안이면 순위를 숨긴다

## 문제 정의 (Context)
운영 회차 1 제출 20건 중 17건이 0점이었고 그중 15건이 빈 답안이었다. 빈 답안이 [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]]의 응시자 분포에 들어가 0점 제출이 "20명 중 4위, 상위 20%"로 보였다 (GitHub #1126 결함 5번, [[ISS-0538-exam-answer-qa-fixes-empty-attempt-ranking]]).

## 결정 (Decision)
- **빈 답안 정의:** 제출된 응시 중 선택한 답(`selectedChoiceKey`)이 하나도 없는 응시. 총점 0점과 구분한다 — 풀고 0점이면 응시로 센다.
- **분포:** 순위 재료 쿼리 `findSubmittedScoresByRoundInSubmitOrder`에서 빈 답안을 뺀다(EXISTS 조건). 회원별 첫 응시는 빈 답안을 뺀 뒤의 첫 응시.
- **내 순위:** 지금 응시가 빈 답안이면 `ranking = null`(앱은 줄을 숨김). null 조건 2개: 빈 답안, 응시자 10명 미만.
- DEC-0301의 나머지(첫 응시 기준, 순위 = 나보다 높은 회원 수 + 1, 상위 % 올림, 10명 미만 숨김, 무료 공개)는 그대로.

## 검토한 대안 (Alternatives)
- 이슈 본문은 원인을 "동점 처리 오류"로 보고 동점 규칙 수정을 예상했으나, 공식은 이미 DEC-0301대로였고 원인은 분모였다. 그 밖에 검토한 대안(예: 0점 전체 제외) 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 빈 제출이 많은 회차에서도 0점이 좋은 순위로 보이지 않는다. 내 판정은 이미 불러온 답안 맵으로 해 추가 쿼리가 없다.

**부정**
- 순위 쿼리에 하위 쿼리(EXISTS)가 붙는다. 비용 영향은 논의 기록 없음.
- 첫 응시가 빈 답안이면 두 번째 응시가 그 회원의 "첫 응시"가 된다 — DEC-0301의 첫 응시 기준이 "빈 답안 제외 첫 응시"로 좁아진다.

## 영향 범위 (Scope)
서버 `MockExamAttemptRepository.findSubmittedScoresByRoundInSubmitOrder`, `MockExamAttemptService.calculateRanking`·`hasAnsweredAnyQuestion`, `MockExamRankingCalculator.rank`(인자 `isCurrentAttemptAnswered` 추가), `MockExamRankingCalculatorTest`. API 응답 모양은 그대로(`MockExamResultResponse.ranking` nullable).

## 출처 (References)
- GitHub #1126 이슈 본문 결함 5번, PR #1127 커밋 c997c097 메시지, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1126#issuecomment-6907744218
- W4: [[DEC-0301-mock-exam-ranking-first-attempt-top-percent]](active)와 대조 — 공식·숨김·무료 공개는 같고 "응시자"의 범위만 좁히는 보완이라 대체하지 않고 조건부 공존(DEC-0301 유지 + 빈 답안 제외). [[DEC-0329-mock-study-mode-reuses-question-flow-device-progress]](학습 모드는 순위에 넣지 않음)·[[DEC-0264-mock-exam-fixed-rounds-server-judged]](서버 판정)와 충돌 없음.
