package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.question.dto.ExamTrendReportResponse;
import com.passql.question.dto.LatestTrendTopicCount;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.List;

@Tag(name = "ExamTrend", description = "SQLD 출제 경향 / 최신 경향 문제")
public interface ExamTrendControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 523, description = "출제 경향 화면 API 추가 (요약·과목 비중·늘어난 유형·자주 나오는 개념·공부 팁·토픽별 최신 경향 문제 수)"),
  })
  @Operation(summary = "최신 출제 경향 조회",
      description = "경향 화면 내용. 항목별 topicCode·latestTrendQuestionCount 로 해당 토픽 최신 경향 문제 풀기 (GET /api/questions?topic=&latestTrend=true).")
  ResponseEntity<ExamTrendReportResponse> getLatestReport();

  @ApiLogs({
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 523, description = "토픽별 최신 경향 문제 수 API 추가 (토픽 목록 '최신 경향' 표시)"),
  })
  @Operation(summary = "토픽별 최신 경향 문제 수", description = "최신 경향 문제가 1개 이상인 활성 토픽만, 토픽 정렬 순서.")
  ResponseEntity<List<LatestTrendTopicCount>> getLatestTrendTopics();
}
