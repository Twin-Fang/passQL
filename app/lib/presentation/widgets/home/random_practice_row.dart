import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../practice/open_random_practice.dart';

// 한도 소진 부제 (광고·오늘의 세트로 더 열 수 있음)
const String _limitReachedSubtitle = '광고나 오늘의 세트로 더 열 수 있어요';

/// 홈 오늘의 세트 구간 안 랜덤 풀기 행: 탭 > 랜덤 풀기 풀이, 무료(결제 켜짐)면 오른쪽에 오늘 남은 N문제
/// 오늘 받은 보너스는 작은 칩, 한도 소진: 부제 > 더 여는 방법, 화살표 없음, 탭 > 안내 시트 (openRandomPractice)
class RandomPracticeRow extends ConsumerWidget {
  const RandomPracticeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final remainingCount = ref.watch(freeRemainingSolvesProvider);
    final bonusChipLabels =
        ref.watch(knownPlanProvider)?.dailyBonus.chipLabels ?? const <String>[];
    final isDailyLimitReached = remainingCount == 0;
    return PassqlListRow(
      title: RandomPracticeFlow.displayName,
      subtitle: isDailyLimitReached
          ? _limitReachedSubtitle
          : RandomPracticeFlow.summary,
      leading: PassqlIconTile(
        icon: CupertinoIcons.shuffle,
        color: colors.accent,
      ),
      trailing: remainingCount == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '오늘 남은 $remainingCount문제',
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                if (bonusChipLabels.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: PassqlSpacing.xxs),
                    child: Wrap(
                      spacing: PassqlSpacing.xxs,
                      children: [
                        for (final label in bonusChipLabels)
                          PassqlBadge(
                            text: label,
                            kind: PassqlBadgeKind.success,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
      hasChevron: !isDailyLimitReached,
      hasHorizontalPadding: false,
      onTap: () => openRandomPractice(context, ref),
    );
  }
}
