import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/stats_providers.dart';
import '../../providers/wrong_questions_provider.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';
import '../../widgets/settings/profile_section.dart';
import '../../widgets/home/heatmap_widget.dart';
import '../../widgets/home/readiness_card.dart';
import '../../widgets/stats/ai_analysis_card.dart';
import '../../widgets/stats/bar_chart_section.dart';
import '../../widgets/stats/radar_chart_section.dart';
import '../../widgets/stats/stats_empty_state_card.dart';
import '../../widgets/stats/stats_shortcut_section.dart';
import '../../widgets/stats/summary_stats_section.dart';

/// 기록 화면(구 통계).
/// statsDataProvider(진행 현황 + 토픽 분석)로 화면을 그리고, AI 코멘트는 따로 받아 자리만 먼저 잡는다.
/// 히트맵·오늘의 세트는 홈과 같은 homeLearningStatusProvider 를 재사용 (새 API 없음)
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
          title: '내 프로필',
          trailing: _ProfileTabTrailing(),
          isTrailingIconButton: true,
          slivers: [_ProfileSliver(), _StatsSkeleton()],
        ),
        error: (error, _) => PassqlLargeTitleScrollView(
          title: '내 프로필',
          trailing: const _ProfileTabTrailing(),
          isTrailingIconButton: true,
          slivers: [
            const _ProfileSliver(),
            SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '기록을 불러오지 못했어요',
                onRetry: () => ref.invalidate(statsDataProvider),
              ),
            ),
          ],
        ),
        data: (data) => PassqlLargeTitleScrollView(
          title: '내 프로필',
          trailing: const _ProfileTabTrailing(),
          isTrailingIconButton: true,
          onRefresh: () async {
            // 화면에 보이는 데이터 전부 (진행·토픽, AI 코멘트, 히트맵·세트, 오답 개수)
            ref.invalidate(statsDataProvider);
            ref.invalidate(statsAiCommentProvider);
            ref.invalidate(homeLearningStatusProvider);
            ref.invalidate(wrongQuestionTotalCountProvider);
            try {
              await Future.wait([
                ref.read(statsDataProvider.future),
                ref.read(homeLearningStatusProvider.future),
              ]);
            } catch (_) {
              if (context.mounted) showAppToast(context, '새로고침하지 못했어요');
            }
          },
          slivers: [
            const _ProfileSliver(),
            _StatsContent(
              data: data,
              isAnalysisLocked: ref.watch(shouldShowProUiProvider),
            ),
          ],
        ),
      ),
    );
  }
}

/// 기록 카드 목록: 요약 > 합격 준비도 > 학습 현황 > AI 분석 > 레이더 > 막대 > 바로가기 > 인라인 광고 순서로 하나씩 등장.
/// 푼 문제가 0개면 요약·차트 대신 빈 상태 카드 1개 (광고는 그대로 맨 아래). 카드 사이 간격은 PassqlSpacing.md.
/// [isAnalysisLocked] (무료, 결제 켜짐): 레이더·막대 자리에 묶음 블러. AI 분석은 무료도 하루 1회 표시 (#699)
class _StatsContent extends ConsumerWidget {
  final StatsData data;
  final bool isAnalysisLocked;

  const _StatsContent({required this.data, required this.isAnalysisLocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = data.progress;
    final isEmpty = (progress?.solvedCount ?? 0) == 0;
    final sections = <Widget>[
      if (isEmpty)
        _withGap(const _StatsEmptyStateSection())
      else ...[
        // 요약 통계 3개 카드
        _withGap(SummaryStatsSection(progress: progress)),
        // 합격 준비도 (없으면 숨김)
        if (progress?.readiness != null)
          _withGap(ReadinessCard(readiness: progress!.readiness!)),
        // 학습 현황 히트맵 (스스로 간격을 둔다)
        _StatsHeatmapSection(streakDays: progress?.streakDays ?? 0),
        // AI 영역 분석 (웹과 같이 요약 바로 아래, 늦게 와도 나머지는 먼저 보인다, 무료·프로 공통)
        const _StatsAiCommentSection(),
        if (isAnalysisLocked)
          _withGap(
            const ProLockedSection(
              preview: StatsLockedSample(),
              caption: LockedPreviewCaptions.stats,
            ),
          )
        else ...[
          // 레이더 차트
          _withGap(
            RadarChartSection(topicStats: data.topicAnalysis?.topicStats),
          ),
          // 카테고리별 가로 막대
          _withGap(BarChartSection(topicStats: data.topicAnalysis?.topicStats)),
        ],
        // 바로가기 (오답 노트, 오늘의 세트 순위)
        _withGap(const StatsShortcutSection()),
      ],
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
            PassqlReveal(index: index, child: sections[index]),
          // 콘텐츠 맨 아래 광고 1칸 (뜬 때만 아래 간격, 등장 연출은 슬롯 공통)
          const AdInlineCard(
            placement: AdPlacement.bannerStats,
            padding: EdgeInsets.only(bottom: PassqlSpacing.md),
          ),
        ],
      ),
    );
  }

  /// 카드 아래 간격 (스스로 간격을 두는 섹션은 감싸지 않는다)
  Widget _withGap(Widget section) => Padding(
    padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
    child: section,
  );
}

