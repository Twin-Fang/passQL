import 'package:freezed_annotation/freezed_annotation.dart';

part 'sqld_exam_guide.freezed.dart';
part 'sqld_exam_guide.g.dart';

/// GET /meta/exam-guide/sqld 응답 (#1076, #1077): 시험 소개 + 연도별 공식 통계 + 회차 메모 + 인사이트
@freezed
class SqldExamGuide with _$SqldExamGuide {
  const factory SqldExamGuide({
    required String oneLineDefinition,
    required String organizerName,
    required String certificationNumber,
    @Default(<String>[]) List<String> recommendedFor,
    @Default(<SqldExamSubject>[]) List<SqldExamSubject> subjects,
    required int examDurationMinutes,
    required int passingTotalScore,
    // 과목 배점 대비 과락 기준 (%, 미만이면 과락)
    required int failingSubjectPercent,
    required int examFeeWon,
    required String validityDescription,
    @Default(<SqldExamFaq>[]) List<SqldExamFaq> faqs,
    // 연도 오름차순
    @Default(<SqldYearlyStatistic>[])
    List<SqldYearlyStatistic> yearlyStatistics,
    @Default(<SqldRoundNote>[]) List<SqldRoundNote> roundNotes,
    @Default(<SqldCertificationComparison>[])
    List<SqldCertificationComparison> comparisons,
    // 연도 통계 2건 미만이면 null
    SqldExamInsights? insights,
    @Default(<SqldExamSource>[]) List<SqldExamSource> sources,
  }) = _SqldExamGuide;

  factory SqldExamGuide.fromJson(Map<String, dynamic> json) =>
      _$SqldExamGuideFromJson(json);
}

@freezed
class SqldExamSubject with _$SqldExamSubject {
  const factory SqldExamSubject({
    required String name,
    required int questionCount,
    required int points,
  }) = _SqldExamSubject;

  factory SqldExamSubject.fromJson(Map<String, dynamic> json) =>
      _$SqldExamSubjectFromJson(json);
}

@freezed
class SqldExamFaq with _$SqldExamFaq {
  const factory SqldExamFaq({
    required String question,
    required String answer,
  }) = _SqldExamFaq;

  factory SqldExamFaq.fromJson(Map<String, dynamic> json) =>
      _$SqldExamFaqFromJson(json);
}

@freezed
class SqldYearlyStatistic with _$SqldYearlyStatistic {
  const factory SqldYearlyStatistic({
    required int year,
    required int applicantCount,
    required int examineeCount,
    required int passerCount,
    required double passRatePercent,
  }) = _SqldYearlyStatistic;

  factory SqldYearlyStatistic.fromJson(Map<String, dynamic> json) =>
      _$SqldYearlyStatisticFromJson(json);
}

@freezed
class SqldRoundNote with _$SqldRoundNote {
  const factory SqldRoundNote({
    required int round,
    required String examDate,
    required String difficultyNote,
    // 체감 난이도 단계: 1 쉬움, 2 보통, 3 어려움 (0: 값 없음 > 아이콘 숨김, #1158)
    @Default(0) int difficultyLevel,
    // 알려진 합격률 (없으면 null)
    double? passRatePercent,
    // false: 수험생 전언·후기 (화면에 비공식 배지)
    @Default(false) bool isOfficial,
  }) = _SqldRoundNote;

  factory SqldRoundNote.fromJson(Map<String, dynamic> json) =>
      _$SqldRoundNoteFromJson(json);
}

@freezed
class SqldCertificationComparison with _$SqldCertificationComparison {
  const factory SqldCertificationComparison({
    required String certificationName,
    required int year,
    required double passRatePercent,
  }) = _SqldCertificationComparison;

  factory SqldCertificationComparison.fromJson(Map<String, dynamic> json) =>
      _$SqldCertificationComparisonFromJson(json);
}

/// 서버 계산 요약: 기준 연도 대비 응시자 배수, 비교 연도(바로 앞 통계 연도) 대비 합격률 증감(%p)
@freezed
class SqldExamInsights with _$SqldExamInsights {
  const factory SqldExamInsights({
    required int latestYear,
    required int previousYear,
    required int growthBaseYear,
    required double examineeGrowthMultiple,
    required double passRateChangePoints,
  }) = _SqldExamInsights;

  factory SqldExamInsights.fromJson(Map<String, dynamic> json) =>
      _$SqldExamInsightsFromJson(json);
}

@freezed
class SqldExamSource with _$SqldExamSource {
  const factory SqldExamSource({
    required String name,
    String? url,
    required String checkedDate,
  }) = _SqldExamSource;

  factory SqldExamSource.fromJson(Map<String, dynamic> json) =>
      _$SqldExamSourceFromJson(json);
}
