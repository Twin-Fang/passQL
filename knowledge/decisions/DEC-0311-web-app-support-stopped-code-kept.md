---
type: decision
id: DEC-0311
created: 2026-11-13
reviewed: null
topics: [store-release, dev-workflow]
status: active
supersedes: DEC-0112
superseded_by: null
related: ["[[DEC-0112-web-app-core-feature-parity]]", "[[ISS-0516-intro-site-light-demo-store-urls]]", "[[DEC-0294-intro-site-self-hosted-own-domain]]"]
---

# DEC-0311: 웹 앱(React) 지원을 중지하고 웹 주소는 소개 사이트로 넘기되, 웹 코드는 레포에 남긴다

## 문제 정의 (Context)
[[DEC-0112-web-app-core-feature-parity]]는 웹·앱 투트랙과 핵심 기능 동등성을 유지하기로 했다. 사용자가 "웹 관리 못하겠어, 웹 기능은 안 넣으려고"라며 웹 지원을 접기로 했다(2026-11-13, #1044·#1057).

## 결정 (Decision)
- 웹 앱(passql.vercel.app)의 모든 화면 주소는 소개 사이트(passql.suhsaechan.kr)로 영구 이동한다(#1044, `client/vercel.json`). AdMob `app-ads.txt`·검색엔진 확인 파일·`robots.txt` 만 남긴다.
- 웹 코드(`client/`)는 지우지 않는다(사용자: "일단 코드는 남겨놔"). 다시 켜려면 이동 규칙만 되돌린다.
- 소개 사이트·스토어에서 웹 입구("웹에서 바로 풀기" 등)를 없애고 앱 설치로만 유도한다.

## 검토한 대안 (Alternatives)
- 웹 코드까지 삭제: 사용자가 남기라고 함.
- 웹 기능 유지(DEC-0112): 관리 부담으로 사용자가 접기로 함.

## 결과 (Consequences)
**긍정**
- 웹·앱 기능 동등성 관리 부담이 사라진다.

**부정**
- 웹 운영 주소 상수(`PRODUCTION_SITE_URL`)는 서버 소셜 로그인 콜백·CORS 에 묶여 있어 그대로 남는다. 웹 코드가 레포에 남아 계약 테스트(`gen:api` 등)는 계속 돈다.

## 영향 범위 (Scope)
`client/vercel.json`·`client/public/robots.txt`, gh-pages 소개 사이트 생성기, App Store·Play 등록 주소.

## 출처 (References)
- GitHub #1044, #1057, 2026-11-13 세션 사용자 지시
