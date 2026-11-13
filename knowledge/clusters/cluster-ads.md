---
type: cluster
topic: ads
created: 2026-10-29
members: 27
status: active
related: []
---

# 클러스터: ads

## 이 주제는
광고

## 현재 상태 요약
(2026-11-12) 결제로 산 프로는 광고가 꺼지고, 이용권 혜택 목록에 광고 제거가 있다 — [[DEC-0262-pro-benefits-seven-ad-removal]]. 앱 광고는 수익 우선으로 조정 중이다. 홈·통계 인라인 카드 광고(`AdInlineCard`)와 탭 셸 하단 한 줄 네이티브 띠([[DEC-0153-single-native-strip-under-tab-bar]])는 그대로이고, 결과 화면 전면 광고는 첫 결과 1회 건너뛰고 3분 간격·하루 5회, 탭 화면 복귀 시 앱 오프닝 광고(1시간 간격·하루 3회, 첫 실행·30초 미만·광고 이탈 제외)가 추가됐다 — [[DEC-0238-app-open-ad-and-interstitial-cap-retune]]. 전체 화면 광고는 `FullScreenAdGuard` 한 곳에서 겹침을 막고, 3종 모두 표시 공통 함수(`full_screen_ad_showing.dart`)가 닫힘·표시 실패·`show()` 예외를 1회만 처리한다 — [[ISS-0447-full-screen-ad-show-failure-bonus-retry]]. 무료 한도 소진 시 보상형 광고로 +5문제(하루 2회)를 여는 경로가 생겼고, 보너스 기록 일시 실패는 1회 재시도한다 — [[DEC-0239-free-daily-limit-bonus-three-kinds]](결제 스위치가 꺼져 아직 사용자에게 안 보임). #787·#808·#814는 2026-11-04 릴리스(#817)로 서버는 운영, 앱은 테스트 트랙(TestFlight·Play 내부 테스트)에 반영됐다. 점검 모드에서도 AdMob 보상 서버 검증 콜백은 통과한다 — [[DEC-0273-maintenance-mode-passes-external-callbacks]] (PR #898 머지, 실광고 빌드 보상 기록 확인은 [[ISS-0469-billing-switch-unverified-screens-races]]). 광고 보너스 확인 중 시트를 닫아도 결과 안내가 남고, 광고 경로 로그는 `AppLogger`로 남는다: [[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss]] (#880, main 머지, 배포 전). 열린 이슈 1개. (2026-11-12) 광고 보너스 +5는 횟수 제한 없이 하루 200 공정 사용 상한까지, 서버 측 확인 필수 — [[DEC-0282-ad-bonus-unlimited-fair-use-200]](DEC-0239 대체). 결과 화면 일반 전면 광고는 보상형 전면 광고(+5)로 바뀌었다 — [[DEC-0285-result-rewarded-interstitial]] (#963, PR #964). (2026-11-12) 광고 보너스는 크레딧 시트 안 카드, 주 버튼은 이용권 — [[DEC-0287-credit-term-top-bar-balance]]. (2026-11-12) 잠금화면 위에서는 광고를 열지 않고 잠금을 풀고 앱에서 연다(Play 정책) — [[DEC-0290-lock-screen-question-policy]]. (2026-11-12) 홈 「다음에 할 일」 카드에서는 광고 보상 카드를 빼고, 광고 보상 안내는 한도 시트에 둔다 — [[DEC-0305-home-next-step-no-ad-card-mock-trial]].

