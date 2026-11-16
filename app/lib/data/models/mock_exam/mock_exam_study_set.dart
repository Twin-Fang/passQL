import 'package:freezed_annotation/freezed_annotation.dart';

part 'mock_exam_study_set.freezed.dart';
part 'mock_exam_study_set.g.dart';

/// 학습 모드 문항 (GET /mock-exams/rounds/{roundUuid}/study-questions, #1084): 시험 번호 순서 문제 uuid
@freezed
class MockExamStudySetResponse with _$MockExamStudySetResponse {
  const factory MockExamStudySetResponse({
    required String roundUuid,
    required String title,
    required List<String> questionUuids,
  }) = _MockExamStudySetResponse;

  factory MockExamStudySetResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamStudySetResponseFromJson(json);
}
