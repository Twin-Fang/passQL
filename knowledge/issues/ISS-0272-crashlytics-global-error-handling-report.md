---
type: completion-report
id: ISS-0272
created: 2026-10-15
topics: [ops-infra]
status: resolved
resolves: "[[ISS-0272-crashlytics-global-error-handling]]"
related: []
source: "https://github.com/Twin-Fang/passQL/issues/466"
---

# ISS-0272 완료 리포트: `CrashReporter` 공통 지점과 Crashlytics 전역 훅

GitHub #466 구현 보고서(2026-10-15) 기준.

## 해결 방법
- `core/monitoring/crash_reporter.dart`(공통 지점 `CrashReporter`, 테스트에서 교체 가능), `core/monitoring/firebase_crash_reporter.dart`(`FlutterError.onError`, `PlatformDispatcher.instance.onError` 연결, 디버그 빌드 수집 끔).
- `safe_call.dart`: 삼키는 오류 중 예상 밖 오류(unknown, 5xx)만 치명적이지 않은 오류로 기록. 네트워크 끊김·401·4xx 제외.
- 로그인 시 회원 UUID만 사용자 식별자로 설정, 로그아웃·세션 만료 시 해제.
- Android `com.google.firebase.crashlytics` 플러그인, iOS Release 빌드 dSYM 업로드 단계.
- 규칙 테스트: Crashlytics·Analytics SDK는 `core/monitoring` 안에서만 import.

## 근본 원인 (확정)
이슈 노트와 같음.

## 재발 방지
- 검증: `flutter analyze` 경고 0, `flutter test` 271개(1차 통합본), TestFlight Release run `38707522779`(dSYM 단계 포함).
- 주의(원본): Firebase 콘솔에서 Crashlytics를 iOS·Android 앱 각각 활성화해야 수집된다. 디버그 빌드는 수집하지 않는다. `--obfuscate`를 켜면 Dart 심볼 업로드가 따로 필요하다.

## 교훈
원본에 적혀 있지 않다.
