---
type: issue
id: ISS-0122
created: 2026-04-13
topics: [practice]
symptoms: ["쿼리 실행 상태 초기화", "실행 중...", useMutation, isPending, variables, useExecuteChoice, "병렬 실행", QuestionDetail]
root_cause: "isExecuting을 단일 useMutation 인스턴스의 isPending·variables로 계산해 마지막 호출 상태만 남았다"
status: resolved
resolution: "[[ISS-0122-per-choice-execute-state-bug-report]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/223"
---

# ISS-0122: 선택지별 쿼리 실행 버튼이 독립적으로 동작하지 않음

GitHub #223 (원본: 이슈 본문과 리포트 댓글).

## 증상
제출 후 실행 모드에서 선택지 A "쿼리 실행"(실행 중...) 상태에서 B를 실행하면 A가 "쿼리 실행"으로 초기화되고 B만 "실행 중..."으로 표시된다.

## 재현 조건
1. EXECUTABLE 문제 답안 제출 2. A "쿼리 실행" 클릭 3. 완료 전 B 클릭 4. A가 초기화됨.

## 조사 기록
- 2026-04-13: 이슈 등록. 관련 `client/src/pages/QuestionDetail.tsx`, `client/src/hooks/useQuestionDetail.ts` `useExecuteChoice`. 같은 날 수정.

## 근본 원인
`executeMutation.isPending && executeMutation.variables === choice.body`로 계산 — `useMutation`은 마지막 호출 상태 하나만 유지해 B 호출 시 `variables`가 덮어씌워진다. 또 `mutate()`에 콜백을 넘기면 병렬 호출 시 마지막 콜백만 보장되어 앞선 `onSuccess`가 무시될 수 있었다.
