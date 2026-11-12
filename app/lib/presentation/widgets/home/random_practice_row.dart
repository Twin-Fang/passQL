import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../practice/open_random_practice.dart';

// 행 제목 (구간 제목이 `랜덤 풀기` 라 행은 풀이 방식을 말함)
const String _rowTitle = '한 문제씩 이어서 풀기';
// 한도 소진 부제 (광고·오늘의 세트로 더 열 수 있음)
const String _limitReachedSubtitle = '광고나 오늘의 세트로 더 열 수 있어요';

/// 홈 랜덤 풀기 구간의 행: 탭 > 랜덤 풀기 풀이, 무료(결제 켜짐)면 오른쪽에 오늘 남은 N문제
/// 한도 소진: 부제 > 더 여는 방법, 화살표 없음, 탭 > 안내 시트 (openRandomPractice)
class RandomPracticeRow extends ConsumerWidget {
  const RandomPracticeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final remainingCount = ref.watch(freeRemainingSolvesProvider);
    final isDailyLimitReached = remainingCount == 0;
    return PassqlListRow(
      title: _rowTitle,
      subtitle: isDailyLimitReached
          ? _limitReachedSubtitle
          : RandomPracticeFlow.summary,
      leading: PassqlIconTile(
        icon: CupertinoIcons.shuffle,
        color: colors.accent,
      ),
      trailing: remainingCount == null
          ? null
          : Text(
              '오늘 남은 $remainingCount문제',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
      hasChevron: !isDailyLimitReached,
      hasHorizontalPadding: false,
      onTap: () => openRandomPractice(context, ref),
    );
  }
}
