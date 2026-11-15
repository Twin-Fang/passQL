import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../mock_exam/expected_pass_summary.dart';

/// 프로필 예상 합격률 구간 (#1086, 무료 포함 전원): 앞 띠 + 최근 모의고사 기준 비율 카드
/// 불러오는 중·실패면 자리 없음, 응시 0회면 안내 한 줄
class ProfileExpectedPassSection extends ConsumerWidget {
  const ProfileExpectedPassSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expectedPass = ref.watch(expectedPassProvider).valueOrNull;
    if (expectedPass == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PassqlSectionGap(),
        PassqlSection(
          title: '예상 합격률',
          // 구간 제목 앞 아이콘: 프로필 구간 모두 같은 모양 (#971)
          leading: PassqlIconTile(
            icon: CupertinoIcons.chart_pie_fill,
            color: context.passqlColors.accent,
            isCompact: true,
          ),
          child: ExpectedPassSummary(expectedPass: expectedPass),
        ),
      ],
    );
  }
}
