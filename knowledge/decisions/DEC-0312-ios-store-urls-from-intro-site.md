---
type: decision
id: DEC-0312
created: 2026-11-13
reviewed: null
topics: [store-release, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0516-intro-site-light-demo-store-urls]]", "[[DEC-0311-web-app-support-stopped-code-kept]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]"]
---

# DEC-0312: App Store 웹사이트·개인정보처리방침 URL 은 레포 원본 파일 2개로 관리하고, 소개 사이트 주소 상수를 기준으로 검사한다

## 문제 정의 (Context)
웹 지원 중지 뒤에도 스토어 웹사이트·방침 주소가 passql.vercel.app 이었다. App Store Connect 는 두 값 모두 "새 앱 버전을 생성해야" 바뀐다고 안내한다(2026-11-13 확인). `marketing_url.txt` 는 웹 운영 주소(`PRODUCTION_SITE_URL`)와 일치 검사됐는데, 이 상수는 서버 소셜 콜백·CORS 기준이라 바꿀 수 없었다(GitHub #1057).

## 결정 (Decision)
- `app/ios/fastlane/marketing_url.txt` = `https://passql.suhsaechan.kr`, `privacy_url.txt` = `https://passql.suhsaechan.kr/privacy.html`. Fastfile 이 iOS 배포 때 로케일마다 넣는다(두 파일을 같은 반복으로).
- `siteUrls.test.ts` 가 두 파일이 `PUBLIC_LEGAL_SITE_URL` 기준인지 검사한다. `PRODUCTION_SITE_URL` 은 웹 앱·서버 연동용으로 그대로 둔다.
- Play 는 콘솔에서 바로 바꾼다(웹사이트는 즉시 공개, 방침은 Google 검토).

## 검토한 대안 (Alternatives)
- `PRODUCTION_SITE_URL` 자체를 소개 사이트로 변경: 서버 소셜 콜백·CORS 설정과의 일치 검사까지 깨져 고르지 않음.
- ASC 콘솔에서 손으로 변경: 새 버전 없이는 불가.

## 결과 (Consequences)
**긍정**
- 다음 iOS 배포에서 웹사이트·방침이 자동으로 맞춰지고, 사본이 어긋나면 테스트가 잡는다.

**부정**
- iOS 새 버전을 내기 전까지 App Store 페이지는 옛 주소(넘겨주기로 열림)를 보인다.

## 영향 범위 (Scope)
`app/ios/fastlane/Fastfile`·`marketing_url.txt`·`privacy_url.txt`, `client/src/constants/siteUrls.ts`·`siteUrls.test.ts`.

## 출처 (References)
- GitHub #1057, PR #1058
