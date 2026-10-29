---
type: decision
id: DEC-0207
created: 2026-10-29
reviewed: null
topics: [design-system, billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]"]
---

# DEC-0207: passQL PASS 탑승권은 시트에서도 기울이지 않고 정방향으로 두고, 띄움 그림자만 쓴다

## 문제 정의 (Context)
GitHub #749 본 개편(PR #750) 머지 뒤 마무리 손질(PR #752)에서 구매 시트·정보 시트의 탑승권 모양을 다시 정했다. PR #752 본문이 "기울이지 않고 정방향으로" 바꿨다고 적어, #750 시점에는 시트 탑승권이 기울어 있었다.

## 결정 (Decision)
- 구매 시트·정보 시트 탑승권을 기울이지 않고 정방향으로 둔다. 띄움 그림자는 유지한다.
- 리포트 표현: "빛줄기·홀로그램·띄움 그림자 선택(시트에서도 기울이지 않고 정방향)".

## 검토한 대안 (Alternatives)
- 시트에서 기울인 탑승권(#750 상태): 정방향으로 바꿨다. 바꾼 이유는 원본과 사용자 정리에 적혀 있지 않다.

## 결과 (Consequences)
**긍정**
- 논의 기록 없음

**부정**
- 논의 기록 없음

## 영향 범위 (Scope)
앱 `design/components/passql_pass_ticket.dart`, `widgets/pro/pro_offer_sheet.dart`, `widgets/pro/pro_info_sheet.dart`.

## 출처 (References)
- PR #752 본문 (2026-10-29 07:30 main 머지), GitHub #749 리포트 댓글 6490566222 「변경 사항 1·2」「리뷰 반영」
- 사용자 정리 (2026-10-29 대화, "#752에서 정한 것")
- [[ISS-0428-app-profile-tab-redesign-report]]
