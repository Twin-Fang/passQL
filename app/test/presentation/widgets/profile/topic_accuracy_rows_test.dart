import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/progress/topic_stat.dart';
import 'package:passql_app/presentation/widgets/profile/topic_accuracy_rows.dart';

TopicStat _stat(String uuid, double rate, int solved) => TopicStat(
  topicUuid: uuid,
  displayName: uuid.toUpperCase(),
  correctRate: rate,
  solvedCount: solved,
);

TopicTree _topic(String uuid, String code, int order) => TopicTree(
  topicUuid: uuid,
  code: code,
  displayName: uuid.toUpperCase(),
  sortOrder: order,
);

void main() {
  final stats = [_stat('a', 0.78, 9), _stat('b', 0.40, 5), _stat('c', 0, 0)];
  final topics = [
    _topic('a', 'sql_join', 4),
    _topic('b', 'sql_window', 7),
    _topic('c', 'data_modeling', 0),
  ];

  test('낮은 순: 정답률 오름차순, 안 푼 영역은 맨 뒤', () {
    final rows = buildTopicAccuracyRows(
      stats: stats,
      topics: topics,
      sort: TopicAccuracySort.lowestRate,
    );
    expect(rows.map((row) => row.topicUuid), ['b', 'a', 'c']);
    expect(rows.first.code, 'sql_window');
  });

  test('많이 푼 순: 푼 수 내림차순, 안 푼 영역은 맨 뒤', () {
    final rows = buildTopicAccuracyRows(
      stats: stats,
      topics: topics,
      sort: TopicAccuracySort.mostSolved,
    );
    expect(rows.map((row) => row.topicUuid), ['a', 'b', 'c']);
  });

  test('토픽 목록에 없는 uuid 는 code null 로 남는다', () {
    final rows = buildTopicAccuracyRows(
      stats: stats,
      topics: const [],
      sort: TopicAccuracySort.lowestRate,
    );
    expect(rows, hasLength(3));
    expect(rows.every((row) => row.code == null), isTrue);
  });

  test('60% 미만이고 푼 영역만 약한 영역 (안 푼 영역은 약하지 않음)', () {
    final rows = buildTopicAccuracyRows(
      stats: [...stats, _stat('d', 0.6, 3)],
      topics: topics,
      sort: TopicAccuracySort.lowestRate,
    );
    final weakByUuid = {for (final row in rows) row.topicUuid: row.isWeak};
    expect(weakByUuid, {'b': true, 'a': false, 'c': false, 'd': false});
  });

  test('차트 줄은 정답률이 아니라 토픽 순서 (꼭짓점 자리가 늘 같음)', () {
    final rows = buildTopicChartRows(stats: stats, topics: topics);
    expect(rows.map((row) => row.topicUuid), ['c', 'a', 'b']);
  });
}
