import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/stats_providers.dart';
import '../../widgets/stats/ai_analysis_card.dart';
import '../../widgets/stats/bar_chart_section.dart';
import '../../widgets/stats/radar_chart_section.dart';
import '../../widgets/stats/summary_stats_section.dart';

/// 통계 화면.
/// statsDataProvider에서 progress + topicAnalysis + aiComment를 받아 렌더링.
/// 로딩: 스켈레톤 / 에러: 재시도 버튼 / 성공: pull-to-refresh 지원.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataProvider);

    return Scaffold(
      backgroundColor: context.passqlColors.background,
      body: statsAsync.when(
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
            await ref.read(statsDataProvider.future);
          },
          slivers: [_StatsContent(data: data)],
        ),
      ),
    );
  }
}

/// 통계 카드 목록. 카드 사이 간격은 PassqlSpacing.md.
class _StatsContent extends StatelessWidget {
  final StatsData data;

  const _StatsContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      // 요약 통계 3개 카드
      SummaryStatsSection(progress: data.progress),
      // 레이더 차트
      RadarChartSection(topicStats: data.topicAnalysis?.topicStats),
      // 카테고리별 가로 막대
      BarChartSection(topicStats: data.topicAnalysis?.topicStats),
      // AI 영역 분석 카드 (/progress/ai-comment 응답, 없으면 숨김)
      if (data.aiComment?.comment != null)
        AiAnalysisCard(aiComment: data.aiComment),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      sliver: SliverList.separated(
        itemCount: children.length,
        itemBuilder: (_, i) => children[i],
        separatorBuilder: (_, _) => const SizedBox(height: PassqlSpacing.md),
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
