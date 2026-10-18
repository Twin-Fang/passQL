import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/ad_placement.dart';
import '../../design/design.dart';
import '../../providers/stats_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/stats/ai_analysis_card.dart';
import '../../widgets/stats/bar_chart_section.dart';
import '../../widgets/stats/radar_chart_section.dart';
import '../../widgets/stats/summary_stats_section.dart';

/// 통계 화면.
/// statsDataProvider(진행 현황 + 토픽 분석)로 화면을 그리고, AI 코멘트는 따로 받아 자리만 먼저 잡는다.
/// 로딩: 스켈레톤 / 에러: 재시도 버튼 / 성공: 섹션 순차 등장, pull-to-refresh 지원.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataProvider);

    return Scaffold(
      // 스크롤 틀은 그대로 두고 내용만 바꾼다(내용은 섹션별 순차 등장)
      // 새로고침 실패 시 이전 데이터 유지 (오류 화면은 첫 조회 실패에만)
      body: statsAsync.when(
        skipError: true,
        loading: () => const PassqlLargeTitleScrollView(
          title: '통계',
          slivers: [_StatsSkeleton()],
        ),
        error: (error, _) => PassqlLargeTitleScrollView(
          title: '통계',
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '통계를 불러오지 못했습니다',
                onRetry: () => ref.invalidate(statsDataProvider),
              ),
            ),
          ],
        ),
        data: (data) => PassqlLargeTitleScrollView(
          title: '통계',
          onRefresh: () async {
            ref.invalidate(statsDataProvider);
            ref.invalidate(statsAiCommentProvider);
            try {
              await ref.read(statsDataProvider.future);
            } catch (_) {
              if (context.mounted) showAppToast(context, '새로고침하지 못했어요');
            }
          },
          slivers: [_StatsContent(data: data)],
        ),
      ),
    );
  }
}

/// 통계 카드 목록: 요약 > AI 분석 > 레이더 > 막대 > 인라인 광고 순서로 하나씩 등장. 카드 사이 간격은 PassqlSpacing.md.
class _StatsContent extends StatelessWidget {
  final StatsData data;

  const _StatsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      // 요약 통계 3개 카드
      SummaryStatsSection(progress: data.progress),
      // AI 영역 분석 (웹과 같이 요약 바로 아래, 늦게 와도 나머지는 먼저 보인다)
      const _StatsAiCommentSection(),
      // 레이더 차트
      RadarChartSection(topicStats: data.topicAnalysis?.topicStats),
      // 카테고리별 가로 막대
      BarChartSection(topicStats: data.topicAnalysis?.topicStats),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      sliver: SliverList.list(
        children: [
          for (var index = 0; index < sections.length; index++)
            PassqlReveal(
              index: index,
              // AI 자리는 비면 간격까지 접히도록 스스로 간격을 둔다
              child: sections[index] is _StatsAiCommentSection
                  ? sections[index]
                  : Padding(
                      padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
                      child: sections[index],
                    ),
            ),
          // 콘텐츠 맨 아래 광고 1칸 (뜬 때만 아래 간격, 등장 연출은 슬롯 공통)
          const AdInlineCard(
            placement: AdPlacement.bannerStats,
            padding: EdgeInsets.only(bottom: PassqlSpacing.md),
          ),
        ],
      ),
    );
  }
}

/// AI 코멘트 자리: 기다리는 동안 스켈레톤, 오면 카드로 교체, 없거나 실패하면 접힘
class _StatsAiCommentSection extends ConsumerWidget {
  const _StatsAiCommentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiCommentAsync = ref.watch(statsAiCommentProvider);
    final aiComment = aiCommentAsync.value;
    final Widget content;
    if (aiCommentAsync.isLoading && aiComment == null) {
      content = const AiAnalysisCardSkeleton(key: ValueKey('loading'));
    } else if (aiComment?.comment == null) {
      content = const SizedBox.shrink(key: ValueKey('empty'));
    } else {
      content = AiAnalysisCard(
        key: const ValueKey('data'),
        aiComment: aiComment,
      );
    }
    final isEmpty = content is SizedBox;
    // 카드 아래 간격도 카드와 함께 접힌다
    return AnimatedSize(
      duration: PassqlMotion.standard,
      curve: PassqlMotion.curve,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: isEmpty ? 0 : PassqlSpacing.md),
        child: PassqlFadeSwitcher(child: content),
      ),
    );
  }
}

/// 로딩 스켈레톤. 실제 카드와 같은 높이로 자리를 잡는다.
// 스켈레톤 자리 높이: 실제 카드(요약 3칸·AI 분석, 차트 2개) 높이와 맞춤
const double _summaryCardHeight = 80;
const double _chartCardHeight = 280;

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SliverPadding(
      padding: EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              Expanded(
                child: PassqlSkeletonBox(
                  height: _summaryCardHeight,
                  radius: PassqlRadius.lg,
                ),
              ),
              SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: PassqlSkeletonBox(
                  height: _summaryCardHeight,
                  radius: PassqlRadius.lg,
                ),
              ),
              SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: PassqlSkeletonBox(
                  height: _summaryCardHeight,
                  radius: PassqlRadius.lg,
                ),
              ),
            ],
          ),
          SizedBox(height: PassqlSpacing.md),
          PassqlSkeletonBox(height: _chartCardHeight, radius: PassqlRadius.lg),
          SizedBox(height: PassqlSpacing.md),
          PassqlSkeletonBox(height: _chartCardHeight, radius: PassqlRadius.lg),
          SizedBox(height: PassqlSpacing.md),
          PassqlSkeletonBox(
            height: _summaryCardHeight,
            radius: PassqlRadius.lg,
          ),
        ]),
      ),
    );
  }
}
