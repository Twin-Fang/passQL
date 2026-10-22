# passQL App (Flutter)

SQLD·SQLP 학습 서비스 passQL의 모바일 앱. 서버(`server/`)와만 통신한다 (AI 서버 직접 호출 금지).
앱 ID `com.coldredrice.passql` (Android/iOS 동일), 한국 대상 출시.

## Tech Stack

- **Flutter** 3.x + **Dart** SDK ^3.9.2
- **상태관리**: flutter_riverpod ^2.6 (Provider 직접 선언, 코드 생성 미사용)
- **라우팅**: go_router ^17
- **HTTP**: Dio ^5.9 + Retrofit (코드 생성)
- **모델**: freezed + json_serializable
- **인증**: Firebase Auth + Google Sign-In + Sign in with Apple, 카카오(kakao_flutter_sdk_user)·네이버(flutter_naver_login)·GitHub(flutter_web_auth_2), 토큰은 flutter_secure_storage
- **UI**: flutter_svg, shimmer, fl_chart(레이더 차트), 아이콘은 CupertinoIcons
- **기기 정보**: package_info_plus(앱 버전), device_info_plus(의견 보내기 기기 정보)
- **폰트**: Pretendard 4굵기(Regular·Medium·SemiBold·Bold), 코드용 JetBrains Mono NL(Regular·Bold) — `assets/fonts`, 라이선스 OFL 동봉

## Project Structure

```
lib/
├── main.dart               # 진입점, 세션 복원, 라우터 연동
├── core/                   # 공통·인프라. data·presentation·router 를 import 하지 않는다 (필요하면 core 에 포트, data 가 구현)
│   ├── ads/                # AdMob SDK 래퍼(배너 카드·네이티브 카드·한 줄 띠·전면 로더, 공통 요청 준비 AdRequestPreparer, ATT 동의 AdConsent,
│   │                       # 단위 ID, 전면 빈도 제한). SDK 는 여기서만 import, 테스트는 Provider 포트를 가짜로 교체
│   ├── auth/               # 토큰 저장, 인터셉터(Bearer·재발급, 재발급 포트 TokenReissueClient), 세션 만료 신호, 소셜 로그인, 설치 가드
│   ├── error/              # ErrorCode(서버 코드 매핑), AppException (서버 오류를 사용자 문구로 변환)
│   ├── monitoring/         # 오류 수집(CrashReporter, reportIfUnexpectedFailure)·분석(AppAnalytics, 이벤트 이름 상수) 공통 지점
│   ├── network/            # dio_client(buildBackendDio·plainDioProvider), safe_call(safeCall·safeCallAll·SafeCallSlot),
│   │                       # api_call(callApiThrowingAppException: Dio 오류 > AppException 공통 변환)
│   ├── notification/       # 앱 아이콘 숫자(AppIconBadgeUpdater, app_badge_plus 는 여기서만), 알림 권한 안내 결과
│   ├── push/               # 푸시 SDK 포트(PushMessagingClient)·이동 허용 목록(PushLink)·안내 기록. 등록·삭제는 data/push/PushNotificationService
│   ├── storage/            # 기기 저장 키 원본(StorageKeys), 일반 저장소 공통 지점(DevicePreferences, shared_preferences 는 여기서만)
│   └── utils/ validation/
├── data/                   # presentation·router 를 import 하지 않는다
│   ├── models/             # freezed 데이터 모델 (도메인별 폴더)
│   ├── push/               # PushNotificationService (푸시 토큰 등록·삭제, 알림 이동)
│   └── sources/            # Retrofit API 정의, api_providers(인증 Dio·authApi·클라이언트 Provider), SSE 클라이언트
├── presentation/
│   ├── design/             # Passql 디자인 시스템 (아래 절 참고)
│   ├── flows/              # 문제 풀이 흐름 공통화 (question_flow, daily_set_flow)
│   ├── pages/              # login, home, questions(문제 탭 세그먼트 주제별·최신 경향·개념 TOP 10 + 오답 노트 바로가기, 챕터·챕터 결과), result, stats, settings,
│   │                       # daily_set(결과·리더보드), feedback, legal
│   ├── providers/          # Riverpod Provider·Notifier·Service (회원별 Provider 는 session_reset 의 currentMemberUuidProvider watch + autoDispose)
│   └── widgets/            # 화면 조각 (설정 그룹, 문제 풀이 본문 등)
└── router/                 # app_router, app_routes(모든 경로 상수), result_route_arguments(결과 화면 이동 인자·extra 해석)
test/
├── architecture/           # 규칙 테스트 (아래 절 참고)
├── core/ data/ design/ presentation/ router/   # lib 구조를 따르는 단위·위젯 테스트
└── helpers/                # pump_app, fakes/(FakeHttpClientAdapter, FakeMemberApi, 푸시 가짜)
tool/store_shots/           # 스토어 스크린샷용 가짜 API 진입점 (운영 코드 아님)
```

