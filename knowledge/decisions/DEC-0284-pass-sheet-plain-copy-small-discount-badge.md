---
type: decision
id: DEC-0284
created: 2026-11-12
reviewed: null
topics: [billing, design-system]
status: superseded
supersedes: null
superseded_by: DEC-0286
related: ["[[ISS-0488-free-practice-reward-flow]]", "[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0272-non-krw-price-hides-won-amounts]]", "[[DEC-0262-pro-benefits-seven-ad-removal]]"]
---

# DEC-0284: 이용권 시트는 기간·가격·할인율·만료일만 담백하게, 할인은 가격 옆 작은 배지, 권유 문구는 두지 않는다

## 문제 정의 (Context)
사용자가 이용권 시트를 보고 "1개월을 눌렀는데 바로 아래 3개월로 바꾸라는 문구 뜨게 하지 마", "굳이 필요 없는 문구들이 많다", "25% 할인 저거", "글자색이 검은색이면 너무 안 보여"라고 지적했다 (GitHub #963). 빨간 리본 위 글자가 `onSemantic`(검정)이라 대비가 낮았다.

## 결정 (Decision)
- 삭제: 1개월권을 고르면 뜨던 3개월 권유 줄, 칸마다 "하루 약 N원"·"월 N원"·줄 그은 정가, 머리글 아래 "무료로는 시험까지 랜덤 최대 N문제"와 "N일 × 10문제", "가장 많이 골라요".
- 이용권 칸은 기간(+ 작은 할인 배지), 만료일, 가격만.
- 할인 표시는 시안 B안: 가격 옆 작은 "25%" 배지(옅은 강조색 바탕 + `accentText`). 프로필 배너·연장 카드는 맥락 때문에 "25% 할인"으로 쓰고, 그라데이션 배너 위에서는 흰 바탕 + 강조색 글자(대비 라이트 5.65, 다크 5.06).
- 남김: "자동 결제 없음, 기간이 끝나면 무료로 돌아가요", 구매 복원.
- PRO 마크 에셋(보라→인디고 둥근 사각형 + 흰 반짝임)을 이용권 시트 머리에, 꽉 찬 PRO 칩 안에서는 흰 반짝임 아이콘.

## 검토한 대안 (Alternatives)
- 할인 A안(흰 글자 리본 유지)·C안(할인 표시 없음): 사용자가 추천안으로 맡겨 B안을 골랐다.
- 칩 안에도 PRO 이미지 마크: 같은 인디고 색에 묻혀 사라져서 반짝임 아이콘으로 바꿨다.

## 결과 (Consequences)
**긍정**
- 결제를 억지로 밀지 않는 화면이 된다. 할인 표시 대비 문제가 사라진다.

**부정**
- 하루·월 환산 같은 가격 설득 정보가 시트에서 없어진다. 프로필 배너에는 하루 가격·할인 전 값이 남는다([[DEC-0272-non-krw-price-hides-won-amounts]]은 그 자리에 계속 적용).

## 영향 범위 (Scope)
- 앱: `widgets/pro/pro_offer_pass_option_list.dart`, `pro_pass_option_tile.dart`, `pro_discount_badge.dart`, `pro_offer_headline.dart`, `pro_offer_sheet.dart`, `profile_upgrade_banner.dart`, `profile_pro_extend_card.dart`, `core/billing/pass_option_pricing.dart`, `core/utils/profile_pass_values.dart`, `design/components/passql_pro_mark.dart`·`passql_plan_chip.dart`, 자산 `app/assets/pro_mark.png`(1x·2.0x·3.0x).

## 출처 (References)
- GitHub #963 완료 보고: https://github.com/Twin-Fang/passQL/issues/963#issuecomment-6803089405
- 시안: 이용권 시트 할인 A·B·C안 (로컬 시안, PR #964)
