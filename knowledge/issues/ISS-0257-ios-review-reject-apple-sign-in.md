---
type: issue
id: ISS-0257
created: 2026-10-15
topics: [auth-member, store-release]
symptoms: [App Store 심사 리젝, "Guideline 2.1(a)", Apple 로그인 실패, operation-not-allowed, signInWithCredential, "로그인에 실패했어요", Firebase Apple 공급자 미등록]
root_cause: "Firebase 프로젝트 `passql` Authentication에 Apple(apple.com) 로그인 공급자가 등록돼 있지 않아 `signInWithCredential`이 `operation-not-allowed`로 실패"
status: resolved
resolution: "[[ISS-0257-ios-review-reject-apple-sign-in-report]]"
related: ["[[ISS-0258-github-secret-synology-backup]]"]
source: "https://github.com/Twin-Fang/passQL/issues/451"
---

# ISS-0257: iOS 심사 리젝 — Apple 로그인 후 에러 (Firebase Apple 공급자 미등록)

GitHub #451 (원본: 이슈 본문과 댓글 3개).

## 증상
App Store 심사(iOS 1.0, 빌드 0.7.0 / 87397003)가 **Guideline 2.1(a) Performance - App Completeness**로 반려. 심사관이 "Apple로 계속하기" → Touch ID 인증까지 마쳤는데 앱에 로그인 실패 메시지. 기기의 Apple 인증은 성공하지만 `FirebaseAuth.signInWithCredential`이 `operation-not-allowed`로 실패해 기본 문구 "로그인에 실패했어요" 표시. 심사관 메시지: "We were unable to use the core feature, Sign in with Apple, because the app displayed an error message when we attempted to sign in with Apple."

## 재현 조건
심사 빌드(0.7.0 / 87397003), iPad Air 11-inch (M3), iPadOS 27.0 → 로그인 화면 "Apple로 계속하기" → Touch ID → 로그인 실패 메시지.

## 조사 기록
- 2026-10-15: Firebase에 등록된 공급자는 Google 하나뿐, Apple 로그인 사용자 0명. 앱 코드(`app/lib/core/auth/firebase_social_sign_in.dart`), 서버 `AppleLoginStrategy`, entitlements는 문제 없음. 앱과 서버가 같은 Firebase 프로젝트(`passql`)를 쓰는 것도 확인.

## 근본 원인
frontmatter `root_cause`와 같음 (콘솔 설정 누락, 코드 문제 아님).
