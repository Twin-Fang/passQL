---
type: completion-report
id: ISS-0488
created: 2026-11-12
topics: [practice, billing, ads, design-system]
status: resolved
resolves: "[[ISS-0488-free-practice-reward-flow]]"
related: ["[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[DEC-0283-daily-limit-view-reward-first]]", "[[DEC-0284-pass-sheet-plain-copy-small-discount-badge]]", "[[DEC-0285-result-rewarded-interstitial]]"]
source: "https://github.com/Twin-Fang/passQL/issues/963"
---

# ISS-0488 완료 리포트: 끊기지 않는 랜덤 풀이, 남은 수 표시, 보상 먼저인 한도 화면, 담백한 이용권 시트, 보상형 전면 광고

## 해결 방법
PR #964 (브랜치 `20261112_#963_기능개선_앱_무료_랜덤_풀이와_보상_흐름_재설계`).
- 서버: 광고 보너스 횟수 제한 제거, 무료·프로 공통 하루 200 공정 사용 상한, 옛 앱 호환 `adBonusMaxCount = 받은 횟수 + 1`, 랜덤 안 푼 문제 먼저 — [[DEC-0282-ad-bonus-unlimited-fair-use-200]].
- 앱: 남은 수 알약과 홈 줄, 이어 풀기와 요약, 한도 A안 화면(본문·시트), 보상 연출 — [[DEC-0283-daily-limit-view-reward-first]].
- 이용권 시트 문구 정리와 작은 할인 배지, PRO 마크 — [[DEC-0284-pass-sheet-plain-copy-small-discount-badge]].
- 결과 화면 보상형 전면 광고 — [[DEC-0285-result-rewarded-interstitial]].
- 운영: AdMob 보상형 전면 광고 단위 2개와 서버 측 확인 콜백, `ads.reward.ssv_ad_unit_ids`, 앱 `.env`·GitHub Secret `ENV_FILE`.
- 검증: 서버 빌드, 앱 analyze·141 테스트, 웹 49 테스트·타입 검사 통과. 과제별 리뷰와 최종 리뷰. 핵심 화면 라이트·다크 위젯 렌더(이때 보상 연출 게이지가 높이 0으로 안 그려지던 버그를 찾아 고침).

## 근본 원인 (확정)
결제를 켠 뒤의 무료 흐름이 10문제 묶음과 구매 권유 우선 시트로 설계돼 있었다.

## 재발 방지
- 옛 앱 호환 값(`adBonusMaxCount`)을 새 화면이 "남은 횟수"로 쓰지 않는다(최종 리뷰에서 프로필 "1번 남음" 사본을 잡음).
- 새 보상형 광고 단위는 운영 `ads.reward.ssv_ad_unit_ids`에 넣고 서버 측 확인을 켜야 보너스가 확인된다.
- 결과 화면처럼 연출·광고 안내·잠금 창이 겹칠 수 있는 곳의 대화상자는 맨 위 창이 아니라 자기 창을 닫는다(`closePassqlDialogRoute`).

## 교훈
- 화면 개편 뒤에는 실기기가 어려워도 위젯 렌더로 라이트·다크를 한 번은 본다. 테스트·리뷰를 다 통과한 게이지 버그가 그림에서만 드러났다.
