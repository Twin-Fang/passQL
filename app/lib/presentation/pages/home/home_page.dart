import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../../providers/exam_trend_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/notification_inbox_providers.dart';
import '../../providers/unread_notification_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/community/community_daily_discussion_card.dart';
import '../../widgets/home/app_notice_banner.dart';
import '../../widgets/home/daily_set_card.dart';
import '../../widgets/home/daily_study_tip_card.dart';
import '../../widgets/home/exam_schedule_card.dart';
import '../../widgets/home/exam_trend_home_section.dart';
import '../../widgets/home/fallback_stats_section.dart';
import '../../widgets/home/greeting_section.dart';
import '../../widgets/home/heatmap_widget.dart';
import '../../widgets/home/readiness_card.dart';
import '../../widgets/home/recommendations_section.dart';
import '../../../router/questions_tab_view.dart';

/// 홈 화면.
/// homeDataProvider에서 6개 API 병렬 결과를 받아 렌더링.
/// 로딩 중: 스켈레톤 / 에러: 재시도 버튼 / 성공: pull-to-refresh.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      // 새로고침 실패 시 이전 데이터 유지 (오류 화면은 첫 조회 실패에만)
      body: homeAsync.when(
        skipError: true,
        loading: () => const _HomeShell(slivers: [_HomeSkeleton()]),
        error: (error, _) => _HomeShell(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: PassqlStatusView.error(
                message: '데이터를 불러오지 못했어요.',
                onRetry: () => invalidateHomeData(ref.invalidate),
              ),
            ),
          ],
        ),
        data: (data) => _HomeShell(
          onRefresh: () async {
            // 공지 배너(안 읽은 중요 공지)도 함께 갱신
            ref.invalidate(
              notificationInboxProvider(NotificationCategory.notice),
            );
            invalidateHomeData(ref.invalidate);
            // 출제 경향·공부 팁도 함께 갱신
            ref.invalidate(examTrendReportProvider);
            try {
              await ref.read(homeDataProvider.future);
            } catch (_) {
              if (context.mounted) showAppToast(context, '새로고침하지 못했어요');
            }
          },
          slivers: [_HomeContent(data: data)],
        ),
      ),
    );
  }
}

/// 로딩·오류·내용 공통 틀: 로고 상단 바 + 오른쪽 종 아이콘
class _HomeShell extends ConsumerWidget {
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;

  const _HomeShell({this.onRefresh, required this.slivers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PassqlBrandBarScrollView(
      onRefresh: onRefresh,
      trailing: PassqlNotificationBellButton(
        unreadCount: ref.watch(
          unreadNotificationCountProvider.select((count) => count.total),
        ),
        onPressed: () => context.push(AppRoutes.notificationInbox),
      ),
      slivers: slivers,
    );
  }
}

/// 홈 카드 목록. 카드 사이 간격은 PassqlSpacing.md.
class _HomeContent extends ConsumerWidget {
  final HomeData data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(homeNoticeProvider);
    final discussion = ref.watch(communityDailyDiscussionProvider).valueOrNull;
    final examTrendReportAsync = ref.watch(examTrendReportProvider);
    final examTrendReport = examTrendReportAsync.valueOrNull;
    final dailyStudyTip = examTrendReport == null
        ? null
        : selectDailyStudyTip(examTrendReport.studyTips, DateTime.now());
    final children = <Widget>[
      // 인사 + 본문 + 시험 상황 배지 (상단 바 아래 화면 제목 자리)
      if (data.greeting != null) GreetingSection(greeting: data.greeting!),

      // 관리자 공지 (안 읽은 중요 공지 첫 건, 닫기 = 서버 읽음)
      if (notice != null)
        AppNoticeBanner(
          notice: notice,
          onDismiss: () => dismissHomeNotice(ref, notice.noticeUuid),
        ),

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

      // 출제 경향 (로딩 = 자리 스켈레톤, 실패 = 항목 없음 > 간격도 없음)
      if (examTrendReport != null)
        ExamTrendHomeSection(
          report: examTrendReport,
          onSolveTopic: (topicCode, topicName) => context.push(
            AppRoutes.questionChapterOf(
              topicCode: topicCode,
              topicName: topicName,
              isLatestTrendOnly: true,
            ),
          ),
          onViewAll: () => context.go(QuestionsTabView.latestTrend.location),
        )
      else if (examTrendReportAsync.isLoading)
        const PassqlLoadingSemantics(
          child: PassqlSkeletonBox(
            height: _examTrendSectionHeight,
            radius: PassqlRadius.lg,
          ),
        ),

      // 오늘의 공부 팁 (팁 없으면 숨김)
      if (dailyStudyTip != null) DailyStudyTipCard(studyTip: dailyStudyTip),

      // 합격 준비도 카드 (readiness 있을 때)
      if (data.progress?.readiness != null)
        ReadinessCard(readiness: data.progress!.readiness!),

      // readiness 없을 때 Fallback 통계 카드
      if (data.progress != null && data.progress!.readiness == null)
        FallbackStatsSection(
          solvedCount: data.progress!.solvedCount,
          correctRate: data.progress!.correctRate,
        ),

      // 오늘의 토론 (뜨는 토론 1위, 없으면 숨김, #525)
      if (discussion != null) CommunityDailyDiscussionCard(card: discussion),

      // 학습 현황 + 인라인 광고 카드 (학습 현황 <-> 추천 문제 사이)
      // 한 항목으로 묶음 > 광고 없으면 카드 간격도 생기지 않음
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeatmapWidget(
            heatmap: data.heatmap,
            streakDays: data.progress?.streakDays ?? 0,
          ),
          const AdInlineCard(
            placement: AdPlacement.bannerHome,
            padding: EdgeInsets.only(top: PassqlSpacing.md),
          ),
        ],
      ),

      if (data.recommendations != null &&
          data.recommendations!.questions.isNotEmpty)
        RecommendationsSection(
          questions: data.recommendations!.questions,
          onQuestionTap: (uuid) => context.push(AppRoutes.questionDetail(uuid)),
        ),
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
        // 카드가 위에서부터 차례로 떠오른다
        itemBuilder: (_, i) => PassqlReveal(index: i, child: children[i]),
        separatorBuilder: (_, _) => const SizedBox(height: PassqlSpacing.md),
      ),
    );
  }
}

// 출제 경향 섹션 로딩 자리 높이: 머리 + 요약 + 캡션 + 유형 카드 가로 목록
const double _examTrendSectionHeight = 340;

/// 로딩 중 스켈레톤. 실제 카드와 같은 높이로 자리를 잡는다.
// 스켈레톤 자리 높이: 실제 카드(오늘의 세트·시험 일정 2열, 준비도, 히트맵) 높이와 맞춤
const double _dualCardHeight = 140;
const double _readinessCardHeight = 180;
const double _heatmapCardHeight = 160;

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

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
                      height: _dualCardHeight,
                      radius: PassqlRadius.lg,
                    ),
                  ),
                  SizedBox(width: PassqlSpacing.sm),
                  Expanded(
                    child: PassqlSkeletonBox(
                      height: _dualCardHeight,
                      radius: PassqlRadius.lg,
                    ),
                  ),
                ],
              ),
              SizedBox(height: PassqlSpacing.md),
              PassqlSkeletonBox(
                height: _readinessCardHeight,
                radius: PassqlRadius.lg,
              ),
              SizedBox(height: PassqlSpacing.md),
              PassqlSkeletonBox(
                height: _heatmapCardHeight,
                radius: PassqlRadius.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
