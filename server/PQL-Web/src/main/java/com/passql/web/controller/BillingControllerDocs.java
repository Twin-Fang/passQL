package com.passql.web.controller;

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

@Tag(name = "Billing", description = "Play 이용권 구매 확인")
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
}
