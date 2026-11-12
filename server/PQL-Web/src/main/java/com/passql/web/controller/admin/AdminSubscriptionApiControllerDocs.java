package com.passql.web.controller.admin;

import com.passql.application.billing.RefundCheckRunResponse;
import com.passql.application.statistics.dto.SubscriptionSummaryResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.util.List;

@Tag(name = "Admin - Subscriptions", description = "관리자 구독·매출 현황 (관리자 세션, 조회는 VIEWER 허용)")
public interface AdminSubscriptionApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 619, description = "구독·매출 현황 요약 API 추가"),
    })
    @Operation(summary = "구독·매출 요약", description = "from·to: yyyy-MM-dd (생략 시 최근 30일). 유효 프로 회원, 7일 내 만료 임박, 구간 구매·회수(직전 기간 비교), 상품별 판매, 통화별 금액, 무료 > 프로 전환율, 일별 구매")
    ResponseEntity<SubscriptionSummaryResponse> getSummary(LocalDate from, LocalDate to);

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 619, description = "구독·매출 현황 CSV 내보내기 추가"),
    })
    @Operation(summary = "구독·매출 CSV", description = "요약과 같은 조건, BOM 포함 UTF-8 CSV 첨부 파일")
    ResponseEntity<byte[]> exportSummaryCsv(LocalDate from, LocalDate to);

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 984, description = "Play 환불 회수 확인 최근 실행 기록 API 추가"),
    })
    @Operation(summary = "환불 회수 확인 기록", description = "최근 14회 실행 (최신순): 실행 방식, 시각, 취소 목록·확인 주문·환불 주문·회수 건수, 실패 사유")
    ResponseEntity<List<RefundCheckRunResponse>> getRecentRefundCheckRuns();

    @ApiLogs({
        @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 984, description = "Play 환불 회수 확인 즉시 실행 API 추가"),
    })
    @Operation(summary = "환불 회수 확인 지금 실행", description = "자동 스케줄과 같은 확인을 관리자 수동(ADMIN)으로 1회 실행하고 결과 반환 (조회 전용 계정 불가)")
    ResponseEntity<RefundCheckRunResponse> runRefundCheck();
}
