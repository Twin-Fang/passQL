import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import 'expected_pass_summary.dart';

/// 모의고사 회차 목록 맨 위 예상 합격률 한 줄 (#1086): 아이콘 + 비율·근거 (응시 0회면 안내)
/// 불러오는 중·실패면 자리 없음
class ExpectedPassLine extends ConsumerWidget {
  const ExpectedPassLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expectedPass = ref.watch(expectedPassProvider).valueOrNull;
    if (expectedPass == null) return const SizedBox.shrink();
    final colors = context.passqlColors;
    final expectedPassPercent = expectedPass.expectedPassPercent;
    final message = expectedPassPercent == null
        ? expectedPassEmptyMessage
        : '예상 합격률 $expectedPassPercent% | '
              '최근 ${expectedPass.basisAttemptCount}회 기준';
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.chart_pie_fill,
            size: PassqlIconSize.sm,
            color: colors.accentText,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
