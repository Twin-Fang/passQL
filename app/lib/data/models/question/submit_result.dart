// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import '../ai/choice_explanation.dart';
import 'execute_result.dart';

part 'submit_result.freezed.dart';
part 'submit_result.g.dart';

/// 제출 결과. ResultPage로 navigate state에 담아 전달.
@freezed
class SubmitResult with _$SubmitResult {
  const factory SubmitResult({
    required bool isCorrect,
    String? correctKey,
    String? rationale,
    ExecuteResult? selectedResult,
    ExecuteResult? correctResult,
    String? correctSql,
    String? selectedSql,
    // 저장된 제출의 UUID. 문제 신고가 어떤 제출에 대한 것인지 가리킨다.
    String? submissionUuid,
    // 고른 선택지의 미리 생성된 AI 해설 (있으면 해설 시트가 요청 없이 바로 보여 줌) (#496)
    String? explanation,
    // 구조화 해설 (있으면 미리보기·전체 해설을 요청 없이 바로 표시, #521)
    ChoiceExplanation? structuredExplanation,
    // 서버 응답이 아니라 앱이 제출 시점에 붙이는 값(신고 시 어떤 선택지 세트였는지 전달).
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? choiceSetUuid,
  }) = _SubmitResult;

  factory SubmitResult.fromJson(Map<String, dynamic> json) =>
      _$SubmitResultFromJson(json);
}
