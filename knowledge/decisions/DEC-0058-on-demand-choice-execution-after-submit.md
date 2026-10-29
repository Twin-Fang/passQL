---
type: decision
id: DEC-0058
created: 2026-04-12
reviewed: null
topics: [practice]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0082-executable-result-compare-ui]]", "[[ISS-0082-executable-result-compare-ui-report]]", "[[ISS-0089-apply-144-pattern-daily-recommend]]"]
---

# DEC-0058: EXECUTABLE 제출 후 실행 결과는 선택지 카드별 실행 버튼으로 골라 보게 한다 (전체 자동 노출 폐기, 풀이 중에는 실행 버튼 없음)

## 문제 정의 (Context)
제출 후 4개 선택지의 SQL 실행 결과가 모두 자동 노출돼 화면이 지나치게 길었다 (GitHub #144).

## 결정 (Decision)
- 정답 카드와 내가 고른 카드는 제출 응답(`selectedResult`/`correctResult`)으로 즉시 결과를 보이고, 나머지 선택지는 카드 안 실행 버튼을 눌러야 실행한다.
- 실행 버튼은 제출 완료 후에만 보인다(`showExecution`). 풀이 중에는 실행 버튼이 없다.
- 피드백바는 딤 오버레이 없이 하단 슬라이드업 — 실행 결과를 보면서 피드백도 확인해야 해서.

## 검토한 대안 (Alternatives)
- 접기/펼치기 또는 탭 전환: 이슈 본문 기대 결과에 있던 방식이다. 구현은 카드별 실행 버튼으로 했고, 두 방식을 비교한 기록은 논의 기록 없음.
- 4개 결과 자동 노출(기존): "스크롤이 너무 길어져 학습 흐름을 방해"해서 바꿨다.

## 결과 (Consequences)
**긍정**
- 결과 화면 길이가 줄고, 정답/내 선택/나머지가 색으로 구분된다.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`AnswerFeedback.tsx`, `QuestionDetail.tsx`(`showExecution`), `ChoiceCard`, `PracticeFeedbackBar.tsx`, `ResultTable.tsx`, `PracticeSet`·`DailyChallenge`(GitHub #159에서 DailyChallenge·추천 문제에도 적용).

## 출처 (References)
- GitHub #144 작업 댓글 (2026-04-12, PR #151)
- [[ISS-0082-executable-result-compare-ui]]
