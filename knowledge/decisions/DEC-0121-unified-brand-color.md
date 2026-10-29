---
type: decision
id: DEC-0121
created: 2026-10-15
reviewed: null
topics: [design-system]
status: active
supersedes: DEC-0022
superseded_by: null
related: ["[[ISS-0264-architecture-audit-commonization-refactor]]", "[[ISS-0265-brand-assets-single-source]]", "[[ISS-0268-web-brand-color-token-lint]]", "[[DEC-0124-brand-folder-generated-assets]]", "[[DEC-0022-design-md-single-source-of-truth]]"]
---

# DEC-0121: 앱·웹 브랜드 색을 하나로 — `#5856D6`(다크 `#5E5CE6`), 웹 토큰은 앱 light 값에 맞춘다

## 문제 정의 (Context)
브랜드 색 정의가 7곳 이상이고 웹은 #4F46E5, 앱은 #5856D6이었다 (GitHub #458).

## 결정 (Decision)
소유자 결정(2026-10-15): 앱·웹 브랜드 색을 **하나로 맞춘다**. 결정 댓글 시점에는 값이 "확인 중(추천: 앱 `#5856D6` / 다크 `#5E5CE6`)"이었고, 같은 날 구현에서 `brand/brand-colors.json`에 `#5856D6`(다크 `#5E5CE6`) 단일 정의(#459), 웹 토큰을 앱 light 값으로 통일(브랜드 `#5856D6`, #462).

## 검토한 대안 (Alternatives)
- 웹 #4F46E5로 맞추기: 원본은 앱 값을 "추천"으로만 적었고 탈락 이유는 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음.

**부정**
- 논의 기록 없음.

## 영향 범위 (Scope)
`brand/brand-colors.json`, 웹 색 토큰, 앱 색 토큰, `brand_color_consistency.py`.
(볼트 정리, 2026-10-29 사용자 승인) 이 결정이 [[DEC-0022-design-md-single-source-of-truth]]를 대체한 것으로 잇는다: 이후 앱·웹 `Design.md`는 값을 적지 않고 코드 토큰(`passql_colors.dart`, 웹 `tokens.css`는 앱 light 값 기준)을 원본으로 가리킨다(main 코드 확인).

## 출처 (References)
- GitHub #458 소유자 결정 댓글 1번 (2026-10-15), GitHub #459·#462 구현 보고서
