---
type: cluster
topic: ads
created: 2026-10-29
members: 12
status: active
related: []
---

# 클러스터: ads

## 이 주제는
광고

## 현재 상태 요약
(2026-11-04) 앱 광고는 수익 우선으로 조정 중이다. 홈·통계 인라인 카드 광고(`AdInlineCard`)와 탭 셸 하단 한 줄 네이티브 띠([[DEC-0153-single-native-strip-under-tab-bar]])는 그대로이고, 결과 화면 전면 광고는 첫 결과 1회 건너뛰고 3분 간격·하루 5회, 탭 화면 복귀 시 앱 오프닝 광고(1시간 간격·하루 3회, 첫 실행·30초 미만·광고 이탈 제외)가 추가됐다 — [[DEC-0238-app-open-ad-and-interstitial-cap-retune]]. 전체 화면 광고는 `FullScreenAdGuard` 한 곳에서 겹침을 막고, 3종 모두 표시 공통 함수(`full_screen_ad_showing.dart`)가 닫힘·표시 실패·`show()` 예외를 1회만 처리한다 — [[ISS-0447-full-screen-ad-show-failure-bonus-retry]]. 무료 한도 소진 시 보상형 광고로 +5문제(하루 2회)를 여는 경로가 생겼고, 보너스 기록 일시 실패는 1회 재시도한다 — [[DEC-0239-free-daily-limit-bonus-three-kinds]](결제 스위치가 꺼져 아직 사용자에게 안 보임). #787·#808·#814는 2026-11-04 릴리스(#817)로 서버는 운영, 앱은 테스트 트랙(TestFlight·Play 내부 테스트)에 반영됐다. 열린 이슈 2개.

## 활성 결정
- [[DEC-0153-single-native-strip-under-tab-bar]] — 탭별 적응형 배너 대신 메인 탭바 아래 한 줄 네이티브 광고 띠 하나를 상시 둔다
- [[DEC-0238-app-open-ad-and-interstitial-cap-retune]] — 탭 복귀 앱 오프닝 광고 추가, 전면 광고 첫 결과 1회 건너뛰고 3분 간격·하루 5회 (인라인 카드 광고·탭 하단 띠 유지, DEC-0148 대체)
- [[DEC-0239-free-daily-limit-bonus-three-kinds]] — 무료 랜덤 풀기 한도 기본 10 + 세트 완료·정답률·보상형 광고(+5×2) 보너스, 최대 30

## 대체된 결정 (역사)
- [[DEC-0148-inline-card-ads-interstitial-cap]] → DEC-0238

## 관련 이슈
- [[ISS-0447-full-screen-ad-show-failure-bonus-retry]] (resolved, GitHub #814) — 광고 표시 실패 시 전체 화면 광고 멈춤, 보너스 요청 재시도 없음
- [[ISS-0442-app-open-ad-interstitial-cap-relax]] (resolved, GitHub #787) — 앱 오프닝 광고 추가와 결과 화면 전면 광고 빈도 완화
- [[ISS-0443-free-daily-limit-bonus]] (resolved, GitHub #808) — 무료 하루 한도 보너스 (오늘의 세트 완료·정답률·보상형 광고)
- [[ISS-0304-ads-rewarded-banner-pro-hide]] (open, GitHub #499) — 광고 도입(보상형·하단 배너) → Pro 회원 광고 숨김
- [[ISS-0311-admob-ads-integration]] (open, GitHub #506) — AdMob 광고 연동 (배너·네이티브·전면)
- [[ISS-0307-app-quality-roadmap]] (resolved, GitHub #502) — 앱 품질 고도화 로드맵 (모션, AI 해설, 성능, 크레딧, 광고, 모의고사)
- [[ISS-0320-ads-cards-notification-sheet-home]] (resolved, GitHub #522) — 하단 상시 광고 제거, 광고 카드화, 알림 권한 시트와 홈 카드 정리
- [[ISS-0324-tab-bar-native-ad-strip]] (resolved, GitHub #527) — 하단 탭바 아래 한 줄 상시 광고 띠 (네이티브)
