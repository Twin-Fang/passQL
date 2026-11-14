// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import 'exam_answer_enums.dart';

part 'exam_answer_sheet_models.freezed.dart';
part 'exam_answer_sheet_models.g.dart';

/// 답안 제출 (POST .../sheets, #1075): 기기 토큰·답안 50자('0' 모름, '1'~'4')·출처 APP
@freezed
class ExamAnswerSheetSubmitRequest with _$ExamAnswerSheetSubmitRequest {
  const factory ExamAnswerSheetSubmitRequest({
    required String clientToken,
    required String answers,
    required String source,
  }) = _ExamAnswerSheetSubmitRequest;

  factory ExamAnswerSheetSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSheetSubmitRequestFromJson(json);
}

/// 내 답안지 (POST 제출 응답·GET .../sheets/{clientToken} 공용, 없으면 404 EXAM_ANSWER_SHEET_NOT_FOUND)
@freezed
class ExamAnswerSheetResponse with _$ExamAnswerSheetResponse {
  const factory ExamAnswerSheetResponse({
    required String certType,
    required int roundNumber,
    required String answers,
    String? source,
    DateTime? submittedAt,
    ExamAnswerGradingResponse? result,
  }) = _ExamAnswerSheetResponse;

  factory ExamAnswerSheetResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSheetResponseFromJson(json);
}

/// 서버 채점 결과: 과목 2개·총점·점수 범위·판정·상위 %·문항별 정오
@freezed
class ExamAnswerGradingResponse with _$ExamAnswerGradingResponse {
  const factory ExamAnswerGradingResponse({
    required ExamAnswerSubjectScoreResponse subject1,
    required ExamAnswerSubjectScoreResponse subject2,
    required int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    @Default(ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    // 참여자 중 상위 % (1~100 올림, 참여 10명 미만이면 null)
    int? percentile,
    @Default([]) List<ExamAnswerQuestionResultResponse> perQuestion,
  }) = _ExamAnswerGradingResponse;

  factory ExamAnswerGradingResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerGradingResponseFromJson(json);
}

/// 과목 점수: 점수·만점·과락
@freezed
class ExamAnswerSubjectScoreResponse with _$ExamAnswerSubjectScoreResponse {
  const factory ExamAnswerSubjectScoreResponse({
    required int score,
    required int max,
    @Default(false) bool isFailCut,
  }) = _ExamAnswerSubjectScoreResponse;

  factory ExamAnswerSubjectScoreResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSubjectScoreResponseFromJson(json);
}

/// 점수 범위 (갈림·미확정을 틀림/맞음 가정)
@freezed
class ExamAnswerScoreRangeResponse with _$ExamAnswerScoreRangeResponse {
  const factory ExamAnswerScoreRangeResponse({
    required int min,
    required int max,
  }) = _ExamAnswerScoreRangeResponse;

  factory ExamAnswerScoreRangeResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerScoreRangeResponseFromJson(json);
}

/// 문항 정오: 내 답(0 모름)·표시 정답·정오(표시 정답 없으면 null)
@freezed
class ExamAnswerQuestionResultResponse with _$ExamAnswerQuestionResultResponse {
  const factory ExamAnswerQuestionResultResponse({
    required int questionNo,
    @Default(0) int myAnswer,
    int? answer,
    bool? isCorrect,
  }) = _ExamAnswerQuestionResultResponse;

  factory ExamAnswerQuestionResultResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$ExamAnswerQuestionResultResponseFromJson(json);
}

/// 서버 채점 결과 > 화면 공통 결과 모양
extension ExamAnswerGradingResponseReport on ExamAnswerGradingResponse {
  ExamAnswerScoreReport toScoreReport() {
    final passStatusValue = switch (passStatus) {
      ExamAnswerPassStatusValue.pass => ExamAnswerPassStatus.pass,
      ExamAnswerPassStatusValue.borderline => ExamAnswerPassStatus.borderline,
      // 모르는 값은 불합격으로 (합격을 잘못 알리지 않게)
      ExamAnswerPassStatusValue.fail ||
      ExamAnswerPassStatusValue.unknown => ExamAnswerPassStatus.fail,
    };
    return ExamAnswerScoreReport(
      subjects: [_toSubjectScore(1, subject1), _toSubjectScore(2, subject2)],
      totalScore: totalScore,
      scoreRange: ExamAnswerScoreRange(
        min: scoreRange?.min ?? totalScore,
        max: scoreRange?.max ?? totalScore,
      ),
      passStatus: passStatusValue,
      percentile: percentile,
      questionMarks: [
        for (final question in perQuestion)
          ExamAnswerQuestionMark(
            questionNo: question.questionNo,
            myAnswer: question.myAnswer,
            answer: question.answer,
            isCorrect: question.isCorrect,
          ),
      ],
    );
  }

  static ExamAnswerSubjectScore _toSubjectScore(
    int subjectNo,
    ExamAnswerSubjectScoreResponse subjectScore,
  ) => ExamAnswerSubjectScore(
    subjectNo: subjectNo,
    score: subjectScore.score,
    maxScore: subjectScore.max,
    isFailCut: subjectScore.isFailCut,
  );
}