/// 빈 상태 카드 자리: 오늘의 세트를 풀 수 있으면 세트 풀기, 아니면 문제 탭 안내
class _StatsEmptyStateSection extends ConsumerWidget {
  const _StatsEmptyStateSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 세트 상태는 늦게 와도 카드를 막지 않음 (오기 전엔 문제 탭 안내)
    final dailySet = ref
        .watch(homeLearningStatusProvider)
        .valueOrNull
        ?.dailySet;
    final hasDailySet =
        dailySet != null &&
        dailySet.questions.isNotEmpty &&
        !dailySet.alreadyCompleted;
    return StatsEmptyStateCard(
      hasDailySet: hasDailySet,
      onSolveDailySet: () => context.push(AppRoutes.dailySet),
      onBrowseQuestions: () => context.go(AppRoutes.questions),
    );
  }
}

/// 학습 현황(히트맵) 자리: 오는 동안 스켈레톤, 못 받았으면 접힘 (간격 포함)
class _StatsHeatmapSection extends ConsumerWidget {
  final int streakDays;

  const _StatsHeatmapSection({required this.streakDays});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningStatusAsync = ref.watch(homeLearningStatusProvider);
    final learningStatus = learningStatusAsync.valueOrNull;
    final Widget content;
    if (learningStatus == null && learningStatusAsync.isLoading) {
      content = const PassqlLoadingSemantics(
        child: PassqlSkeletonBox(
          height: _heatmapCardHeight,
          radius: PassqlRadius.lg,
        ),
      );
    } else if (learningStatus?.heatmap == null) {
      return const SizedBox.shrink();
    } else {
      content = HeatmapWidget(
        heatmap: learningStatus!.heatmap,
        streakDays: streakDays,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
      child: content,
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
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
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
const double _heatmapCardHeight = 160;

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
      // 스켈레톤 조각 대신 '불러오는 중' 한 번
      sliver: SliverToBoxAdapter(
        child: PassqlLoadingSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              PassqlSkeletonBox(
                height: _chartCardHeight,
                radius: PassqlRadius.lg,
              ),
              SizedBox(height: PassqlSpacing.md),
              PassqlSkeletonBox(
                height: _chartCardHeight,
                radius: PassqlRadius.lg,
              ),
              SizedBox(height: PassqlSpacing.md),
              PassqlSkeletonBox(
                height: _summaryCardHeight,
                radius: PassqlRadius.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 내 프로필 탭 맨 위 구역 (이용권 카드 + 프로필)
class _ProfileSliver extends StatelessWidget {
  const _ProfileSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverPadding(
      padding: EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.md,
        PassqlSpacing.md,
        0,
      ),
      sliver: SliverToBoxAdapter(child: ProfileSection()),
    );
  }
}

/// 제목줄 오른쪽: 설정 톱니바퀴 (이용권 표시는 맨 위 이용권 카드가 맡음)
class _ProfileTabTrailing extends StatelessWidget {
  const _ProfileTabTrailing();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PassqlSemanticButton(
          label: '설정',
          onTap: () => context.push(AppRoutes.settings),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size.square(PassqlSize.minTouchTarget),
            onPressed: () => context.push(AppRoutes.settings),
            // 홈 알림 종과 같은 크기·색 (탭 상단 아이콘 통일, #701)
            child: Icon(
              CupertinoIcons.gear,
              size: PassqlIconSize.xl,
              color: colors.label,
            ),
          ),
        ),
      ],
    );
  }
}
