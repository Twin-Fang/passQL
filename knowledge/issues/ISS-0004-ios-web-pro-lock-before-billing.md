---
type: issue
id: ISS-0004
created: 2026-10-22
topics: [billing]
symptoms: ["iOS 잠금 화면 없음", "웹 잠금 화면 없음", PRO_REQUIRED, FREE_DAILY_LIMIT_REACHED, "App Store 규정", "앱 밖 구매 유도", "비갱신 구독"]
root_cause: "결제 스위치를 켜면 서버가 iOS·웹에도 같은 무료 규칙을 적용하는데, iOS·웹에는 잠금 화면도 구매 수단도 없어 잠금 응답이 오류처럼 보인다"
status: resolved
resolution: "[[ISS-0004-ios-web-pro-lock-before-billing-report]]"
related: ["[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0006-ios-non-renewing-web-no-purchase]]", "[[DEC-0007-hold-pass-review-until-switch-on]]"]
source: "https://github.com/Twin-Fang/passQL/issues/578"
---

# ISS-0004: iOS 앱, 웹 무료 프로 잠금 화면 (결제 켜기 전 선행)

GitHub #578 (원본: 이슈 본문, 결정 댓글 2026-10-23, `## 개요` 리포트 댓글).

## 증상
#576은 등급을 계정 기준으로 서버가 판정하고 결제는 Android 먼저 연다. 스위치를 켜면 iOS 앱과 웹 사용자도 같은 무료 규칙(랜덤 하루 10문제, 실행·전체 해설·출제 경향 잠금)을 받는데, 두 곳에는 잠금 화면도 구매 수단도 없어 `PRO_REQUIRED`·`FREE_DAILY_LIMIT_REACHED`가 오류처럼 보인다.

## 재현 조건
결제 스위치를 켠 상태에서 iOS·웹으로 잠긴 기능 접근.

## 조사 기록
- 2026-10-23: 이 이슈 댓글에서 결제 상품 구조를 1개월·3개월 이용권으로 바꾸기로 결정(#591에서 서버·Android 반영).
- 2026-10-23: iOS 1.40.0 + 이용권 2개를 심사 제출했다가 이용권 제출만 취소.

## 근본 원인
스위치가 계정 기준 하나라 모든 플랫폼에 동시에 적용되는 구조.
