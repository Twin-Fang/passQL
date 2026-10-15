# passQL App (Flutter)

SQLD·SQLP 학습 서비스 passQL의 모바일 앱. 서버(`server/`)와만 통신한다 (AI 서버 직접 호출 금지).
앱 ID `com.coldredrice.passql` (Android/iOS 동일), 한국 대상 출시.

## Tech Stack

- **Flutter** 3.x + **Dart** SDK ^3.9.2
- **상태관리**: flutter_riverpod ^2.6 (Provider 직접 선언, 코드 생성 미사용)
- **라우팅**: go_router ^17
- **HTTP**: Dio ^5.9 + Retrofit (코드 생성)
- **모델**: freezed + json_serializable
- **인증**: Firebase Auth + Google Sign-In + Sign in with Apple, 토큰은 flutter_secure_storage
- **UI**: flutter_svg, shimmer, fl_chart(레이더 차트), 아이콘은 CupertinoIcons
- **기기 정보**: package_info_plus(앱 버전), device_info_plus(의견 보내기 기기 정보)
- **폰트**: Pretendard 4굵기(Regular·Medium·SemiBold·Bold), 코드용 JetBrains Mono NL(Regular·Bold) — `assets/fonts`, 라이선스 OFL 동봉

## Project Structure

```
lib/
├── main.dart               # 진입점, 세션 복원, 라우터 연동
├── core/                   # 공통·인프라. presentation·router 를 import 하지 않는다
│   ├── auth/               # 토큰 저장, 인터셉터(Bearer·재발급), 세션 만료 신호, 소셜 로그인, 설치 가드
│   ├── error/              # ErrorCode(서버 코드 매핑), AppException (서버 오류를 사용자 문구로 변환)
│   ├── monitoring/         # 오류 수집(CrashReporter)·분석(AppAnalytics, 이벤트 이름 상수) 공통 지점
│   ├── network/            # dio_client, safe_call(safeCall·safeCallAll·SafeCallSlot),
│   │                       # api_call(callApiThrowingAppException: Dio 오류 > AppException 공통 변환)
│   ├── push/               # 푸시 SDK 포트(PushMessagingClient)·이동 허용 목록(PushLink). 등록·삭제는 data/push/PushNotificationService
│   └── utils/ validation/
├── data/                   # presentation·router 를 import 하지 않는다
│   ├── models/             # freezed 데이터 모델 (도메인별 폴더)
│   └── sources/            # Retrofit API 정의, api_providers(클라이언트 Provider), SSE 클라이언트
├── presentation/
│   ├── design/             # Passql 디자인 시스템 (아래 절 참고)
│   ├── flows/              # 문제 풀이 흐름 공통화 (question_flow, daily_set_flow)
│   ├── pages/              # login, home, questions(챕터·챕터 결과), result, stats, settings,
│   │                       # daily_set(결과·리더보드), feedback, legal
│   ├── providers/          # Riverpod Provider·Notifier·Service (계정 전환 시 session_reset으로 초기화)
│   └── widgets/            # 화면 조각 (설정 그룹, 문제 풀이 본문 등)
└── router/                 # app_router, app_routes(모든 경로 상수)
test/
├── architecture/           # 규칙 테스트 (아래 절 참고)
└── helpers/fakes/          # 공용 가짜 (FakeHttpClientAdapter, FakeMemberApi)
tool/store_shots/           # 스토어 스크린샷용 가짜 API 진입점 (운영 코드 아님)
```

## Passql 디자인 시스템

`Passql` 접두사 = passQL 앱 디자인 시스템 소속. 디자인 시스템 밖 클래스에는 붙이지 않는다.

```
tokens(passql_*.dart: 색·글자·간격·모서리·크기·아이콘 크기·모션)
  > theme(PassqlTheme, context.passqlColors, context.isDark)
  > components(PassqlButton, PassqlCard, showPassqlSheet, showPassqlConfirmDialog,
               PassqlLoadingIndicator, PassqlStatusView, PassqlStatusScaffold 등)
  > 화면(pages·widgets: 토큰과 컴포넌트만 조합)
```

- 화면은 `presentation/design/design.dart` 하나만 import 한다.
- 값의 원본은 `lib/presentation/design/tokens/`. 문서에 값을 복사하지 않는다.
- 상세 규칙: `.claude/rules/Design.md`, API 연동: `.claude/rules/api-guide.md`

## 규칙 테스트 (test/architecture)

문서로만 둔 규칙은 무너지므로 소스 스캔 테스트로 강제한다. `flutter test` 에 포함된다.

| 테스트 | 막는 것 |
|---|---|
| `design_system_rules_test.dart` | pages·widgets·flows 에서 `Color(0x`, `Colors.white/black`, `Image.asset(`, `showModalBottomSheet(`, `showCupertinoDialog(`, `CupertinoActivityIndicator(` 직접 사용, `go('/...')`·`push('/...')` 라우트 문자열 |
| `layer_dependency_test.dart` | core·data 의 presentation·router import, design 의 providers·pages·widgets·flows import, 화면의 `data/sources` 직접 import, core/monitoring 밖의 Crashlytics·Analytics SDK 직접 import, core/push 밖의 firebase_messaging 직접 import |

- 예외는 각 테스트의 allow-list(`_allowedUsages`, `_allowedReverseImports`)에 파일과 **이유**를 적어서만 둔다. 비어 있는 것이 정상이다.

## 인증 구조

- 로그인: `POST /auth/login {authProvider, idToken}` → access/refresh JWT. 이후 요청은 `Authorization: Bearer`.
- 401이면 인터셉터가 refresh로 재발급, 실패하면 세션 만료 신호(`SessionExpirySignal`) > `AuthNotifier` 로그아웃 > 라우터가 로그인 화면으로 보냄.
- 403 `MEMBER_SUSPENDED`면 이용 제한 신호(`MemberSuspensionSignal`) > `AuthNotifier` 로그아웃 > 로그인 화면에 안내 문구.
- 회원 탈퇴는 서버 삭제 + 소셜 접근 권한 회수(Apple 토큰 revoke) 후 세션 삭제.

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
