import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';

/// 모의고사 바로가기 행 (홈 구간·문제 탭 공용): 풀이 중이면 이어 풀기 안내, 아니면 형식 한 줄
/// 등급 판정은 목록 화면이 서버 응답으로 (여기서는 이동만)
class MockExamEntryRow extends ConsumerWidget {
  const MockExamEntryRow({super.key, this.hasHorizontalPadding = true});

  final bool hasHorizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final rounds = ref.watch(mockExamRoundsProvider).valueOrNull;
    final inProgressAttempt = rounds?.inProgressAttempt;
    final rule = rounds?.examRule;
    final String subtitle = inProgressAttempt != null
        ? '제${inProgressAttempt.roundNumber}회 풀이 중 · 이어서 풀기'
        : rule != null
        ? '${rule.questionCount}문항 ${rule.durationMinutes}분 · 합격·과락 판정'
        : '실제 시험처럼 풀고 합격 판정';
    return PassqlListRow(
      title: 'SQLD 모의고사',
      subtitle: subtitle,
      leading: PassqlIconTile(
        icon: CupertinoIcons.doc_text_viewfinder,
        color: colors.accent,
      ),
      trailing: inProgressAttempt != null
          ? const PassqlBadge(text: '풀이 중', kind: PassqlBadgeKind.warning)
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
