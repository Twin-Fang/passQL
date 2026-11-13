---
type: decision
id: DEC-0296
created: 2026-11-12
reviewed: null
topics: [billing, admin]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0509-admin-billing-payout-app-store-refund-check]]", "[[ISS-0374-admin-subscription-revenue-dashboard]]"]
---

# DEC-0296: 관리자 실수령액은 원화 판매가에 부가세 10%가 포함됐다고 가정해 빼고, 스토어 수수료 15%를 뺀 추정치로 보여 주며 두 요율은 설정값이다

GitHub #1032 (PR #1033, 코드 주석·Flyway V1_114_2 설정 설명).

## 문제 정의 (Context)
매출 요약이 판매 금액뿐이라 환불·스토어 수수료를 뺀 실수령액이 보이지 않았다(이슈 본문).

## 결정 (Decision)
- 실수령 = 판매 − 환불 = 순매출 > 부가세 = 순매출 x 세율 / (100 + 세율) > 수수료 = (순매출 − 부가세) x 수수료율 / 100 > 나머지.
- 원화 판매가에는 부가세 10%가 포함돼 스토어가 떼고 정산한다고 가정한다(`billing.krw_vat_rate_percent` 기본 10). 원화 외 통화는 나라별 세금을 몰라 0.
- 스토어 수수료율은 Play·App Store 각각 기본 15%(`billing.fee_rate_percent.play`/`.app_store`, 소규모 사업자·첫해 기준 가정).
- 모두 관리자에서 바꿀 수 있는 설정값이고, 화면 값은 추정치다.

## 검토한 대안 (Alternatives)
- 이슈 본문의 첫 안은 판매 − 환불 − 수수료(부가세 없음)였다. 부가세 차감을 더한 이유와 다른 대안은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 운영 실측: 전체 기간 실수령 6,800원(판매 13,200 / 환불 4,400 / 부가세 800 / 수수료 1,200)이 한 화면에 보인다.

**부정**
- 실제 정산서(세금·환율·수수료 등급)와 다를 수 있다. 가정이 바뀌면 설정값을 고쳐야 한다.

## 영향 범위 (Scope)
`StorePayoutCalculator`, `BillingPayoutService`, `PayoutSettings`, `app_setting` BILLING 키, 관리자 실수령액 탭.

## 출처 (References)
- GitHub #1032, PR #1033, 보고서 댓글 https://github.com/Twin-Fang/passQL/issues/1032#issuecomment-6825820372
