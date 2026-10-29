---
type: issue
id: ISS-0272
created: 2026-10-15
topics: [ops-infra]
symptoms: [크래시 수집 없음, FlutterError.onError 없음, PlatformDispatcher.onError, safeCall 오류 삼킴, debugPrint]
root_cause: "pubspec에 크래시 수집 도구가 없고 `main.dart`에 전역 오류 훅이 없으며 `safeCall`이 삼킨 API 실패는 `debugPrint`로만 남았다"
status: resolved
resolution: "[[ISS-0272-crashlytics-global-error-handling-report]]"
related: ["[[ISS-0274-firebase-analytics-events]]"]
source: "https://github.com/Twin-Fang/passQL/issues/466"
---

# ISS-0272: 앱 크래시·삼킨 API 실패를 알 방법이 없음

GitHub #466 (원본: 이슈 본문과 구현 보고서).

## 증상
- pubspec에 크래시 수집 도구가 없음
- `main.dart`에 `FlutterError.onError`, `PlatformDispatcher.onError`가 없음
- `safeCall`이 삼킨 API 실패는 `debugPrint`로만 남음

## 재현 조건
해당 없음 (기능 부재). 관련 위치: `app/pubspec.yaml`, `app/lib/main.dart:14-44`, `app/lib/core/network/safe_call.dart:16,44`.

## 조사 기록
- 2026-10-15: 제안 — `firebase_crashlytics`, 전역 오류 훅(iOS dSYM 업로드 포함), `safeCall`이 삼키는 오류는 치명적이지 않은 오류로, 릴리스 빌드에서만 수집.

## 근본 원인
frontmatter `root_cause`와 같음.
