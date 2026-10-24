package com.passql.web.controller.admin;

import com.passql.application.statistics.dto.SubscriptionSummaryResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;

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
}
