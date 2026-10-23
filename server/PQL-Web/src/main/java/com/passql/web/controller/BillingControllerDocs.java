package com.passql.web.controller;

import com.passql.application.billing.AppStoreNotificationRequest;
import com.passql.application.billing.AppStoreVerifyRequest;
import com.passql.application.billing.PlayVerifyRequest;
import com.passql.application.entitlement.MemberPlanResponse;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.RequestBody;

@Tag(name = "Billing", description = "Play·App Store 이용권 구매 확인, App Store 서버 알림")
public interface BillingControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.22", author = Author.SUHSAECHAN, issueNumber = 576, description = "Play 회차 패스 구매 확인 API 추가 (확인·등급 부여·소모)"),
        @ApiLog(date = "2026.10.23", author = Author.SUHSAECHAN, issueNumber = 591, description = "회차 패스 > 1개월·3개월 이용권 교체 (상품 ID 2종, 만료일 이어 붙임)"),
    })
    @Operation(
        summary = "Play 이용권 구매 확인",
        description = """
            ## 인증(JWT): **필요**

            앱이 Play 구매 완료 후(또는 앱 시작·복원 시 미처리 구매를) 보낸다.
            서버가 Google Play 에서 구매를 확인하고 이용권 만료일을 저장한 뒤 소모(consume)까지 처리한다.
            만료일 = max(구매 시각, 현재 프로 만료일) + 이용 일수 (보유 중 재구매는 뒤로 이어 붙임).
            같은 토큰을 다시 보내도 만료일은 한 번만 연장된다 (소모 실패분은 이때 다시 소모).

            ## 요청 바디 (PlayVerifyRequest)
            - **`productId`**: Play 상품 ID (필수, `pro_pass_3m` 90일, `pro_pass_1m` 30일 — `GET /api/members/me/plan` 의 `passOptions` 값)
            - **`purchaseToken`**: Play 구매 토큰 (필수)

            ## 반환값 (MemberPlanResponse)
            - 확인 후 내 등급 (`GET /api/members/me/plan` 과 같은 형태)
            - 결제 대기(pending) 구매는 등급을 바꾸지 않고 현재 등급을 그대로 반환

            ## 에러
            - 400 `INVALID_INPUT_VALUE`: 알 수 없는 상품 ID(옛 `pro_exam_pass` 포함), Play 가 인식하지 못하는 구매 토큰
            - 400 `INVALID_REQUEST`: 취소된 구매, 환불로 회수된 구매
            - 403 `ACCESS_DENIED`: 다른 회원이 이미 등록한 구매 토큰
            - 409 `DATA_INTEGRITY_VIOLATION`: 동시 저장 충돌 (다시 시도)
            - 502 `EXTERNAL_API_ERROR`: Play API 호출 실패 또는 서버 결제 설정 없음
            """
    )
    MemberPlanResponse verifyPlayPurchase(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody PlayVerifyRequest request
    );

    @ApiLogs({
        @ApiLog(date = "2026.10.23", author = Author.SUHSAECHAN, issueNumber = 578, description = "App Store 이용권 구매 확인 API 추가 (StoreKit 2 거래 JWS 서명 검증·등급 부여)"),
    })
    @Operation(
        summary = "App Store 이용권 구매 확인",
        description = """
            ## 인증(JWT): **필요**

            앱이 StoreKit 2 구매 완료 후(또는 앱 시작·복원 시 미처리 거래를) 보낸다.
            서버가 Apple 루트 인증서로 거래 JWS 서명을 검증하고 이용권 만료일을 저장한다 (운영 > 샌드박스 순, TestFlight·심사는 샌드박스).
            만료일 = max(구매 시각, 현재 프로 만료일) + 이용 일수 (보유 중 재구매는 뒤로 이어 붙임).
            같은 거래를 다시 보내도 만료일은 한 번만 연장된다. 서버 확인이 끝난 뒤 앱이 `transaction.finish()` 를 호출한다.

            ## 요청 바디 (AppStoreVerifyRequest)
            - **`productId`**: App Store 상품 ID (필수, `pro_pass_3m` 90일, `pro_pass_1m` 30일 — `GET /api/members/me/plan` 의 `passOptions` 값)
            - **`signedTransaction`**: StoreKit 2 `Transaction.jwsRepresentation` (필수)

            ## 거래 대조
            - 번들 ID `com.coldredrice.passql`, 상품 ID(요청 = 거래), 유형 비갱신 구독(Non-Renewing Subscription)
            - `appAccountToken`: 앱이 결제 때 회원 uuid 를 넣는다. 값이 있으면 요청 회원 uuid 와 같아야 한다 (없으면 대조 생략)

            ## 반환값 (MemberPlanResponse)
            - 확인 후 내 등급 (`GET /api/members/me/plan` 과 같은 형태, Play 확인과 같음)

            ## 에러
            - 400 `INVALID_INPUT_VALUE`: 알 수 없는 상품 ID, 서명·번들 ID·환경 검증 실패, 상품 ID·유형 불일치
            - 400 `INVALID_REQUEST`: 결제 스위치 꺼짐, 환불로 회수된 거래
            - 403 `ACCESS_DENIED`: 다른 회원의 거래(appAccountToken 불일치 또는 다른 회원이 이미 등록)
            - 409 `DATA_INTEGRITY_VIOLATION`: 동시 저장 충돌 (다시 시도)
            """
    )
    MemberPlanResponse verifyAppStorePurchase(
        @AuthMember LoginMember loginMember,
        @Valid @RequestBody AppStoreVerifyRequest request
    );

    @ApiLogs({
        @ApiLog(date = "2026.10.23", author = Author.SUHSAECHAN, issueNumber = 578, description = "App Store 서버 알림 V2 수신 API 추가 (REFUND·REVOKE 등급 회수)"),
    })
    @Operation(
        summary = "App Store 서버 알림 V2 수신",
        description = """
            ## 인증(JWT): **불필요** (Apple 이 호출, 알림 JWS 서명으로 검증)

            App Store Connect 의 App Store Server Notifications V2 URL(운영·샌드박스)로 등록한다.
            `REFUND`·`REVOKE` 알림이면 담긴 거래의 구매를 회수하고 회원 만료일을 남은 구매로 다시 계산한다.
            그 외 유형(`TEST` 포함)은 기록만 하고 200. 기록 없는 거래·이미 회수한 거래도 200 (재전송 안전).

            ## 요청 바디 (AppStoreNotificationRequest)
            - **`signedPayload`**: Apple 알림 JWS (필수)

            ## 반환값
            - 200 (본문 없음)

            ## 에러
            - 400 `INVALID_INPUT_VALUE`: 서명·번들 ID·환경 검증 실패, `signedPayload` 누락
            """
    )
    void receiveAppStoreNotification(@Valid @RequestBody AppStoreNotificationRequest request);
}
