import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ads/ad_placement.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/mock_exam_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/stats_providers.dart';
import '../../widgets/ads/ad_inline_card.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/profile/profile_pro_analysis_locked_section.dart';
import '../../widgets/profile/difficulty_accuracy_section.dart';
import '../../widgets/profile/profile_mock_exam_trend_section.dart';
import '../../widgets/profile/profile_plan_section.dart';
import '../../widgets/profile/profile_status_section.dart';
import '../../widgets/profile/study_record_section.dart';
import '../../widgets/profile/study_time_pattern_section.dart';
import '../../widgets/profile/topic_accuracy_section.dart';
import '../../widgets/profile/wrong_note_progress_section.dart';
import '../../widgets/stats/ai_analysis_card.dart';
import '../../widgets/stats/ai_analysis_card_skeleton.dart';

/// 내 프로필 탭 (#749, #909): 홈과 같은 구간 + 띠 구조.
/// 내 상태(이름 줄·정답률·탑승권) > AI 분석 > 영역별 정답률 > 최근 4주 학습 > 공부하는 시간
/// > 난이도별 정답률 > 오답 정리 > 모의고사 점수 추이 > 광고. 홈에 있는 준비도·히트맵·바로가기는 두지 않는다.
/// 로딩: 구간 모양 스켈레톤 / 에러: 재시도 / 성공: 구간 순차 등장, pull-to-refresh 지원.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
                message: PassqlLoadFailureCopy.messageOf('기록을'),
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
            // 화면에 보이는 데이터 전부 (진행·토픽·학습 패턴·정답률 상세, AI 코멘트, 등급, 시험 일정, 빈 상태 세트, 모의고사 추이)
            ref.invalidate(statsDataProvider);
            ref.invalidate(mockExamHistoryProvider);
            ref.invalidate(statsAiCommentProvider);
            ref.invalidate(examScheduleProvider);
            ref.invalidate(profileDailySetProvider);
            // 등급은 마지막 값을 둔 채 다시 받기 (무효화하면 로딩 동안 광고·PRO·잠금 UI 가 깜빡이고, 실패 시 잠금이 풀림)
            final planRefresh = ref.read(planProvider.notifier).refresh();
            try {
              await planRefresh;
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

/// 구간 목록: 내 상태 > AI 분석 > 영역별 정답률 > 학습 기록 > 공부 시간 > 정답률 상세(프로) > 모의고사 > 광고, 하나씩 등장.
/// 구간 사이는 회색 띠. 푼 문제가 0개면 내 상태만 (볼 기록이 없음), 응답이 없는 구간은 자리째 뺌
class _StatsContent extends StatelessWidget {
  final StatsData data;
  final bool isAnalysisLocked;

  const _StatsContent({required this.data, required this.isAnalysisLocked});

  @override
  Widget build(BuildContext context) {
    final progress = data.progress;
    final hasRecords = (progress?.solvedCount ?? 0) > 0;
    final studyPattern = data.studyPattern;
    final accuracyDetail = data.accuracyDetail;
    final hasDifficultyStats =
        accuracyDetail?.difficultyStats.isNotEmpty ?? false;
    final sections = <Widget>[
      ProfileStatusSection(progress: progress),
      // 크레딧·이용권 구간 (스스로 앞 띠, 결제 꺼짐이면 없음)
      const ProfilePlanSection(),
      // 광고 1칸: 이용권 구간 바로 아래 (뜬 때만 앞 띠 + 구간, 맨 아래에 두면 거의 안 보임, #971)
      const AdInlineCard(placement: AdPlacement.bannerStats, isSection: true),
      // 무료(결제 켜짐): 볼 수 있는 구간 먼저, 프로 분석은 맨 아래 한 칸으로 모음 (#971)
      if (hasRecords && isAnalysisLocked) ...[
        if (studyPattern != null) ...[
          const PassqlSectionGap(),
          StudyRecordSection(studyPattern: studyPattern),
          const PassqlSectionGap(),
          StudyTimePatternSection(studyPattern: studyPattern),
        ],
        const PassqlSectionGap(),
        const ProfileProAnalysisLockedSection(),
      ],
      // 프로·결제 꺼짐: AI 분석은 스스로 앞 띠를 두고, 없으면 띠째 접힌다
      if (hasRecords && !isAnalysisLocked) ...[
        const _StatsAiCommentSection(),
        const PassqlSectionGap(),
        TopicAccuracySection(topicStats: data.topicAnalysis?.topicStats),
        if (studyPattern != null) ...[
          const PassqlSectionGap(),
          StudyRecordSection(studyPattern: studyPattern),
          const PassqlSectionGap(),
          StudyTimePatternSection(studyPattern: studyPattern),
        ],
        // 응답 있을 때만 두 구간
        if (accuracyDetail != null) ...[
          if (hasDifficultyStats) ...[
            const PassqlSectionGap(),
            DifficultyAccuracySection(
              difficultyStats: accuracyDetail.difficultyStats,
            ),
          ],
          const PassqlSectionGap(),
          WrongNoteProgressSection(accuracyDetail: accuracyDetail),
        ],
        // 모의고사 추이는 스스로 앞 띠를 두고, 기록이 없으면 띠째 없음
        const ProfileMockExamTrendSection(),
      ],
    ];

    return SliverList.list(
      children: [
        // 제목과 첫 구간 사이 회색 여백 (문제·토론 탭처럼 제목 아래에 숨 쉴 자리)
        const PassqlSectionGap(),
        for (var index = 0; index < sections.length; index++)
          PassqlReveal(index: index, child: sections[index]),
      ],
    );
  }
}

/// AI 코멘트 자리 (프로·결제 꺼짐만, 무료 잠금은 맨 아래 프로 분석 한 칸): 기다리는 동안 스켈레톤, 오면 구간으로 교체, 실패하면 다시 시도 자리, 없으면 앞 띠와 함께 접힘
class _StatsAiCommentSection extends ConsumerWidget {
  const _StatsAiCommentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiCommentAsync = ref.watch(statsAiCommentProvider);
    final aiComment = aiCommentAsync.value;
    final Widget content;
    if (aiCommentAsync.isLoading && aiComment == null) {
      content = const AiAnalysisCardSkeleton(key: ValueKey('loading'));
    } else if (aiCommentAsync.hasError && aiComment == null) {
      content = AiAnalysisErrorSection(
        key: const ValueKey('error'),
        onRetry: () => ref.invalidate(statsAiCommentProvider),
      );
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
const double _aiSkeletonHeight = 260;
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
