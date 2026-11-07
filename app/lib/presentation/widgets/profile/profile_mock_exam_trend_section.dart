import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../mock_exam/mock_exam_trend_chart.dart';

/// 프로필 모의고사 점수 추이 (#909, 프로): 회차 목록과 같은 막대(합격선 가로줄), 막대 탭 > 그 응시 결과.
/// 응시 기록이 있을 때만. 잠금(무료)·불러오는 중·실패면 자리 없음 (잠금 미리보기는 모의고사 화면이 맡음)
class ProfileMockExamTrendSection extends ConsumerWidget {
  const ProfileMockExamTrendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(mockExamHistoryProvider).valueOrNull;
    if (history == null || history.attempts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PassqlSectionGap(),
        PassqlSection(
          title: '모의고사 점수 추이',
          child: MockExamTrendChart(
            history: history,
            onAttemptTap: (attemptUuid) =>
                context.push(AppRoutes.mockExamResult(attemptUuid)),
          ),
        ),
      ],
    );
  }
}
