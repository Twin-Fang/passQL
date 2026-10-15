import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../widgets/home/daily_set_card.dart';
import '../../widgets/home/exam_schedule_card.dart';
import '../../widgets/home/fallback_stats_section.dart';
import '../../widgets/home/greeting_section.dart';
import '../../widgets/home/heatmap_widget.dart';
import '../../widgets/home/readiness_card.dart';
import '../../widgets/home/recommendations_section.dart';

/// 홈 화면.
/// homeDataProvider에서 6개 API 병렬 결과를 받아 렌더링.
/// 로딩 중: 스켈레톤 / 에러: 재시도 버튼 / 성공: pull-to-refresh.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: context.passqlColors.background,
      body: homeAsync.when(
        loading: () => const _HomeShell(slivers: [_HomeSkeleton()]),
        error: (error, _) => _HomeShell(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '데이터를 불러오지 못했어요.',
                onRetry: () => ref.invalidate(homeDataProvider),
              ),
            ),
          ],
        ),
        data: (data) => _HomeShell(
          // 인사 문구를 large title 로 올린다. 없으면 '홈'.
          largeTitle: data.greeting == null
              ? null
              : _GreetingTitle(GreetingSection.resolveMessage(data.greeting!)),
          onRefresh: () async {
            ref.invalidate(homeDataProvider);
            await ref.read(homeDataProvider.future);
          },
          slivers: [_HomeContent(data: data)],
        ),
      ),
    );
  }
}

/// large title 바 + 좌우 inset 을 공통으로 쓰는 틀.
class _HomeShell extends StatelessWidget {
  final Widget? largeTitle;
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;

  const _HomeShell({this.largeTitle, this.onRefresh, required this.slivers});

  @override
  Widget build(BuildContext context) {
    return PassqlLargeTitleScrollView(
      title: '홈',
      largeTitle: largeTitle,
      onRefresh: onRefresh,
      slivers: slivers,
    );
  }
}

/// 인사 문구 large title. 길면 한 줄로 줄여 바 높이를 지킨다.
class _GreetingTitle extends StatelessWidget {
  final String text;

  const _GreetingTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: PassqlTypography.largeTitle.copyWith(color: context.passqlColors.label),
    );
  }
}

/// 홈 카드 목록. 카드 사이 간격은 PassqlSpacing.md.
class _HomeContent extends StatelessWidget {
  final HomeData data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      // 인사 둘째 줄 본문 + 시험 상황 배지 (있을 때만)
      if (data.greeting != null && GreetingSection.hasContent(data.greeting!))
        GreetingSection(greeting: data.greeting!),

      // 2열 카드: 오늘의 세트 + 시험 일정 (높이를 맞춘다)
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DailySetCard(
                dailySet: data.dailySet,
                onStart: () => context.push(AppRoutes.dailySet),
                onViewResult: () => context.push(AppRoutes.dailySetResult),
                onBrowse: () => context.go(AppRoutes.questions),
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(child: ExamScheduleCard(schedule: data.examSchedule)),
          ],
        ),
      ),

      // 합격 준비도 카드 (readiness 있을 때)
      if (data.progress?.readiness != null)
        ReadinessCard(readiness: data.progress!.readiness!),

      // readiness 없을 때 Fallback 통계 카드
      if (data.progress != null && data.progress!.readiness == null)
        FallbackStatsSection(
          solvedCount: data.progress!.solvedCount,
          correctRate: data.progress!.correctRate,
        ),

      HeatmapWidget(
        heatmap: data.heatmap,
        streakDays: data.progress?.streakDays ?? 0,
      ),

      if (data.recommendations != null &&
          data.recommendations!.questions.isNotEmpty)
        RecommendationsSection(
          questions: data.recommendations!.questions,
          onQuestionTap: (uuid) => context.push('/questions/$uuid'),
        ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(PassqlSpacing.md, PassqlSpacing.md, PassqlSpacing.md, 0),
      sliver: SliverList.separated(
        itemCount: children.length,
        itemBuilder: (_, i) => children[i],
        separatorBuilder: (_, _) => const SizedBox(height: PassqlSpacing.md),
      ),
    );
  }
}

/// 로딩 중 스켈레톤. 실제 카드와 같은 높이로 자리를 잡는다.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SliverPadding(
      padding: EdgeInsets.fromLTRB(PassqlSpacing.md, PassqlSpacing.md, PassqlSpacing.md, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
          Row(
            children: [
              Expanded(child: PassqlSkeletonBox(height: 140, radius: PassqlRadius.lg)),
              SizedBox(width: PassqlSpacing.sm),
              Expanded(child: PassqlSkeletonBox(height: 140, radius: PassqlRadius.lg)),
            ],
          ),
          SizedBox(height: PassqlSpacing.md),
          PassqlSkeletonBox(height: 180, radius: PassqlRadius.lg),
          SizedBox(height: PassqlSpacing.md),
          PassqlSkeletonBox(height: 160, radius: PassqlRadius.lg),
        ]),
      ),
    );
  }
}
