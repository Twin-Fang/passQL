import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../../router/app_routes.dart';
import '../../../router/questions_tab_view.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../../providers/exam_trend_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/notification_inbox_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../../providers/unread_notification_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/community/community_daily_discussion_card.dart';
import '../../widgets/home/app_notice_banner.dart';
import '../../widgets/home/daily_set_section.dart';
import '../../widgets/home/daily_study_tip_card.dart';
import '../../widgets/home/exam_dday_bar_title.dart';
import '../../widgets/home/exam_trend_home_section.dart';
import '../../widgets/home/fallback_stats_section.dart';
import '../../widgets/home/greeting_section.dart';
import '../../widgets/home/heatmap_widget.dart';
import '../../widgets/home/readiness_card.dart';
import '../../widgets/home/recommendations_section.dart';
import '../../widgets/pro/pro_plan_chip_slot.dart';

/// 홈 화면.
/// homeDataProvider에서 6개 API 병렬 결과를 받아 렌더링.
/// 로딩 중: 스켈레톤 / 에러: 재시도 버튼 / 성공: pull-to-refresh.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);

    return Scaffold(
      // 구간 면(card) 위에 상단 바가 놓이고, 구간 사이 띠만 화면 배경색 (#701)
      backgroundColor: context.passqlColors.card,
      // 새로고침 실패 시 이전 데이터 유지 (오류 화면은 첫 조회 실패에만)
      body: homeAsync.when(
        skipError: true,
        loading: () => const _HomeShell(slivers: [_HomeSkeleton()]),
        error: (error, _) => _HomeShell(
          slivers: [
            PassqlSliverFillStatus(
              child: PassqlStatusView.error(
                message: '데이터를 불러오지 못했어요.',
                onRetry: () => invalidateHomeData(ref.invalidate),
              ),
            ),
          ],
        ),
        data: (data) => _HomeShell(
          leading: ExamDdayBarTitle(schedule: data.examSchedule),
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

/// 로딩·오류·내용 공통 틀: 상단 바(왼쪽 로고 또는 시험 D-day) + 오른쪽 등급 칩·종 아이콘
class _HomeShell extends ConsumerWidget {
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;

  /// 내용 상태의 시험 D-day 제목 (로딩·오류는 null > 로고)
  final Widget? leading;

  const _HomeShell({this.onRefresh, required this.slivers, this.leading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PassqlBrandBarScrollView(
      onRefresh: onRefresh,
      leading: leading,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 결제 꺼짐·등급 모름이면 빈 자리 (종 아이콘만)
          const ProPlanChipSlot(),
          PassqlNotificationBellButton(
            unreadCount: ref.watch(
              unreadNotificationCountProvider.select((count) => count.total),
            ),
            onPressed: () => context.push(AppRoutes.notificationInbox),
          ),
        ],
      ),
      slivers: slivers,
    );
  }
}

/// 홈 구간 목록: 좌우 끝까지 닿는 구간 면 사이에 [PassqlSectionGap] 띠 (#701)
/// 숨은 구간은 목록에서 빠져 띠가 연달아 생기지 않는다
class _HomeContent extends ConsumerWidget {
  final HomeData data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(homeNoticeProvider);
    final discussion = ref.watch(communityDailyDiscussionProvider).valueOrNull;
    final recommendations = ref.watch(homeRecommendationsProvider).valueOrNull;
    final examTrendReportAsync = ref.watch(examTrendReportProvider);
    final examTrendReport = examTrendReportAsync.valueOrNull;
    final dailyStudyTip = examTrendReport == null
        ? null
        : selectDailyStudyTip(examTrendReport.studyTips, DateTime.now());
    final greeting = data.greeting;

    final readiness = data.progress?.readiness;
    final dailySet = data.dailySet;
    final hasDailySet =
        dailySet != null &&
        (dailySet.alreadyCompleted || dailySet.questions.isNotEmpty);
    final progress = data.progress;
    // 첫 구간 아래쪽: 준비도 링, 없으면 푼 문제·정답률 (면은 첫 구간이 감쌈)
    final Widget? status = readiness != null
        ? ReadinessCard(readiness: readiness, isSection: true)
        : progress != null
        ? FallbackStatsSection(
            solvedCount: progress.solvedCount,
            correctRate: progress.correctRate,
          )
        : null;

    // 위 구간들: 내 상태 > 오늘 할 일
    final sectionsTop = <Widget>[
      // 첫 구간: 인사·공지 > 합격 준비도 (위 여백은 상단 바가 가짐)
      // 상태를 먼저 보여 주고, 오늘의 세트 버튼은 다음 구간으로 내려 엄지가 닿는 자리에 둔다
      PassqlSection(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xs,
          PassqlSpacing.md,
          PassqlSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 인사 + 본문 + 시험 상황 배지 (상단 바 아래 화면 제목 자리)
            if (greeting != null) GreetingSection(greeting: greeting),
            // 관리자 공지 (안 읽은 중요 공지 첫 건, 닫기 = 서버 읽음)
            if (notice != null) ...[
              if (greeting != null) const SizedBox(height: PassqlSpacing.sm),
              AppNoticeBanner(
                notice: notice,
                onDismiss: () => dismissHomeNotice(ref, notice.noticeUuid),
              ),
            ],
            // 인사 덩어리와 준비도를 확실히 떼어 놓는다
            if (status != null) ...[
              if (greeting != null || notice != null)
                const SizedBox(height: PassqlSpacing.xxl),
              status,
            ],
          ],
        ),
      ),

      // 오늘의 세트: 다른 구간과 같은 제목 줄(순위 ›는 세트가 있을 때만) > 버튼 > 랜덤 풀기 행
      PassqlSection(
        title: '오늘의 세트',
        trailing: hasDailySet
            ? PassqlSectionLink(
                label: '순위',
                semanticLabel: '오늘의 순위 보기',
                onTap: () => context.push(AppRoutes.leaderboard),
              )
            : null,
        child: DailySetSection(
          dailySet: data.dailySet,
          isRandomPracticeVisible: ref.watch(isRandomPracticeVisibleProvider),
          onStart: () => context.push(AppRoutes.dailySet),
          onViewResult: () => context.push(AppRoutes.dailySetResult),
          onBrowse: () => context.go(AppRoutes.questions),
        ),
      ),
    ];

    // 출제 경향: 구간 면으로 감싸지 않고 회색 바탕 위에 강조색 카드를 바로 띄운다 (#701)
    // 오늘의 세트(풀기) 바로 다음에 '이 유형 풀기' 를 이어 둔다. 위아래 lg 바탕이 구간 사이 띠 역할을 대신함
    // (로딩 = 자리 스켈레톤, 실패·잠금·유형 없음 = 없음 > 그 자리는 보통 띠)
    final Widget? examTrendBand =
        examTrendReport != null && examTrendReport.risingPatterns.isNotEmpty
        ? _BackgroundBand(
            child: ExamTrendHomeSection(
              // 시작 카드는 날짜마다 다음 유형으로 (같은 날은 같은 카드)
              patterns: rotateToDailyStart(
                examTrendReport.risingPatterns,
                DateTime.now(),
              ),
              updatedDate: examTrendReport.updatedDate,
              onSolveTopic: (topicCode, topicName) => context.push(
                AppRoutes.questionChapterOf(
                  topicCode: topicCode,
                  topicName: topicName,
                  isLatestTrendOnly: true,
                ),
              ),
              onViewAll: () =>
                  context.go(QuestionsTabView.latestTrend.location),
            ),
          )
        : examTrendReportAsync.isLoading
        ? const _BackgroundBand(
            child: PassqlLoadingSemantics(
              child: PassqlSkeletonBox(
                height: _examTrendSectionHeight,
                radius: PassqlRadius.lg,
              ),
            ),
          )
        : null;

    final sectionsMiddle = <Widget>[
      // 추천 문제는 늦게 도착해도 나머지 홈을 붙잡지 않는다 (도착하면 제자리에 끼어듦, #676)
      if (recommendations != null && recommendations.questions.isNotEmpty)
        RecommendationsSection(
          questions: recommendations.questions,
          onQuestionTap: (uuid) => context.push(AppRoutes.questionDetail(uuid)),
          onViewMore: () => context.go(AppRoutes.questions),
        ),

      HeatmapWidget(
        heatmap: data.heatmap,
        streakDays: data.progress?.streakDays ?? 0,
        isSection: true,
      ),
    ];

    final sectionsAfterAd = <Widget>[
      // 오늘의 공부 팁 (팁 없으면 숨김)
      if (dailyStudyTip != null) DailyStudyTipCard(studyTip: dailyStudyTip),

      // 오늘의 토론 (뜨는 토론 1위, 없으면 숨김, #525)
      if (discussion != null) CommunityDailyDiscussionCard(card: discussion),
    ];

    final items = <Widget>[
      ..._withGaps(sectionsTop),
      // 출제 경향 바탕 띠가 있으면 그것이 구간 사이를 대신하고, 없으면 보통 띠
      examTrendBand ?? const PassqlSectionGap(),
      ..._withGaps(sectionsMiddle),
      // 학습 현황 아래 광고 구간: 광고가 뜬 뒤에만 자기 앞 띠와 면을 그림
      const AdInlineCard(placement: AdPlacement.bannerHome, isSection: true),
      ..._withGaps(sectionsAfterAd, hasLeadingGap: true),
    ];

    return SliverList.builder(
      itemCount: items.length,
      // 구간이 위에서부터 차례로 떠오른다
      itemBuilder: (_, i) => PassqlReveal(index: i, child: items[i]),
    );
  }

  /// 구간 사이마다 띠. [hasLeadingGap] 이면 첫 구간 앞에도 (앞 목록과 이어질 때)
  static List<Widget> _withGaps(
    List<Widget> sections, {
    bool hasLeadingGap = false,
  }) => [
    for (var i = 0; i < sections.length; i++) ...[
      if (i > 0 || hasLeadingGap) const PassqlSectionGap(),
      sections[i],
    ],
  ];
}

