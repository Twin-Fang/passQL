import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/home_next_step.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../practice/open_random_practice.dart';

/// 홈 「다음에 할 일」 카드 (#975): 지금 할 한 가지를 제목·한 줄·버튼으로 (홈의 유일한 채운 버튼)
/// 판정은 decideHomeNextStep, 이 위젯은 문구와 이동만. 크레딧을 다 쓴 날은 모의고사 무료 1회 안내, 그것도 없으면 숨김
class HomeNextStepCard extends ConsumerWidget {
  const HomeNextStepCard({
    super.key,
    required this.dailySetQuestionCount,
    required this.canSolveDailySet,
    required this.onStartDailySet,
    this.hasTopGap = false,
  });

  /// 오늘의 세트 문제 수 (제목에 표시)
  final int dailySetQuestionCount;

  /// 오늘의 세트를 지금 풀 수 있는가 (문제가 있고 아직 안 끝냄)
  final bool canSolveDailySet;
  final VoidCallback onStartDailySet;

  /// 위 요소(인사말)와 띄울지
  final bool hasTopGap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final remainingCredits = ref.watch(freeRemainingSolvesProvider);
    final nextStep = decideHomeNextStep(
      canSolveDailySet: canSolveDailySet,
      isRandomPracticeVisible: ref.watch(isRandomPracticeVisibleProvider),
      remainingCredits: remainingCredits,
      hasMockExamTrial:
          ref
              .watch(mockExamRoundsProvider)
              .valueOrNull
              ?.rounds
              .any((round) => round.isFreeTrialRound && round.canStart) ??
          false,
    );
    // 크레딧을 다 쓴 날은 카드를 숨김 (홈 첫 화면에서 광고·결제를 앞세우지 않음, 상단 크레딧 알약이 안내)
    if (nextStep == HomeNextStep.earnCredits) return const SizedBox.shrink();
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
        // 남은 크레딧 수는 상단 바 알약이 보여 줌 (한 화면 한 번)
        '안 푼 문제부터 골라 드려요',
        '이어서 풀기',
        () => openRandomPractice(context, ref),
      ),
      // 위에서 숨김 (switch 완결용)
      HomeNextStep.earnCredits => ('', '', '', () {}),
      HomeNextStep.mockExamTrial => (
        'SQLD 모의고사 1회 무료',
        '실제 시험처럼 풀고 합격 판정을 받아 봐요',
        '모의고사 풀기',
        () => context.push(AppRoutes.mockExams),
      ),
      HomeNextStep.browseQuestions => (
        '문제를 골라 풀어요',
        '토픽별로 풀 수 있어요',
        '문제 풀러 가기',
        () => context.go(AppRoutes.questions),
      ),
    };
    final card = Container(
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
    if (!hasTopGap) return card;
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.md),
      child: card,
    );
  }
}
