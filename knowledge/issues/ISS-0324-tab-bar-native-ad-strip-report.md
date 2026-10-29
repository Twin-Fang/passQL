---
type: completion-report
id: ISS-0324
created: 2026-10-18
topics: [ads]
status: resolved
resolves: "[[ISS-0324-tab-bar-native-ad-strip]]"
related: ["[[DEC-0153-single-native-strip-under-tab-bar]]"]
source: "https://github.com/Twin-Fang/passQL/issues/527"
---

# ISS-0324 완료 리포트: 탭별 배너 3개를 없애고 탭바 아래 44dp 네이티브 광고 띠 하나로

GitHub #527 보고 댓글과 Android 확인 댓글 기준 (2026-10-18, PR #528).

## 해결 방법
- `AdPlacement`의 `banner*` 3개 제거, `nativeStrip` 추가. AdMob 네이티브 고급형 단위 2개 생성, `ENV_FILE`·`app/.env`에 `PASSQL_ADMOB_{ANDROID|IOS}_NATIVE_STRIP` 추가(기존 키 유지).
- `native_ad_loading.dart`(20초 시간 초과, 실패 시 해제), `ad_native_strip_loader.dart`(customOptions로 색·배지 문구, `AdRequestPreparer` 경유), `ad_native_strip_slot.dart`(셸 생존 동안 1회 로드, 테마 변경 시 재로드, 광고 없으면 높이 0, 앱 복귀 시 광고가 1시간 넘으면 재로드).
- `PassqlTabBarWithBottomStrip`: 탭바 → 헤어라인 띠(44dp, card 색) → 홈 인디케이터 여백. `app_shell.dart`가 띠 하나만 둠, 셸을 덮는 화면에서는 안 그려짐.
- 네이티브: Android `PassqlStripNativeAdFactory.kt`·`passql_strip_native_ad.xml`, iOS `PassqlStripNativeAdFactory.swift`.
- 광고 위치 규칙: 띠는 `app_shell`에 정확히 1개, 배너 슬롯 사용 0개. `app/CLAUDE.md`·`Design.md` 갱신.
- 검증: iOS 시뮬레이터 검증기 "No implementation issues found", Android 에뮬레이터에서 띠 확인, Play 내부 테스트 versionCode 325 포함.

## 근본 원인 (확정)
탭별 배너 구조.

## 재발 방지
- factoryId `passqlStrip`과 customOptions 키는 Dart·Kotlin·Swift 세 곳에 같은 값 — 함께 바꾼다.
- 띠 전체가 NativeAdView라 클릭 영역이 광고 밖으로 나가지 않는다. AD 배지·헤드라인·AdChoices를 가리거나 바꾸면 안 된다.
- 실제 게재는 AdMob 앱 인증(iOS app-ads.txt, Android 스토어 연결) 이후.
- 삭제 승인 대기: `ad_banner_loader.dart`, `ad_banner_slot.dart`, `.env`의 `*_BANNER_*` 키 6개.

## 교훈
(원본에 없음, 볼트 정리) 에뮬레이터에서 앱 액티비티가 등록되지 않으면 낡은 패키지 상태를 의심하고 `-wipe-data`로 초기화한다.
