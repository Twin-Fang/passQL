import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../data/models/notification/notification_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/notification_inbox_providers.dart';
import '../../providers/unread_notification_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/home/app_notice_banner.dart';
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
          // 인사 문구가 한 줄에 들어가면 large title 로 올린다. 없거나 길면 '홈' (긴 인사는 본문 첫 줄)
          largeTitle: _isGreetingInLargeTitle(context, data)
              ? _GreetingTitle(GreetingSection.resolveMessage(data.greeting!))
              : null,
          onRefresh: () async {
            // 공지 배너(안 읽은 중요 공지)도 함께 갱신
            ref.invalidate(
              notificationInboxProvider(NotificationCategory.notice),
            );
            invalidateHomeData(ref.invalidate);
            try {
              await ref.read(homeDataProvider.future);
            } catch (_) {
              if (context.mounted) showAppToast(context, '새로고침하지 못했어요');
            }
          },
          slivers: [
            _HomeContent(
              data: data,
              isGreetingHeadlineInBody:
                  data.greeting != null &&
                  !_isGreetingInLargeTitle(context, data),
            ),
          ],
        ),
      ),
    );
  }

  /// 인사 첫 줄이 large title 한 줄에 들어가는지 (폭 = 화면 - 좌우 여백, 시스템 글자 배율 반영)
  static bool _isGreetingInLargeTitle(BuildContext context, HomeData data) {
    final greeting = data.greeting;
    if (greeting == null) return false;
    return GreetingSection.fitsInLargeTitle(
      GreetingSection.resolveMessage(greeting),
      maxWidth: MediaQuery.sizeOf(context).width - PassqlSpacing.md * 2,
      textScaler: MediaQuery.textScalerOf(context),
    );
  }
}

/// large title 바 + 좌우 inset 을 공통으로 쓰는 틀 (오른쪽 위 종 아이콘 포함).
class _HomeShell extends ConsumerWidget {
  final Widget? largeTitle;
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;

  const _HomeShell({this.largeTitle, this.onRefresh, required this.slivers});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PassqlLargeTitleScrollView(
      title: '홈',
      largeTitle: largeTitle,
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
      style: PassqlTypography.largeTitle.copyWith(
        color: context.passqlColors.label,
      ),
    );
  }
}

/// 홈 카드 목록. 카드 사이 간격은 PassqlSpacing.md.
class _HomeContent extends ConsumerWidget {
  final HomeData data;

  /// true > large title 에 못 올라간 인사 첫 줄을 본문 맨 위에 그림
  final bool isGreetingHeadlineInBody;

  const _HomeContent({
    required this.data,
    required this.isGreetingHeadlineInBody,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(homeNoticeProvider);
    final children = <Widget>[
      // 관리자 공지 (안 읽은 중요 공지 첫 건, 닫기 = 서버 읽음)
      if (notice != null)
        AppNoticeBanner(
          notice: notice,
          onDismiss: () => dismissHomeNotice(ref, notice.noticeUuid),
        ),

      // 인사(긴 첫 줄이면 여기로) + 둘째 줄 본문 + 시험 상황 배지 (있을 때만)
      if (data.greeting != null &&
          GreetingSection.hasContent(
            data.greeting!,
            isHeadlineShown: isGreetingHeadlineInBody,
          ))
        GreetingSection(
          greeting: data.greeting!,
          isHeadlineShown: isGreetingHeadlineInBody,
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

      // 합격 준비도 카드 (readiness 있을 때)
      if (data.progress?.readiness != null)
        ReadinessCard(readiness: data.progress!.readiness!),

      // readiness 없을 때 Fallback 통계 카드
      if (data.progress != null && data.progress!.readiness == null)
        FallbackStatsSection(
          solvedCount: data.progress!.solvedCount,
          correctRate: data.progress!.correctRate,
        ),

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
      sliver: SliverList(
        delegate: SliverChildListDelegate.fixed([
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
        ]),
      ),
    );
  }
}
