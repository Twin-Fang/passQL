package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveRequest;
import com.passql.submission.dto.mockexam.MockExamAnswerSaveResponse;
import com.passql.submission.dto.mockexam.MockExamHistoryResponse;
import com.passql.submission.dto.mockexam.MockExamResultResponse;
import com.passql.submission.dto.mockexam.MockExamRoundListResponse;
import com.passql.submission.dto.mockexam.MockExamSheetResponse;
import com.passql.submission.dto.mockexam.MockExamSubmitRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.UUID;

@Tag(name = "MockExam", description = "SQLD 모의고사 (50문항 90분, 과목별 과락, 무료 체험 1회 · 프로 전체)")
public interface MockExamControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 회차 목록 API 추가"),
  })
  @Operation(summary = "회차 목록",
      description = "시험 형식(examRule), 풀이 중 응시(이어 풀기), 공개 회차별 시작 가능 여부·막힌 이유·최고 점수·마지막 응시. 마감 지난 내 응시는 먼저 채점.")
  ResponseEntity<MockExamRoundListResponse> getRounds(LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 시작·이어 풀기 API 추가"),
  })
  @Operation(summary = "시작 또는 이어 풀기",
      description = "같은 회차 풀이 중이면 그 응시 시험지, 아니면 새 응시(마감 = 지금 + 90분). 무료 체험 소진 403 MOCK_EXAM_FREE_TRIAL_USED, 체험 회차 아님 403 PRO_REQUIRED, 다른 회차 풀이 중 409 MOCK_EXAM_ATTEMPT_IN_PROGRESS.")
  ResponseEntity<MockExamSheetResponse> startOrResume(LoginMember loginMember, UUID roundUuid);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 시험지 조회 API 추가"),
  })
  @Operation(summary = "시험지",
      description = "남은 시간(초)·50문항(정답 없음)·내 답·표시. 마감이 지났으면 채점 후 status SUBMITTED, questions 빈 목록.")
  ResponseEntity<MockExamSheetResponse> getSheet(LoginMember loginMember, UUID attemptUuid);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 문항 답 저장 API 추가"),
  })
  @Operation(summary = "문항 답 저장",
      description = "고른 보기(null 선택 해제)·표시 여부. 마감 + 15초 뒤면 채점 후 409 MOCK_EXAM_TIME_OVER, 제출한 응시 409 MOCK_EXAM_ALREADY_SUBMITTED.")
  ResponseEntity<MockExamAnswerSaveResponse> saveAnswer(LoginMember loginMember, UUID attemptUuid, int questionNumber,
                                                        MockExamAnswerSaveRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 제출 API 추가"),
  })
  @Operation(summary = "제출 (멱등)",
      description = "기기에 남은 답 묶음은 마감 + 15초 안 도착분만 반영 > 채점 > 결과. 이미 채점된 응시는 같은 결과.")
  ResponseEntity<MockExamResultResponse> submit(LoginMember loginMember, UUID attemptUuid, MockExamSubmitRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 결과 API 추가"),
  })
  @Operation(summary = "결과",
      description = "총점·합격·불합격 이유·문항 정오 공개. 과목별 점수·토픽별 정답률·문항 해설·다음에 할 일은 프로 전용(무료는 빈 값 + lockedSections). 풀이 중 409 MOCK_EXAM_NOT_SUBMITTED.")
  ResponseEntity<MockExamResultResponse> getResult(LoginMember loginMember, UUID attemptUuid);

  @ApiLogs({
      @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 866, description = "모의고사 점수 추이 API 추가 (프로)"),
  })
  @Operation(summary = "점수 추이 (프로)", description = "채점된 응시 제출 시간순. 무료 403 PRO_REQUIRED.")
  ResponseEntity<MockExamHistoryResponse> getHistory(LoginMember loginMember);
}
