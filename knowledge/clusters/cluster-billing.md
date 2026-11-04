---
type: cluster
topic: billing
created: 2026-10-29
members: 34
status: active
related: []
---

# 클러스터: billing

## 이 주제는
무료/프로 등급, 이용권 상품과 가격, 스토어(Play·App Store) 결제 검증, 결제 스위치. 서버 `FeatureAccessPolicy`가 등급 판정의 유일한 지점이다.

## 현재 상태 요약
(2026-11-04) 상품은 1개월권 ₩4,400·3개월권 ₩9,900 기간제 이용권, 자동 갱신 없음, 3개월권 기본 선택 — [[DEC-0003-one-and-three-month-pass]]. 무료/프로 경계는 [[DEC-0004-free-pro-feature-boundary]]. Android(Play 일회성)·iOS(비갱신 구독) 결제와 iOS·웹 잠금은 구현됐지만 결제 스위치는 전체로는 꺼진 채 — [[DEC-0005-ship-with-billing-switch-off]]. 2026-10-23부터 관리자 설정 `billing.preview_member_uuids`에 등록된 심사 계정만 결제가 켜지고, iOS 1.41.0 + 이용권 2개가 심사 대기 중이다. 켜기 전 남은 일(Apple 심사 결과, 실구매·환불 확인, Play 프로덕션, 최소 버전 1.41.0 상향)은 [[ISS-0361-billing-switch-final-checks]](열림, GitHub #596). 무료 랜덤 풀기 한도는 기본 10 + 보너스 3종(세트 완료 +5, 세트 정답률 80% +5, 보상형 광고 +5×2, 최대 30)이고, 응답은 `dailyFreeLimit`(기본 10) 외에 `todayFreeLimit`·`dailyBonus`를 준다 — [[DEC-0239-free-daily-limit-bonus-three-kinds]](2026-11-04 #817 릴리스로 서버 운영 반영, 앱은 테스트 트랙). 한도 초기화는 하루(KST 0시)를 유지하고 시간 충전은 하지 않는다 — [[DEC-0245-free-limit-daily-reset-kept]]. 프로필 상단은 A안(계정 줄, 무료 오늘 남은 문제·업그레이드 배너, 프로 PRO 탑승권 카드 + 이어서 연장) — [[DEC-0243-profile-top-card-style-a]], 계정·이용권 화면 `/account`와 내 구매 내역 API(`GET /api/members/me/purchases`), 이용권 시트 할인 리본·하루 가격이 생겼다(PR #822, 작성 시점 미머지). 프로모션 코드는 스토어 코드만 쓴다 — [[DEC-0244-promo-code-store-codes-only]]. 결제 스위치를 켤 때 최소 지원 버전을 보너스 기능이 들어간 버전으로 올려야 한다.

## 활성 결정
- [[DEC-0003-one-and-three-month-pass]] — 1개월권 ₩4,400 · 3개월권 ₩9,900 기간제 이용권 (자동 갱신 없음)
- [[DEC-0004-free-pro-feature-boundary]] — 무료/프로 기능 경계 — 무료도 계속 쓸 수 있되 쓸수록 프로가 아쉬운 구조
- [[DEC-0005-ship-with-billing-switch-off]] — 결제 기능은 결제 스위치(`billing.android.enabled`)를 끈 채로 배포한다
- [[DEC-0006-ios-non-renewing-web-no-purchase]] — iOS는 App Store 비갱신 구독으로 판매, 웹은 결제 없이 앱 구매 안내만
- [[DEC-0007-hold-pass-review-until-switch-on]] — iOS 이용권 심사는 결제 스위치를 켤 버전과 함께 제출한다
- [[DEC-0175-record-store-paid-amount-nonblocking]] — 구매 기록 금액은 레포 상수가 아니라 스토어 실결제액으로 저장하고, 금액 조회 실패는 구매 확인을 막지 않는다(NULL 저장)
- [[DEC-0205-pro-benefits-single-source]] — 앱 이용권 혜택 목록은 `pro_benefits.dart` 한 곳을 원본으로 쓰고, 실제 잠금이 있는 기능만 보인다
- [[DEC-0207-pass-ticket-upright-float-shadow]] — passQL PASS 탑승권은 시트에서도 기울이지 않고 정방향으로 두고, 띄움 그림자만 쓴다
- [[DEC-0210-benefit-icons-reuse-app-icons]] — 이용권 혜택 아이콘은 앱에서 같은 기능에 이미 쓰는 아이콘으로 통일한다
- [[DEC-0211-benefit-colors-per-benefit]] — 혜택 아이콘 색은 혜택마다 다른 색으로 두고, 출제 경향 불꽃만 문제 탭 불꽃 색(`warning`)을 쓴다
- [[DEC-0212-keep-benefit-icon-row-in-ticket]] — 탑승권 안의 혜택 아이콘 줄은 유지한다 (세 곳 모양 통일)
- [[DEC-0239-free-daily-limit-bonus-three-kinds]] — 무료 랜덤 풀기 한도 기본 10 + 세트 완료·정답률·보상형 광고(+5×2) 보너스, 최대 30, 광고는 앱 신고 방식
- [[DEC-0243-profile-top-card-style-a]] — 프로필 상단 A안(카드형): 계정 줄 + 무료는 탑승권 대신 오늘 남은 문제·업그레이드 배너, 프로는 남은 날 큰 숫자 PRO 탑승권 카드(승객 · 만료일 · 이용권) + 이어서 연장 (DEC-0208 대체)
- [[DEC-0244-promo-code-store-codes-only]] — 프로모션 코드는 스토어 코드만(iOS 오퍼 코드, Android Play 프로모 코드), 자체 서버 코드 없음(가이드라인 3.1.1), 운영 보상은 관리자 부여 유지
- [[DEC-0245-free-limit-daily-reset-kept]] — 무료 한도 초기화는 하루(KST 0시) 유지, 시간 충전 안 함

- [[DEC-0247-promo-site-free-banner-while-billing-off]] — 결제 스위치가 꺼진 동안 소개 사이트는 비교표 대신 "지금은 모든 기능이 무료" 안내 (`IS_PRO_PLAN_VISIBLE`)

## 대체된 결정 (역사)
- [[DEC-0001-pro-monthly-yearly-subscription]] → DEC-0002
- [[DEC-0002-exam-pass-until-next-sqld]] → DEC-0003
- [[DEC-0208-pass-ticket-fields-unified]] → DEC-0243

## 관련 이슈
- [[ISS-0450-promo-site-dynamic-revamp]] (resolved, GitHub #823) — 소개 사이트 무료 안내(결제 꺼짐 동안)
- [[ISS-0448-mypage-account-pass-area-promo-code]] (resolved, GitHub #816) — 마이페이지 계정·이용권 영역과 결제 유도, 할인 표시, 프로모션 코드
- [[ISS-0447-full-screen-ad-show-failure-bonus-retry]] (resolved, GitHub #814) — 광고 표시 실패 시 전체 화면 광고 멈춤, 보너스 요청 재시도 없음
- [[ISS-0443-free-daily-limit-bonus]] (resolved, GitHub #808) — 무료 하루 한도 보너스 (오늘의 세트 완료·정답률·보상형 광고)
- [[ISS-0304-ads-rewarded-banner-pro-hide]] (open, GitHub #499) — 광고 도입(보상형·하단 배너) → Pro 회원 광고 숨김
- [[ISS-0358-concept-learning-by-unit]] (open, GitHub #577) — 단원별 개념 학습 (수험서 대체)
- [[ISS-0361-billing-switch-final-checks]] (open, GitHub #596) — 결제 스위치 켜기 전 최종 점검 (실구매·심사·최소 버전)
- [[ISS-0400-business-info-display-kollylab]] (open, GitHub #658) — 앱·웹·사이트 사업자 정보 표기 (콜리랩)
- [[ISS-0003-free-pro-plan-android-exam-pass]] (resolved, GitHub #576) — 무료, 프로 플랜과 Android 회차 패스 결제
- [[ISS-0004-ios-web-pro-lock-before-billing]] (resolved, GitHub #578) — iOS 앱, 웹 무료 프로 잠금 화면 (결제 켜기 전 선행)
- [[ISS-0005-replace-exam-pass-with-period-pass]] (resolved, GitHub #591) — 회차 패스를 1개월, 3개월 이용권으로 교체 (서버, Android)
- [[ISS-0303-basic-pro-tiers-credits]] (resolved, GitHub #498) — 기본·Pro 등급과 크레딧 (잔액 확인, 매일 지급, 관리자 지급)
- [[ISS-0306-pro-subscription-credit-iap]] (resolved, GitHub #501) — Pro 구독과 크레딧 구매 인앱 결제 연동
- [[ISS-0307-app-quality-roadmap]] (resolved, GitHub #502) — 앱 품질 고도화 로드맵 (모션, AI 해설, 성능, 크레딧, 광고, 모의고사)
- [[ISS-0374-admin-subscription-revenue-dashboard]] (resolved, GitHub #619) — 관리자에 구독·매출 현황이 없고, 구매 기록에 금액·통화가 저장되지 않음
- [[ISS-0428-app-profile-tab-redesign]] (resolved, GitHub #749) — 앱 내 프로필 탭 UI/UX 개편 (정보 위계 재구성, passQL PASS 탑승권)
