// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

import '../mock_exam/mock_exam_enums.dart';

part 'question_bookmark_models.freezed.dart';
part 'question_bookmark_models.g.dart';

/// 즐겨찾기 목록 항목 (#1082): 지문 50자 미리보기, 토픽, 과목, 추가 시각
@freezed
class QuestionBookmarkItem with _$QuestionBookmarkItem {
  const factory QuestionBookmarkItem({
    required String questionUuid,
    required String stemPreview,
    String? topicName,
    @JsonKey(unknownEnumValue: MockExamSubject.unknown)
    @Default(MockExamSubject.unknown)
    MockExamSubject subject,
    DateTime? bookmarkedAt,
  }) = _QuestionBookmarkItem;

  factory QuestionBookmarkItem.fromJson(Map<String, dynamic> json) =>
      _$QuestionBookmarkItemFromJson(json);
}

/// GET /bookmarks 응답 한 페이지 (최근 추가 순)
@freezed
class QuestionBookmarksResponse with _$QuestionBookmarksResponse {
  const factory QuestionBookmarksResponse({
    @Default([]) List<QuestionBookmarkItem> items,
    @Default(0) int totalCount,
    @Default(0) int page,
    @Default(false) bool hasNext,
  }) = _QuestionBookmarksResponse;

  factory QuestionBookmarksResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionBookmarksResponseFromJson(json);
}

/// PUT·DELETE /questions/{uuid}/bookmark 응답: 요청 뒤 상태
@freezed
class QuestionBookmarkStatusResponse with _$QuestionBookmarkStatusResponse {
  const factory QuestionBookmarkStatusResponse({
    required String questionUuid,
    @Default(false) bool isBookmarked,
  }) = _QuestionBookmarkStatusResponse;

  factory QuestionBookmarkStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$QuestionBookmarkStatusResponseFromJson(json);
}

/// GET /bookmarks/practice-set 응답: 즐겨찾기 문제 무작위 최대 10개
@freezed
class QuestionBookmarkPracticeSetResponse
    with _$QuestionBookmarkPracticeSetResponse {
  const factory QuestionBookmarkPracticeSetResponse({
    @Default([]) List<String> questionUuids,
  }) = _QuestionBookmarkPracticeSetResponse;

  factory QuestionBookmarkPracticeSetResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$QuestionBookmarkPracticeSetResponseFromJson(json);
}
