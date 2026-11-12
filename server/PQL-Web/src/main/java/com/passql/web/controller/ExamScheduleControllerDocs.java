package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.meta.dto.ExamScheduleResponse;
import com.passql.meta.dto.SqldExamScheduleOverviewResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Tag(name = "ExamSchedule", description = "시험 일정 조회")
public interface ExamScheduleControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 23, description = "시험 일정 조회 API 신규 추가. certType 파라미터로 자격증 종류 필터링 가능"),
      @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 991, description = "응답에 접수·수험표·사전점수·발표 일정, 출처, 지금 단계(phase) 추가"),
  })
  @Operation(
      summary = "시험 일정 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 요청 파라미터
          - **`certType`** (optional): 자격증 종류 필터 (SQLD / SQLP). 미입력 시 전체 조회

          ## 반환값 (List<ExamScheduleResponse>)
          - certType + round 오름차순 정렬
          - 각 행: examScheduleUuid, certType, round, examDate, isSelected
          - 일정 (#991, 없으면 null): applicationStartDate·applicationEndDate(원서접수), admissionTicketDate(수험표 발급),
            preliminaryScoreStartDate·preliminaryScoreEndDate(사전점수 공개·재검토 접수), resultAnnouncementDate(합격 발표)
          - source: AUTO(공식 페이지 자동 수집) / MANUAL(관리자 입력), isManualLocked, lastCollectedAt
          - phase (서버 계산, KST 오늘 기준): BEFORE_APPLICATION 접수 전 / APPLICATION_OPEN 접수 중 /
            WAITING_ADMISSION_TICKET 수험표 대기 / WAITING_EXAM 시험 대기(수험표 발급~시험 당일) / WAITING_RESULT 발표 대기 / FINISHED 끝(발표일부터)
          """
  )
  ResponseEntity<List<ExamScheduleResponse>> getSchedules(
      @RequestParam(value = "certType", required = false) String certType);

  @ApiLogs({
      @ApiLog(date = "2026.11.12", author = Author.SUHSAECHAN, issueNumber = 991, description = "앱 시험 일정 화면용 SQLD 한 해 일정 조회 API 신규 추가"),
  })
  @Operation(
      summary = "SQLD 한 해 시험 일정 (앱 시험 일정 화면)",
      description = """
          ## 인증(JWT): **불필요**

          ## 요청 파라미터
          - **`year`** (optional): 시험일 기준 연도. 미입력 시 올해(KST)

          ## 반환값 (SqldExamScheduleOverviewResponse)
          - **`year`**: 조회 연도
          - **`schedules`**: 그해 SQLD 회차 (회차 오름차순, 각 행은 GET /api/exam-schedules 와 같은 형태 + phase)
          - **`nextSchedule`**: 오늘 이후 가장 가까운 SQLD 시험 (연도 무관, 없으면 null)
          - **`lastCollectedAt`**: 마지막 자동 수집 성공 시각 (KST, 없으면 null)
          - **`officialScheduleUrl`**: 공식 일정·접수 페이지 (데이터자격검정)
          """
  )
  ResponseEntity<SqldExamScheduleOverviewResponse> getSqldOverview(
      @RequestParam(value = "year", required = false) Integer year);

  @ApiLogs({
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 23, description = "현재 선택된 시험 일정 조회 API 신규 추가. 선택된 일정이 없으면 200 + null 반환"),
  })
  @Operation(
      summary = "현재 선택된 시험 일정 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 반환값 (ExamScheduleResponse)
          - isSelected = true 인 단일 시험 일정
          - 선택된 일정이 없으면 200 OK + null body (홈화면 greeting fallback 처리)
          """
  )
  ResponseEntity<ExamScheduleResponse> getSelected();
}
