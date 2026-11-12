---
type: decision
id: DEC-0298
created: 2026-11-12
reviewed: null
topics: [billing, ci-deploy]
status: active
supersedes: null
superseded_by: null
related: ["[[ISS-0509-admin-billing-payout-app-store-refund-check]]"]
---

# DEC-0298: App Store Server API 호출에는 인앱 결제 키를 별도 GitHub Secret(APP_STORE_IAP_* 3개)으로 두고, 없으면 서버가 App Store 환불 점검을 건너뛴다

GitHub #1032 (PR #1033, 배포 워크플로·`application.yml` 주석).

## 문제 정의 (Context)
App Store 환불 점검·소비 정보 응답은 App Store Server API를 ES256 JWT로 호출해야 하고, 그 서명에 인앱 결제 키(p8, key ID, issuer ID)가 필요하다.

## 결정 (Decision)
- 키는 GitHub Secret `APP_STORE_IAP_KEY_P8_BASE64`, `APP_STORE_IAP_KEY_ID`, `APP_STORE_IAP_ISSUER_ID`로 따로 둔다. 배포 워크플로가 형식(key ID 영숫자, issuer ID UUID)을 확인한 뒤 p8 파일과 환경변수로 컨테이너에 연결한다.
- 레포·`application.yml`에는 값을 넣지 않는다(환경변수 또는 운영 `application-prod.yml`).
- 하나라도 없거나 형식이 틀리면 서버는 호출 없이 `APP_STORE_KEY_NOT_CONFIGURED`로 기록하고 관리자에 "키 미설정"을 보인다.
- 로그에는 실패 종류·상태 코드만 남기고 키 원문·거래 응답은 남기지 않는다.

## 검토한 대안 (Alternatives)
- 기존 다른 키를 함께 쓰는 안 등은 논의 기록 없음.

## 결과 (Consequences)
**긍정**
- 키가 없는 환경(로컬·초기 배포)에서도 서버가 정상 기동한다. 운영 로그 `app store server api : configured=true`로 연결을 확인했다.

**부정**
- p8 파일은 다시 내려받을 수 없어 분실하면 새 키를 발급해 Secret 3개를 갱신해야 한다.

## 영향 범위 (Scope)
`.github/workflows/PROJECT-SPRING-SYNOLOGY-PASSQL-CICD.yaml`, `PROJECT-COMMON-SYNOLOGY-SECRET-FILE-UPLOAD.yaml`, `application.yml` `passql.billing.app-store.server-api.*`, `AppleAppStoreServerApiClient`.

## 출처 (References)
- GitHub #1032, PR #1033
