---
type: decision
id: DEC-0096
created: 2026-10-06
reviewed: null
topics: [store-release]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0189-unify-app-id-asc-bundle]]", "[[ISS-0189-unify-app-id-asc-bundle-report]]"]
---

# DEC-0096: Android·iOS 앱 ID를 `com.coldredrice.passql` 하나로 쓴다

## 문제 정의 (Context)
App Store Connect에 이미 등록된 앱(Apple ID 6762165005)의 번들 ID는 `com.coldredrice.passql`인데 앱은 `kr.suhsaechan.passql`이라 업로드할 수 없었다 (GitHub #344, #341 댓글).

## 결정 (Decision)
Android applicationId/namespace와 iOS 번들 ID를 모두 `com.coldredrice.passql`로 바꾼다. iOS와 Android 앱 ID는 같아야 한다 (이슈 본문).

## 검토한 대안 (Alternatives)
- GitHub #341 댓글이 두 선택지를 적었다: "번들 ID가 다르면 앱 ID를 그 값으로 변경하거나, `kr.suhsaechan.passql`로 새 앱 생성". #344는 앞의 것을 택했다. 새 앱 생성을 버린 이유는 원본에 없다.

## 결과 (Consequences)
**긍정**
- 이미 만들어 둔 App Store Connect 앱에 업로드할 수 있다.

**부정**
- Firebase 앱 재등록, 디버그 SHA-1 등록, 설정 파일 재발급, iOS 구글 로그인 URL 스킴 갱신이 필요했다.

## 영향 범위 (Scope)
Android `applicationId`/namespace, iOS 번들 ID, Firebase Android/iOS 앱 설정, Play Console 앱 등록(`com.coldredrice.passql`, GitHub #345·#353).

## 출처 (References)
- GitHub #344 이슈 본문, 완료 댓글(2026-10-07)
- GitHub #341 댓글 「막힌 것」(2026-10-06)
