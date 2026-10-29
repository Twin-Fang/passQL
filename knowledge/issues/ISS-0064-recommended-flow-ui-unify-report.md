---
type: completion-report
id: ISS-0064
created: 2026-04-11
topics: [practice]
status: resolved
resolves: "[[ISS-0064-recommended-flow-ui-unify]]"
related: ["[[DEC-0051-no-auto-execute-review-after-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/112"
---

# ISS-0064 완료 리포트: 풀이 플로우 통일, 카드 클릭 선택, 제출 후 `ChoiceReview`

GitHub #112 프론트 작업 댓글(2026-04-11) 기준.

## 해결 방법
- `ChoiceCard.tsx`: 라디오 제거, 카드 전체 클릭. `<button>` wrapper → `<div role="button" tabIndex={0} aria-pressed={isSelected}>` + `onKeyDown`(Enter/Space). `kind === "TEXT"` + JSON 배열 body면 `ResultMatchTable`(실행 버튼 없음), CONCEPT_ONLY는 텍스트, EXECUTABLE은 모노 폰트 SQL.
- `ChoiceReview.tsx` 신규: 제출 후 각 선택지 SQL을 실행해 비교. `choices.filter(c => c.kind === "SQL")`로 RESULT_MATCH 제외, 실패 시 에러 메시지·재시도 버튼.
- `AnswerFeedback`·`PracticeSet`·`DailyChallenge`: EXECUTABLE 제출 시 `reviewChoices` 저장, `choices[0]?.kind === "SQL"` 가드로 `ChoiceReview` 렌더링, `selectedKey` 강조.
- `QuestionDetail.tsx`: 스키마 토글 제거(`SchemaViewer` 항상 표시), 선택지 클릭 시 자동 SQL 실행 제거, 제출 payload에 `choices` 포함, `submitMutation.isPending` 시 `LoadingOverlay`(하드코딩 300ms 지연 제거), 단일 스크롤.
- `LoadingOverlay`에 `staticMessage`·`subMessage`, `PracticeFeedbackBar`에서 `correctKey` 노출 제거.
- 검증: 수동 흐름 확인, 키보드 접근성, `npm run build`.

## 근본 원인 (확정)
이슈 노트와 같다. 부수 버그 3건(중첩 버튼, RESULT_MATCH JSON의 execute 호출 가능성, 실행 실패 무시)도 원인과 함께 수정됐다.

## 재발 방지
작업 댓글: PracticeSet·DailyChallenge의 `choices[0]?.kind === "SQL"` 가드와 AnswerFeedback의 `executionMode === "EXECUTABLE"` 조건이 각각 독립적으로 RESULT_MATCH 선택지 유입을 막는다.

## 교훈
(원본에 없음, 볼트 정리) 선택지 `kind`가 여럿이면 실행 API를 부르는 모든 곳에서 `kind === "SQL"`을 확인한다.
