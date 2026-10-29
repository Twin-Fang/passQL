---
type: decision
id: DEC-0212
created: 2026-10-29
reviewed: null
topics: [design-system, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]", "[[DEC-0205-pro-benefits-single-source]]"]
---

# DEC-0212: 탑승권 안의 혜택 아이콘 줄은 유지한다 (세 곳 모양 통일)

## 문제 정의 (Context)
#749 개편의 탑승권은 본문에 혜택 아이콘 줄을 둔다(무료는 흐린 아이콘). PR #752 마무리 손질 때 이 줄을 유지하기로 정했다 (사용자 정리).

## 결정 (Decision)
- 탑승권 안 혜택 아이콘 줄을 유지한다.
- 프로필·구매 시트·정보 시트 세 곳의 모양을 통일한다.

## 검토한 대안 (Alternatives)
- 아이콘 줄 빼기: 사용자 정리에 유지 이유만 있고 뺀다는 안의 논의 기록은 없다.

## 결과 (Consequences)
**긍정**
- 사용자 정리: 무료 회원에게 못 받는 혜택을 보여 주는 핵심 장치다.

**부정**
- 리포트 후속 후보: 혜택 아이콘 누르는 영역이 22pt(탑승권 전체 누르기가 대체).

## 영향 범위 (Scope)
앱 `design/components/passql_pass_ticket.dart`, `widgets/pro/pro_benefits.dart`.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- 사용자 정리 (2026-10-29 대화, "#752에서 정한 것")
- [[ISS-0428-app-profile-tab-redesign-report]]
