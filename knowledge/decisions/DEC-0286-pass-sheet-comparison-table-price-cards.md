---
type: decision
id: DEC-0286
created: 2026-11-12
reviewed: null
topics: [billing, design-system]
status: active
supersedes: DEC-0284
superseded_by: null
related: ["[[ISS-0489-pass-sheet-home-profile-cleanup]]", "[[DEC-0284-pass-sheet-plain-copy-small-discount-badge]]", "[[DEC-0272-non-krw-price-hides-won-amounts]]"]
---

# DEC-0286: 이용권 시트는 나란한 가격 카드(줄 그은 정가 + -25%)와 접지 않는 무료·프로 비교표로 보여 준다

## 문제 정의 (Context)
1.96.0 을 본 사용자가 "PRO로 달라지는 점은 FREE·PRO 차이를 표 같은 것으로 한 번에", "더 보기·접기 말고 그냥 보여야", "25% 싸게 하는 것은 실가격이 얼마고 줄 그어 보여야", "빨간 할인 배지 위치가 이상하다", "아이콘이 알록달록하다"고 했다 (GitHub #966).

## 결정 (Decision)
- 혜택 3줄 + 더 보기·접기를 없애고 무료·프로 비교표(회색 카드, PRO 칸만 흰 카드 + 강조색 머리)로 8줄을 한 번에 보인다. 왼쪽 제목은 짧게, 아이콘 없음. 모의고사 줄을 더한다.
- 이용권 칸은 나란한 카드 두 장: 기간, 큰 가격, 줄 그은 정가 + `-25%`, 만료일. 가격 카드가 표 위.
- 탑승권 혜택 아이콘은 한 색 픽토그램, `승객`은 `수험생`, 바코드는 세로.
- 줄 그은 정가를 다시 넣었으므로 [[DEC-0284-pass-sheet-plain-copy-small-discount-badge]]의 "정가 줄긋기 삭제"를 바꾼다. 하루·월 환산, 권유 줄, "가장 많이 골라요"를 두지 않는 것은 그대로다.

## 검토한 대안 (Alternatives)
- 표 모양 A안(줄 표)·C안(혜택 색 아이콘): 사용자가 가운데 B안을 골랐고, 색 아이콘은 알록달록해서 버렸다.
- 표에 한 색 픽토그램: 한 화면에 안 들어가 아이콘을 뺐다.
- 이용권 칸 얇은 줄 두 개: 나란한 카드가 가격 비교가 쉬워 골랐다.
- 빨간 `25% 할인` 배지: 위치가 어색하다는 지적으로 버렸다.

## 결과 (Consequences)
**긍정**
- 무료와 프로의 차이, 할인 전후 가격이 스크롤 없이 한 화면에 보인다.

**부정**
- 비교표 줄(모의고사, 광고)은 탑승권 아이콘 줄의 혜택 목록과 따로 관리된다(`pro_comparison_rows.dart` 가 혜택 원본에서 만들고 2줄을 덧붙임).

## 영향 범위 (Scope)
- 앱: `widgets/pro/pro_offer_sheet.dart`, `pro_offer_comparison_table.dart`, `pro_comparison_rows.dart`, `pro_pass_option_tile.dart`, `pro_offer_pass_option_list.dart`, `pro_discount_badge.dart`, `design/components/pass_ticket/`.

## 출처 (References)
- GitHub #966 구현 보고: https://github.com/Twin-Fang/passQL/issues/966#issuecomment-6811416858
