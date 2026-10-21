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
import '../../widgets/ads/ad_native_slot.dart';
import '../../widgets/exam_trend/concept_ranking_tab_view.dart';
import '../../widgets/exam_trend/latest_trend_tab_view.dart';
import '../../widgets/question/questions_tab_segmented_control.dart';
import '../../widgets/question/topic_card.dart';
import '../../widgets/question/wrong_notes_shortcut_row.dart';
import '../../../router/questions_tab_view.dart';

/// 네이티브 광고를 끼우는 위치: 토픽 5개 뒤 (그 뒤에 토픽이 하나라도 남을 때만)
const int _nativeAdAfterTopicCount = 5;

/// 토픽 목록 머리글 (스켈레톤과 같은 자리)
const _topicListHeader = '학습할 토픽을 선택하세요';

/// 문제 탭: 보기 3개 (주제별 | 최신 경향 | 개념 TOP 10)
/// 주제별 > 오답 노트 바로가기 + 토픽 선택 (토픽 행 탭 시 /questions/chapter?topic=CODE&topicName=NAME 이동)
/// 최신 경향·개념 TOP 10 > 출제 경향 응답 (행 탭 시 그 토픽의 최신 경향 문제 풀기)
class TopicListPage extends ConsumerWidget {
  const TopicListPage({super.key, this.view = QuestionsTabView.byTopic});

  /// 현재 보기 (라우트 쿼리 ?view= 에서 옴)
  final QuestionsTabView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: PassqlLargeTitleScrollView(
        title: '문제',
        // 토픽 추가·비활성화, 출제 경향 갱신을 앱 재시작 없이 반영
        onRefresh: () async {
          ref.invalidate(topicsProvider);
          ref.invalidate(latestTrendQuestionCountByTopicProvider);
          ref.invalidate(examTrendReportProvider);
          // 보기에 맞는 데이터만 기다림 (주제별 > 토픽, 최신 경향·개념 TOP 10 > 출제 경향)
          await switch (view) {
            QuestionsTabView.byTopic => ref.read(topicsProvider.future),
            QuestionsTabView.latestTrend || QuestionsTabView.conceptRanking =>
              ref.read(examTrendReportProvider.future),
          };
        },
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              PassqlSpacing.xs,
              PassqlSpacing.md,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: QuestionsTabSegmentedControl(
                selectedView: view,
                onSelected: (next) => context.go(next.location),
              ),
            ),
          ),
          ...switch (view) {
            QuestionsTabView.byTopic => _topicSlivers(context, ref),
            QuestionsTabView.latestTrend ||
            QuestionsTabView.conceptRanking => [_examTrendSliver(context, ref)],
          },
        ],
      ),
    );
  }

  // 주제별: 오류만 전체 자리, 로딩 > 목록은 같은 sliver 안에서 페이드 교체
  List<Widget> _topicSlivers(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(topicsProvider);
    if (topicsAsync.hasError && !topicsAsync.hasValue) {
      // 다시 시도할 방법이 없으면 탭을 오가야 해서 버튼을 둔다 (#375).
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: PassqlStatusView.error(
            message: '토픽을 불러올 수 없어요',
            onRetry: () => ref.invalidate(topicsProvider),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.md,
          PassqlSpacing.md,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const WrongNotesShortcutRow(),
              const SizedBox(height: PassqlSpacing.lg),
              PassqlFadeSwitcher(
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
            ],
          ),
        ),
      ),
    ];
  }

  // 최신 경향·개념 TOP 10: 같은 출제 경향 응답, 보기마다 다른 key 로 페이드 교체
  Widget _examTrendSliver(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(examTrendReportProvider);
    // 갱신 실패여도 이전 값이 있으면 그대로 보여 줌 (오류 화면은 값이 없을 때만)
    final report = reportAsync.valueOrNull;
    final isAdsEnabled = ref.watch(adsEnabledProvider);

    void onSolveTopic(String topicCode, String topicName) => context.push(
      AppRoutes.questionChapterOf(
        topicCode: topicCode,
        topicName: topicName,
        isLatestTrendOnly: true,
      ),
    );

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: PassqlFadeSwitcher(
          child: switch (reportAsync) {
            _ when report != null => switch (view) {
              QuestionsTabView.conceptRanking => ConceptRankingTabView(
                key: ValueKey('${view.queryValue}-data'),
                concepts: report.frequentConcepts,
                onSolveTopic: onSolveTopic,
                // 5위 <-> 6위 네이티브 1칸 (광고 위 간격은 광고 쪽, 광고 꺼짐 > 자리 없음)
                adSlot: isAdsEnabled
                    ? const AdNativeSlot(
                        placement: AdPlacement.nativeQuestions,
                        padding: EdgeInsets.only(top: PassqlSpacing.md),
                      )
                    : null,
              ),
              _ => LatestTrendTabView(
                key: ValueKey('${view.queryValue}-data'),
                report: report,
                onSolveTopic: onSolveTopic,
                // 늘어난 유형 <-> 공부 팁 네이티브 1칸
                adSlot: isAdsEnabled
                    ? const AdNativeSlot(
                        placement: AdPlacement.nativeQuestions,
                        padding: EdgeInsets.only(top: PassqlSpacing.md),
                      )
                    : null,
              ),
            },
            AsyncError() => KeyedSubtree(
              key: ValueKey('${view.queryValue}-error'),
              child: PassqlStatusView.error(
                message: '출제 경향을 불러올 수 없어요',
                onRetry: () => ref.invalidate(examTrendReportProvider),
              ),
            ),
            _ => PassqlListSkeleton(
              key: ValueKey('${view.queryValue}-loading'),
            ),
          },
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
