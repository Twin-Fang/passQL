import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../widgets/concept/concept_status_mark.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 개념 탭 첫 화면 (#577, #764): 큰 제목 > 진도 구간(끝낸 개념 큰 숫자·막대·이어서 학습 띠) > 단원 구간(열린 단원·잠긴 단원)
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
              ? _ConceptTopicSections(topicList: loadedTopicList)
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

/// 구간 두 개: 진도 > 단원. 다른 탭처럼 제목 아래·구간 사이는 회색 띠, 하나씩 등장
class _ConceptTopicSections extends StatelessWidget {
  const _ConceptTopicSections({required this.topicList});

  final ConceptTopicListResponse topicList;

  @override
  Widget build(BuildContext context) {
    final openTopics = topicList.topics
        .where((topic) => !topic.isLocked)
        .toList();
    final hasLockedTopic = topicList.topics.any((topic) => topic.isLocked);
    final sections = [
      _ProgressSection(
        topics: topicList.topics,
        continueTopic: _findContinueTopic(openTopics),
      ),
      _TopicListSection(openTopics: openTopics, hasLockedTopic: hasLockedTopic),
    ];
    return SliverList.list(
      children: [
        const PassqlSectionGap(),
        for (var index = 0; index < sections.length; index++) ...[
          if (index > 0) const PassqlSectionGap(),
          PassqlReveal(index: index, child: sections[index]),
        ],
        const SizedBox(height: PassqlSpacing.xxl),
      ],
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

/// 진도 구간: "N개 중 끝낸 개념" > 큰 숫자 > 막대 > 이어서 학습 띠(있을 때)
/// 같은 진도를 %·개수·막대로 세 번 말하지 않게 개수 + 막대만 둔다
class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.topics, required this.continueTopic});

  final List<ConceptTopicSummary> topics;
  final ConceptTopicSummary? continueTopic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final totalConceptCount = topics.fold<int>(
      0,
      (sum, topic) => sum + topic.conceptCount,
    );
    final totalCompletedCount = topics.fold<int>(
      0,
      (sum, topic) => sum + topic.completedCount,
    );
    final continueTopicValue = continueTopic;
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$totalConceptCount개 중 끝낸 개념',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            '$totalCompletedCount개',
            style: PassqlTypography.largeTitle.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          PassqlProgressBar(
            value: totalConceptCount == 0
                ? 0
                : totalCompletedCount / totalConceptCount,
            semanticValue: '개념 $totalConceptCount개 중 $totalCompletedCount개 끝냄',
          ),
          if (continueTopicValue != null) ...[
            const SizedBox(height: PassqlSpacing.md),
            _ContinueStudyBand(topic: continueTopicValue),
          ],
        ],
      ),
    );
  }
}

/// 이어서 학습 띠: 띠 전체가 버튼 (따로 있던 "이어서 공부하기" 버튼 대신)
class _ContinueStudyBand extends StatelessWidget {
  const _ContinueStudyBand({required this.topic});

  final ConceptTopicSummary topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final topicLabel = '${topic.orderIndex + 1}. ${topic.displayName}';
    final countLabel = '${topic.completedCount}/${topic.conceptCount}';
    return PassqlPressable(
      semanticLabel:
          '이어서 학습, $topicLabel, ${topic.conceptCount}개 중 ${topic.completedCount}개 끝냄',
      onTap: () => context.push(AppRoutes.conceptTopic(topic.topicUuid)),
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '이어서 학습',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accentText,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.hairlineGap),
                  Text(
                    '$topicLabel · $countLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.headline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.md,
              color: colors.accentText,
            ),
          ],
        ),
      ),
    );
  }
}

/// 단원 구간: 열린 단원 줄 > 잠긴 단원(있을 때) 흐린 미리보기
class _TopicListSection extends StatelessWidget {
  const _TopicListSection({
    required this.openTopics,
    required this.hasLockedTopic,
  });

  final List<ConceptTopicSummary> openTopics;
  final bool hasLockedTopic;

  @override
  Widget build(BuildContext context) {
    return PassqlSection(
      title: '단원',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final topic in openTopics) _ConceptTopicRow(topic: topic),
          if (hasLockedTopic) ...[
            const SizedBox(height: PassqlSpacing.sm),
            const ProLockedSection(
              preview: ConceptTopicsLockedSample(),
              caption: LockedPreviewCaptions.conceptTopics,
            ),
          ],
        ],
      ),
    );
  }
}

/// 단원 한 줄: 번호 타일(다 끝냈으면 초록 체크) > 단원 이름 > 끝낸 수(다 끝냈으면 "완료")
class _ConceptTopicRow extends StatelessWidget {
  const _ConceptTopicRow({required this.topic});

  final ConceptTopicSummary topic;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isCompleted =
        topic.conceptCount > 0 && topic.completedCount >= topic.conceptCount;
    return PassqlListRow(
      hasHorizontalPadding: false,
      leading: ConceptStatusMark(
        shape: ConceptStatusMarkShape.tile,
        status: isCompleted
            ? ConceptStatusMarkKind.done
            : ConceptStatusMarkKind.active,
        order: topic.orderIndex + 1,
      ),
      title: topic.displayName,
      trailing: Text(
        isCompleted ? '완료' : '${topic.completedCount}/${topic.conceptCount}',
        style: PassqlTypography.subheadline.copyWith(
          color: isCompleted ? colors.correctText : colors.secondaryLabel,
          fontFeatures: PassqlTypography.tabular,
        ),
      ),
      hasChevron: true,
      onTap: () => context.push(AppRoutes.conceptTopic(topic.topicUuid)),
    );
  }
}
