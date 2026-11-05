---
type: decision
id: DEC-0250
created: 2026-11-05
reviewed: null
topics: [practice, ai]
status: active
supersedes: DEC-0055
superseded_by: null
related: ["[[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]", "[[DEC-0249-result-table-choices-from-executed-sql]]", "[[DEC-0030-answer-sql-sandbox-ground-truth]]"]
---

# DEC-0250: SQL·결과 표 보기 세트는 샌드박스 검증을 통과한 것만 저장하고 노출한다

## 문제 정의 (Context)
3회 재시도 후에도 정답이 여러 개(MULTIPLE_CORRECT)면 AI 정답 표시를 믿고 저장하는 경로가 있었다([[DEC-0055-multiple-correct-ai-fallback-save]]). 사용자 요구는 "오답 선택지가 나오면 절대 안 된다"였다 (GitHub #828).

## 결정 (Decision)
- `saveWithAiCorrect` 대체 저장을 없앤다. 검증에 실패하면 실패로 기록만 한다(`saveFailed`).
- 실전 모드 실시간 생성이 실패하면 같은 문제의 검증 통과 세트를 재사용하고, 없으면 생성 실패를 그대로 돌려준다.
- 프리페치·관리자 재생성은 문제 정책별 경로(`generateForQuestion`: 개념형 > 개념 보기, 결과 표 > 결과형, 그 외 SQL 보기)로만 만든다.
- 이미 노출 중인 세트는 관리자 전수 검증(`GET /admin/choice-sets/integrity-audit`)으로 다시 채점해, 정답 수가 1이 아니거나 표시 정답이 다르거나 정책과 보기 종류가 다른 세트를 내린다.
- 개념형(실행 검증 불가) 세트는 이 결정 범위 밖이다. AI 정답 표시를 쓰는 기존 방식 그대로다.

## 검토한 대안 (Alternatives)
- AI 대체 저장 유지(사용자를 막지 않음): 틀린 채점이 나갈 수 있어 버렸다.
- 논의 기록 없음 (그 밖의 대안).

## 결과 (Consequences)
**긍정**
- 회원에게 나가는 SQL·결과 표 보기는 모두 재실행 기준 정답이 하나다.

**부정**
- 검증 통과 세트가 하나도 없는 문제에서 생성이 3회 실패하면 그 문제를 풀 수 없다(실패 응답).

## 영향 범위 (Scope)
`ChoiceSetGenerationService`, `ChoiceSetSaveService`, `ChoiceSetResolver`, `PrefetchService`, `ChoiceSetIntegrityAuditService`, `AdminChoiceSetController`.

## 출처 (References)
- GitHub #828 이슈 본문, PR #829 (2026-11-05)
- 이슈: [[ISS-0451-result-table-choices-fabricated-unvalidated-sets]]
