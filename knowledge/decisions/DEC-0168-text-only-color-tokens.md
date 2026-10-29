---
type: decision
id: DEC-0168
created: 2026-10-21
reviewed: null
topics: [design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0356-home-questions-tab-restructure]]", "[[ISS-0356-home-questions-tab-restructure-report]]", "[[DEC-0216-count-badge-contrast-exception]]"]
---

# DEC-0168: 글자에는 브랜드 `accent` 대신 글자 전용 토큰(`accentText` 등)을 쓴다

## 문제 정의 (Context)
같은 accent 색이 채움과 글자에 모두 쓰여, 채움에 맞추면 다크 모드 글자 대비가 모자랐다 (GitHub #574 접근성 점검).

## 결정 (Decision)
- 글자 전용 토큰 `accentText`, `warningText`, `onSemantic`, `iconSecondary`를 추가하고 글자에는 이 토큰을 쓴다. 브랜드 accent 색은 그대로 둔다.
- 라이트·다크 모두 본문 글자 대비 4.5:1 이상, 화면과 같은 색 함수로 계산하는 대비 테스트로 고정한다.

## 검토한 대안 (Alternatives)
- 브랜드 accent 색 자체 조정: 리포트는 "브랜드 색 대신 글자 전용 토큰을 추가했다"고만 적었고, 브랜드 색을 바꾸지 않은 이유는 원본에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 채움과 글자 용도가 분리된다.

**부정**
- 규칙 테스트가 일부 형태만 잡아 글자에 `accent`를 직접 쓰는지 리뷰에서도 확인해야 한다.

## 영향 범위 (Scope)
앱 디자인 시스템 색 토큰, 글자색을 쓰는 화면 전반. GitHub #576 병합 때 `pro_offer_sheet.dart`·`pro_plan_comparison_table.dart`도 `accent` → `accentText`.

## 출처 (References)
- GitHub #574 리포트 댓글(2026-10-21, 2026-10-22)
- [[ISS-0356-home-questions-tab-restructure]]
