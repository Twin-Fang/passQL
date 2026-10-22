import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ads/ad_placement.dart';
import '../../../data/models/meta/topic_tree.dart';
import '../../../presentation/providers/ad_providers.dart';
import '../../../presentation/providers/exam_trend_providers.dart';
import '../../../presentation/providers/topic_providers.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../../widgets/ads/ad_native_slot.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';
import '../../widgets/pro/pro_plan_chip_slot.dart';
import '../../widgets/question/topic_card.dart';

/// 네이티브 광고를 끼우는 위치: 토픽 5개 뒤 (그 뒤에 토픽이 하나라도 남을 때만)
const int _nativeAdAfterTopicCount = 5;

/// 토픽 목록 머리글 (스켈레톤과 같은 자리)
const _topicListHeader = '학습할 토픽을 선택하세요';

/// 내용 묶음 사이 가로·위 여백
const _sectionPadding = EdgeInsets.fromLTRB(
  PassqlSpacing.md,
  PassqlSpacing.md,
  PassqlSpacing.md,
  0,
);

/// 문제 탭 1단계 — 풀기 방식(랜덤 풀기) + 토픽 선택 화면.
/// 토픽 행 탭 시 /questions/list?topic=CODE&topicName=NAME으로 이동.
/// 무료(결제 켜짐): 토픽 골라 풀기·실전 모드·약점 추천 묶음 블러 (토픽 목록·최신 경향 요청 없음)
class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(shouldShowProUiProvider)) {
      return const Scaffold(
        body: PassqlLargeTitleScrollView(
          title: '문제',
          trailing: ProPlanChipSlot(),
          slivers: [
            _RandomPracticeSection(),
            SliverPadding(
              padding: _sectionPadding,
              sliver: SliverToBoxAdapter(
                child: ProLockedSection(
                  preview: PracticeModesLockedSample(),
                  caption: LockedPreviewCaptions.practiceModes,
                ),
              ),
            ),
          ],
        ),
      );
    }
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      body: PassqlLargeTitleScrollView(
        title: '문제',
        trailing: const ProPlanChipSlot(),
        // 토픽 추가·비활성화를 앱 재시작 없이 반영
        onRefresh: () async {
          ref.invalidate(topicsProvider);
          ref.invalidate(latestTrendQuestionCountByTopicProvider);
          await ref.read(topicsProvider.future);
        },
        slivers: [
          const _RandomPracticeSection(),
          // 오류만 전체 자리, 로딩 > 목록은 같은 sliver 안에서 페이드 교체
          if (topicsAsync.hasError && !topicsAsync.hasValue)
            // 다시 시도할 방법이 없으면 탭을 오가야 해서 버튼을 둔다 (#375).
            SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '토픽을 불러올 수 없어요',
                onRetry: () => ref.invalidate(topicsProvider),
              ),
            )
          else
            SliverPadding(
              padding: _sectionPadding,
              sliver: SliverToBoxAdapter(
                child: PassqlFadeSwitcher(
                  child: switch (topicsAsync.valueOrNull) {
                    null => const PassqlListSkeleton(
                      key: ValueKey('loading'),
                      header: _topicListHeader,
                    ),
                    final topics => _TopicSections(
                      key: const ValueKey('data'),
                      topics: topics,
                      onTopicTap: (topic) => context.push(
                        AppRoutes.questionChapterOf(
                          topicCode: topic.code,
                          topicName: topic.displayName,
                        ),
                      ),
                    ),
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 풀기 방식 묶음: 랜덤 풀기 (무료·프로 공통, #576). 결제 꺼짐이면 빈 sliver (진입 없음)
class _RandomPracticeSection extends ConsumerWidget {
  const _RandomPracticeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isRandomPracticeVisibleProvider)) {
      return const SliverToBoxAdapter();
    }
    return SliverPadding(
      padding: _sectionPadding,
      sliver: SliverToBoxAdapter(
        child: PassqlGroupedSection(
          header: '풀기 방식',
          children: [
            PassqlListRow(
              leading: PassqlIconTile(
                icon: CupertinoIcons.shuffle,
                color: context.passqlColors.accent,
              ),
              title: RandomPracticeFlow.displayName,
              subtitle: RandomPracticeFlow.summary,
              hasChevron: true,
              onTap: () => context.push(AppRoutes.randomPractice),
            ),
          ],
        ),
      ),
    );
  }
}

/// 토픽 목록: 광고 켜짐 + 토픽이 [_nativeAdAfterTopicCount]개보다 많으면 두 묶음 사이에 네이티브 광고 1칸
/// 광고 꺼짐 > 한 묶음 그대로. 광고 로드 실패 > 두 묶음이 섹션 간격으로만 떨어짐 (빈 광고 자리 없음)
class _TopicSections extends ConsumerWidget {
  const _TopicSections({
    super.key,
    required this.topics,
    required this.onTopicTap,
  });

  final List<TopicTree> topics;
  final ValueChanged<TopicTree> onTopicTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 최신 경향 문제가 있는 토픽 (불러오기 전·실패면 표시 없음, #523)
    final latestTrendTopicCodes =
        ref
            .watch(latestTrendQuestionCountByTopicProvider)
            .valueOrNull
            ?.keys
            .toSet() ??
        const <String>{};
    final hasNativeAdSlot =
        ref.watch(adsEnabledProvider) &&
        topics.length > _nativeAdAfterTopicCount;
    if (!hasNativeAdSlot) {
      return PassqlGroupedSection(
        header: _topicListHeader,
        children: _topicRows(topics, latestTrendTopicCodes, firstIndex: 0),
      );
    }
    final leadingTopics = topics.take(_nativeAdAfterTopicCount).toList();
    final trailingTopics = topics.skip(_nativeAdAfterTopicCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: _topicListHeader,
          children: _topicRows(
            leadingTopics,
            latestTrendTopicCodes,
            firstIndex: 0,
          ),
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
            latestTrendTopicCodes,
            firstIndex: _nativeAdAfterTopicCount,
          ),
        ),
      ],
    );
  }

  // 토픽 행이 위에서부터 차례로 나타난다 (두 묶음에 걸쳐 순번 이어짐)
  List<Widget> _topicRows(
    List<TopicTree> rowTopics,
    Set<String> latestTrendTopicCodes, {
    required int firstIndex,
  }) => [
    for (final (offset, topic) in rowTopics.indexed)
      PassqlReveal(
        index: firstIndex + offset,
        child: TopicCard(
          topic: topic,
          onTap: () => onTopicTap(topic),
          hasLatestTrendQuestion: latestTrendTopicCodes.contains(topic.code),
        ),
      ),
  ];
}
