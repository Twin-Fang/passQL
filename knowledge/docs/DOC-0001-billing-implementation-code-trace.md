---
type: doc
id: DOC-0001
doc_type: design
authority: internal
created: 2026-11-12
reviewed: null
source: "_sources/docs/DOC-0001-billing-implementation-code-trace.md"
topics: [billing]
topics_ref: [admin, practice]
decisions: []
status: active
supersedes: null
superseded_by: null
related: ["[[DEC-0003-one-and-three-month-pass]]", "[[DEC-0004-free-pro-feature-boundary]]", "[[DEC-0005-ship-with-billing-switch-off]]", "[[DEC-0006-ios-non-renewing-web-no-purchase]]", "[[DEC-0175-record-store-paid-amount-nonblocking]]", "[[DEC-0244-promo-code-store-codes-only]]", "[[DEC-0271-daily-limit-judged-in-submit-record-tx]]", "[[DEC-0273-maintenance-mode-passes-external-callbacks]]", "[[DEC-0282-ad-bonus-unlimited-fair-use-200]]", "[[ISS-0361-billing-switch-final-checks]]", "[[ISS-0485-billing-test-setup-e2e]]"]
---

# DOC-0001: 인앱 결제(이용권) 구현 코드 추적 — 서버·앱·웹

## 요약
2026-11-12 main(`f0d36e94`, v1.101.0) 코드를 직접 따라가 정리한 결제 구현 지도다. 결정 노트들은 "무엇을 왜"만 담고 있어서, 실제로 어느 파일이 어떤 순서로 결제를 처리하는지는 이 문서가 기준이다. 결제는 서버·앱·웹 세 스택에 나뉘어 있다. 앱이 스토어 결제를 띄우고, 서버가 Play Developer API 또는 Apple JWS 서명으로 검증해 `entitlement_purchase`(구매 기록)와 `member_entitlement`(회원 등급)에 반영하며, 웹은 판매 없이 등급만 읽는다. 등급 판정은 서버 `FeatureAccessPolicy` 한 곳이다. 코드가 바뀌면 이 문서는 낡으므로, 인용 전에 파일이 아직 있는지 확인한다.

## 핵심 내용 · 논점

### 스택별 역할
| 스택 | 역할 | 주요 위치 |
|---|---|---|
| 서버 | 영수증 검증, 이용권 부여·회수, 결제 스위치, 등급 판정, 관리자 | `PQL-Application/.../billing/`(`PlayBillingService`, `AppStoreBillingService`, `StorePurchaseRecorder`, `EntitlementPurchaseRevoker`), `.../entitlement/FeatureAccessPolicy`, `PQL-Web/.../BillingController`, `PQL-Domain-Member/.../PassProduct`·`EntitlementPurchase` |
| 앱 | 스토어 결제창, 영수증을 서버로 전송, 등급 갱신 | `app/lib/data/billing/`(`store_purchase_service`, `play_purchase_service`, `app_store_purchase_service`), `core/billing/`, `presentation/providers/pro_purchase_sync.dart`·`plan_providers.dart`, `widgets/pro/pro_offer_sheet.dart` |
| 웹 | 판매 없음. 잠금 표시와 "앱에서 구매" 안내 | `client/src/lib/proAccess.ts`, `hooks/useMemberPlan.ts`, `components/pro/`(`UnlockInAppButton`, `AppPassGuideModal`) |

### Android 구매
1. 이용권 시트(`showProOfferSheet`)에서 `purchasePass(productId)`. 상품 ID는 등급 응답 `passOptions`에서 받는다.
2. `PlayPurchaseService.launchPurchase` → `buyConsumable`(`autoConsume: false`, `applicationUserName` = SHA-256(회원 uuid)).
3. `POST /api/billing/play/verify` {`productId`, `purchaseToken`} → `PlayBillingService.verify`.
4. 상품 확인 → 기록된 토큰이면 기존 경로 → Play `purchases.products.get`으로 상태 조회(자격 증명 setting `billing.play_service_account_json`) → 계정 해시 대조(값 없으면 통과) → PENDING이면 저장 없이 반환.
5. 금액은 트랜잭션 밖에서 `orders.get`으로 조회, 실패 시 NULL (DEC-0175).
6. `StorePurchaseRecorder.recordPurchaseAndExtendPlan`: 회원 행 `FOR UPDATE` → 등급 행 잠금 → 만료일 계산 → `INSERT ... ON CONFLICT DO NOTHING` → 1건 들어갔을 때만 등급 연장(`source = PLAY_PURCHASE`).
7. 커밋 뒤 `consume`. 실패하면 다음 verify 때 재시도. acknowledge는 따로 없다.
8. 응답 `MemberPlanResponse` → 앱은 확인 성공 뒤에만 `completePurchase`, `refreshAfterPurchase`로 등급 갱신.
9. 환불: `PlayVoidedPurchaseScheduler`가 매일 04:50 KST에 최근 30일 voided 목록으로 회수.

### iOS 구매
1. StoreKit 2 비갱신 구독, `appAccountToken` = 회원 uuid.
2. `POST /api/billing/app-store/verify` {`productId`, `signedTransaction`(JWS)} → `AppStoreBillingService.verify`.
3. 회원 기준 결제 스위치 확인(꺼지면 400) → Apple 루트 인증서로 JWS 서명 검증(운영 먼저, `INVALID_ENVIRONMENT`면 샌드박스) → 번들·상품·유형(Non-Renewing Subscription)·계정 대조 → 같은 `StorePurchaseRecorder`로 저장(`source = APP_STORE_PURCHASE`).
4. 서버 알림 V2 `POST /api/billing/app-store/notifications`: 인증 없음, 점검 모드 통과(DEC-0273). `REFUND`·`REVOKE`만 처리하고 나머지는 로그만.

