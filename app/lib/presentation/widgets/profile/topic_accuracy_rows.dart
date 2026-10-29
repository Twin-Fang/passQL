import '../../../data/models/meta/topic_tree.dart';
import '../../../data/models/progress/topic_stat.dart';

/// 약한 영역 기준 정답률 (목록 숫자·차트 꼭짓점을 빨강으로, 차트 점선)
const double weakAccuracyThreshold = 0.6;

/// 영역별 정답률 정렬: 정답률 낮은 순(약한 곳 먼저) / 많이 푼 순
enum TopicAccuracySort { lowestRate, mostSolved }

/// 영역 목록 한 줄. [code] 는 토픽 아이콘·색과 문제 이동에 쓰고, 토픽 목록에 없으면 null
class TopicAccuracyRow {
  const TopicAccuracyRow({
    required this.topicUuid,
    required this.name,
    required this.code,
    required this.solvedCount,
    required this.correctRate,
  });

  final String topicUuid;
  final String name;
  final String? code;
  final int solvedCount;
  final double correctRate;

  bool get isUnsolved => solvedCount == 0;

  /// 풀어 본 영역 중 기준 미만 (안 푼 영역은 약한지 알 수 없음)
  bool get isWeak => !isUnsolved && correctRate < weakAccuracyThreshold;
}

/// topic-analysis 에는 토픽 코드가 없어 토픽 목록과 topicUuid 로 짝짓는다 (#749).
/// 안 푼 영역은 정렬과 무관하게 맨 뒤(서로는 토픽 순서), 나머지는 고른 정렬.
List<TopicAccuracyRow> buildTopicAccuracyRows({
  required List<TopicStat> stats,
  required List<TopicTree> topics,
  required TopicAccuracySort sort,
}) {
  final topicByUuid = {for (final topic in topics) topic.topicUuid: topic};
  final rows = _rowsOf(stats, topicByUuid);
  int orderOf(TopicAccuracyRow row) =>
      topicByUuid[row.topicUuid]?.sortOrder ?? 0;
  int compareSolved(TopicAccuracyRow a, TopicAccuracyRow b) => switch (sort) {
    TopicAccuracySort.lowestRate =>
      a.correctRate != b.correctRate
          ? a.correctRate.compareTo(b.correctRate)
          : b.solvedCount.compareTo(a.solvedCount),
    TopicAccuracySort.mostSolved =>
      a.solvedCount != b.solvedCount
          ? b.solvedCount.compareTo(a.solvedCount)
          : a.correctRate.compareTo(b.correctRate),
  };
  final solved = rows.where((row) => !row.isUnsolved).toList()
    ..sort(compareSolved);
  final unsolved = rows.where((row) => row.isUnsolved).toList()
    ..sort((a, b) => orderOf(a).compareTo(orderOf(b)));
  return [...solved, ...unsolved];
}

/// 8각 차트 꼭짓점 순서: 토픽 순서 그대로 (정답률로 정렬하면 볼 때마다 꼭짓점 자리가 바뀜)
List<TopicAccuracyRow> buildTopicChartRows({
  required List<TopicStat> stats,
  required List<TopicTree> topics,
}) {
  final topicByUuid = {for (final topic in topics) topic.topicUuid: topic};
  int orderOf(TopicAccuracyRow row) =>
      topicByUuid[row.topicUuid]?.sortOrder ?? 0;
  return _rowsOf(stats, topicByUuid)
    ..sort((a, b) => orderOf(a).compareTo(orderOf(b)));
}

List<TopicAccuracyRow> _rowsOf(
  List<TopicStat> stats,
  Map<String, TopicTree> topicByUuid,
) {
  return [
    for (final stat in stats)
      TopicAccuracyRow(
        topicUuid: stat.topicUuid,
        name: stat.displayName,
        code: topicByUuid[stat.topicUuid]?.code,
        solvedCount: stat.solvedCount,
        correctRate: stat.correctRate,
      ),
  ];
}
