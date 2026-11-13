// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../progress/ai_stats_analysis.dart';
import '../question/question_schema_table.dart';
import 'mock_exam_enums.dart';
import 'mock_exam_sheet.dart';

part 'mock_exam_result.freezed.dart';
part 'mock_exam_result.g.dart';

/// 모의고사 결과 (#866): 총점·합격·불합격 이유·정오 번호판은 모두 공개
/// 과목·토픽·문항 해설·다음에 할 일은 프로 전용 (무료는 빈 값 + lockedSections)
@freezed
class MockExamResultResponse with _$MockExamResultResponse {
  const factory MockExamResultResponse({
    required String attemptUuid,
    required String roundUuid,
    required int roundNumber,
    required String title,
    @JsonKey(unknownEnumValue: MockExamSubmitReason.unknown)
    required MockExamSubmitReason submitReason,
    required String startedAt,
    required String submittedAt,
    required int elapsedSeconds,
    required int totalScore,
    required int maxScore,
    required int passScore,
    required int correctCount,
    required int questionCount,
    required bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required MockExamFailReason failReason,
    // 같은 회차 응시자 중 내 위치 (응시자 10명 미만이면 null, #1041)
    MockExamRanking? ranking,
    @Default([]) List<MockExamSubjectResult> subjects,
    @Default([]) List<MockExamTopicResult> topics,
    @Default([]) List<MockExamQuestionMark> questionMarks,
    @Default([]) List<MockExamQuestionReview> reviews,
    MockExamNextStep? nextStep,
    @Default([]) List<String> lockedSections,
  }) = _MockExamResultResponse;

  factory MockExamResultResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamResultResponseFromJson(json);
}

/// 회차 순위 (#1041): 회원별 그 회차 첫 응시 점수 분포에서 이번 점수 위치
@freezed
class MockExamRanking with _$MockExamRanking {
  const factory MockExamRanking({
    // 내 순위 (1부터, 동점은 같은 순위)
    required int rankPosition,
    // 순위 계산에 든 응시자 수
    required int takerCount,
    // 상위 퍼센트 (1~100)
    required int topPercent,
  }) = _MockExamRanking;

  factory MockExamRanking.fromJson(Map<String, dynamic> json) =>
      _$MockExamRankingFromJson(json);
}

/// 과목 점수: 과락 기준(미만이면 과락)
@freezed
class MockExamSubjectResult with _$MockExamSubjectResult {
  const factory MockExamSubjectResult({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    required String name,
    required int correctCount,
    required int questionCount,
    required int score,
    required int maxScore,
    required int failBelowScore,
    required bool isFailed,
  }) = _MockExamSubjectResult;

  factory MockExamSubjectResult.fromJson(Map<String, dynamic> json) =>
      _$MockExamSubjectResultFromJson(json);
}

/// 토픽별 이번 시험 정답 수 (정답률 낮은 순)
@freezed
class MockExamTopicResult with _$MockExamTopicResult {
  const factory MockExamTopicResult({
    required String topicUuid,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    required int correctCount,
    required int questionCount,
  }) = _MockExamTopicResult;

  factory MockExamTopicResult.fromJson(Map<String, dynamic> json) =>
      _$MockExamTopicResultFromJson(json);
}

/// 문항 정오 (번호판)
@freezed
class MockExamQuestionMark with _$MockExamQuestionMark {
  const factory MockExamQuestionMark({
    required int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    required bool isAnswered,
    required bool isCorrect,
    required bool isFlagged,
  }) = _MockExamQuestionMark;

  factory MockExamQuestionMark.fromJson(Map<String, dynamic> json) =>
      _$MockExamQuestionMarkFromJson(json);
}

/// 문항 해설: 보기(정답·근거) + 내 답 + 요약 해설 (미리 저장된 내용)
@freezed
class MockExamQuestionReview with _$MockExamQuestionReview {
  const factory MockExamQuestionReview({
    required int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    required String questionUuid,
    String? topicName,
    required String stem,
    String? schemaDisplay,
    @Default([]) List<QuestionSchemaTable> schemaTables,
    @Default([]) List<MockExamChoice> choices,
    String? selectedChoiceKey,
    required String correctChoiceKey,
    required bool isCorrect,
    String? explanationSummary,
  }) = _MockExamQuestionReview;

  factory MockExamQuestionReview.fromJson(Map<String, dynamic> json) =>
      _$MockExamQuestionReviewFromJson(json);
}

/// 다음에 할 일 (서버 판정): 제목 한 줄, 이유 한 줄, 버튼 (통계 AI 분석 버튼과 같은 모양)
@freezed
class MockExamNextStep with _$MockExamNextStep {
  const factory MockExamNextStep({
    required String headline,
    required String message,
    @Default([]) List<AiAnalysisAction> actions,
  }) = _MockExamNextStep;

  factory MockExamNextStep.fromJson(Map<String, dynamic> json) =>
      _$MockExamNextStepFromJson(json);
}

/// 점수 추이 (프로): 채점된 응시 제출 시간순
@freezed
class MockExamHistoryResponse with _$MockExamHistoryResponse {
  const factory MockExamHistoryResponse({
    required int passScore,
    @Default([]) List<MockExamHistoryEntry> attempts,
  }) = _MockExamHistoryResponse;

  factory MockExamHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamHistoryResponseFromJson(json);
}

/// 추이 1칸
@freezed
class MockExamHistoryEntry with _$MockExamHistoryEntry {
  const factory MockExamHistoryEntry({
    required String attemptUuid,
    required int roundNumber,
    required String title,
    required String submittedAt,
    required int totalScore,
    required int subjectOneScore,
    required int subjectTwoScore,
    required bool isPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    required MockExamFailReason failReason,
  }) = _MockExamHistoryEntry;

  factory MockExamHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$MockExamHistoryEntryFromJson(json);
}

/// 서버가 무료 결과에서 뺀 묶음 이름 2개 (lockedSections 값)
abstract final class MockExamLockedSectionNames {
  // 과목별 점수·토픽별 정답률·다음에 할 일
  static const String subjectDetail = 'MOCK_EXAM_SUBJECT_DETAIL';
  // 문항별 해설
  static const String review = 'MOCK_EXAM_REVIEW';
}

/// 결과 잠금 판정
extension MockExamResultLocks on MockExamResultResponse {
  bool get isSubjectDetailLocked =>
      lockedSections.contains(MockExamLockedSectionNames.subjectDetail);

  bool get isReviewLocked =>
      lockedSections.contains(MockExamLockedSectionNames.review);
}
