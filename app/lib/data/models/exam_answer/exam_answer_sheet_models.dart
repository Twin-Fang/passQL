// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exam_answer/exam_answer_score_report.dart';
import 'exam_answer_enums.dart';

part 'exam_answer_sheet_models.freezed.dart';
part 'exam_answer_sheet_models.g.dart';

/// 답안 제출 (POST .../sheets, #1075): 기기 토큰·답안 50자('0' 모름, '1'~'4')·출처 APP
@freezed
class ExamAnswerSheetRequest with _$ExamAnswerSheetRequest {
  const factory ExamAnswerSheetRequest({
    required String clientToken,
    required String answers,
    required String source,
  }) = _ExamAnswerSheetRequest;

  factory ExamAnswerSheetRequest.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSheetRequestFromJson(json);
}

/// 내 답안지 (POST 제출 응답·GET .../sheets/{clientToken} 공용): 답안 + 채점 결과
/// 결과는 `result` 묶음 또는 최상위 칸 두 모양 모두 받음 (서버 병행 개발)
class ExamAnswerSheetResponse {
  const ExamAnswerSheetResponse({this.answers, this.grade});

  final String? answers;
  final ExamAnswerGradeResult? grade;

  // 채점 결과가 최상위에 있는지 가르는 칸
  static const String _flatGradeMarkerKey = 'totalScore';

  factory ExamAnswerSheetResponse.fromJson(Map<String, dynamic> json) {
    final nestedGrade = json['result'];
    final gradeJson = nestedGrade is Map<String, dynamic>
        ? nestedGrade
        : json.containsKey(_flatGradeMarkerKey)
        ? json
        : null;
    return ExamAnswerSheetResponse(
      answers: json['answers'] as String?,
      grade: gradeJson == null
          ? null
          : ExamAnswerGradeResult.fromJson(gradeJson),
    );
  }
}

/// 서버 채점 결과: 과목 2개·총점·점수 범위·판정·상위 %·문항별 정오
@freezed
class ExamAnswerGradeResult with _$ExamAnswerGradeResult {
  const factory ExamAnswerGradeResult({
    required ExamAnswerSubjectGrade subject1,
    required ExamAnswerSubjectGrade subject2,
    required int totalScore,
    ExamAnswerScoreRangeResponse? scoreRange,
    @JsonKey(unknownEnumValue: ExamAnswerPassStatusValue.unknown)
    @Default(ExamAnswerPassStatusValue.unknown)
    ExamAnswerPassStatusValue passStatus,
    // 참여자 중 상위 % (0~100)
    double? percentile,
    @Default([]) List<ExamAnswerQuestionGrade> perQuestion,
  }) = _ExamAnswerGradeResult;

  factory ExamAnswerGradeResult.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerGradeResultFromJson(json);
}

/// 과목 점수: 점수·만점·과락
@freezed
class ExamAnswerSubjectGrade with _$ExamAnswerSubjectGrade {
  const factory ExamAnswerSubjectGrade({
    required int score,
    required int max,
    @Default(false) bool isFailCut,
  }) = _ExamAnswerSubjectGrade;

  factory ExamAnswerSubjectGrade.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSubjectGradeFromJson(json);
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

/// 문항 정오: 내 답(0 모름)·표시 정답·정오(갈림·미확정이면 null)
@freezed
class ExamAnswerQuestionGrade with _$ExamAnswerQuestionGrade {
  const factory ExamAnswerQuestionGrade({
    required int questionNo,
    @Default(0) int myAnswer,
    int? answer,
    bool? isCorrect,
  }) = _ExamAnswerQuestionGrade;

  factory ExamAnswerQuestionGrade.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerQuestionGradeFromJson(json);
}

/// 서버 채점 결과 > 화면 공통 결과 모양
extension ExamAnswerGradeResultReport on ExamAnswerGradeResult {
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
    ExamAnswerSubjectGrade grade,
  ) => ExamAnswerSubjectScore(
    subjectNo: subjectNo,
    score: grade.score,
    maxScore: grade.max,
    isFailCut: grade.isFailCut,
  );
}
