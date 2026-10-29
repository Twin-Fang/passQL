---
type: completion-report
id: ISS-0122
created: 2026-04-13
topics: [practice]
status: resolved
resolves: "[[ISS-0122-per-choice-execute-state-bug]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/223"
---

# ISS-0122 완료 리포트: `executingKeys` Set으로 선택지별 실행 상태 독립 추적

GitHub #223 `## 개요` 리포트 댓글 기준 (2026-04-13).

## 해결 방법
`client/src/pages/QuestionDetail.tsx`:
- `executingKeys: Set<string>` state + `executingKeysRef`(클로저 stale 방지).
- `mutate()` → `mutateAsync()` + try/finally — 호출마다 독립 Promise, `finally`에서 해당 key 제거.
- `questionUuid` 변경 시 `executingKeys` 초기화(practiceMode에서 리마운트 없이 문제가 바뀌는 경우).

## 근본 원인 (확정)
단일 `useMutation` 인스턴스 상태 공유와 `mutate()` 콜백의 병렬 호출 누락.

## 재발 방지
리포트 주의사항: HTTP 에러(네트워크, 500)는 `catch`에서 묵음 처리 — SQL 실행 실패는 HTTP 200 + `errorCode`로 와서 `ResultTable` 에러 카드로 표시되고, HTTP 에러는 `finally`에서 버튼이 복구되어 재시도 가능. `AnswerFeedback.tsx`도 같은 Set 패턴이라 두 화면이 일관.

## 교훈
(원본에 없음, 볼트 정리) 여러 항목이 같은 mutation을 동시에 쓰면 `isPending`·`variables`로 항목별 상태를 판단하지 않는다.
