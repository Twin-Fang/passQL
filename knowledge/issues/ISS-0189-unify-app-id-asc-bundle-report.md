---
type: completion-report
id: ISS-0189
created: 2026-10-07
topics: [store-release]
status: resolved
resolves: "[[ISS-0189-unify-app-id-asc-bundle]]"
related: ["[[DEC-0096-app-id-com-coldredrice-passql]]"]
source: "https://github.com/Twin-Fang/passQL/issues/344"
---

# ISS-0189 완료 리포트: Android·iOS 앱 ID를 `com.coldredrice.passql`로 통일

GitHub #344 완료 댓글 기준 (2026-10-07). `## 개요` 형식 리포트는 없음.

## 해결 방법
앱 ID를 App Store Connect 등록값 `com.coldredrice.passql`로 통일했다 (Android/iOS, Firebase 설정 교체 포함, 진행 기록 GitHub #347). 이슈 본문 계획: Android applicationId/namespace·iOS 번들 ID 변경, Firebase에 새 ID로 Android/iOS 앱 등록, 디버그 SHA-1 등록, 설정 파일 재발급, iOS 구글 로그인 URL 스킴 갱신.

## 근본 원인 (확정)
앱 ID와 등록 번들 ID 불일치.

## 재발 방지
원본에 적혀 있지 않다.

## 교훈
(원본에 없음, 볼트 정리) 앱 ID를 바꾸면 Firebase 앱 등록·SHA-1·설정 파일·구글 로그인 URL 스킴까지 함께 바뀐다.
