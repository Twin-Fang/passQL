import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/stats_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/profile/profile_status_section.dart';
import '../../widgets/profile/topic_accuracy_section.dart';
import '../../widgets/stats/ai_analysis_card.dart';

/// 내 프로필 탭 (#749): 홈과 같은 구간 + 띠 구조.
/// 내 상태(이름 줄·정답률·탑승권) > AI 분석 > 영역별 정답률 > 광고. 홈에 있는 준비도·히트맵·바로가기는 두지 않는다.
/// 로딩: 구간 모양 스켈레톤 / 에러: 재시도 / 성공: 구간 순차 등장, pull-to-refresh 지원.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsDataProvider);

    return Scaffold(
      // 새로고침 실패 시 이전 데이터 유지 (오류 화면은 첫 조회 실패에만)
      body: statsAsync.when(
        skipError: true,
        loading: () => const PassqlLargeTitleScrollView(
          title: '프로필',
          trailing: _ProfileTabTrailing(),
          isTrailingIconButton: true,
          slivers: [_StatsSkeleton()],
        ),
        error: (error, _) => PassqlLargeTitleScrollView(
          title: '프로필',
          trailing: const _ProfileTabTrailing(),
          isTrailingIconButton: true,
          slivers: [
            PassqlSliverFillStatus(
              child: PassqlStatusView.error(
                message: '기록을 불러오지 못했어요',
                onRetry: () => ref.invalidate(statsDataProvider),
              ),
            ),
          ],
        ),
        data: (data) => PassqlLargeTitleScrollView(
          title: '프로필',
          trailing: const _ProfileTabTrailing(),
          isTrailingIconButton: true,
          onRefresh: () async {
            // 화면에 보이는 데이터 전부 (진행·토픽, AI 코멘트, 등급, 시험 일정, 빈 상태 세트)
            ref.invalidate(statsDataProvider);
            ref.invalidate(statsAiCommentProvider);
            ref.invalidate(planProvider);
            ref.invalidate(examScheduleProvider);
            ref.invalidate(profileDailySetProvider);
            try {
              await ref.read(statsDataProvider.future);
            } catch (_) {
              if (context.mounted) showAppToast(context, '새로고침하지 못했어요');
            }
          },
          slivers: [
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

/// 구간 목록: 내 상태 > AI 분석 > 영역별 정답률 > 광고, 하나씩 등장. 구간 사이는 회색 띠.
/// 푼 문제가 0개면 영역 목록은 두지 않는다 (볼 기록이 없음)
class _StatsContent extends StatelessWidget {
  final StatsData data;
  final bool isAnalysisLocked;

  const _StatsContent({required this.data, required this.isAnalysisLocked});

  @override
  Widget build(BuildContext context) {
    final progress = data.progress;
    final hasRecords = (progress?.solvedCount ?? 0) > 0;
    final sections = <Widget>[
      ProfileStatusSection(progress: progress),
      // AI 분석은 스스로 앞 띠를 두고, 없으면 띠째 접힌다
      if (hasRecords) const _StatsAiCommentSection(),
      if (hasRecords) ...[
        const PassqlSectionGap(),
        TopicAccuracySection(
          topicStats: data.topicAnalysis?.topicStats,
          isLocked: isAnalysisLocked,
        ),
      ],
    ];

    return SliverList.list(
      children: [
        // 제목과 첫 구간 사이 회색 여백 (문제·토론 탭처럼 제목 아래에 숨 쉴 자리)
        const PassqlSectionGap(),
        for (var index = 0; index < sections.length; index++)
          PassqlReveal(index: index, child: sections[index]),
        // 콘텐츠 맨 아래 광고 1칸 (뜬 때만 앞 띠 + 구간, 홈과 같은 방식)
        const AdInlineCard(placement: AdPlacement.bannerStats, isSection: true),
      ],
    );
  }
}

/// AI 코멘트 자리: 기다리는 동안 스켈레톤, 오면 구간으로 교체, 없거나 실패하면 앞 띠와 함께 접힘
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
    return AnimatedSize(
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
      curve: PassqlMotion.curve,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isEmpty) const PassqlSectionGap(),
          PassqlFadeSwitcher(child: content),
        ],
      ),
    );
  }
}

/// 로딩 스켈레톤: 실제 구간 3개와 비슷한 높이로 자리를 잡는다
// 스켈레톤 구간 높이 (어림값: 내 상태·AI 분석·영역 목록)
const double _statusSkeletonHeight = 260;
const double _aiSkeletonHeight = 120;
const double _topicSkeletonHeight = 280;

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      // 스켈레톤 조각 대신 '불러오는 중' 한 번
      child: PassqlLoadingSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PassqlSection(
              child: PassqlSkeletonBox(
                height: _statusSkeletonHeight,
                radius: PassqlRadius.lg,
              ),
            ),
            PassqlSectionGap(),
            PassqlSection(
              child: PassqlSkeletonBox(
                height: _aiSkeletonHeight,
                radius: PassqlRadius.lg,
              ),
            ),
            PassqlSectionGap(),
            PassqlSection(
              child: PassqlSkeletonBox(
                height: _topicSkeletonHeight,
                radius: PassqlRadius.lg,
              ),
            ),
          ],
        ),
      ),
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
