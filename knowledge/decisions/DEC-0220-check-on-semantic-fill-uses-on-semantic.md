---
type: decision
id: DEC-0220
created: 2026-10-30
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0432-app-concept-tab-redesign]]", "[[ISS-0432-app-concept-tab-redesign-report]]", "[[DEC-0168-text-only-color-tokens]]", "[[DEC-0218-concept-result-ring-climax]]", "[[DEC-0222-concept-perfect-fullscreen-scoreboard]]"]
---

# DEC-0220: 진한 의미색 위의 체크는 시안의 흰색 대신 `onSemantic`(초록 위), 강조색 위는 `onAccent`

## 문제 정의 (Context)
개념 5/5 시안은 초록 원 위에 흰 체크였다 (GitHub #764). 디자인 규칙은 진한 의미색 채움 위 글자·아이콘에 `onSemantic`(라이트 테마에서 검정)을 쓰게 한다.

## 결정 (Decision)
- 초록(`correct`) 원 위 체크는 `onSemantic`으로 그린다. 흰색으로 바꾸면 초록 위 대비 기준에 못 미친다. 구현 뒤 선택지로 제시했고 사용자가 추천(규칙 유지)을 골랐다.
- 다 맞힘 점수판은 사용자가 파랑 계열을 골라 원이 강조색(`accent`)이 되었고, 그 위 체크는 짝인 `onAccent`(흰색)다. 강조색 채움 위 흰 글자는 이미 앱 버튼이 쓰는 조합이라 규칙 안이다.
- [[DEC-0168-text-only-color-tokens]]의 적용이며 예외를 만들지 않는다.

## 검토한 대안 (Alternatives)
- 시안대로 초록 위 흰 체크: 대비 기준 미달.

## 결과 (Consequences)
**긍정**
- 대비 규칙과 테스트 기준 안에 머문다.

**부정**
- 결과 머리의 초록 원 체크는 검정이라 시안과 색이 다르다.

## 영향 범위 (Scope)
`app/lib/presentation/widgets/concept/concept_result_ring.dart`(`checkColor` 기본 `onSemantic`, 점수판은 `onAccent`).

## 출처 (References)
- GitHub #764 리포트 댓글 주의사항
- [[ISS-0432-app-concept-tab-redesign]]
