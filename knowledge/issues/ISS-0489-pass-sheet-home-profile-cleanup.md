---
type: issue
id: ISS-0489
created: 2026-11-12
topics: [billing, design-system, home, practice]
symptoms: ["PRO로 달라지는 점 더 보기 접기", "25% 할인 정가 안 보임", "혜택 아이콘 알록달록", "이용권으로 열기 딱딱함", "영역별 정답률 잠금 모양 다름", "오늘의 세트 완료 배지 위치", "랜덤 풀기 오늘의 세트 카드 안", "승객", "pro_offer_sheet", "daily_set_section"]
root_cause: "혜택을 접어 보이고 정가 없이 할인율만 보여 무료·프로 차이와 할인 폭이 한눈에 안 보였고, 홈·프로필은 서로 다른 기능과 상태가 한 카드에 섞여 있었다"
status: resolved
resolution: "[[ISS-0489-pass-sheet-home-profile-cleanup-report]]"
related: ["[[DEC-0286-pass-sheet-comparison-table-price-cards]]", "[[DEC-0287-credit-term-top-bar-balance]]", "[[ISS-0488-free-practice-reward-flow]]"]
source: "https://github.com/Twin-Fang/passQL/issues/966"
---

# ISS-0489: 이용권 시트 비교표와 홈·프로필 정리

GitHub #966.

## 증상
1.96.0 출시 뒤 사용자가 실기기에서 본 문제.
- 이용권 시트: 혜택 3줄 + "N가지 더 보기·접기", 3개월권에 정가 없이 `25%` 만, 탑승권 혜택 아이콘이 색색.
- 잠금 자리: "이용권으로 열기", "AI 약점 분석 · 다음 공부 추천" 같은 명사 나열이 딱딱함. 프로필 영역별 정답률만 잠금 모양이 다름.
- 홈: "[완료] 오늘의 세트 0 / 정답" 한 줄이 어색하고, 랜덤 풀기가 오늘의 세트 카드 안에 있음.
- 프로필 보너스 3종이 회색 칸.

## 재현 조건
결제 켜짐 + 무료 회원.

## 조사 기록
- 2026-11-12: HTML 시안 여러 판 > 사용자가 "지금 UI 와 너무 다르다"고 지적 > 실제 코드 렌더로 지금 화면을 먼저 보고 그 위에서 고침.

## 근본 원인
혜택을 접어 보이고 정가 없이 할인율만 보여 차이와 할인 폭이 한눈에 안 보였고, 홈·프로필은 서로 다른 기능과 상태가 한 카드에 섞여 있었다.
