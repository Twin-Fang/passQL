---
type: decision
id: DEC-0346
created: 2026-11-18
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0544-callout-no-left-bar-roadmap-home-entry]]", "[[ISS-0544-callout-no-left-bar-roadmap-home-entry-report]]"]
---

# DEC-0346: 강조 상자는 왼쪽 세로 막대 없이 옅은 의미색 바탕 + 둥근 모서리 + 원형 아이콘으로 그리고, 왼쪽 막대는 규칙 테스트로 금지한다

GitHub #1158 (이슈 본문, 완료 보고서). 2026-11-18 대화에서 사용자가 추천안 전체 승인.

## 문제 정의 (Context)
공통 강조 상자(#835)가 왼쪽 의미색 막대를 써서 AI 티가 났고, 사용자가 이전에도 금지한 모양이 디자인 시스템 원본에 남아 있었다.

## 결정 (Decision)
- `PassqlCallout`: 옅은 의미색 바탕(배지와 같은 진하기) + 둥근 모서리, 아이콘이 있으면 왼쪽 원형 의미색 배지 > 라벨 > 내용.
- `lib/presentation` 전체에서 `Border(left:` / `left: BorderSide(` 금지(규칙 테스트). 예외는 GROUP BY 그림 그룹 행 표시처럼 콜아웃이 아닌 그림만, 이유와 함께 목록에.

## 검토한 대안 (Alternatives)
- 흰 카드 + 아이콘 타일: 흰 구간 면 위 카드 안 카드가 됨(보고서).
- 바탕 없는 한 줄 안내: 함정·외울 것이 묻힘(보고서).

## 결과 (Consequences)
**긍정**
- 10곳이 한 번에 바뀌고 다시 생기지 않는다.

**부정**
- 표·그림의 정당한 한쪽 테두리도 예외 등록이 필요하다.

## 영향 범위 (Scope)
앱 `design/components/passql_callout.dart`, `test/architecture/design_system_rules_test.dart`, `.claude/rules/Design.md`.

## 출처 (References)
- GitHub #1158 이슈 본문, 완료 보고서 댓글
