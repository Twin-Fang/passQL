// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../mock_exam/mock_exam_enums.dart';

part 'expected_pass_response.freezed.dart';
part 'expected_pass_response.g.dart';

/// 예상 합격률 과목별 평균 (#1086)
@freezed
class ExpectedPassSubjectAverage with _$ExpectedPassSubjectAverage {
  const factory ExpectedPassSubjectAverage({
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    @Default(MockExamSubject.unknown)
    MockExamSubject subject,
    @Default('') String subjectName,
    // 최근 응시 과목 평균 점수 (소수 1자리)
    @Default(0) double averageScore,
    @Default(0) int maxScore,
    // 과락 기준 점수 (미만이면 과락)
    @Default(0) int failBelowScore,
    // 평균이 과락 기준 + 4점 이하
    @Default(false) bool isFailRisk,
  }) = _ExpectedPassSubjectAverage;

  factory ExpectedPassSubjectAverage.fromJson(Map<String, dynamic> json) =>
      _$ExpectedPassSubjectAverageFromJson(json);
}

/// GET /progress/expected-pass 응답: 최근 모의고사 최대 5회 기준 (응시 0회면 비율·평균 null)
@freezed
class ExpectedPassResponse with _$ExpectedPassResponse {
  const ExpectedPassResponse._();

  const factory ExpectedPassResponse({
    int? expectedPassPercent,
    double? averageScore,
    @Default(0) int basisAttemptCount,
    @Default(0) int passedAttemptCount,
    @Default(0) int passScore,
    @Default([]) List<ExpectedPassSubjectAverage> subjectAverages,
    // 공식 최근 연도 합격률 (%)
    double? officialPassRatePercent,
    int? officialStatisticYear,
  }) = _ExpectedPassResponse;

  factory ExpectedPassResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpectedPassResponseFromJson(json);

  /// 응시 기록이 있어 비율을 보여 줄 수 있는지
  bool get hasEstimate => expectedPassPercent != null;

  /// 과락 위험 과목
  List<ExpectedPassSubjectAverage> get failRiskSubjects => [
    for (final subjectAverage in subjectAverages)
      if (subjectAverage.isFailRisk) subjectAverage,
  ];
}
