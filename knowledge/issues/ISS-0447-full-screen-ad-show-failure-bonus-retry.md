---
type: issue
id: ISS-0447
created: 2026-11-04
topics: [ads, billing]
symptoms: ["전체 화면 광고 멈춤", "광고 표시 중 해제 안 됨", "show() 예외", "닫힘 콜백 안 옴", "세션 내내 전면 광고 안 뜸", "앱 오프닝 광고 안 뜸", "보상형 광고 버튼 로딩 남음", "보너스 기록 실패", "광고 보너스 사라짐", "광고 최대 횟수 2", FullScreenAdGuard, interstitial_ad_loader, app_open_ad_loader, rewarded_ad_player, rewarded_ad_bonus_button, "DailyFreeBonus.none()", "POST /members/me/plan/ad-bonus"]
root_cause: "SDK show()가 예외를 내면 닫힘 콜백이 오지 않는데 그 경로에서 '전체 화면 광고 표시 중' 해제가 빠졌고, 보너스 기록 요청은 재시도가 없었으며, 프로·결제 꺼짐 보너스 응답이 광고 최대 횟수 기본값 2를 실었다"
status: resolved
resolution: "[[ISS-0447-full-screen-ad-show-failure-bonus-retry-report]]"
related: ["[[ISS-0447-full-screen-ad-show-failure-bonus-retry-report]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax]]", "[[ISS-0443-free-daily-limit-bonus]]", "[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]"]
source: "https://github.com/Twin-Fang/passQL/issues/814"
---

# ISS-0447: 광고 표시 실패 시 전체 화면 광고 멈춤, 보너스 요청 재시도 없음

GitHub #814 이슈 본문 기준. 원본 사본: `_sources/issues/ISS-0447-full-screen-ad-show-failure-bonus-retry.md` (로컬 전용). 완료 리포트: [[ISS-0447-full-screen-ad-show-failure-bonus-retry-report]]

## 증상
- 전체 화면 광고(전면·앱 오프닝·보상형)의 SDK `show()`가 실패(예외)하면 닫힘 콜백이 오지 않아 "전체 화면 광고 표시 중" 표시가 풀리지 않는다.
  - 그 세션 동안 전면·앱 오프닝 광고가 전부 막히고, 보상형 광고 버튼은 로딩 상태로 남는다 (#787·#808 리뷰 지적, 기존 전면 로더도 같은 구조).
- 보상형 광고를 끝까지 본 뒤 보너스 기록 요청(`POST /members/me/plan/ad-bonus`)이 네트워크 오류로 실패하면 재시도 없이 보너스가 사라진다.
- 프로·결제 꺼짐 회원의 보너스 응답(`DailyFreeBonus.none()`)에 광고 최대 횟수 2가 실린다 (의미상 0).

## 재현 조건
SDK `show()`가 예외를 내는 경우(실제 재현은 못 함), 보상형 광고 시청 직후 네트워크 오류, 프로 또는 결제 스위치 꺼짐 회원의 등급 응답.

## 조사 기록
- 2026-11-04: [[ISS-0442-app-open-ad-interstitial-cap-relax]](#787)·[[ISS-0443-free-daily-limit-bonus]](#808) 리뷰에서 남겨 둔 엣지 케이스를 배포 전에 고치기로 했다.

## 근본 원인
`show()` 예외 경로가 닫힘·표시 실패 콜백과 별도라 표시 중 해제가 빠졌고, 보너스 기록 요청에 재시도가 없었으며, `DailyFreeBonus.none()`이 광고 최대 횟수 기본값을 그대로 실었다.
