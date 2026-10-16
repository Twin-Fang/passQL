import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ads/ad_placement.dart';
import '../../../data/models/meta/topic_tree.dart';
import '../../../presentation/providers/ad_providers.dart';
import '../../../presentation/providers/topic_providers.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../widgets/ads/ad_native_slot.dart';
import '../../widgets/question/topic_card.dart';

/// 네이티브 광고를 끼우는 위치: 토픽 5개 뒤 (그 뒤에 토픽이 하나라도 남을 때만)
const int _nativeAdAfterTopicCount = 5;

/// 문제 탭 1단계 — 토픽 선택 화면.
/// 토픽 행 탭 시 /questions/list?topic=CODE&topicName=NAME으로 이동.
class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      backgroundColor: context.passqlColors.background,
      body: PassqlLargeTitleScrollView(
        title: '문제',
        // 토픽 추가·비활성화를 앱 재시작 없이 반영
        onRefresh: () async {
          ref.invalidate(topicsProvider);
          await ref.read(topicsProvider.future);
        },
        slivers: [
          topicsAsync.when(
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.loading(),
            ),
            // 다시 시도할 방법이 없으면 탭을 오가야 해서 버튼을 둔다 (#375).
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '토픽을 불러올 수 없어요',
                onRetry: () => ref.invalidate(topicsProvider),
              ),
            ),
            data: (topics) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.md,
                PassqlSpacing.md,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _TopicSections(
                  topics: topics,
                  onTopicTap: (topic) => context.push(
                    AppRoutes.questionChapterOf(
                      topicCode: topic.code,
                      topicName: topic.displayName,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 토픽 목록: 광고 켜짐 + 토픽이 [_nativeAdAfterTopicCount]개보다 많으면 두 묶음 사이에 네이티브 광고 1칸
/// 광고 꺼짐 > 한 묶음 그대로. 광고 로드 실패 > 두 묶음이 섹션 간격으로만 떨어짐 (빈 광고 자리 없음)
class _TopicSections extends ConsumerWidget {
  const _TopicSections({required this.topics, required this.onTopicTap});

  final List<TopicTree> topics;
  final ValueChanged<TopicTree> onTopicTap;

  static const _header = '학습할 토픽을 선택하세요';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNativeAdSlot =
        ref.watch(adsEnabledProvider) &&
        topics.length > _nativeAdAfterTopicCount;
    if (!hasNativeAdSlot) {
      return PassqlGroupedSection(
        header: _header,
        children: _topicRows(topics, firstIndex: 0),
      );
    }
    final leadingTopics = topics.take(_nativeAdAfterTopicCount).toList();
    final trailingTopics = topics.skip(_nativeAdAfterTopicCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: _header,
          children: _topicRows(leadingTopics, firstIndex: 0),
        ),
        // 광고가 뜬 때만 위 간격 (아래 간격은 묶음 사이 기본 간격)
        const AdNativeSlot(
          placement: AdPlacement.nativeQuestions,
          padding: EdgeInsets.only(top: PassqlSpacing.md),
        ),
        const SizedBox(height: PassqlSpacing.md),
        PassqlGroupedSection(
          children: _topicRows(
            trailingTopics,
            firstIndex: _nativeAdAfterTopicCount,
          ),
        ),
      ],
    );
  }

  // 토픽 행이 위에서부터 차례로 나타난다 (두 묶음에 걸쳐 순번 이어짐)
  List<Widget> _topicRows(
    List<TopicTree> rowTopics, {
    required int firstIndex,
  }) => [
    for (final (offset, topic) in rowTopics.indexed)
      PassqlReveal(
        index: firstIndex + offset,
        child: TopicCard(topic: topic, onTap: () => onTopicTap(topic)),
      ),
  ];
}
