import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../../providers/plan_providers.dart';

/// 모의고사 바로가기 행 (홈 구간·문제 탭 공용): 풀이 중이면 이어 풀기 안내, 아니면 형식 한 줄
/// 등급 판정은 목록 화면이 서버 응답으로 (여기서는 이동만)
class MockExamEntryRow extends ConsumerWidget {
  const MockExamEntryRow({
    super.key,
    this.title = defaultTitle,
    this.hasHorizontalPadding = true,
  });

  static const String defaultTitle = 'SQLD 모의고사';

  /// 행 제목 (홈은 구간 제목이 `SQLD 모의고사` 라 풀이 방식을 말함)
  final String title;
  final bool hasHorizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final rounds = ref.watch(mockExamRoundsProvider).valueOrNull;
    final inProgressAttempt = rounds?.inProgressAttempt;
    final rule = rounds?.examRule;
    // 무료 회원이 지금 시작할 수 있는 체험 회차가 있으면 `무료 1회` 배지 (#980)
    final hasFreeTrial =
        ref.watch(shouldShowProUiProvider) &&
        (rounds?.rounds.any(
              (round) => round.isFreeTrialRound && round.canStart,
            ) ??
            false);
    final String subtitle = inProgressAttempt != null
        ? '제${inProgressAttempt.roundNumber}회 풀이 중 · 이어서 풀기'
        : rule != null
        ? '${rule.questionCount}문항 ${rule.durationMinutes}분 · 합격·과락 판정'
        : '합격·과락까지 바로 판정';
    return PassqlListRow(
      title: title,
      subtitle: subtitle,
      leading: PassqlIconTile(
        icon: CupertinoIcons.doc_text_viewfinder,
        color: colors.accent,
      ),
      trailing: inProgressAttempt != null
          ? const PassqlBadge(text: '풀이 중', kind: PassqlBadgeKind.warning)
          : hasFreeTrial
          ? const PassqlBadge(text: '무료 1회', kind: PassqlBadgeKind.success)
          : null,
      hasChevron: true,
      hasHorizontalPadding: hasHorizontalPadding,
      onTap: () => context.push(
        inProgressAttempt != null
            ? AppRoutes.mockExamAttempt(inProgressAttempt.attemptUuid)
            : AppRoutes.mockExams,
      ),
    );
  }
}
