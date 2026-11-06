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

/// 바로 풀기 버튼 4종: 토픽 문제 풀기, 오답 다시 풀기, 랜덤 풀기(데이터 부족), 최신 경향 풀기(모두 안정권) + 앱이 모르는 값
enum AiAnalysisActionType {
  @JsonValue('PRACTICE_TOPIC')
  practiceTopic,
  @JsonValue('REVIEW_WRONG')
  reviewWrong,
  @JsonValue('RANDOM_PRACTICE')
  randomPractice,
  @JsonValue('PRACTICE_LATEST_TREND')
  practiceLatestTrend,
  // 서버에 새 버튼 종류가 생겼을 때 (버튼 숨김)
  unknown,
}

/// 예상 점수 판정 4종 (#862): 과락 위험, 합격권, 합격선 근처, 합격선 아래 + 앱이 모르는 값
enum AiForecastVerdict {
  @JsonValue('SUBJECT_FAIL_RISK')
  subjectFailRisk,
  @JsonValue('PASS_LIKELY')
  passLikely,
  @JsonValue('BORDERLINE')
  borderline,
  @JsonValue('BELOW_PASS')
  belowPass,
  // 서버에 새 판정이 생겼을 때 (회색 배지)
  unknown,
}

/// 통계 AI 구조화 분석 (#861, #862): 한 줄 진단 > 예상 점수 > 약한 토픽 최대 2 > 반복 오답 > 추세·강점 > 다음 목표 > 바로 풀기 최대 2
/// 데이터 부족이면 readiness 만 (약한 토픽 없음)
@freezed
class AiStatsAnalysis with _$AiStatsAnalysis {
  const factory AiStatsAnalysis({
    @Default('') String headline,
    @Default([]) List<AiAnalysisFinding> findings,
    // 이번 주 정답률 변화 한 줄 (비교할 기록 없으면 null)
    String? trend,
    AiAnalysisStrength? strength,
    @Default([]) List<AiAnalysisAction> actions,
    // 판정 기간 표기 (예: 최근 90일 기준, 옛 서버면 빈 값)
    @Default('') String periodLabel,
    AiExamForecast? forecast,
    // 예상 점수 근거 부족 안내 (예: 1과목 2문제 더 풀면 예상 점수를 알려 드려요)
    String? forecastHint,
    AiRepeatedWrong? repeatedWrong,
    AiAnalysisReadiness? readiness,
    // 모두 안정권일 때 다음 목표 한 줄
    String? nextGoal,
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
    // 열 수 있는 개념 학습 단원 (없으면 null, #862)
    String? conceptTopicUuid,
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

/// SQLD 과목별 예상 점수 (#862): 1과목 10·2과목 40문항 기준 예상 맞힐 수 + 판정
@freezed
class AiExamForecast with _$AiExamForecast {
  const factory AiExamForecast({
    // 100점 환산 (문항당 2점)
    @Default(0) int expectedScore,
    @Default(0) int subjectOneExpectedCount,
    @Default(0) int subjectOneQuestionCount,
    // 40% 미만 (과락)
    @Default(false) bool isSubjectOneFailRisk,
    @Default(0) int subjectTwoExpectedCount,
    @Default(0) int subjectTwoQuestionCount,
    @Default(false) bool isSubjectTwoFailRisk,
    @JsonKey(unknownEnumValue: AiForecastVerdict.unknown)
    @Default(AiForecastVerdict.unknown)
    AiForecastVerdict verdict,
    @Default('') String verdictLabel,
    // 예: 1과목 예상 6/10 · 2과목 예상 26/40
    @Default('') String summary,
    // 예: 합격선까지 2문제 더 맞히면 돼요 / 과락 경고
    @Default('') String detail,
  }) = _AiExamForecast;

  factory AiExamForecast.fromJson(Map<String, dynamic> json) =>
      _$AiExamForecastFromJson(json);
}

/// 반복 오답 (#862): 같은 문제 2번 이상 틀린 문제 수 + 서버 문구
@freezed
class AiRepeatedWrong with _$AiRepeatedWrong {
  const factory AiRepeatedWrong({
    @Default(0) int questionCount,
    // 그중 마지막 시도도 오답인 문제 수
    @Default(0) int unresolvedCount,
    @Default('') String text,
  }) = _AiRepeatedWrong;

  factory AiRepeatedWrong.fromJson(Map<String, dynamic> json) =>
      _$AiRepeatedWrongFromJson(json);
}

/// 데이터 부족 안내 (#862): 토픽별 5문제씩 풀면 진단 > 가장 많이 푼 토픽 지금 N/5
@freezed
class AiAnalysisReadiness with _$AiAnalysisReadiness {
  const factory AiAnalysisReadiness({
    @Default('') String message,
    // 진행 대상 토픽 짧은 이름 (토픽 없으면 null)
    String? topicName,
    @Default(0) int solvedCount,
    @Default(0) int targetCount,
  }) = _AiAnalysisReadiness;

  factory AiAnalysisReadiness.fromJson(Map<String, dynamic> json) =>
      _$AiAnalysisReadinessFromJson(json);
}
