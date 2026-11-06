import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import 'mock_exam_trend_chart.dart';

/// 회차 목록의 점수 추이 (프로): 무료(결제 켜짐)는 잠금 미리보기, 기록 없음·실패면 자리 없음
class MockExamTrendSection extends ConsumerWidget {
  const MockExamTrendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mockExamHistoryProvider);
    if (historyAsync.isLoading) return const SizedBox.shrink();
    final history = historyAsync.valueOrNull;
    if (historyAsync.hasValue && history == null) {
      return const ProLockedSection(
        preview: MockExamTrendLockedSample(),
        caption: LockedPreviewCaptions.mockExamTrend,
      );
    }
    if (history == null || history.attempts.isEmpty) {
      return const SizedBox.shrink();
    }
    return PassqlCard(
      title: '점수 추이',
      child: MockExamTrendChart(
        history: history,
        onAttemptTap: (attemptUuid) =>
            context.push(AppRoutes.mockExamResult(attemptUuid)),
      ),
    );
  }
}
