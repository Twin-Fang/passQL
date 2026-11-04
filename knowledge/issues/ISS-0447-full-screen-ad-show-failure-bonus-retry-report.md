---
type: completion-report
id: ISS-0447
created: 2026-11-04
topics: [ads, billing]
status: resolved
resolves: "[[ISS-0447-full-screen-ad-show-failure-bonus-retry]]"
related: ["[[DEC-0238-app-open-ad-and-interstitial-cap-retune]]", "[[DEC-0239-free-daily-limit-bonus-three-kinds]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]", "[[ISS-0443-free-daily-limit-bonus-report]]", "[[ISS-0445-tab-bar-equal-vertical-spacing-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/814"
---

# ISS-0447 완료 리포트: 전체 화면 광고 표시 공통 함수(끝나는 경로 3개 1회 처리), 보너스 기록 1회 재시도, 프로·결제 꺼짐 광고 최대 0

GitHub #814 리포트 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0447-full-screen-ad-show-failure-bonus-retry-report.md` (로컬 전용).

> 배포 상태: 커밋 `96c78198`(PR #815) 머지 뒤 2026-11-04 릴리스(#817)로 서버는 운영에, 앱은 테스트 트랙(TestFlight·Play 내부 테스트)에 반영됐다.

## 해결 방법
- `app/lib/core/ads/full_screen_ad_showing.dart` (신규): 전체 화면 광고 표시 공통 함수. 끝나는 경로 3개(닫힘, 표시 실패 콜백, `show()` 예외)를 모두 1회만 처리해 광고를 해제하고 `onClosed`를 부른다.
- `interstitial_ad_loader.dart`, `app_open_ad_loader.dart`, `rewarded_ad_player.dart`: 위 공통 함수로 표시.
- `rewarded_ad_bonus_button.dart`: 광고를 끝까지 본 뒤 보너스 기록 요청이 일시 실패하면 1회 재시도 (하루 횟수 소진 409는 재시도 없음).
- `profile_pass_slot.dart`: 프로필 탑승권 오늘 사용량 게이지를 보너스 포함 한도로 (혜택 아이콘은 기본 한도 유지).
- 서버 `DailyFreeBonus.none()`: 프로·결제 꺼짐 회원의 광고 최대 횟수 0.
- **검증:** 앱 analyze 0, 테스트 98 통과, 서버 테스트 통과. iOS 시뮬레이터(운영 서버, 최신 main)에서 개발자 도구 보상형 광고 > `결과: rewarded`, 40초 백그라운드 뒤 앱 오프닝 광고 표시 > 닫기 정상. 다크 모드·최대 글자 크기에서 하단 탭 바(#810) 위아래 여백 같음 확인. 운영 서버 로그에서 Flyway `1.72.2 - member daily ad bonus` 적용과 새 서버 정상 기동 확인.

## 근본 원인 (확정)
SDK `show()`가 예외를 내면 닫힘 콜백이 오지 않는데, 이 경로를 처리하지 않아 "전체 화면 광고 표시 중" 표시가 남았다. 그래서 그 세션 동안 전면·앱 오프닝 광고가 하나도 뜨지 않았다.

## 재발 방지
- 전체 화면 광고 3종은 표시 공통 함수 하나를 거친다. 끝나는 경로 3개를 한 곳에서 1회만 처리해 표시 중 해제가 빠지지 않는다.

## 알고 남긴 것
- `show()` 예외 경로는 SDK가 실제로 예외를 내는 상황을 재현하지 못해 코드 판정으로만 확인했다.

## 교훈
(원본의 핵심 구현에서 정리)
- SDK 콜백 기반 표시 상태는 콜백이 오지 않는 경로(동기 예외)까지 "끝나는 경로"로 세어 한 곳에서 해제한다.
