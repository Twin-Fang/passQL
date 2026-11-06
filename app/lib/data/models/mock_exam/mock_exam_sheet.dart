// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../question/choice_item.dart';
import '../question/question_schema_table.dart';
import 'mock_exam_enums.dart';

part 'mock_exam_sheet.freezed.dart';
part 'mock_exam_sheet.g.dart';

/// 응시 시험지 (시작·조회 응답, #866): 남은 시간(서버 기준 초) + 50문항(정답 없음)
/// status 가 submitted 면 문항이 비고 결과 화면으로 간다
@freezed
class MockExamSheetResponse with _$MockExamSheetResponse {
  const factory MockExamSheetResponse({
    required String attemptUuid,
    required String roundUuid,
    required int roundNumber,
    required String title,
    @JsonKey(unknownEnumValue: MockExamAttemptStatus.unknown)
    required MockExamAttemptStatus status,
    required int remainingSeconds,
    @Default([]) List<MockExamSheetQuestion> questions,
  }) = _MockExamSheetResponse;

  factory MockExamSheetResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamSheetResponseFromJson(json);
}

/// 시험지 문항 1개 + 내 답·표시 (이어 풀기 원본은 서버)
@freezed
class MockExamSheetQuestion with _$MockExamSheetQuestion {
  const factory MockExamSheetQuestion({
    required int questionNumber,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    required MockExamSubject subject,
    String? topicName,
    required String stem,
    String? schemaDisplay,
    @Default([]) List<QuestionSchemaTable> schemaTables,
    @Default([]) List<MockExamChoice> choices,
    String? selectedChoiceKey,
    @Default(false) bool isFlagged,
  }) = _MockExamSheetQuestion;

  factory MockExamSheetQuestion.fromJson(Map<String, dynamic> json) =>
      _$MockExamSheetQuestionFromJson(json);
}

/// 보기 1개 (풀이 중 isCorrect·rationale 은 null, 해설에서만 채움)
@freezed
class MockExamChoice with _$MockExamChoice {
  const factory MockExamChoice({
    required String key,
    required String kind,
    required String body,
    bool? isCorrect,
    String? rationale,
  }) = _MockExamChoice;

  factory MockExamChoice.fromJson(Map<String, dynamic> json) =>
      _$MockExamChoiceFromJson(json);
}

/// 보기 > 공통 선택지 카드 모델 (ChoiceItemCard 재사용)
extension MockExamChoiceAsChoiceItem on MockExamChoice {
  ChoiceItem toChoiceItem() => ChoiceItem(
    key: key,
    kind: kind,
    body: body,
    isCorrect: isCorrect,
    rationale: rationale,
  );
}

/// 문항 답 저장 요청 (현재 값 그대로, 선택 해제는 null)
@freezed
class MockExamAnswerSaveRequest with _$MockExamAnswerSaveRequest {
  const factory MockExamAnswerSaveRequest({
    String? selectedChoiceKey,
    required bool isFlagged,
  }) = _MockExamAnswerSaveRequest;

  factory MockExamAnswerSaveRequest.fromJson(Map<String, dynamic> json) =>
      _$MockExamAnswerSaveRequestFromJson(json);
}

/// 답 저장 결과: 서버 기준 남은 시간 (타이머 보정)
@freezed
class MockExamAnswerSaveResponse with _$MockExamAnswerSaveResponse {
  const factory MockExamAnswerSaveResponse({
    required int questionNumber,
    required int remainingSeconds,
  }) = _MockExamAnswerSaveResponse;

  factory MockExamAnswerSaveResponse.fromJson(Map<String, dynamic> json) =>
      _$MockExamAnswerSaveResponseFromJson(json);
}

/// 제출 요청: 저장 못 한 답 묶음 (마감 + 유예 안 도착분만 서버가 반영)
@freezed
class MockExamSubmitRequest with _$MockExamSubmitRequest {
  const factory MockExamSubmitRequest({
    @Default([]) List<MockExamAnswerEntry> answers,
  }) = _MockExamSubmitRequest;

  factory MockExamSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$MockExamSubmitRequestFromJson(json);
}

/// 제출 묶음의 답 1개
@freezed
class MockExamAnswerEntry with _$MockExamAnswerEntry {
  const factory MockExamAnswerEntry({
    required int questionNumber,
    String? selectedChoiceKey,
    @Default(false) bool isFlagged,
  }) = _MockExamAnswerEntry;

  factory MockExamAnswerEntry.fromJson(Map<String, dynamic> json) =>
      _$MockExamAnswerEntryFromJson(json);
}
