package com.passql.web.controller.admin;

import com.passql.application.statistics.dto.AiMonthlyUsageResponse;
import com.passql.application.statistics.dto.SignupsByProviderResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.time.YearMonth;

@Tag(name = "Admin - Statistics", description = "관리자 AI 사용량·비용, 가입 경로 통계 (관리자 세션, 조회는 VIEWER 허용)")
public interface AdminStatisticsApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "AI 월 사용량·비용 API 추가"),
    })
    @Operation(summary = "AI 월 사용량·비용", description = "month: yyyy-MM (생략 시 이번 달). 합계, 모델별, 출처·경로별, 단가표")
    ResponseEntity<AiMonthlyUsageResponse> getAiMonthlyUsage(YearMonth month);

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "가입 경로별 월 가입 수 API 추가"),
    })
    @Operation(summary = "가입 경로별 월 가입 수", description = "최근 12개월, member.auth_provider 별 (테스트 계정 제외, 탈퇴 포함)")
    ResponseEntity<SignupsByProviderResponse> getSignupsByProvider();
}
