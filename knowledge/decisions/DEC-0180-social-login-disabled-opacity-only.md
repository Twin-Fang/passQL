---
type: decision
id: DEC-0180
created: 2026-10-26
reviewed: null
topics: [design-system, auth-member]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0402-login-buttons-bottom-disabled-state]]", "[[ISS-0402-login-buttons-bottom-disabled-state-report]]"]
---

# DEC-0180: 소셜 로그인 버튼은 비활성일 때 회색으로 바꾸지 않고 투명도만 낮춘다 (브랜드 색 유지)

## 문제 정의 (Context)
로그인 중 다른 소셜 버튼이 잠겨 있어도 모양이 그대로라 반응이 없는 것처럼 보였다 (GitHub #668).

## 결정 (Decision)
- 비활성이면서 로딩 중이 아닌 소셜 로그인 버튼은 `Opacity` 0.4(`_disabledOpacity`)로만 흐리게 한다. 공용 버튼(`PassqlButton`)처럼 회색으로 바꾸지 않는다.
- 이슈 본문: "소셜 로그인 버튼은 공용 버튼과 달리 비활성일 때 회색으로 바꾸지 않는다 (제공자 브랜드 색 유지)".
- 처리는 로그인 전용 위젯 `social_login_button.dart` 안에서 한다 (`PassqlPressable` 위에 만든 위젯이라 공용 버튼의 비활성 모양을 이어받지 않음, 합치지 않음).

## 검토한 대안 (Alternatives)
- 공용 버튼과 같은 회색 비활성: 카카오, 네이버, Google 등 제공자 브랜드 색 가이드가 있어 색을 바꾸지 않기 위해 택하지 않음(리포트).

## 결과 (Consequences)
**긍정**
- 제공자 가이드에 맞게 브랜드 색 유지.

**부정**
- 앱 비활성 표시가 제각각으로 남음(공용 버튼 회색, 로그인 0.4, 채점 후 선택지 카드 0.5). 디자인 시스템에 비활성 공통 값이 없다(리포트 주의사항).

## 영향 범위 (Scope)
`app/lib/presentation/pages/login/social_login_button.dart`, `login_page.dart`.

## 출처 (References)
- GitHub #668 이슈 본문 「추가 요청 사항」, 리포트 댓글 「주요 구현 내용」
- [[ISS-0402-login-buttons-bottom-disabled-state]]
