---
type: completion-report
id: ISS-0082
created: 2026-04-12
topics: [practice]
status: resolved
resolves: "[[ISS-0082-executable-result-compare-ui]]"
related: ["[[DEC-0058-on-demand-choice-execution-after-submit]]"]
source: "https://github.com/Twin-Fang/passQL/issues/144"
---

# ISS-0082 완료 리포트: 선택지 카드별 실행 버튼, Duolingo 스타일 피드백바, 채점 오버레이

GitHub #144 작업 댓글 기준 (2026-04-12, PR #151).

## 해결 방법
- `src/pages/AnswerFeedback.tsx`: 선택지별 결과를 카드로 재구성. 정답(초록)·내 오답(파란)·나머지(회색). 제출 응답의 `selectedResult`/`correctResult`로 정답·내 선택 카드는 즉시 표시, 나머지는 실행 버튼으로 개별 실행. `executing`을 `string | null` → `Set<string>`(CodeRabbit 리뷰 반영, 연속 클릭 시 로딩 상태 꼬임 방지).
- `src/components/ResultTable.tsx`: `success-card` 래퍼 제거, `overflow-hidden rounded-xl border` + `overflow-x-auto`. `components.css` `data-table` 헤더 배경·행 구분선.
- `src/components/PracticeFeedbackBar.tsx`: 하단 슬라이드업(`animate-slide-up`, `rounded-t-2xl`), 딤 오버레이 제거(실행 버튼 접근 위해), 정답 "계속하기" / 오답 "확인", 스크롤 `pb-52`.
- `PracticeSet.tsx`·`DailyChallenge.tsx`: 제출 중 `LoadingOverlay`("채점 중이에요"), `useBlocker(... && !submitting)`.
- `QuestionDetail.tsx`: `showExecution` 프롭 — 제출 완료 후에만 ChoiceCard 안에 실행 버튼, 제출 후 선택 변경 방지, 재시도 시 이전 결과 미노출.
- `SchemaViewer.tsx`: `useState(false)` → `useState(true)` 기본 펼침(EXECUTABLE 문제는 스키마 확인이 필수라서).
- `ChoiceReview.tsx` 제거, 기능을 `AnswerFeedback.tsx`와 `showExecution` 방식으로 통합.

## 근본 원인 (확정)
해당 없음 (디자인 개선).

## 재발 방지
참고사항: `wrap-break-word`는 Tailwind 기본 유틸리티가 아니라는 CodeRabbit 지적이 있었으나 유지, 별도 검토 필요. `AnswerFeedback.tsx`는 같은 경로 재진입 시 이전 결과 캐시가 남는 edge case가 있다(`location.key` 기반 리셋이 이상적, 범위 외).

## 교훈
특이사항: DailyChallenge 제출 시 이탈 모달 오탐 버그를 발견했으나 범위 밖이라 별도 문서화(GitHub #146로 이어짐).
