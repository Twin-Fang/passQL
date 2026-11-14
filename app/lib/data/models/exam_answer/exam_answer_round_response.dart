// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/exam_answer/exam_grading_rule.dart';
import 'exam_answer_enums.dart';

part 'exam_answer_round_response.freezed.dart';
part 'exam_answer_round_response.g.dart';

/// 회차 가답안 (GET /exam-answers/{certType}/{roundNumber}, #1075, 로그인 불필요)
/// 회차 정보·채점 규칙·참여자 수·집계 시각(KST)·문항 50개 (득표 집계는 서버 60초 캐시)
@freezed
class ExamAnswerRoundResponse with _$ExamAnswerRoundResponse {
  const ExamAnswerRoundResponse._();

  const factory ExamAnswerRoundResponse({
    required String certType,
    required int roundNumber,
    @Default('') String title,
    // 시험일 yyyy-MM-dd
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    @Default(ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
    ExamAnswerGradingRuleResponse? gradingRule,
    @Default(0) int participantCount,
    DateTime? updatedAt,
    @Default([]) List<ExamAnswerItemResponse> items,
  }) = _ExamAnswerRoundResponse;

  factory ExamAnswerRoundResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerRoundResponseFromJson(json);

  /// 채점 규칙: 서버 규칙 우선, 없으면 SQLD 대체값
  ExamGradingRule get effectiveGradingRule =>
      gradingRule?.toGradingRule() ?? ExamGradingRule.sqldFallback;

  /// 회차 제목: 서버 제목, 없으면 `SQLD 제63회`
  String get displayTitle =>
      title.isNotEmpty ? title : '$certType 제$roundNumber회';
}

/// 서버 채점 규칙: 문항 수·배점·만점·합격 총점·과락 비율·과목별 규칙
@freezed
class ExamAnswerGradingRuleResponse with _$ExamAnswerGradingRuleResponse {
  const ExamAnswerGradingRuleResponse._();

  const factory ExamAnswerGradingRuleResponse({
    required int totalQuestionCount,
    required int pointsPerQuestion,
    required int maxScore,
    required int passScore,
    // 과락 기준 (과목 만점 대비 %, 미만이면 과락)
    @Default(0) int subjectFailBelowPercent,
    @Default([]) List<ExamAnswerSubjectRuleResponse> subjects,
  }) = _ExamAnswerGradingRuleResponse;

  factory ExamAnswerGradingRuleResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerGradingRuleResponseFromJson(json);

  /// 서버 규칙 > 채점 규칙 (과목이 비면 대체값의 과목)
  ExamGradingRule toGradingRule() => ExamGradingRule(
    questionCount: totalQuestionCount,
    pointsPerQuestion: pointsPerQuestion,
    maxScore: maxScore,
    passScore: passScore,
    subjects: subjects.isEmpty
        ? ExamGradingRule.sqldFallback.subjects
        : [
            for (final subject in subjects)
              ExamSubjectRule(
                subjectNo: subject.subjectNo,
                name: subject.subjectName,
                firstQuestionNo: subject.firstQuestionNo,
                lastQuestionNo: subject.lastQuestionNo,
                maxScore: subject.maxScore,
                failBelowScore: subject.failBelowScore,
              ),
          ],
  );
}

/// 과목 규칙: 번호·이름·문항 범위·만점·과락 기준 점수
@freezed
class ExamAnswerSubjectRuleResponse with _$ExamAnswerSubjectRuleResponse {
  const factory ExamAnswerSubjectRuleResponse({
    required int subjectNo,
    @Default('') String subjectName,
    required int firstQuestionNo,
    required int lastQuestionNo,
    required int maxScore,
    required int failBelowScore,
  }) = _ExamAnswerSubjectRuleResponse;

  factory ExamAnswerSubjectRuleResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerSubjectRuleResponseFromJson(json);
}

/// 문항 1개: 실제 번호·과목·출제 개념 한 줄·표시 정답·상태·득표·합의율·메모 (지문·보기 원문 없음)
@freezed
class ExamAnswerItemResponse with _$ExamAnswerItemResponse {
  const ExamAnswerItemResponse._();

  const factory ExamAnswerItemResponse({
    required int questionNo,
    required int subjectNo,
    String? conceptTitle,
    @Default([]) List<String> conceptTags,
    // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
    String? topicCode,
    // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    @Default(ExamAnswerItemStatus.undecided)
    ExamAnswerItemStatus answerStatus,
    // 복수 정답 인정 보기
    @Default([]) List<int> alternativeAnswers,
    // 보기별 득표 {"1": n, ..., "4": n}
    @Default({}) Map<String, int> tally,
    @Default(0) int voteCount,
    // 표시 정답 득표 비율 0~1
    @Default(0) double agreementRate,
    String? note,
  }) = _ExamAnswerItemResponse;

  factory ExamAnswerItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerItemResponseFromJson(json);

  /// 보기 [choice] 득표 수 (없으면 0)
  int votesOf(int choice) => tally['$choice'] ?? 0;

  /// 정답으로 인정하는 보기 (표시 정답 + 복수 정답)
  Set<int> get acceptedAnswers => {?answer, ...alternativeAnswers};
}
