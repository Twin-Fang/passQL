// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'mock_exam_enums.dart';

part 'mock_exam_round_list.freezed.dart';
part 'mock_exam_round_list.g.dart';

/// 모의고사 회차 목록 (GET /mock-exams/rounds, #866): 시험 형식, 풀이 중 응시, 공개 회차
@freezed
class MockExamRoundListResponse with _$MockExamRoundListResponse {
  const factory MockExamRoundListResponse({
    required MockExamRule examRule,
    MockExamInProgressAttempt? inProgressAttempt,
    @Default([]) List<MockExamRoundSummary> rounds,
  }) = _MockExamRoundListResponse;

  factory MockExamRoundListResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamRoundListResponseFromJson(json);
}

/// 시험 형식 (안내 문구 원본, 앱에 숫자를 두지 않음)
@freezed
class MockExamRule with _$MockExamRule {
  const factory MockExamRule({
    required int questionCount,
    required int durationMinutes,
    required int maxScore,
    required int passScore,
    required int pointsPerQuestion,
    @Default([]) List<MockExamSubjectRule> subjects,
  }) = _MockExamRule;

  factory MockExamRule.fromJson(Map<String, dynamic> json) =>
      _$MockExamRuleFromJson(json);
}

/// 과목 형식: 문항 수·만점·과락 기준(미만이면 과락)
@freezed
class MockExamSubjectRule with _$MockExamSubjectRule {
  const factory MockExamSubjectRule({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    required String name,
    required int questionCount,
    required int maxScore,
    required int failBelowScore,
  }) = _MockExamSubjectRule;

  factory MockExamSubjectRule.fromJson(Map<String, dynamic> json) =>
      _$MockExamSubjectRuleFromJson(json);
}

/// 풀이 중 응시 (이어 풀기 띠): 남은 시간은 응답 시점 서버 기준 초
@freezed
class MockExamInProgressAttempt with _$MockExamInProgressAttempt {
  const factory MockExamInProgressAttempt({
    required String attemptUuid,
    required String roundUuid,
    required int roundNumber,
    required String title,
    required int remainingSeconds,
    required int answeredCount,
  }) = _MockExamInProgressAttempt;

  factory MockExamInProgressAttempt.fromJson(Map<String, dynamic> json) =>
      _$MockExamInProgressAttemptFromJson(json);
}

/// 회차 1개: 시작 가능 여부·막힌 이유·무료 회차는 서버 판정
@freezed
class MockExamRoundSummary with _$MockExamRoundSummary {
  const factory MockExamRoundSummary({
    required String roundUuid,
    required int roundNumber,
    required String title,
    // 회차 종류·실제 시험 회차(기출만, #1079)·시험일(기출 실제 시험일, FINAL 대상 시험일 #1084)
    @JsonKey(unknownEnumValue: MockExamRoundType.unknown)
    @Default(MockExamRoundType.mock)
    MockExamRoundType roundType,
    int? examRoundNumber,
    String? examDate,
    required bool isFreeTrialRound,
    // 무료 기출 회차 (가장 최근 기출, 체험 횟수와 별개, #1079)
    @Default(false) bool isFreePastExamRound,
    required bool canStart,
    @JsonKey(unknownEnumValue: MockExamStartBlockReason.unknown)
    MockExamStartBlockReason? startBlockReason,
    // 학습 모드 가능 (PRO 또는 무료 체험·무료 기출 회차, #1084)
    @Default(false) bool canStudy,
    // 문항 평균 난이도 1~5 (#1084)
    double? averageDifficulty,
    required int submittedAttemptCount,
    int? bestScore,

    /// 최고 점수 응시(동점이면 최근)의 합격 여부·불합격 이유 (과락 포함 서버 판정)
    bool? bestAttemptIsPassed,
    @JsonKey(unknownEnumValue: MockExamFailReason.unknown)
    MockExamFailReason? bestAttemptFailReason,
    MockExamLastAttempt? lastAttempt,
  }) = _MockExamRoundSummary;

  factory MockExamRoundSummary.fromJson(Map<String, dynamic> json) =>
      _$MockExamRoundSummaryFromJson(json);
}

/// 회차의 마지막 응시 (풀이 중이면 점수 없음)
@freezed
class MockExamLastAttempt with _$MockExamLastAttempt {
  const factory MockExamLastAttempt({
    required String attemptUuid,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required MockExamAttemptStatus status,
    int? totalScore,
    bool? isPassed,
    String? submittedAt,
  }) = _MockExamLastAttempt;

  factory MockExamLastAttempt.fromJson(Map<String, dynamic> json) =>
      _$MockExamLastAttemptFromJson(json);
}
