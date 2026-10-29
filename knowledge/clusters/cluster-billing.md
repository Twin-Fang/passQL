---
type: cluster
topic: billing
created: 2026-10-29
members: 10
status: active
related: []
---

# 클러스터: 결제·요금제

## 이 주제는
무료/프로 등급, 이용권 상품과 가격, 스토어(Play·App Store) 결제 검증, 결제 스위치. 서버 `FeatureAccessPolicy`가 등급 판정의 유일한 지점이다.

## 현재 상태 요약
(2026-10-29) 상품은 1개월권 ₩4,400·3개월권 ₩9,900 기간제 이용권, 자동 갱신 없음, 3개월권 기본 선택 — [[DEC-0003-one-and-three-month-pass]]. 무료/프로 경계는 [[DEC-0004-free-pro-feature-boundary]]. Android(Play 일회성)·iOS(비갱신 구독) 결제와 iOS·웹 잠금은 구현됐지만 결제 스위치는 꺼진 채 — [[DEC-0005-ship-with-billing-switch-off]]. 켜기 전 점검은 GitHub #596(열림, 볼트 미적재).

## 활성 결정
- [[DEC-0003-one-and-three-month-pass]] — 1·3개월 기간제 이용권, 만료일 이어 붙이기
- [[DEC-0004-free-pro-feature-boundary]] — 무료/프로 기능 경계 표
- [[DEC-0005-ship-with-billing-switch-off]] — 결제 스위치 끈 채 배포
- [[DEC-0006-ios-non-renewing-web-no-purchase]] — iOS 비갱신 구독, 웹은 앱 구매 안내만
- [[DEC-0007-hold-pass-review-until-switch-on]] — iOS 이용권 심사는 스위치 켤 버전과 함께

## 대체된 결정 (역사)
- [[DEC-0001-pro-monthly-yearly-subscription]] → [[DEC-0002-exam-pass-until-next-sqld]] 로 대체됨 (체인 메모는 DEC-0001 본문, 원본상 대체 선언은 2026-10-23)
- [[DEC-0002-exam-pass-until-next-sqld]] → [[DEC-0003-one-and-three-month-pass]] 로 대체됨 (2026-10-23)

## 관련 이슈
- [[ISS-0003-free-pro-plan-android-exam-pass]] (resolved)
- [[ISS-0004-ios-web-pro-lock-before-billing]] (resolved)
- [[ISS-0005-replace-exam-pass-with-period-pass]] (resolved)
