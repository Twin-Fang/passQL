package com.passql.web.controller.admin;

import com.passql.application.statistics.dto.RetentionResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;

@Tag(name = "Admin - Retention", description = "관리자 리텐션·코호트 (관리자 세션, 조회는 VIEWER 허용)")
public interface AdminRetentionApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 620, description = "리텐션·코호트 API 추가"),
    })
    @Operation(summary = "리텐션·코호트", description = "from·to: 가입 기간 yyyy-MM-dd (생략 시 최근 56일). D1·D7·D30 리텐션, 가입 주차별 0~7주 유지율, 같은 기간 활동 회원 대비 기능 이용률")
    ResponseEntity<RetentionResponse> getRetention(LocalDate from, LocalDate to);

    @ApiLogs({
        @ApiLog(date = "2026.10.24", author = Author.SUHSAECHAN, issueNumber = 620, description = "리텐션·코호트 CSV 내보내기 추가"),
    })
    @Operation(summary = "리텐션·코호트 CSV", description = "조회와 같은 조건, BOM 포함 UTF-8 CSV 첨부 파일")
    ResponseEntity<byte[]> exportRetentionCsv(LocalDate from, LocalDate to);
}
