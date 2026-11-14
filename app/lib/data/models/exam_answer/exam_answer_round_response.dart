// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import 'exam_answer_enums.dart';
import 'exam_answer_json_converters.dart';

part 'exam_answer_round_response.freezed.dart';
part 'exam_answer_round_response.g.dart';

/// 회차 가답안 (GET /exam-answers/{certType}/{roundNumber}, #1075, 로그인 불필요)
/// 회차 정보·문항 50개·참여자 수·마지막 갱신 시각 (득표 집계는 서버 60초 캐시)
@freezed
class ExamAnswerRoundResponse with _$ExamAnswerRoundResponse {
  const factory ExamAnswerRoundResponse({
    // 회차 정보: `round` 묶음, 없으면 최상위 칸에서 읽음
    @JsonKey(readValue: _readRoundJson) required ExamAnswerRound round,
    @Default([]) List<ExamAnswerItem> items,
    @Default(0) int participantCount,
    DateTime? updatedAt,
  }) = _ExamAnswerRoundResponse;

  factory ExamAnswerRoundResponse.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerRoundResponseFromJson(json);
}

Object? _readRoundJson(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json;

/// 회차 1개: 시험·회차 번호·제목·시행일(yyyy-MM-dd)·상태·운영 안내
@freezed
class ExamAnswerRound with _$ExamAnswerRound {
  const factory ExamAnswerRound({
    required String certType,
    required int roundNumber,
    @Default('') String title,
    String? examDate,
    @JsonKey(unknownEnumValue: ExamAnswerRoundStatus.unknown)
    @Default(ExamAnswerRoundStatus.unknown)
    ExamAnswerRoundStatus status,
    String? notice,
  }) = _ExamAnswerRound;

  factory ExamAnswerRound.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerRoundFromJson(json);
}

/// 문항 1개: 실제 번호·과목·출제 개념 한 줄·표시 정답·상태·득표·합의율·메모 (지문·보기 원문 없음)
@freezed
class ExamAnswerItem with _$ExamAnswerItem {
  const factory ExamAnswerItem({
    required int questionNo,
    required int subjectNo,
    @Default('') String conceptTitle,
    @ExamAnswerStringListConverter() @Default([]) List<String> conceptTags,
    // 우리 토픽 코드 (개념 학습·문제 풀기 연결, 없으면 연결 버튼 없음)
    String? topicCode,
    // 표시용 정답 1~4 (공식·확정·우세면 운영 정답, 아니면 득표 1위, 표 없으면 null)
    int? answer,
    @JsonKey(unknownEnumValue: ExamAnswerItemStatus.unknown)
    @Default(ExamAnswerItemStatus.undecided)
    ExamAnswerItemStatus answerStatus,
    // 복수 정답 (예: 2,3)
    @ExamAnswerIntListConverter() @Default([]) List<int> alternativeAnswers,
    // 보기 1~4 득표 (0번 칸 = 보기 1)
    @ExamAnswerTallyConverter() @Default([0, 0, 0, 0]) List<int> tally,
    @Default(0) int voteCount,
    // 표시 정답 득표 비율 0~1
    @Default(0) double agreementRate,
    String? note,
  }) = _ExamAnswerItem;

  factory ExamAnswerItem.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerItemFromJson(json);
}
