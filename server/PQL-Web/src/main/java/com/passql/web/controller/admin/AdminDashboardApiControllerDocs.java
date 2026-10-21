package com.passql.web.controller.admin;

import com.passql.application.constant.StatisticsRange;
import com.passql.application.statistics.dto.DashboardAiStatusResponse;
import com.passql.application.statistics.dto.DashboardAiUsageResponse;
import com.passql.application.statistics.dto.DashboardCommunityResponse;
import com.passql.application.statistics.dto.DashboardGrowthResponse;
import com.passql.application.statistics.dto.DashboardHourlyVisitorResponse;
import com.passql.application.statistics.dto.DashboardLearningResponse;
import com.passql.application.statistics.dto.DashboardRealtimeResponse;
import com.passql.application.statistics.dto.DashboardTopicActivityResponse;
import com.passql.common.dto.Author;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "Admin - Dashboard", description = "관리자 대시보드 그래프·KPI (관리자 세션, 조회는 VIEWER 허용)")
public interface AdminDashboardApiControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "대시보드 지금·오늘 KPI API 추가"),
    })
    @Operation(summary = "지금·오늘 KPI", description = "온라인(최근 5분), 오늘·어제 같은 시각 방문자, 가입, 제출·정답률, AI 호출·실패·평균 지연, 토론 새 글·신고 대기")
    ResponseEntity<DashboardRealtimeResponse> getRealtime();

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "가입·방문자 추이 API 추가"),
    })
    @Operation(summary = "가입·방문자 추이", description = "range: DAY 최근 30일(기본) / MONTH 최근 12개월. 빈 묶음 0, 누적 회원 수는 비삭제·비테스트 기준")
    ResponseEntity<DashboardGrowthResponse> getGrowth(StatisticsRange range);

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "AI 호출량·비용 추이 API 추가"),
    })
    @Operation(summary = "AI 호출량·비용 추이", description = "range: DAY / MONTH. 성공·실패·평균 지연(ms)·추정 비용(USD, 단가 미등록 모델 0)")
    ResponseEntity<DashboardAiUsageResponse> getAiUsage(StatisticsRange range);

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "AI API 상태 API 추가"),
    })
    @Operation(summary = "AI API 상태", description = "AI 서버·서킷·Gemini 키, 24시간 실패 원인 4종, 이번 달 토큰·비용·예산·모델별 비용")
    ResponseEntity<DashboardAiStatusResponse> getAiStatus();

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "학습 활동 API 추가"),
    })
    @Operation(summary = "학습 활동 30일", description = "일별 제출 수·정답률(%)")
    ResponseEntity<DashboardLearningResponse> getLearning();

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "토론 활동 API 추가"),
    })
    @Operation(summary = "토론 활동 14일", description = "일별 새 글 수(삭제 제외) + 최근 글 5건")
    ResponseEntity<DashboardCommunityResponse> getCommunity();

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "시간대별 접속 API 추가"),
    })
    @Operation(summary = "시간대별 접속", description = "0~23시 최근 7일(오늘 제외) 방문 회원 수 평균, 길이 24")
    ResponseEntity<DashboardHourlyVisitorResponse> getHourlyVisitors();

    @ApiLogs({
        @ApiLog(date = "2026.10.20", author = Author.SUHSAECHAN, issueNumber = 557, description = "토픽별 문제·풀이 수 API 추가"),
    })
    @Operation(summary = "토픽별 문제·풀이 수", description = "활성 문제 수 많은 순, 최근 30일 제출 수")
    ResponseEntity<List<DashboardTopicActivityResponse>> getTopicActivities();
}
