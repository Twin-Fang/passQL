// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_stats_analysis.freezed.dart';
part 'ai_stats_analysis.g.dart';

/// 토픽 판정 3종: 약점(정답률 60% 미만), 불안정(75% 미만), 판단 이름(5문제 미만) + 앱이 모르는 값
enum AiFindingKind {
  @JsonValue('WEAK')
  weak,
  @JsonValue('SHAKY')
  shaky,
  @JsonValue('UNTRIED')
  untried,
  // 서버에 새 판정이 생겼을 때 (칩 없이 표시)
  unknown,
}

/// 바로 풀기 버튼 2종: 토픽 문제 풀기, 최근 오답 다시 풀기 + 앱이 모르는 값
enum AiAnalysisActionType {
  @JsonValue('PRACTICE_TOPIC')
  practiceTopic,
  @JsonValue('REVIEW_WRONG')
  reviewWrong,
  // 서버에 새 버튼 종류가 생겼을 때 (버튼 숨김)
  unknown,
}

/// 통계 AI 구조화 분석 (#861): 한 줄 진단 > 약한 토픽 최대 2 > 추세·강점 > 바로 풀기 최대 2
@freezed
class AiStatsAnalysis with _$AiStatsAnalysis {
  const factory AiStatsAnalysis({
    @Default('') String headline,
    @Default([]) List<AiAnalysisFinding> findings,
    // 이번 주 정답률 변화 한 줄 (비교할 기록 없으면 null)
    String? trend,
    AiAnalysisStrength? strength,
    @Default([]) List<AiAnalysisAction> actions,
  }) = _AiStatsAnalysis;

  factory AiStatsAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AiStatsAnalysisFromJson(json);
}

/// 약한 토픽 1건: 판정 + 근거 숫자 + (선택) AI 오답 패턴 한 줄
@freezed
class AiAnalysisFinding with _$AiAnalysisFinding {
  const factory AiAnalysisFinding({
    @Default('') String topicUuid,
    // 서버가 줄인 표시 이름
    @Default('') String topicName,
    @JsonKey(unknownEnumValue: AiFindingKind.unknown)
    @Default(AiFindingKind.unknown)
    AiFindingKind kind,
    @Default(0) int solvedCount,
    @Default(0) int correctRatePercent,
    // 숫자 근거 한 줄 (예: 6문제 중 3문제 정답 (50%))
    @Default('') String evidence,
    // AI 오답 패턴 한 줄 (LLM 실패·근거 부족이면 null)
    String? insight,
  }) = _AiAnalysisFinding;

  factory AiAnalysisFinding.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisFindingFromJson(json);
}

/// 가장 잘하는 토픽 1건
@freezed
class AiAnalysisStrength with _$AiAnalysisStrength {
  const factory AiAnalysisStrength({
    @Default('') String topicUuid,
    @Default('') String topicName,
    @Default(0) int correctRatePercent,
  }) = _AiAnalysisStrength;

  factory AiAnalysisStrength.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisStrengthFromJson(json);
}

/// 바로 풀기 버튼 1개: 종류 + 대상 토픽(오답 다시 풀기면 null) + 서버가 만든 문구
@freezed
class AiAnalysisAction with _$AiAnalysisAction {
  const factory AiAnalysisAction({
    @JsonKey(unknownEnumValue: AiAnalysisActionType.unknown)
    @Default(AiAnalysisActionType.unknown)
    AiAnalysisActionType type,
    String? topicUuid,
    String? topicName,
    // 문구용 문제 수 (화면 이동에는 안 씀)
    @Default(0) int count,
    @Default('') String label,
  }) = _AiAnalysisAction;

  factory AiAnalysisAction.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisActionFromJson(json);
}
