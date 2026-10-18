import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/api_providers.dart';
import '../../data/models/meta/topic_tree.dart';

/// 토픽 목록 Provider. staleTime 없음 — 탭 진입 시 1회 로드.
/// isActive=true인 항목만 sortOrder 기준 정렬하여 반환.
final topicsProvider = FutureProvider<List<TopicTree>>((ref) async {
  final topics = await ref.read(metaApiProvider).getTopics();
  return topics.where((topic) => topic.isActive == true).toList()..sort(
    (first, second) => (first.sortOrder ?? 0).compareTo(second.sortOrder ?? 0),
  );
});

/// 챕터 1회 풀이 문제 수
const chapterQuestionCount = 10;

/// 토픽 챕터 문제 목록 조회 (첫 페이지 [chapterQuestionCount]개)
class TopicChapterService {
  TopicChapterService(this._ref);

  final Ref _ref;

  /// [isLatestTrendOnly] 면 최신 출제 경향 문제만 (#523)
  Future<List<String>> fetchQuestionUuids(
    String topicCode, {
    bool isLatestTrendOnly = false,
  }) async {
    final questionPage = await _ref
        .read(questionApiProvider)
        .getQuestions(
          0,
          chapterQuestionCount,
          topic: topicCode,
          latestTrend: isLatestTrendOnly ? true : null,
        );
    return questionPage.content
        .map((question) => question.questionUuid)
        .toList();
  }
}

final topicChapterServiceProvider = Provider<TopicChapterService>(
  TopicChapterService.new,
);
