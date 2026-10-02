/// `POST /questions/recommendations` 요청 본문.
class RecommendationsRequest {
  const RecommendationsRequest({
    required this.size,
    this.excludeQuestionUuids = const [],
  });

  /// 받을 추천 문제 개수.
  final int size;

  /// 이미 본 문제 UUID. 새로고침 시 중복 추천을 피하려고 보낸다.
  final List<String> excludeQuestionUuids;

  Map<String, dynamic> toJson() => {
    'size': size,
    'excludeQuestionUuids': excludeQuestionUuids,
  };
}
