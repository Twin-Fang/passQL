---
type: issue
id: ISS-0488
created: 2026-11-12
topics: [practice, billing, ads, design-system]
symptoms: ["랜덤 풀기 10문제마다 끊김", "남은 한도 안 보임", "한도 소진 광고 버튼 못 찾음", "세트 보너스 안 보임", "이용권 3개월 권유 문구", "하루 약 110원", "25% 할인 리본 검은 글자", "보상형 광고 하루 2회", "RewardedAdBonusButton", "pro_offer_sheet"]
root_cause: "결제를 켠 뒤의 무료 흐름이 10문제 묶음·구매 권유 우선 시트로 설계돼, 보상과 남은 한도가 보이지 않고 결제를 미는 문구가 겹쳤다"
status: resolved
resolution: "[[ISS-0488-free-practice-reward-flow-report]]"
related: ["[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0283-daily-limit-view-reward-first]]", "[[DEC-0284-pass-sheet-plain-copy-small-discount-badge]]", "[[DEC-0285-result-rewarded-interstitial]]", "[[ISS-0485-billing-test-setup-e2e]]", "[[ISS-0361-billing-switch-final-checks]]"]
source: "https://github.com/Twin-Fang/passQL/issues/963"
---

# ISS-0488: 무료 랜덤 풀이와 보상 흐름 재설계 (끊기지 않는 풀이, 남은 수, 보상 먼저, 이용권 시트 정리)

GitHub #963 (처음에는 "광고 보너스 진입 화면 개선"으로 열렸다가 2026-11-12 전체 재설계로 넓혔다).

## 증상
2026-11-11 결제 스위치를 켠 뒤 사용자가 무료 계정(Android·iOS)으로 직접 풀어 보며 나온 문제.
- 랜덤 풀이가 10문제 묶음이라 10문제마다 결과 화면("챕터 결과" 재사용) > 홈 > 다시 진입을 거쳐야 함.
- 남은 한도가 풀이 중 어디에도 없음. 3문제 남아도 "1 / 10"으로 시작해 중간에 갑자기 막힘.
- 한도에 닿으면 "이용권으로 열기" 하나뿐이고, 광고 보너스 버튼은 구매 권유 아래 네 번째 블록. 시트를 닫으면 막다른 길.
- 세트 완료 +5, 정답 80% +5 보상이 오늘의 세트 결과의 회색 글 한두 줄뿐.
- 이용권 시트에 3개월 권유 줄, 하루·월 환산, 줄 그은 정가, 빨간 바탕 검은 글자의 "25% 할인 · 가장 많이 골라요" 리본.

## 재현 조건
결제 켜짐 + 무료 회원 + 랜덤 풀기.

## 조사 기록
- 2026-11-12: 코드 추적으로 흐름 단계와 결함 목록 확정(풀이 화면 `chapter_page`, 한도 시트 `pro_offer_sheet`, 랜덤 흐름 `random_practice_flow`, 서버 `RandomPracticeService` 안 푼·푼 문제 섞음).
- 2026-11-12: 설계 문서와 시안(한도 A·B안, 할인 A·B·C안) > 사용자가 추천안으로 맡김.

## 근본 원인
결제를 켠 뒤의 무료 흐름이 10문제 묶음과 구매 권유 우선 시트로 짜여 있어, 보상과 남은 한도가 보이지 않고 결제를 미는 문구가 겹쳤다.