## Passql 디자인 시스템

`Passql` 접두사 = passQL 앱 디자인 시스템 소속. 디자인 시스템 밖 클래스에는 붙이지 않는다.

```
tokens(passql_*.dart: 색·글자·간격·모서리·크기·아이콘 크기·모션)
  > theme(PassqlTheme, context.passqlColors, context.isDark)
  > components(PassqlButton, PassqlCard, showPassqlSheet, showPassqlConfirmDialog,
               PassqlLoadingIndicator, PassqlStatusView, PassqlStatusScaffold,
               PassqlNotificationBellButton, PassqlTextScaleLimit 등 — 전체 목록은 Design.md)
  > 화면(pages·widgets: 토큰과 컴포넌트만 조합)
```

- 화면은 `presentation/design/design.dart` 하나만 import 한다.
- 값의 원본은 `lib/presentation/design/tokens/`. 문서에 값을 복사하지 않는다.
- 상세 규칙: `.claude/rules/Design.md`, API 연동: `.claude/rules/api-guide.md`
- 무료·프로 (#576): 등급 원본은 `planProvider`, 잠금 UI 표시 여부는 `shouldShowProUiProvider` 하나로 판정. 잠금 자리는 `PassqlLockedPreview`(화면은 `ProLockedSection`)만, 프로 에러(403)는 화면 진입점에서 `showProAccessFeedback`

## 규칙 테스트 (test/architecture)

문서로만 둔 규칙은 무너지므로 소스 스캔 테스트로 강제한다. `flutter test` 에 포함된다.

| 테스트 | 막는 것 |
|---|---|
| `design_system_rules_test.dart` | pages·widgets·flows 에서 `Color(0x`, `Colors.white/black`, `Image.asset(`, `showModalBottomSheet(`, `showCupertinoDialog(`, `CupertinoActivityIndicator(`·`ImageFilter.blur(` 직접 사용, `go('/...')`·`push('/...')` 라우트 문자열, 글자색 `tertiaryLabel`·`accent`(대비 미달 > `secondaryLabel`·`accentText`), 탭 동작 없는 `Semantics(button + excludeSemantics)` |
| `ad_placement_rules_test.dart` | core/ads 밖의 `google_mobile_ads`·ATT import, 허용 목록(탭 쉘·홈·통계·토픽 목록·결과 화면 2곳·main) 밖의 광고 사용, 탭 쉘 밖·2개 이상의 한 줄 띠와 탭별 배너, 홈·통계 밖·화면당 2개 이상의 인라인 카드, 토픽 목록 밖의 네이티브 카드, 풀이·로그인·약관·설정·차단 화면의 광고, `ad_request_preparer.dart` 밖의 `AdRequest(` 조립, 사용자 정보를 실은 광고 요청 |
| `layer_dependency_test.dart` | core 의 data·presentation·router import, data 의 presentation·router import, design 의 providers·pages·widgets·flows import, 화면의 `data/sources` 직접 import, core/monitoring 밖의 Crashlytics·Analytics SDK, core/push 밖의 firebase_messaging, core/notification 밖의 app_badge_plus, core/storage 밖의 shared_preferences 직접 import, 종 아이콘 밖의 알림함 경로 |
| `server_api_schema_test.dart` | 앱 모델 필드 <-> `api-contract/openapi.json` 어긋남 (서버에 없는 필드, 기본값 없는 nullable, 타입 불일치, #493) |
| `architecture_rules_test.dart` | 레포 공통 규칙(`docs/architecture/rules/*.rule`)의 새 위반·고쳐진 동결 항목 (pro-architecture-consult 템플릿) |

- 예외는 각 테스트의 allow-list(`_allowedUsages`, `_allowedReverseImports`)에 파일과 **이유**를 적어서만 둔다. 비어 있는 것이 정상이다.

## 인증 구조

- 로그인: `POST /auth/login {authProvider, idToken}` → access/refresh JWT. 이후 요청은 `Authorization: Bearer`.
  - 제공자별 재료(`SocialCredential`, #509): Google·Apple Firebase ID 토큰, 카카오·네이버 SDK 액세스 토큰(`idToken` 자리) > `/auth/login`.
    GitHub 인가 코드(콜백 `passql://auth/callback/github`, state 대조, PKCE S256) > `POST /auth/login/code`(codeVerifier 포함). 제공자 연결은 `MultiProviderSocialSignIn`.
  - `.env` 키: `KAKAO_NATIVE_APP_KEY`, `NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET`, `NAVER_CLIENT_NAME`. 네이티브 SDK 설정은 빌드 타임 값:
    Android 는 `build.gradle.kts`(manifestPlaceholders·resValue), iOS 는 `pod install` 때 `tool/gen_ios_social_login_config.sh` 가 `ios/Flutter/SocialLogin.xcconfig`(커밋 제외)로 만든다. 비면 해당 버튼은 준비 중 안내.
- 401이면 인터셉터가 refresh로 재발급, 실패하면 세션 만료 신호(`SessionExpirySignal`) > `AuthNotifier` 로그아웃 > 라우터가 로그인 화면으로 보냄.
- 403 `MEMBER_SUSPENDED`면 이용 제한 신호(`MemberSuspensionSignal`) > `AuthNotifier` 로그아웃 > 로그인 화면에 안내 문구.
- 회원 탈퇴 (#516): 제공자(세션 저장값 > `/members/me` authProvider) 기준 분기. Apple·Google 은 재인증 Firebase uid <-> `/members/me` providerUserId 대조
  (다르면 중단), Apple revoke 필수(취소·실패면 중단) > 서버 삭제 > Google disconnect·네이버 토큰 삭제(최선, 카카오는 서버 unlink·앱은 로그아웃만) > 세션 삭제.
  회원별 로컬 저장값은 보안 저장소 세션뿐.
- 소셜 토큰 검증 실패(INVALID_SOCIAL_TOKEN·INVALID_SOCIAL_AUTHORIZATION_CODE·INVALID/EXPIRED_FIREBASE_TOKEN)는 `socialLoginFailed` > 로그인 실패 문구.
- 계정 범위 데이터 (#516): 회원별 Provider 는 `currentMemberUuidProvider` 를 watch(로그아웃이면 API 호출 없음) + autoDispose(이전 회원 값 미보존).

## 광고 (AdMob, #506·#527)

- 자리 4종: 탭 셸 하단 탭 바 아래 한 줄 네이티브 띠(메인 탭 5개 공통 1개), 콘텐츠 안 인라인 배너 카드 `AdInlineCard`(홈 학습 현황 <-> 추천 문제 사이, 통계 맨 아래),
  문제 탭 네이티브 3칸(주제별 토픽 5개 뒤, 최신 경향 유형 <-> 공부 팁, 개념 TOP 10 5위 <-> 6위), 오늘의 세트·챕터 결과 진입 전면(설치 후 첫 결과 2회 제외·5분 간격·하루 3회, 기기 저장). 화면 안 광고는 '광고' 라벨(`AdLabel`) 필수.
- 한 줄 띠 (#527): `AdNativeStripSlot` > `GoogleAdNativeStripLoader`(factoryId `passqlStrip`, 색·배지 문구는 customOptions) > 네이티브 팩토리
  (Android `PassqlStripNativeAdFactory.kt` + `res/layout/passql_strip_native_ad.xml`, iOS `ios/Runner/PassqlStripNativeAdFactory.swift`, 등록은 `MainActivity`·`AppDelegate`).
  셸 수명 동안 1회 로드(탭 전환 재로드 없음), 앱 복귀 때 1시간 넘은 광고만 교체, 라이트·다크 전환 시 다시 로드. 로드 전·실패면 탭 바만(띠 자리 0).
  customOptions 키·factoryId 는 Dart·Kotlin·Swift 3곳이 같은 값 (바꾸면 함께 바꿈). 띠에는 AD 배지·헤드라인 필수, AdChoices 는 SDK 기본 위치(가리지 않음).
- 토픽 목록 네이티브 카드 (#522): `AdNativeSlot` > `GoogleAdNativeLoader`(factoryId `passqlNativeCard`, 미디어 120 이상) > 네이티브 팩토리
  (Android `PassqlNativeAdFactory.kt` + `res/layout/passql_native_ad_card.xml`, iOS `ios/Runner/PassqlNativeAdFactory.swift`, 등록은 띠와 같은 곳). 모양 값은 Dart `NativeAdCardStyle` 원본.
- 허용 조건 `adsEnabledProvider`: 모바일 + 로그인. 디버그·프로필은 Google 테스트 단위 고정, 릴리스는 `.env` 값(비면 광고 없음).
- `.env` 키: `PASSQL_ADMOB_{ANDROID|IOS}_APP_ID`, `PASSQL_ADMOB_{ANDROID|IOS}_{NATIVE_STRIP|BANNER_HOME|BANNER_STATS|NATIVE_QUESTIONS|INTERSTITIAL_RESULT}`.
  앱 ID 는 빌드 타임 값: Android 는 `build.gradle.kts` 가 직접 읽고, iOS 는 `pod install` 때 `tool/gen_ios_admob_config.sh` 가 `ios/Flutter/AdMob.xcconfig`(커밋 제외)로 만든다. 비면 Google 테스트 앱 ID.
- iOS 추적 허용(ATT)은 앱 시작 첫 프레임 뒤 1회. 거부면 비개인화 요청.

## 코드 생성

모델/API 변경 후 반드시 실행:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 테스트·검증

```bash
flutter analyze        # 정적 분석 (무이슈 유지)
flutter test           # 단위·위젯 테스트
flutter run -d <기기>  # 실행. app/.env 에 BACKEND_BASE_URL 필요
```

- 화면 캡처는 `tool/store_shots/main_shots.dart` 로 가짜 API를 붙여 시뮬레이터에서 찍는다
  (`/tmp/passql_shot_route.txt` 에 경로를 적고 launch). 로그인 이후 실제 동작은 Maestro 실계정 E2E로 확인한다.

## 릴리스

- iOS: GitHub Actions `PROJECT-FLUTTER-IOS-TESTFLIGHT` (workflow_dispatch). 수동 서명 프로파일 사용. 자세한 내용 `docs/ios-release/README.md`.
- Android: 업로드 키로 서명한 AAB를 Play Console에 올린다. `docs/android-release/`, Firebase 설정은 `docs/FIREBASE-SETUP.md`.
- 비밀 파일(`.env`, `google-services.json`, `GoogleService-Info.plist`, 키스토어)은 커밋하지 않는다.

## 금지 규칙

- **`git push`는 사용자가 요청한 경우에만**
- **커밋 시 Co-Authored-By 태그 금지**
- **파일 삭제 시 반드시 사용자 허락**
- **모르면 모른다고 말하기** — 추측하지 않는다
- **답변은 항상 한국어로** — 코드/커맨드 제외
- **코드 주석 필수** — 간결한 한국어, WHY 중심
- **이모지 금지** — 아이콘은 `CupertinoIcons`(또는 `Icons`), SVG는 `flutter_svg`

## Git Conventions

- 커밋 메시지에 이슈 링크를 붙인다. 형식: `<이슈 제목> : <type> : <설명> <이슈 URL>` (`/pro-commit` 사용)
- 모든 작업은 이슈로 시작하고 수정 전후 이미지를 이슈에 남긴다.
