// freezed 생성자 파라미터의 JsonKey 는 정상 사용법이라 경고를 끈다.
// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_models.freezed.dart';
part 'feedback_models.g.dart';

/// 건의사항 처리 상태. 서버 `FeedbackStatus` 와 대응.
enum FeedbackStatus {
  /// 접수됨, 아직 확인 전.
  @JsonValue('PENDING')
  pending,

  /// 팀에서 확인함.
  @JsonValue('REVIEWED')
  reviewed,

  /// 서비스에 반영됨.
  @JsonValue('APPLIED')
  applied;

  /// 화면에 보여줄 상태 이름.
  String get label => switch (this) {
    FeedbackStatus.pending => '대기',
    FeedbackStatus.reviewed => '확인됨',
    FeedbackStatus.applied => '반영됨',
  };
}

/// 내가 보낸 건의 한 건.
@freezed
class FeedbackItem with _$FeedbackItem {
  const factory FeedbackItem({
    required String feedbackUuid,
    required String content,
    // 서버에 상태가 추가돼도 앱이 깨지지 않도록 모르는 값은 대기로 본다.
    @JsonKey(unknownEnumValue: FeedbackStatus.pending)
    @Default(FeedbackStatus.pending)
    FeedbackStatus status,
    required DateTime createdAt,
  }) = _FeedbackItem;

  factory FeedbackItem.fromJson(Map<String, dynamic> json) =>
      _$FeedbackItemFromJson(json);
}

/// GET /feedback/me 응답.
@freezed
class FeedbackListResponse with _$FeedbackListResponse {
  const factory FeedbackListResponse({
    @Default([]) List<FeedbackItem> items,
  }) = _FeedbackListResponse;

  factory FeedbackListResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedbackListResponseFromJson(json);
}

/// POST /feedback 요청.
class FeedbackSubmitRequest {
  const FeedbackSubmitRequest(this.content);

  final String content;

  Map<String, dynamic> toJson() => {'content': content};
}
