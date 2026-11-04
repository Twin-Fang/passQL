---
type: decision
id: DEC-0251
created: 2026-11-05
reviewed: null
topics: [ai, practice]
status: active
supersedes: DEC-0087
superseded_by: null
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]", "[[DEC-0250-never-store-unvalidated-sql-choice-sets]]", "[[DEC-0028-realtime-choice-set-with-prefetch]]"]
---

# DEC-0251: 연습 모드는 검증 통과 세트 최신 5개 중 무작위로 재사용하고, 실전 모드는 매번 생성한다

## 문제 정의 (Context)
연습 모드는 같은 문제에 최신 OK 세트 1건만 재사용해 모든 회원이 같은 보기를 반복해서 봤고, 검증에 실패한 세트도 재사용 대상이었다([[DEC-0087-choice-generation-practice-real-mode]], GitHub #828). 사용자 요구는 "엄청 헷갈리게, 근데 매번 창의적이게".

## 결정 (Decision)
- 선택지 생성 모드 `PRACTICE` / `REAL`는 그대로 둔다 ([[DEC-0087-choice-generation-practice-real-mode]]의 모드 구분 유지).
- 연습 모드(SQL·결과 표 문제): (1) 본인 프리페치 > (2) 샌드박스 검증 통과 OK 세트 최신 5개 중 무작위 1개 > (3) 모두 없으면 실시간 생성.
- 실전 모드: 매번 실시간 생성, 실패하면 검증 통과 세트 재사용([[DEC-0250-never-store-unvalidated-sql-choice-sets]]).
- 개념형 연습 모드는 기존 그대로(최신 OK 1건).

## 검토한 대안 (Alternatives)
- 연습 모드도 매번 생성: AI 비용과 대기(수십 초)가 커져 버렸다.
- 논의 기록 없음 (그 밖의 대안).

## 결과 (Consequences)
**긍정**
- 세트가 쌓일수록 같은 문제도 다른 보기가 나온다. 검증 실패 세트는 재사용되지 않는다.

**부정**
- 세트가 1개뿐인 문제는 여전히 같은 보기다 (실전 모드 풀이·프리페치로 세트가 늘어야 바뀜).

## 영향 범위 (Scope)
`ChoiceSetResolver`, `QuestionChoiceSetRepository.findTop5ByQuestionUuidAndStatusAndSandboxValidationPassedOrderByCreatedAtDesc`.

## 출처 (References)
- GitHub #828 PR #829 (2026-11-05)
- 이슈: [[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]
