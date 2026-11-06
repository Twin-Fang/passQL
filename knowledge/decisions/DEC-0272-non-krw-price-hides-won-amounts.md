---
type: decision
id: DEC-0272
created: 2026-11-07
reviewed: null
topics: [billing]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0469-billing-switch-unverified-screens-races]]", "[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0175-record-store-paid-amount-nonblocking]]"]
---

# DEC-0272: 스토어 가격이 원화가 아니면 원으로 계산한 금액(하루·할인 전·월 환산·권유)을 숨기고 스토어 가격 문자열과 할인율만 보여 준다

## 문제 정의 (Context)
앱 이용권 가격 계산이 원화를 전제해, 해외 스토어 계정에서는 "$5.99 하루 약 0원"처럼 표시됐다 (GitHub #867, [[ISS-0469-billing-switch-unverified-screens-races]]).

## 결정 (Decision)
- 스토어 통화 코드를 함께 받는다 (`pro_purchase_port.dart`, `store_purchase_service.dart`).
- 원화가 아니면 원 금액(하루 가격, 할인 전 가격, 월 환산, 긴 이용권 권유의 아끼는 금액)을 숨긴다. 환율로 바꿔 보여 주지 않는다.
- 스토어가 준 가격 문자열과 할인율만 보여 준다. 할인율은 같은 통화끼리일 때만 계산한다 (`pass_option_pricing.dart`).

## 검토한 대안 (Alternatives)
논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 해외 계정에 틀린 원 금액이 보이지 않는다.

**부정**
- 해외 계정에는 하루 가격·월 환산 같은 비교 정보가 없다 (구조상 결과, 원본에 별도 논의 없음).

## 영향 범위 (Scope)
앱 `core/billing/pass_option_pricing.dart`, `pro_purchase_port.dart`, `data/billing/store_purchase_service.dart`, `widgets/pro/pro_offer_pass_option_list.dart`. 구매 내역 금액 표기(`6 USD` 반올림)는 후속 후보로 남음. PR #898 main 머지 (2026-11-07).

## 출처 (References)
- GitHub #867 이슈 본문·리포트 댓글 (2026-11-07, PR #898 main 머지)
- W4 충돌 검사: [[DEC-0003-one-and-three-month-pass]](원화 가격 정의), [[DEC-0175-record-store-paid-amount-nonblocking]](구매 기록 금액)과 충돌 없음 — 화면 표시만 정함
