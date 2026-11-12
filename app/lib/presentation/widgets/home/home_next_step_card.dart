import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/home_next_step.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../practice/daily_limit_reward_sheet.dart';
import '../practice/open_random_practice.dart';

/// 홈 「다음에 할 일」 카드 (#975): 지금 할 한 가지를 제목·한 줄·버튼으로 (홈의 유일한 채운 버튼)
/// 판정은 decideHomeNextStep, 이 위젯은 문구와 이동만
class HomeNextStepCard extends ConsumerWidget {
  const HomeNextStepCard({
    super.key,
    required this.dailySetQuestionCount,
    required this.canSolveDailySet,
    required this.onStartDailySet,
  });

  /// 오늘의 세트 문제 수 (제목에 표시)
  final int dailySetQuestionCount;

  /// 오늘의 세트를 지금 풀 수 있는가 (문제가 있고 아직 안 끝냄)
  final bool canSolveDailySet;
  final VoidCallback onStartDailySet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final remainingCredits = ref.watch(freeRemainingSolvesProvider);
    final nextStep = decideHomeNextStep(
      canSolveDailySet: canSolveDailySet,
      isRandomPracticeVisible: ref.watch(isRandomPracticeVisibleProvider),
      remainingCredits: remainingCredits,
    );
    final (
      String title,
      String subtitle,
      String buttonLabel,
      VoidCallback onPressed,
    ) = switch (nextStep) {
      HomeNextStep.dailySet => (
        '오늘의 세트 $dailySetQuestionCount문제',
        // 크레딧이 적용되는 회원에게만 크레딧 안내
        remainingCredits == null ? '오늘 문제로 실력을 확인해요' : '크레딧 없이 풀 수 있어요',
        '오늘의 세트 풀기',
        onStartDailySet,
      ),
      HomeNextStep.randomPractice => (
        '랜덤 풀기로 이어 가요',
        remainingCredits == null
            ? '안 푼 문제부터 골라 드려요'
            : '크레딧 $remainingCredits개 남았어요',
        '이어서 풀기',
        () => openRandomPractice(context, ref),
      ),
      HomeNextStep.earnCredits => (
        '오늘 크레딧을 다 썼어요',
        '광고를 보거나 PRO로 이어서 풀 수 있어요',
        '크레딧 받기',
        () => showDailyLimitRewardSheet(context),
      ),
      HomeNextStep.browseQuestions => (
        '문제를 골라 풀어요',
        '토픽별로 풀 수 있어요',
        '문제 풀러 가기',
        () => context.go(AppRoutes.questions),
      ),
    };
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.md),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '다음에 할 일',
            style: PassqlTypography.captionSemibold.copyWith(
              color: colors.accentText,
            ),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          Semantics(
            header: true,
            child: Text(
              title,
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            subtitle,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          PassqlButton(label: buttonLabel, onPressed: onPressed),
        ],
      ),
    );
  }
}