### 회수·만료
- 상품: `pro_pass_3m`=90일, `pro_pass_1m`=30일 (DEC-0003). 옛 `pro_exam_pass`는 거절.
- 만료일 = max(구매 시각, 현재 프로 만료일) + 일수. 구매 저장, `passOptions[].expiresAtIfPurchased`, 환불 재계산이 같은 `PassExpiryCalculator`를 쓴다.
- 회수(`EntitlementPurchaseRevoker`): 등급이 `ADMIN_GRANT`면 유지, 아니면 남은 VERIFIED 구매로 만료일을 다시 쌓는다. 관리자 부여 위에 이어 붙인 구매가 환불되면 관리자 부여분도 사라진다(코드 주석에 명시).

### 등급 판정과 결제 스위치
- `FeatureAccessPolicy.isPro`: 회원 기준 결제가 꺼져 있으면 모두 프로, 켜져 있으면 `plan == PRO && expiresAt > now`. 기능 잠금은 `ProFeature`(11개) + `@RequiresProFeature`/`ProFeatureInterceptor`, 일부 필드 숨김은 `ProResponseRedactor`.
- 하루 한도: 무료 10 + 광고 보너스, 공정 사용 상한 200(DEC-0282). 판정 위치는 DEC-0271.
- setting 키: `billing.android.enabled`(이름과 달리 서버 전체 스위치, iOS 포함), `billing.preview_member_uuids`(꺼져 있어도 이 회원은 켜짐), `billing.play_service_account_json`(SECRET).
- 앱 UI 판정은 등급 응답 `isBillingEnabled`(회원 기준) 하나. `AppConfigResponse.isAndroidBillingEnabled`는 전체 스위치만 알려 주는 미리 판단용.
- 웹: `shouldShowProUiForPlan` = `isBillingEnabled && FREE`. 구매 버튼 대신 스토어 안내 모달 (DEC-0006).

### 복원·프로모션 코드·구매 내역
- 복원: 서버 확인 전 구매를 재전송(Play 과거 구매, iOS 미완료 거래). 로그인·앱 복귀 때 자동 재전송도 한다.
- 프로모션 코드: 스토어 코드만, 서버 API 없음 (DEC-0244). Android는 Play redeem URL, iOS는 코드 입력 시트.
- 구매 내역 `GET /api/members/me/purchases`: 스토어 구매(VERIFIED·REVOKED)와 관리자 운영 지급분을 합쳐 최신순. 토큰·주문 번호·관리자 정보는 응답에 넣지 않는다.

### 관리자
- 회원 상세: 프로 부여(`ADMIN_GRANT`, 사유 필수), 등급 회수, 구매 1건 회수. 모두 감사 로그.
- 앱 운영 화면: 결제 스위치 전환, 미리보기 회원 관리, 켜기 전 점검표 6개(경고만, 전환을 막지 않음).
- 구독·매출 통계: `/admin/subscriptions`.

### 멱등성·동시성
- 기록된 토큰/거래는 연장 없이 현재 등급만 반환. 동시 요청은 회원 행 잠금으로 직렬화, 같은 주문 번호에 다른 토큰이면 409.
- 앱도 같은 구매의 확인 요청을 하나로 합친다(`_verificationByKey`).
- 스토어 조회는 트랜잭션 밖, 기록·등급 변경은 한 트랜잭션, consume은 커밋 뒤.

## 추출된 결정
없음. 이미 구현된 내용을 지도로 옮긴 문서라 새 결정은 만들지 않았다. 관련 결정은 `related`에 연결했다.

W4 대조(구현 vs 활성 결정): DEC-0003(상품·기간), DEC-0005(스위치), DEC-0006(iOS 비갱신·웹 판매 없음), DEC-0175(금액 NULL 저장), DEC-0244(스토어 코드만), DEC-0273(외부 콜백 통과), DEC-0282(공정 사용 200)와 코드가 일치했다. 충돌 없음. 단 결정 본문은 DEC-0006만 읽었고 나머지는 클러스터 한 줄 요약과 대조했다.

## 열린 질문
- **결제 스위치 비대칭**: `AppStoreBillingService.verify`는 결제가 꺼진 회원의 요청을 400으로 거절하지만, `PlayBillingService.verify`에는 이 검사가 없다(2026-11-12 코드에서 확인). 꺼진 동안 앱 UI는 구매 버튼을 숨기고 등급도 전원 프로라 실사용 영향은 작지만, 의도인지 누락인지는 기록이 없다.
- **계정 대조 생략**: 계정 식별값이 없는 구매(예전 앱, 테스트 구매)는 대조 없이 통과한다.
- **Apple 검증 범위**: 온라인 폐기 확인(OCSP)이 꺼져 있고, 운영 서버도 샌드박스 거래를 받는다(환경은 로그에만 남김).
- **iOS 알림**: `REFUND`·`REVOKE` 외 유형(예: `CONSUMPTION_REQUEST`)은 무시한다.
- **Play consume 실패**: 다음 verify 때만 재시도한다. 앱이 재전송하지 않으면 3일 안에 소모되지 않은 구매가 자동 환불될 수 있다.
- **Play 환불 반영 지연**: 하루 1번 스케줄러로만 반영하고 RTDN(실시간 알림)은 쓰지 않는다.
- **키 이름**: `billing.android.enabled`가 iOS에도 적용된다.

## 원본 참조
- `_sources/docs/DOC-0001-billing-implementation-code-trace.md` — 코드 추적 원문
- 코드 기준: main `f0d36e94` (2026-11-12). 관련 마이그레이션 `V1_33_0__member_entitlement.sql`, `V1_38_0__entitlement_purchase_granted_days.sql`, `V1_41_0__billing_preview_member_uuids.sql`
