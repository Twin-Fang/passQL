---
type: cluster
topic: billing
created: 2026-10-29
members: 65
status: active
related: []
---

# 클러스터: billing

## 이 주제는
무료/프로 등급, 이용권 상품과 가격, 스토어(Play·App Store) 결제 검증, 결제 스위치. 서버 `FeatureAccessPolicy`가 등급 판정의 유일한 지점이다.

## 현재 상태 요약
(2026-11-12) 상품은 1개월권 ₩4,400·3개월권 ₩9,900 기간제 이용권, 자동 갱신 없음, 3개월권 기본 선택 — [[DEC-0003-one-and-three-month-pass]]. 무료/프로 경계는 [[DEC-0004-free-pro-feature-boundary]]. Android(Play 일회성)·iOS(비갱신 구독) 결제와 iOS·웹 잠금은 구현됐지만 결제 스위치는 전체로는 꺼진 채 — [[DEC-0005-ship-with-billing-switch-off]]. 2026-10-23부터 관리자 설정 `billing.preview_member_uuids`에 등록된 심사 계정만 결제가 켜지고, iOS 1.41.0 + 이용권 2개가 심사 대기 중이다. 켜기 전 남은 일(Apple 심사 결과, 실구매·환불 확인, Play 프로덕션, 최소 버전 1.41.0 상향)은 [[ISS-0361-billing-switch-final-checks]](열림, GitHub #596). 무료 랜덤 풀기 한도는 기본 10 + 보너스 3종(세트 완료 +5, 세트 정답률 80% +5, 보상형 광고 +5×2, 최대 30)이고, 응답은 `dailyFreeLimit`(기본 10) 외에 `todayFreeLimit`·`dailyBonus`를 준다 — [[DEC-0239-free-daily-limit-bonus-three-kinds]](2026-11-04 #817 릴리스로 서버 운영 반영, 앱은 테스트 트랙). 한도 초기화는 하루(KST 0시)를 유지하고 시간 충전은 하지 않는다 — [[DEC-0245-free-limit-daily-reset-kept]]. 프로필 상단은 A안(계정 줄, 무료 오늘 남은 문제·업그레이드 배너, 프로 PRO 탑승권 카드 + 이어서 연장)이고, 구매 내역·구매 복원·프로모션 코드 행은 계정·이용권 화면 `/account` 한 곳·프로필은 "이용권 관리" 한 줄이고 이 구조는 [[DEC-0276-account-provider-icon-email-avatar]] (#908, DEC-0263 대체)가 이어받았다. 통계 정답률 상세(난이도별, 오답 정리)는 프로 `TOPIC_ANALYSIS`, 학습 패턴은 무료: [[DEC-0274-stats-radar-above-list-study-pattern-free]] (#909). 결제나 광고 보너스 확인 중 시트를 닫아도 결과 안내와 재시도가 남는다: [[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss]] (#880). 이상 main 머지, 배포 전. 내 구매 내역 API(`GET /api/members/me/purchases`), 이용권 시트 할인 리본·하루 가격이 있다. 이용권 혜택은 `pro_benefits.dart` 원본, 실제 잠금만, 광고 제거를 더한 7개 — [[DEC-0262-pro-benefits-seven-ad-removal]] (DEC-0205 대체). 프로 핵심 기능 SQLD 모의고사는 무료 1회 체험·프로 무제한 — [[DEC-0264-mock-exam-fixed-rounds-server-judged]] (PR #889 머지, 이슈 #866 열림). 프로모션 코드는 스토어 코드만 쓴다 — [[DEC-0244-promo-code-store-codes-only]]. 결제 스위치를 켤 때 최소 지원 버전을 보너스 기능이 들어간 버전으로 올려야 한다. 켜기 전 미확인 화면·경합 점검은 [[ISS-0469-billing-switch-unverified-screens-races]](열림, GitHub #867, PR #898 머지): 하루 한도 판정은 제출 기록 트랜잭션 안 회원 행 잠금 뒤 — [[DEC-0271-daily-limit-judged-in-submit-record-tx]], 원화가 아닌 스토어 가격은 원 환산 금액을 숨김 — [[DEC-0272-non-krw-price-hides-won-amounts]], 점검 모드에서도 외부 콜백 통과 — [[DEC-0273-maintenance-mode-passes-external-callbacks]]. 실기기 한도 소진·광고 보너스·동시 제출 확인과 `ads.reward.ssv_required` 켜기는 사람이 할 일로 남았다. 결제 시험 환경 세팅·E2E 는 열림, 운영 `billing.play_service_account_json`·`ads.reward.ssv_ad_unit_ids` 가 비어 있다 — [[ISS-0485-billing-test-setup-e2e]]. (2026-11-12) 결제 스위치를 켠 뒤 무료 흐름을 다시 짰다(#963, PR #964): 광고 보너스 횟수 제한 없음 + 하루 200 공정 사용 상한 — [[DEC-0282-ad-bonus-unlimited-fair-use-200]](DEC-0239 대체), 한도 화면은 보상 먼저 — [[DEC-0283-daily-limit-view-reward-first]], 이용권 시트는 권유 문구 없이 작은 할인 배지 — [[DEC-0284-pass-sheet-plain-copy-small-discount-badge]]. (2026-11-12) 이용권 시트는 나란한 가격 카드와 무료·프로 비교표 — [[DEC-0286-pass-sheet-comparison-table-price-cards]](DEC-0284 대체), 무료 한도는 크레딧으로 부르고 상단 알약에서 크레딧 시트로 — [[DEC-0287-credit-term-top-bar-balance]]. 구매·광고 흐름 분석 이벤트는 [[ISS-0490-credit-term-purchase-funnel-events]]. (2026-11-12) 프로필 크레딧 「내역」은 날짜별 화면이며, 따로 저장하지 않고 한도 판정 원본에서 계산한다 — [[DEC-0290-credit-history-computed-from-limit-records]]. 결제 스위치·미리보기 회원·켜기 전 점검표는 관리자 앱 운영 화면 한 곳에 있다 — [[DEC-0292-admin-app-operation-single-entry]].

## 활성 결정
- [[DEC-0003-one-and-three-month-pass]] — 1개월권 ₩4,400 · 3개월권 ₩9,900 기간제 이용권 (자동 갱신 없음)
- [[DEC-0004-free-pro-feature-boundary]] — 무료/프로 기능 경계 — 무료도 계속 쓸 수 있되 쓸수록 프로가 아쉬운 구조
- [[DEC-0005-ship-with-billing-switch-off]] — 결제 기능은 결제 스위치(`billing.android.enabled`)를 끈 채로 배포한다
- [[DEC-0006-ios-non-renewing-web-no-purchase]] — iOS는 App Store 비갱신 구독으로 판매, 웹은 결제 없이 앱 구매 안내만
- [[DEC-0007-hold-pass-review-until-switch-on]] — iOS 이용권 심사는 결제 스위치를 켤 버전과 함께 제출한다
- [[DEC-0175-record-store-paid-amount-nonblocking]] — 구매 기록 금액은 레포 상수가 아니라 스토어 실결제액으로 저장하고, 금액 조회 실패는 구매 확인을 막지 않는다(NULL 저장)
- [[DEC-0207-pass-ticket-upright-float-shadow]] — passQL PASS 탑승권은 시트에서도 기울이지 않고 정방향으로 두고, 띄움 그림자만 쓴다
- [[DEC-0210-benefit-icons-reuse-app-icons]] — 이용권 혜택 아이콘은 앱에서 같은 기능에 이미 쓰는 아이콘으로 통일한다
- [[DEC-0211-benefit-colors-per-benefit]] — 혜택 아이콘 색은 혜택마다 다른 색으로 두고, 출제 경향 불꽃만 문제 탭 불꽃 색(`warning`)을 쓴다
- [[DEC-0212-keep-benefit-icon-row-in-ticket]] — 탑승권 안의 혜택 아이콘 줄은 유지한다 (세 곳 모양 통일)
- [[DEC-0244-promo-code-store-codes-only]] — 프로모션 코드는 스토어 코드만(iOS 오퍼 코드, Android Play 프로모 코드), 자체 서버 코드 없음(가이드라인 3.1.1), 운영 보상은 관리자 부여 유지
- [[DEC-0245-free-limit-daily-reset-kept]] — 무료 한도 초기화는 하루(KST 0시) 유지, 시간 충전 안 함

- [[DEC-0247-promo-site-free-banner-while-billing-off]] — 결제 스위치가 꺼진 동안 소개 사이트는 비교표 대신 "지금은 모든 기능이 무료" 안내 (`IS_PRO_PLAN_VISIBLE`)
- [[DEC-0258-ai-comment-pro-only-all-forms]] — AI 코멘트는 결과·통계 모두 프로 전용 (#699 무료 하루 1회 폐지, #860)
- [[DEC-0262-pro-benefits-seven-ad-removal]] — 혜택 원본 `pro_benefits.dart`, 실제 잠금만, 광고 제거 더해 7개·"새 보기·토픽" (#863, DEC-0205 대체)
- [[DEC-0264-mock-exam-fixed-rounds-server-judged]] — SQLD 모의고사: 관리자 고정 회차(검증 세트), 시간·채점·응시 수 서버 판정, 무료 1회 체험·프로 무제한 (#866)
- [[DEC-0271-daily-limit-judged-in-submit-record-tx]] — 무료 하루 한도 판정은 제출 기록 트랜잭션 안, 회원 행 잠금 뒤 (#867, PR #898)
- [[DEC-0272-non-krw-price-hides-won-amounts]] — 원화가 아닌 스토어 가격은 원 환산 금액을 숨기고 가격 문자열·할인율만 (#867, PR #898)
- [[DEC-0273-maintenance-mode-passes-external-callbacks]] — 점검 모드에서도 AdMob 보상 검증·App Store 알림 콜백 통과, 경로는 `ExternalCallbackPaths` 한 곳 (#867, PR #898)
- [[DEC-0274-stats-radar-above-list-study-pattern-free]]: 영역별 정답률은 레이더 그래프 위, 목록 아래(토글 없음), 학습 패턴 무료, 정답률 상세(난이도, 오답 정리) 프로 (#909, DEC-0206 대체)
- [[DEC-0276-account-provider-icon-email-avatar]]: 닉네임 변경은 계정 화면 관리에서만(펜 없음), 로그인 방법은 제공자 아이콘 + 이메일, 소셜 프로필 이미지, 최근 로그인 배지 (#908, DEC-0263 대체)
- [[DEC-0282-ad-bonus-unlimited-fair-use-200]] — 광고 보너스 +5 횟수 제한 없음, 무료·프로 공통 하루 200 공정 사용 상한, 옛 앱 호환 `adBonusMaxCount = 받은 횟수 + 1` (#963, DEC-0239 대체)
- [[DEC-0283-daily-limit-view-reward-first]] — 무료 랜덤은 끊기지 않게 이어 풀기, 남은 수 상시 표시, 한도 화면은 광고 > 오늘의 세트 > 이용권 한 줄 (#963)
- [[DEC-0286-pass-sheet-comparison-table-price-cards]] — 이용권 시트: 나란한 가격 카드(줄 그은 정가 + -25%), 접지 않는 무료·프로 비교표, 탑승권 한 색 아이콘·수험생 (#966, DEC-0284 대체)
- [[DEC-0287-credit-term-top-bar-balance]] — 무료 한도는 `크레딧`, 잔액은 탭 상단 바 알약(누르면 크레딧 시트: PRO 주 버튼 > 광고 > 오늘의 세트), 상태는 아이콘·색 (#966, #971)
- [[DEC-0289-home-next-step-no-ad-card-mock-trial]] — 홈 「다음에 할 일」 카드는 광고를 권하지 않고, 크레딧 0이면 모의고사 무료 1회 카드 또는 숨김 (#980)
- [[DEC-0290-credit-history-computed-from-limit-records]] — 크레딧 내역은 따로 저장하지 않고 한도 판정과 같은 메서드로 날짜별 계산(최근 14일), DEC-0287의 "오늘 내역만" 부분 대체 (#974)
- [[DEC-0292-admin-app-operation-single-entry]] — 최소·권장 버전과 결제 켜기 준비는 `/admin/app-operation` 한 곳, 최소 버전 경고는 서버 빌드 버전 비교, 일반 설정 API는 호환 유지 (#961)

## 대체된 결정 (역사)
- [[DEC-0284-pass-sheet-plain-copy-small-discount-badge]] → DEC-0286
- [[DEC-0239-free-daily-limit-bonus-three-kinds]] → DEC-0282
- [[DEC-0001-pro-monthly-yearly-subscription]] → DEC-0002
- [[DEC-0002-exam-pass-until-next-sqld]] → DEC-0003
- [[DEC-0208-pass-ticket-fields-unified]] → DEC-0243
- [[DEC-0205-pro-benefits-single-source]] → DEC-0262
- [[DEC-0243-profile-top-card-style-a]] → DEC-0263
- [[DEC-0263-pass-rows-on-account-screen-only]] → DEC-0276

## 핵심 문서
- [[DOC-0001-billing-implementation-code-trace]] (internal, 2026-11-12 코드 기준) — 결제 구현 지도: Android·iOS 구매 검증, 이용권 저장·회수·만료 계산, 결제 스위치, 서버·앱·웹 역할 분담. 열린 질문: Play verify에 결제 스위치 검사 없음(iOS만 있음)

## 관련 이슈
- [[ISS-0493-credit-history-screen]] (resolved, GitHub #974, PR #978): 크레딧 내역이 오늘 요약뿐, 날짜별 받고 쓴 내역 없음 > 원본 기록에서 계산
- [[ISS-0495-admin-app-operation-settings]] (resolved, GitHub #961, PR #969): 최소 버전 입구가 둘, 결제 켜기 전 점검표 없음, 비밀 설정 미설정 문구 오해
- [[ISS-0489-pass-sheet-home-profile-cleanup]] (resolved, GitHub #966, PR #968): 이용권 시트 혜택 접기·정가 없는 할인, 잠금 문구 딱딱함, 홈·프로필 카드에 기능이 섞임
- [[ISS-0490-credit-term-purchase-funnel-events]] (resolved, GitHub #971, PR #973): 구매·광고 흐름 분석 이벤트 없음, 한도·보상 표현이 여러 말로 겹침(크레딧으로 통일), 탭 제목 정렬
- [[ISS-0488-free-practice-reward-flow]] (resolved, GitHub #963, PR #964): 무료 랜덤 10문제 끊김, 남은 한도 안 보임, 한도 화면 광고 버튼 묻힘, 세트 보너스 표시 없음, 이용권 시트 문구 과다
- [[ISS-0485-billing-test-setup-e2e]] (open, GitHub #941): 결제 시험 환경 세팅과 결제 E2E (Play 서비스 계정·SSV 설정 비어 있음)
- [[ISS-0470-app-audit-uiscene-plan-flicker-sheet-dismiss]] (resolved, GitHub #880): 앱 전체 점검: iOS UIScene 대응, 새로고침 시 등급 깜빡임, 확인 중 시트 닫힘, 결제 로그
- [[ISS-0469-billing-switch-unverified-screens-races]] (open, GitHub #867, PR #898 머지) — 결제 스위치 켜기 전 미확인 화면과 경합 점검: 제출 거부 사유 시트, 동시 제출 한도, 점검 중 외부 콜백, 해외 가격
- [[ISS-0461-plan-aligned-options-new-choices-mode]] (resolved, GitHub #863) — 요금제에 맞춘 옵션 재배치: 실전 모드 이름과 위치, 광고 제거 혜택, 중복 진입점
- [[ISS-0462-web-wrong-notes-page-404]] (resolved, GitHub #865) — 웹 마이페이지 오답 전체보기 404, 웹 오답 노트 화면 없음
- [[ISS-0463-sqld-mock-exam]] (open, GitHub #866) — SQLD 모의고사: 50문항 90분, 과목별 과락, 프로 핵심 기능 (PR #889 머지, 리포트 전)
- [[ISS-0450-promo-site-dynamic-revamp]] (resolved, GitHub #823) — 소개 사이트 무료 안내(결제 꺼짐 동안)
- [[ISS-0448-mypage-account-pass-area-promo-code]] (resolved, GitHub #816) — 마이페이지 계정·이용권 영역과 결제 유도, 할인 표시, 프로모션 코드
- [[ISS-0447-full-screen-ad-show-failure-bonus-retry]] (resolved, GitHub #814) — 광고 표시 실패 시 전체 화면 광고 멈춤, 보너스 요청 재시도 없음
- [[ISS-0443-free-daily-limit-bonus]] (resolved, GitHub #808) — 무료 하루 한도 보너스 (오늘의 세트 완료·정답률·보상형 광고)
- [[ISS-0304-ads-rewarded-banner-pro-hide]] (resolved, GitHub #499) — 광고 도입(보상형·하단 배너) → Pro 회원 광고 숨김
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
