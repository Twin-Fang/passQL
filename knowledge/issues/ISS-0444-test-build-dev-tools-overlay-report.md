---
type: completion-report
id: ISS-0444
created: 2026-11-04
topics: [dev-workflow, ci-deploy]
status: resolved
resolves: "[[ISS-0444-test-build-dev-tools-overlay]]"
related: ["[[DEC-0240-dev-tools-two-layer-gate-test-builds]]", "[[ISS-0443-free-daily-limit-bonus-report]]", "[[ISS-0442-app-open-ad-interstitial-cap-relax-report]]"]
source: "https://github.com/Twin-Fang/passQL/issues/809"
---

# ISS-0444 완료 리포트: 테스트 빌드에 플로팅 버튼 개발자 도구 (등급 강제, 무료 한도 흉내, 광고 도구)

GitHub #809 리포트 댓글 기준 (2026-11-04). 원본 사본: `_sources/issues/ISS-0444-test-build-dev-tools-overlay-report.md` (로컬 전용).

> 머지 상태: 작성 시점(2026-11-04)에 미머지·미배포. 코드 커밋은 `84685d74`이고 #787·#808 브랜치 위에 쌓였다. 이 노트는 그 코드 PR과 같이 들어간다.

## 해결 방법
- **빌드 프로파일:** `.github/config/build-profile.json`의 `test`는 `.env` `APP_SHOW_DEV_TOOLS=true` + `--dart-define=APP_FLAVOR=dev`, `release`는 개발 키 꺼짐 검증. 개발 키는 적용 전에 `.env`에서 걷어내 Secret에 남은 값이 살아남지 못한다.
- **판정:** `core/config/app_build_flavor.dart` — 개발용 빌드(컴파일타임 `APP_FLAVOR`), 도구 노출(빌드 + `.env` 두 층 모두 켜져야 함).
- **광고:** `core/ads/ad_placement.dart`에서 개발용 빌드도 테스트 광고 단위를 쓴다. `core/ads/ad_frequency_history_reset.dart`는 전면·앱 오프닝 빈도 기록 7개를 지운다.
- **등급 강제·한도 흉내:** `presentation/providers/dev_plan_overrides.dart`(시작값 `PRO_DEBUG_PLAN`, 강제값 서버값·무료·프로, 무료 한도 흉내 4종). `plan_providers.dart`가 마지막 서버 등급을 보관하고 강제값을 바꾸면 서버 요청 없이 다시 적용한다. 흉내 중 광고 보너스는 서버 대신 흉내 단계만 넘긴다.
- **화면:** `widgets/dev_tools/dev_tools_overlay.dart`(플로팅 버튼, 앱 맨 바깥 builder에서 한 번만 감싸고 운영 빌드는 감싸지 않음), `dev_tools_sheet.dart`, `widgets/ads/dev_ad_tools_section.dart`(보상형 광고 바로 보기, 빈도 기록 초기화), 빌드 상태·상태 복사.
- **연결:** `main.dart`, `router/app_router.dart`(라우터보다 위에서 시트를 띄우려고 최상위 Navigator 키 노출).
- **테스트:** `app_build_flavor_test.dart`(운영 빌드는 `.env`가 true여도 안 보임), 광고 배치 허용 목록에 도구 시트 추가.
- **검증:** `flutter analyze` 문제 없음, 앱 테스트 98개 통과. 빌드 프로파일 복사본 시험에서 `test`는 두 값이 켜지고 `release`는 모두 꺼짐을 확인했다. iOS 시뮬레이터(디버그, 운영 서버, Apple 로그인)에서 플로팅 버튼 > 시트 > 한도 흉내로 #808 화면 전체를 확인했다. 테스트 빌드는 푸시 후 `@projectops app build`로 iOS 테스트 TestFlight·Android 테스트 APK를 돌리는 중이었다.

## 근본 원인 (확정)
결제 스위치가 꺼진 운영 서버로는 무료 회원 경로를 재현할 수 없었고, 테스트 빌드에 표시 상태를 바꿀 도구가 없었다.

## 재발 방지
- 개발용 기능은 컴파일타임 `APP_FLAVOR=dev`(또는 디버그)와 런타임 `.env` `APP_SHOW_DEV_TOOLS=true`가 모두 켜질 때만 보인다. 스토어 제출 빌드는 `APP_FLAVOR`가 없어 `.env` 값과 무관하게 꺼진다. 기준은 [[DEC-0240-dev-tools-two-layer-gate-test-builds]].
- `app_build_flavor_test.dart`가 운영 빌드 노출을 막는다.

## 알고 남긴 것
- 플로팅 버튼은 시트·대화상자 위에도 떠 있다(라우터보다 위). 가리면 끌어서 옮긴다.
- 흉내 중에는 잠금 화면도 무료 회원처럼 보인다(결제 켜짐 무료로 바꾸기 때문). 확인이 끝나면 `끔 (서버값)`으로 되돌린다.
- 운영/로컬 서버 전환, 로그 보기는 범위에서 뺐다.

## 교훈
- 결제 스위치가 꺼진 상태에서 결제 켜짐 화면을 확인할 때는 서버 데이터를 바꾸지 말고 앱 표시 강제값으로 흉내 낸다.
