import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 개념 탭 첫 화면 (#577): 큰 제목 > 이어서 학습 > 전체 진행 > 열린 단원 목록 > 잠긴 단원 블러
/// 이용 불가(공개 전이고 미리보기 회원 아님)면 안내만 (탭 자체도 셸에서 숨김)
class ConceptsHomePage extends ConsumerWidget {
  const ConceptsHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicList = ref.watch(conceptTopicsProvider);
    return PassqlLargeTitleScrollView(
      title: '개념',
      onRefresh: () => ref.refresh(conceptTopicsProvider.future),
      slivers: [
        topicList.when(
          loading: () => const SliverToBoxAdapter(child: PassqlListSkeleton()),
          error: (_, _) => PassqlSliverFillStatus(
            child: PassqlStatusView.error(
              message: '개념 목록을 불러오지 못했어요.',
              onRetry: () => ref.invalidate(conceptTopicsProvider),
            ),
          ),
          data: (loadedTopicList) =>
              loadedTopicList.isAvailable && loadedTopicList.topics.isNotEmpty
              ? SliverToBoxAdapter(
                  child: _ConceptTopicSections(topicList: loadedTopicList),
                )
              : PassqlSliverFillStatus(
                  child: PassqlStatusView.empty(
                    icon: CupertinoIcons.lightbulb,
                    title: '개념 학습을 준비하고 있어요',
                    message: '단원별 개념 설명과 확인 문제가 곧 열려요.',
                  ),
                ),
        ),
      ],
    );
  }
}

/// 단원 묶음: 소개 문구 > 이어서 학습 카드 > 열린 단원 > 잠긴 단원
class _ConceptTopicSections extends StatelessWidget {
  const _ConceptTopicSections({required this.topicList});

  final ConceptTopicListResponse topicList;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final openTopics = topicList.topics
        .where((topic) => !topic.isLocked)
        .toList();
    final hasLockedTopic = topicList.topics.any((topic) => topic.isLocked);
    final totalConceptCount = topicList.topics.fold<int>(
      0,
      (sum, topic) => sum + topic.conceptCount,
    );
    final totalCompletedCount = topicList.topics.fold<int>(
      0,
      (sum, topic) => sum + topic.completedCount,
    );
    final continueTopic = _findContinueTopic(openTopics);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SQL을 몰라도 처음부터 차근차근 읽고, 바로 확인 문제로 점검해요.',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.lg),
          if (continueTopic != null) ...[
            _ContinueStudyCard(topic: continueTopic),
            const SizedBox(height: PassqlSpacing.xl),
          ],
          PassqlGroupedSection(
            header: '전체 진행 · 개념 $totalConceptCount개 중 $totalCompletedCount개 완료',
            children: [
              for (final topic in openTopics)
                _ConceptTopicRow(
                  topic: topic,
                  isFreeBadgeVisible: hasLockedTopic,
                ),
            ],
          ),
          if (hasLockedTopic) ...[
            const SizedBox(height: PassqlSpacing.lg),
            const ProLockedSection(
              preview: ConceptTopicsLockedSample(),
              caption: LockedPreviewCaptions.conceptTopics,
            ),
          ],
          const SizedBox(height: PassqlSpacing.xxl),
        ],
      ),
    );
  }

  /// 이어서 학습할 단원: 열린 단원 중 아직 다 끝내지 않은 첫 단원 (모두 끝났으면 없음)
  static ConceptTopicSummary? _findContinueTopic(
    List<ConceptTopicSummary> openTopics,
  ) {
    for (final topic in openTopics) {
      if (topic.completedCount < topic.conceptCount) return topic;
    }
    return null;
  }
}

/// 이어서 학습 카드: 진행 고리 + 단원 이름 + 버튼 하나
class _ContinueStudyCard extends StatelessWidget {
  const _ContinueStudyCard({required this.topic});

  final ConceptTopicSummary topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final progress = topic.conceptCount == 0
        ? 0.0
        : topic.completedCount / topic.conceptCount;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PassqlProgressRing(
                value: progress,
                centerText: '${topic.completedCount}/${topic.conceptCount}',
              ),
              const SizedBox(width: PassqlSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이어서 학습',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(height: PassqlSpacing.xxs),
                    Text(
                      '${topic.orderIndex + 1}. ${topic.displayName}',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: '이어서 공부하기',
            size: PassqlButtonSize.regular,
            onPressed: () =>
                context.push(AppRoutes.conceptTopic(topic.topicUuid)),
          ),
        ],
      ),
    );
  }
}

/// 단원 한 줄: 진행 고리(단원 번호) > 단원 이름 > 완료 수 > 무료 배지(잠긴 단원이 있을 때)
class _ConceptTopicRow extends StatelessWidget {
  const _ConceptTopicRow({
    required this.topic,
    required this.isFreeBadgeVisible,
  });

  final ConceptTopicSummary topic;
  final bool isFreeBadgeVisible;

  @override
  Widget build(BuildContext context) {
    final progress = topic.conceptCount == 0
        ? 0.0
        : topic.completedCount / topic.conceptCount;
    return PassqlListRow(
      leading: PassqlProgressRing(
        value: progress,
        centerText: '${topic.orderIndex + 1}',
      ),
      title: topic.displayName,
      subtitle: '개념 ${topic.conceptCount}개 중 ${topic.completedCount}개 완료',
      trailing: isFreeBadgeVisible
          ? const PassqlBadge(text: '무료', kind: PassqlBadgeKind.success)
          : null,
      hasChevron: true,
      onTap: () => context.push(AppRoutes.conceptTopic(topic.topicUuid)),
    );
  }
}