// 출제 경향 섹션 로딩 자리 높이: 머리 + 넘김 카드 + 페이지 점
const double _examTrendSectionHeight = 290;

/// 로딩 중 스켈레톤: 실제 구간과 같은 자리(구간 면 + 띠)를 잡는다.
// 스켈레톤 자리 높이: 실제 구간(오늘의 세트, 준비도, 학습 현황) 내용 높이와 맞춤
const double _dailySetSectionHeight = 180;
const double _readinessSectionHeight = 180;
const double _heatmapSectionHeight = 200;

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

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
                height: _dailySetSectionHeight,
                radius: PassqlRadius.lg,
              ),
            ),
            PassqlSectionGap(),
            PassqlSection(
              child: PassqlSkeletonBox(
                height: _readinessSectionHeight,
                radius: PassqlRadius.lg,
              ),
            ),
            PassqlSectionGap(),
            PassqlSection(
              child: PassqlSkeletonBox(
                height: _heatmapSectionHeight,
                radius: PassqlRadius.lg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 구간 면 없이 화면 배경색 위에 놓는 띠 (홈 출제 경향): 좌우 md, 위아래 lg
class _BackgroundBand extends StatelessWidget {
  const _BackgroundBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.passqlColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.lg,
        ),
        child: child,
      ),
    );
  }
}
