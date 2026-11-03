import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/concept/concept_models.dart';
import 'package:passql_app/presentation/providers/concept_providers.dart';
import 'package:passql_app/presentation/providers/concept_unit_progress_provider.dart';

// 단원 3개: 지금 단원(1단원) > 잠긴 2단원 > 열린 3단원
const _topics = [
  ConceptTopicSummary(
    topicUuid: 'topic-1',
    displayName: '데이터 모델링',
    orderIndex: 0,
    conceptCount: 3,
    completedCount: 0,
  ),
  ConceptTopicSummary(
    topicUuid: 'topic-2',
    displayName: '정규화',
    orderIndex: 1,
    conceptCount: 4,
    completedCount: 2,
    isLocked: true,
  ),
  ConceptTopicSummary(
    topicUuid: 'topic-3',
    displayName: 'SELECT 기본',
    orderIndex: 2,
    conceptCount: 5,
    completedCount: 1,
  ),
];

/// 1단원 개념 3개 중 [solvedCount] 개를 끝낸 목록
ConceptListResponse _topicConceptsWithSolved(int solvedCount) =>
    ConceptListResponse(
      topicUuid: 'topic-1',
      displayName: '데이터 모델링',
      concepts: [
        for (var index = 0; index < 3; index++)
          ConceptSummary(
            conceptUuid: 'concept-$index',
            title: '개념 $index',
            status: index < solvedCount
                ? ConceptStatus.solved
                : ConceptStatus.notStarted,
          ),
      ],
    );

void main() {
  test('단원 진행 집계: 이름·다음 열린 단원·전체 합계', () {
    final progress = aggregateConceptUnitProgress(
      topicUuid: 'topic-1',
      topicConcepts: _topicConceptsWithSolved(2),
      topics: _topics,
      solvedCountAtStart: 1,
    );

    expect(progress.label, '1단원 · 데이터 모델링');
    expect(progress.shortLabel, '1단원');
    expect(progress.solvedCountBefore, 1);
    expect(progress.solvedCount, 2);
    expect(progress.total, 3);
    // 잠긴 2단원은 건너뜀
    expect(progress.nextUnitLabel, '3단원');
    expect(progress.nextUnitTopicUuid, 'topic-3');
    // 이 단원은 방금 센 2 + 다른 단원 목록 값 2 + 1
    expect(progress.overallSolvedCount, 5);
    expect(progress.overallTotal, 12);
  });

  test('단원 진행은 처음 받은 완료 수를 기억해 이번 증가분을 낸다', () async {
    var solvedCount = 1;
    final container = ProviderContainer(
      overrides: [
        conceptDetailProvider.overrideWith(
          (ref, conceptUuid) async => ConceptDetailResponse(
            conceptUuid: conceptUuid,
            topicUuid: 'topic-1',
            title: '엔터티',
          ),
        ),
        conceptListProvider.overrideWith(
          (ref, topicUuid) async => _topicConceptsWithSolved(solvedCount),
        ),
        conceptTopicsProvider.overrideWith(
          (ref) async => const ConceptTopicListResponse(topics: _topics),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      conceptUnitProgressProvider('concept-0'),
      (_, _) {},
    );

    await container.read(conceptDetailProvider('concept-0').future);
    await container.read(conceptListProvider('topic-1').future);
    await container.read(conceptTopicsProvider.future);
    final atStart = subscription.read()!;
    expect(atStart.solvedCountBefore, 1);
    expect(atStart.hasIncrease, isFalse);

    // 채점 뒤 목록 새로고침 > 증가분만 반영, 시작 값은 그대로
    solvedCount = 3;
    container.invalidate(conceptListProvider);
    await container.read(conceptListProvider('topic-1').future);
    final afterSolve = subscription.read()!;
    expect(afterSolve.solvedCountBefore, 1);
    expect(afterSolve.solvedCount, 3);
    expect(afterSolve.isCompletedNow, isTrue);
  });
}
