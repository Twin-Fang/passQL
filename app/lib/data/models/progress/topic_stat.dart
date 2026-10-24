import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic_stat.freezed.dart';
part 'topic_stat.g.dart';

/// GET /progress/topic-analysis 응답 내 토픽별 집계 항목.
@freezed
class TopicStat with _$TopicStat {
  const factory TopicStat({
    required String topicUuid,
    required String displayName,
    // 화면 미사용, 서버가 필드를 뺀 뒤에도 읽히도록 기본값 (#632)
    @Default(0) int totalQuestionCount,
    @Default(0.0) double correctRate,
    @Default(0) int solvedCount,
  }) = _TopicStat;

  factory TopicStat.fromJson(Map<String, dynamic> json) =>
      _$TopicStatFromJson(json);
}
