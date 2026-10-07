# passQL App (Flutter)

SQLD·SQLP 학습 서비스 passQL의 모바일 앱. 서버(`server/`)와만 통신한다 (AI 서버 직접 호출 금지).
앱 ID `com.coldredrice.passql` (Android/iOS 동일), 한국 대상 출시.

## Tech Stack

- **Flutter** 3.x + **Dart** SDK ^3.9.2
- **상태관리**: flutter_riverpod ^2.6 (+ riverpod_annotation)
- **라우팅**: go_router ^17
- **HTTP**: Dio ^5.9 + Retrofit (코드 생성)
- **모델**: freezed + json_serializable
- **인증**: Firebase Auth + Google Sign-In + Sign in with Apple, 토큰은 flutter_secure_storage
- **UI**: flutter_screenutil, flutter_svg, shimmer, fl_chart(레이더 차트), font_awesome_flutter
- **폰트**: Pretendard (`assets/fonts`)

## Project Structure

```
lib/
├── main.dart               # 진입점, 세션 복원, 라우터 연동
├── core/
│   ├── auth/               # 토큰 저장, 인터셉터(Bearer·재발급), 소셜 로그인, 설치 가드
│   ├── error/              # ErrorCode, AppException (서버 오류를 사용자 문구로 변환)
│   ├── network/            # dio_client, api_providers, safe_call
│   └── utils/ validation/
├── data/
│   ├── models/             # freezed 데이터 모델 (도메인별 폴더)
│   └── sources/            # Retrofit API 정의, SSE 클라이언트
├── presentation/
│   ├── flows/              # 문제 풀이 흐름 공통화 (question_flow, daily_set_flow)
│   ├── pages/              # login, home, questions, practice, result, stats, settings,
│   │                       # daily_set(결과·리더보드), feedback, legal
│   ├── providers/          # Riverpod 프로바이더 (계정 전환 시 session_reset으로 초기화)
│   └── widgets/            # 공용 위젯 (settings_group 등)
└── router/                 # app_router, app_routes
tool/store_shots/           # 스토어 스크린샷용 가짜 API 진입점 (운영 코드 아님)
```

## 인증 구조

- 로그인: `POST /auth/login {authProvider, idToken}` → access/refresh JWT. 이후 요청은 `Authorization: Bearer`.
- 401이면 인터셉터가 refresh로 재발급, 실패하면 로그아웃 처리(라우터가 로그인 화면으로 보냄).
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
- **이모지 금지** — 아이콘은 `font_awesome_flutter` 또는 `Icons`, SVG는 `flutter_svg`

## Git Conventions

- 커밋 메시지에 이슈 링크를 붙인다. 형식: `<이슈 제목> : <type> : <설명> <이슈 URL>` (`/pro-commit` 사용)
- 모든 작업은 이슈로 시작하고 수정 전후 이미지를 이슈에 남긴다.
