---
type: issue
id: ISS-0189
created: 2026-10-06
topics: [store-release]
symptoms: [번들 ID 불일치, kr.suhsaechan.passql, com.coldredrice.passql, App Store 업로드 불가, applicationId]
root_cause: "App Store Connect에 등록된 앱의 번들 ID는 `com.coldredrice.passql`인데 앱은 `kr.suhsaechan.passql`로 만들어져 있었다"
status: resolved
resolution: "[[ISS-0189-unify-app-id-asc-bundle-report]]"
related: ["[[DEC-0096-app-id-com-coldredrice-passql]]", "[[ISS-0186-ios-app-review-compliance-check]]"]
source: "https://github.com/Twin-Fang/passQL/issues/344"
---

# ISS-0189: 앱 ID를 App Store Connect 등록값(`com.coldredrice.passql`)으로 통일

GitHub #344 (원본: 이슈 본문과 댓글).

## 증상
App Store Connect에 이미 등록된 앱(passQL, Apple ID 6762165005)의 번들 ID는 `com.coldredrice.passql`인데 앱은 `kr.suhsaechan.passql`이라 업로드할 수 없다. iOS와 Android 앱 ID도 같아야 한다.

## 재현 조건
`kr.suhsaechan.passql`로 빌드한 앱을 App Store Connect에 업로드할 때.

## 조사 기록
- 2026-10-06: GitHub #341 댓글에서 번들 ID `kr.suhsaechan.passql`로 조회한 앱이 0개임을 확인.

## 근본 원인
앱 ID와 App Store Connect 등록 번들 ID가 달랐다. 왜 달라졌는지는 원본에 적혀 있지 않다.
