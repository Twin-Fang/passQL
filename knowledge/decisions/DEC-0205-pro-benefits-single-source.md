---
type: decision
id: DEC-0205
created: 2026-10-29
reviewed: null
topics: [billing, design-system]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0428-app-profile-tab-redesign]]", "[[ISS-0428-app-profile-tab-redesign-report]]", "[[DEC-0004-free-pro-feature-boundary]]"]
---

# DEC-0205: 앱 이용권 혜택 목록은 `pro_benefits.dart` 한 곳을 원본으로 쓰고, 실제 잠금이 있는 기능만 보인다

## 문제 정의 (Context)
프로필 개편(GitHub #749)에서 탑승권 혜택 아이콘, 구매 시트 혜택 줄, 정보 시트가 모두 혜택 목록을 보여 줘야 했다. 리포트가 적은 이유: "탑승권 아이콘과 시트 혜택 줄이 따로 목록을 갖고 있으면 판매 화면과 어긋난다."

## 결정 (Decision)
- 이용권 비교표의 행을 `widgets/pro/pro_benefits.dart`로 옮겨 원본 하나로 만든다. 탑승권 아이콘, 시트 혜택 줄, 정보 시트가 모두 이것을 읽는다.
- 혜택 6개: 문제 풀이, SQL 직접 실행, 해설, 실전 모드·토픽, 출제 경향, 통계.
- 화면에 보이는 혜택은 앱에 실제 잠금이 있는 기능만 둔다 (리포트가 확인한 잠금 위치: 홈 랜덤 풀기, SQL 실습·결과 화면, AI 해설, 문제 탭 실전 모드·최신 경향, 내 프로필 영역 분석).
- 무엇을 PRO 혜택으로 둘지는 바꾸지 않는다 — 리포트: "요금제 결정이라 화면 개편에서 바꾸지 않았다." 경계는 [[DEC-0004-free-pro-feature-boundary]].

## 검토한 대안 (Alternatives)
- 화면마다 따로 목록을 두기: 판매 화면과 어긋난다는 이유로 하지 않음 (리포트 문장 외 논의 기록 없음).

## 결과 (Consequences)
**긍정**
- 탑승권·구매 시트·정보 시트의 혜택이 한 언어로 이어진다 (이슈 기대 결과).

**부정 / 조건**
- `pro_benefits.dart`의 순서가 탑승권 아이콘 순서이자 `focusedBenefitIndex` 기준이다(영역 잠금 줄은 5번 통계를 강조). 순서를 바꾸면 강조되는 혜택이 달라진다.
- 오답 노트는 실제로 PRO 잠금이지만 비교표에 없다. 넣을지는 요금제 표시 결정으로 남김 (별도 이슈 후보).

## 영향 범위 (Scope)
앱 `widgets/pro/pro_benefits.dart`(신규), `pro_offer_sheet.dart`, `pro_info_sheet.dart`, `design/components/passql_pass_ticket.dart`. 기존 `pro_plan_comparison_table`은 삭제.

## 출처 (References)
- GitHub #749 리포트 댓글 「주요 구현 내용 2·3」, 「건드리면 위험한 곳」 (2026-10-29)
- [[ISS-0428-app-profile-tab-redesign-report]]