## 활성 결정
- [[DEC-0290-lock-screen-question-policy]] — 잠금화면 문제(Android): 무료도 하루 크레딧 공유, 프로 한 문제 더, 광고·결제는 잠금 풀고 앱에서 (#990, 현재 배포 앱은 #1002로 숨김)
- [[DEC-0153-single-native-strip-under-tab-bar]] — 탭별 적응형 배너 대신 메인 탭바 아래 한 줄 네이티브 광고 띠 하나를 상시 둔다
- [[DEC-0238-app-open-ad-and-interstitial-cap-retune]] — 탭 복귀 앱 오프닝 광고 추가, 전면 광고 첫 결과 1회 건너뛰고 3분 간격·하루 5회 (인라인 카드 광고·탭 하단 띠 유지, DEC-0148 대체)
- [[DEC-0262-pro-benefits-seven-ad-removal]] — 혜택 원본 `pro_benefits.dart`, 실제 잠금만, 광고 제거 더해 7개·"새 보기·토픽" (#863, DEC-0205 대체)
- [[DEC-0273-maintenance-mode-passes-external-callbacks]] — 점검 모드에서도 AdMob 보상 검증·App Store 알림 콜백 통과, 경로는 `ExternalCallbackPaths` 한 곳 (#867, PR #898)
- [[DEC-0282-ad-bonus-unlimited-fair-use-200]] — 광고 보너스 +5 횟수 제한 없음, 무료·프로 공통 하루 200 공정 사용 상한, 옛 앱 호환 `adBonusMaxCount = 받은 횟수 + 1` (#963, DEC-0239 대체)
- [[DEC-0283-daily-limit-view-reward-first]] — 무료 랜덤은 끊기지 않게 이어 풀기, 남은 수 상시 표시, 한도 화면은 광고 > 오늘의 세트 > 이용권 한 줄 (#963)
- [[DEC-0285-result-rewarded-interstitial]] — 결과 화면 일반 전면 광고 > 보상형 전면 광고(+5), 토픽 결과는 들어올 때·세트 결과는 떠날 때 (#963)
- [[DEC-0287-credit-term-top-bar-balance]] — 무료 한도는 `크레딧`, 잔액은 탭 상단 바 알약(누르면 크레딧 시트: PRO 주 버튼 > 광고 > 오늘의 세트), 상태는 아이콘·색 (#966, #971)
- [[DEC-0305-home-next-step-no-ad-card-mock-trial]] — 홈 「다음에 할 일」 카드는 광고를 권하지 않고, 크레딧 0이면 모의고사 무료 1회 카드 또는 숨김 (#980)

## 대체된 결정 (역사)
- [[DEC-0239-free-daily-limit-bonus-three-kinds]] → DEC-0282
- [[DEC-0148-inline-card-ads-interstitial-cap]] → DEC-0238

## 관련 이슈
- [[ISS-0493-first-launch-push-prompt-common-sense-fixes]] (resolved, GitHub #980, PR #981): 첫 실행 알림 안내 없음, 결과 화면 번호뿐인 목록, 크레딧 0일 때 홈 광고 권유
- [[ISS-0513-admin-app-operation-settings]] (resolved, GitHub #961, PR #969): 최소 버전 입구가 둘, 결제 켜기 전 점검표 없음, 비밀 설정 미설정 문구 오해
- [[ISS-0501-lock-screen-question-android]] (resolved, #990): 잠금화면 위 SQLD 문제 1개(Android), 서버 출제 API·운영 설정 3개
- [[ISS-0490-credit-term-purchase-funnel-events]] (resolved, GitHub #971, PR #973): 구매·광고 흐름 분석 이벤트 없음, 한도·보상 표현이 여러 말로 겹침(크레딧으로 통일), 탭 제목 정렬
- [[ISS-0488-free-practice-reward-flow]] (resolved, GitHub #963, PR #964): 무료 랜덤 10문제 끊김, 남은 한도 안 보임, 한도 화면 광고 버튼 묻힘, 세트 보너스 표시 없음, 이용권 시트 문구 과다
- [[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss]] (resolved, GitHub #880): 앱 전체 점검: iOS UIScene 대응, 새로고침 시 등급 깜빡임, 확인 중 시트 닫힘, 결제 로그
- [[ISS-0469-billing-switch-unverified-screens-races]] (open, GitHub #867, PR #898 머지) — 결제 스위치 켜기 전 미확인 화면과 경합 점검: 제출 거부 사유 시트, 동시 제출 한도, 점검 중 외부 콜백, 해외 가격
- [[ISS-0447-full-screen-ad-show-failure-bonus-retry]] (resolved, GitHub #814) — 광고 표시 실패 시 전체 화면 광고 멈춤, 보너스 요청 재시도 없음
- [[ISS-0442-app-open-ad-interstitial-cap-relax]] (resolved, GitHub #787) — 앱 오프닝 광고 추가와 결과 화면 전면 광고 빈도 완화
- [[ISS-0443-free-daily-limit-bonus]] (resolved, GitHub #808) — 무료 하루 한도 보너스 (오늘의 세트 완료·정답률·보상형 광고)
- [[ISS-0304-ads-rewarded-banner-pro-hide]] (resolved, GitHub #499) — 광고 도입(보상형·하단 배너) → Pro 회원 광고 숨김
- [[ISS-0311-admob-ads-integration]] (resolved, GitHub #506) — AdMob 광고 연동 (배너·네이티브·전면)
- [[ISS-0307-app-quality-roadmap]] (resolved, GitHub #502) — 앱 품질 고도화 로드맵 (모션, AI 해설, 성능, 크레딧, 광고, 모의고사)
- [[ISS-0320-ads-cards-notification-sheet-home]] (resolved, GitHub #522) — 하단 상시 광고 제거, 광고 카드화, 알림 권한 시트와 홈 카드 정리
- [[ISS-0324-tab-bar-native-ad-strip]] (resolved, GitHub #527) — 하단 탭바 아래 한 줄 상시 광고 띠 (네이티브)
