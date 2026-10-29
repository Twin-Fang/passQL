---
type: issue
id: ISS-0190
created: 2026-10-06
topics: [store-release, ci-deploy]
symptoms: [디버그 키 서명, Play Store 업로드 불가, key.properties, 릴리스 키스토어, SHA-1]
root_cause: "Android 릴리스 빌드가 디버그 키로 서명되어 있었다"
status: resolved
resolution: "[[ISS-0190-android-release-signing-key-report]]"
related: ["[[DEC-0097-release-signing-key-properties]]"]
source: "https://github.com/Twin-Fang/passQL/issues/345"
---

# ISS-0190: Android 릴리스 서명 키 구성 (Play Store 업로드 준비)

GitHub #345 (원본: 이슈 본문과 댓글).

## 증상
Android 릴리스 빌드가 디버그 키로 서명되어 Play Store에 올릴 수 없다 (GitHub #339 확인된 위험 2번).

## 재현 조건
릴리스 빌드를 Play Console에 업로드할 때.

## 조사 기록
- 2026-10-06: 계획 — `key.properties` 기반 서명 구성, 업로드 키스토어 생성·SHA-1 Firebase 등록, Play Console 앱 등록(`com.coldredrice.passql`)과 CI 시크릿 연결.

## 근본 원인
릴리스 서명 구성이 없었다.
