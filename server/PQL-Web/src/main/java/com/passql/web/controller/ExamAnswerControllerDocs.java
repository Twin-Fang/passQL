package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.examanswer.ExamAnswerRoundResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetResponse;
import com.passql.submission.dto.examanswer.ExamAnswerSheetSubmitRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

@Tag(name = "ExamAnswer", description = "실제 시험 회차별 가답안·OMR 가채점 (로그인 불필요, 공식 정답 아님)")
public interface ExamAnswerControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.11.14", author = Author.SUHSAECHAN, issueNumber = 1075, description = "회차별 가답안 조회 API 추가"),
  })
  @Operation(
      summary = "회차 가답안",
      description = """
          ## 인증(JWT): **불필요** (IP 당 분당 120회)

          ## 경로
          - **`certType`**: SQLD, **`roundNumber`**: 회차 번호 (예: 63)

          ## 반환값 (ExamAnswerRoundResponse)
          - 회차 정보(title·examDate·status·notice), gradingRule(채점 규칙), participantCount, updatedAt(집계 기준 시각)
          - items 50개: questionNo, subjectNo, conceptTitle, conceptTags, topicCode,
            answer(표시용 정답: answerStatus 가 OFFICIAL·CONFIRMED·LEADING 이면 운영 가답안, 아니면 득표 1위, 없으면 null),
            answerStatus, alternativeAnswers, tally({"1"~"4": 득표}), voteCount, agreementRate(0~1), note
          - 득표·참여자 수는 최대 60초 늦게 반영
          - 회차 없음 404 EXAM_ANSWER_ROUND_NOT_FOUND, 잘못된 certType 400 INVALID_INPUT_VALUE
          """
  )
  ResponseEntity<ExamAnswerRoundResponse> getRound(String certType, int roundNumber);

  @ApiLogs({
      @ApiLog(date = "2026.11.14", author = Author.SUHSAECHAN, issueNumber = 1075, description = "OMR 답안 제출·가채점 API 추가"),
  })
  @Operation(
      summary = "OMR 답안 제출 (가채점)",
      description = """
          ## 인증(JWT): **선택** (있으면 회원 UUID 함께 저장, IP 당 분당 30회)

          ## 요청 (ExamAnswerSheetSubmitRequest)
          - **`clientToken`**: 기기·브라우저가 만든 토큰 (UUID 권장, 8~100자 영문·숫자·-_), 같은 토큰 재제출은 갱신. 서버는 SHA-256 해시만 저장
          - **`answers`**: 50자 (0 모름, 1~4 보기), **`source`**: WEB | APP (없으면 WEB)

          ## 반환값 (ExamAnswerSheetResponse)
          - answers, source, submittedAt, result:
            subject1/subject2 {score, max, isFailCut}, totalScore, scoreRange {min, max}(확정 안 된 문항 틀림/맞음 가정),
            passStatus(PASS·FAIL·BORDERLINE), percentile(상위 %, 참여 10명 미만 null), perQuestion[{questionNo, myAnswer, answer, isCorrect}]
          - 마감 회차 409 EXAM_ANSWER_ROUND_CLOSED, 형식 오류 400 INVALID_INPUT_VALUE
          """
  )
  ResponseEntity<ExamAnswerSheetResponse> submitSheet(LoginMember loginMember, String certType, int roundNumber,
                                                      ExamAnswerSheetSubmitRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.11.14", author = Author.SUHSAECHAN, issueNumber = 1075, description = "내 OMR 답안·가채점 조회 API 추가"),
  })
  @Operation(
      summary = "내 답안 + 가채점",
      description = """
          ## 인증(JWT): **불필요** (IP 당 분당 60회)

          ## 경로
          - **`clientToken`**: 제출 때 쓴 토큰

          ## 반환값: POST sheets 와 같은 형태 (지금 가답안 기준으로 다시 채점)
          - 제출 기록 없음 404 EXAM_ANSWER_SHEET_NOT_FOUND
          """
  )
  ResponseEntity<ExamAnswerSheetResponse> getMySheet(String certType, int roundNumber, String clientToken);
}
