import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/concept/concept_models.dart';
import '../../data/models/concept/concept_unit_progress.dart';
import 'concept_providers.dart';

/// 단원 순번(0부터): 단원 목록에서 찾음 (목록을 아직 못 불러왔거나 없는 단원이면 null > 이름만 표시)
final conceptTopicOrderProvider = Provider.autoDispose.family<int?, String>(
  (ref, topicUuid) => _findTopicOrderIndex(
    ref.watch(conceptTopicsProvider).valueOrNull?.topics,
    topicUuid,
  ),
);

/// 개념 화면 단원 진행 (결과 단원 줄·점수판 카드): 상세의 단원 > 단원 개념 목록 + 단원 목록 집계
/// 단원 개념 목록을 아직 못 불러왔으면 null (줄 숨김). 처음 받은 단원 완료 수는 화면 수명 동안 기억
class ConceptUnitProgressNotifier
    extends AutoDisposeFamilyNotifier<ConceptUnitProgress?, String> {
  // 이 개념 화면을 처음 열었을 때 단원의 끝낸 개념 수 (결과의 단원 +1 연출 비교용, 재계산에도 유지)
  int? _solvedCountAtStart;

  @override
  ConceptUnitProgress? build(String conceptUuid) {
    // 단원 목록은 단원 개념 목록과 함께 미리 구독 (늦게 구독하면 조회도 늦게 시작)
    final topics = ref.watch(conceptTopicsProvider).valueOrNull?.topics;
    final topicUuid = ref
        .watch(conceptDetailProvider(conceptUuid))
        .valueOrNull
        ?.topicUuid;
    if (topicUuid == null) return null;
    final topicConcepts = ref.watch(conceptListProvider(topicUuid)).valueOrNull;
    if (topicConcepts == null) return null;
    final solvedCountAtStart = _solvedCountAtStart ??=
        topicConcepts.solvedConceptCount;
    return aggregateConceptUnitProgress(
      topicUuid: topicUuid,
      topicConcepts: topicConcepts,
      topics: topics,
      solvedCountAtStart: solvedCountAtStart,
    );
  }
}

final conceptUnitProgressProvider = NotifierProvider.autoDispose
    .family<ConceptUnitProgressNotifier, ConceptUnitProgress?, String>(
      ConceptUnitProgressNotifier.new,
    );

/// 단원 진행 집계: 단원 개념 목록 + 단원 목록(없으면 이름만·전체 0) > 단원 줄 값
/// 다음 단원 = 순번이 더 큰 단원 중 잠기지 않은 가장 앞 단원, 전체 = 다른 단원은 목록 값 + 이 단원은 방금 센 값
ConceptUnitProgress aggregateConceptUnitProgress({
  required String topicUuid,
  required ConceptListResponse topicConcepts,
  required List<ConceptTopicSummary>? topics,
  required int solvedCountAtStart,
}) {
  final solvedCount = topicConcepts.solvedConceptCount;
  final topicOrder = _findTopicOrderIndex(topics, topicUuid);
  final nextTopic = topicOrder == null
      ? null
      : _findNextOpenTopic(topics!, afterOrderIndex: topicOrder);
  return ConceptUnitProgress(
    label: toConceptUnitLabel(
      topicOrder,
      displayName: topicConcepts.displayName,
    ),
    solvedCountBefore: solvedCountAtStart,
    solvedCount: solvedCount,
    total: topicConcepts.concepts.length,
    nextUnitLabel: nextTopic == null
        ? null
        : toConceptUnitLabel(nextTopic.orderIndex),
    nextUnitTopicUuid: nextTopic?.topicUuid,
    // 목록 새로고침 시차를 피하려고 이 단원만 방금 센 값 사용
    overallSolvedCount: topics == null
        ? 0
        : topics.fold<int>(
            solvedCount,
            (sum, topic) =>
                topic.topicUuid == topicUuid ? sum : sum + topic.completedCount,
          ),
    overallTotal: topics == null
        ? 0
        : topics.fold<int>(0, (sum, topic) => sum + topic.conceptCount),
  );
}

/// 단원 목록에서 [topicUuid] 의 순번 (목록 없음·없는 단원이면 null)
int? _findTopicOrderIndex(
  List<ConceptTopicSummary>? topics,
  String topicUuid,
) => topics
    ?.where((topic) => topic.topicUuid == topicUuid)
    .firstOrNull
    ?.orderIndex;

/// [afterOrderIndex] 뒤 단원 중 잠기지 않은 가장 앞 단원 (없으면 null = 마지막 단원)
ConceptTopicSummary? _findNextOpenTopic(
  List<ConceptTopicSummary> topics, {
  required int afterOrderIndex,
}) => topics
    .where((topic) => topic.orderIndex > afterOrderIndex && !topic.isLocked)
    .fold<ConceptTopicSummary?>(
      null,
      (best, topic) =>
          best == null || topic.orderIndex < best.orderIndex ? topic : best,
    );
