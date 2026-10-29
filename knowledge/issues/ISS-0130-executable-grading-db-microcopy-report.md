---
type: completion-report
id: ISS-0130
created: 2026-04-13
topics: [practice]
status: resolved
resolves: "[[ISS-0130-executable-grading-db-microcopy]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/236"
---

# ISS-0130 완료 리포트: EXECUTABLE 채점 마이크로카피 추가

GitHub #236 `## 개요` 리포트 댓글과 후속 댓글(2026-04-13) 기준.

## 해결 방법
- `client/src/constants/microcopy.ts`: `EXECUTABLE_GRADING_MESSAGES`(5개)와 `getRandomExecutableGradingMessage()`.
- `client/src/components/LoadingOverlay.tsx`: optional `isExecutable` prop, 채점 중(`staticMessage` 존재 시)에만 표시, `useState(getRandomExecutableGradingMessage)`로 마운트 시 1회 고정.
- `client/src/components/PracticeFeedbackBar.tsx`: `result.correctResult != null`(백엔드가 EXECUTABLE일 때만 non-null)로 판단, `useRef`로 1회 고정.
- 호출부 `PracticeSet.tsx`, `QuestionDetail.tsx`에서 `executionMode === "EXECUTABLE"` 전달.
- 후속 댓글: 문구 조정 — "채점 중이에요" 아래 한 줄만. EXECUTABLE `"DB에 쿼리를 날려보는 중이에요"`(브랜드 색상), CONCEPT_ONLY `"정답을 확인하고 있어요"`(기본 caption). 이후 "정상 작동 확인".

## 근본 원인 (확정)
해당 없음 (기능 개선).

## 재발 방지
리포트 주의사항: SQL 실행이 에러를 반환해도(`correctResult.errorCode != null`) 피드백 바 문구가 노출된다 — `errorCode == null` 조건 추가 여부 검토 필요.

## 교훈
논의 기록 없음.
