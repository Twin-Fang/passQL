---
type: decision
id: DEC-0240
created: 2026-11-04
reviewed: null
topics: [dev-workflow, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0444-test-build-dev-tools-overlay]]", "[[ISS-0444-test-build-dev-tools-overlay-report]]", "[[DEC-0202-test-build-shared-version-adjust-no-block]]", "[[DEC-0005-ship-with-billing-switch-off]]"]
---

# DEC-0240: 앱 개발자 도구는 테스트 빌드에만 — 컴파일타임 `APP_FLAVOR=dev`와 `.env` `APP_SHOW_DEV_TOOLS=true` 두 층이 모두 켜져야 보이고, 강제값은 표시만 바꾼다

## 문제 정의 (Context)
결제 스위치가 꺼진 운영 서버에서는 모두 무제한이라 테스트 빌드에서 무료 등급·한도 소진·보상형 광고 화면을 확인할 수 없었다 (GitHub #809). 개발용 기능이 스토어 제출 빌드에 새면 안 된다.

## 결정 (Decision)
- **두 층 게이트:** 컴파일타임 `APP_FLAVOR=dev`(또는 디버그 빌드)와 런타임 `.env` `APP_SHOW_DEV_TOOLS=true`가 **모두** 켜질 때만 개발자 도구가 보인다. `.env`는 Secret으로 들어와 실수로 켜질 수 있지만, 스토어 제출 빌드는 `APP_FLAVOR`가 없어 꺼진다.
- **빌드 프로파일:** `.github/config/build-profile.json`의 `test`가 두 값을 켜고, `release`는 개발 키가 꺼졌는지 검증한다. 개발 키는 적용 전에 `.env`에서 걷어낸다.
- **광고:** 개발용 빌드(`APP_FLAVOR=dev` 또는 디버그)는 테스트 광고 단위만 쓴다.
- **강제값은 표시만 바꾼다:** 등급 강제·무료 한도 흉내는 마지막 서버 등급 위에 덧씌우는 것이고, 서버 요청이나 서버 데이터 변경은 없다. 흉내 중 광고 보너스도 서버 대신 흉내 단계만 넘긴다.
- **모양:** 엘룸 프로젝트의 `DevToolsOverlay`처럼 끌어서 옮기는 플로팅 버튼 + 도구 시트로 두고, 앱 맨 바깥 builder에서 한 번만 감싼다.

## 검토한 대안 (Alternatives)
- `.env` 한 층만으로 켜기는 Secret 값이 남으면 운영 빌드에 켜질 수 있다는 이유로 두 층 게이트를 썼다. 다른 게이트 방식을 비교한 기록은 없다 (논의 기록 없음).
- 운영/로컬 서버 전환, 로그 보기는 이번 범위에서 뺐다 (이유 기록 없음).

## 결과 (Consequences)
**긍정**
- 결제 스위치를 켜지 않고도 테스트 빌드에서 결제 켜짐 무료 회원 화면을 확인할 수 있다.
- 운영 빌드는 `.env` 값과 무관하게 도구가 꺼지고, `app_build_flavor_test.dart`가 이를 지킨다.

**부정**
- 플로팅 버튼이 시트·대화상자 위에도 떠 있어 화면을 가릴 수 있다.
- 흉내 중에는 잠금 화면도 무료 회원처럼 보여, 확인 뒤 `끔 (서버값)`으로 되돌려야 한다.

## 영향 범위 (Scope)
- CI: `.github/config/build-profile.json`.
- 앱: `core/config/app_build_flavor.dart`, `core/ads/ad_placement.dart`, `core/ads/ad_frequency_history_reset.dart`, `presentation/providers/dev_plan_overrides.dart`, `presentation/providers/plan_providers.dart`, `presentation/widgets/dev_tools/`, `presentation/widgets/ads/dev_ad_tools_section.dart`, `main.dart`, `router/app_router.dart`.
- 테스트: `app_build_flavor_test.dart`, 광고 배치 허용 목록.

## 출처 (References)
- GitHub #809 완료 리포트 댓글 (2026-11-04)
- 이슈: [[ISS-0444-test-build-dev-tools-overlay]], 리포트 [[ISS-0444-test-build-dev-tools-overlay-report]]
