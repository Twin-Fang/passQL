import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/api_providers.dart';
import '../../data/models/meta/topic_tree.dart';

/// 토픽 목록 Provider. staleTime 없음 — 탭 진입 시 1회 로드.
/// isActive=true인 항목만 sortOrder 기준 정렬하여 반환.
final topicsProvider = FutureProvider<List<TopicTree>>((ref) async {
  final topics = await ref.read(metaApiProvider).getTopics();
  return topics
      .where((topic) => topic.isActive == true)
      .toList()
    ..sort((first, second) => (first.sortOrder ?? 0).compareTo(second.sortOrder ?? 0));
});
