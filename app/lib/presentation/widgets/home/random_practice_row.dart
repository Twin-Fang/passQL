import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import '../practice/open_random_practice.dart';

// 행 제목 (구간 제목이 `랜덤 풀기` 라 행은 풀이 방식을 말함)
const String _rowTitle = '한 문제씩 이어서 풀기';
// 한도 소진 부제 (광고·오늘의 세트로 더 열 수 있음)
const String _limitReachedSubtitle = '광고나 오늘의 세트로 크레딧을 받을 수 있어요';
// 한도 소진 + 오늘의 세트 보너스를 다 받음 (세트로는 더 못 받음)
const String _limitReachedAdOnlySubtitle = '광고를 보면 크레딧을 받을 수 있어요';

/// 홈 랜덤 풀기 구간의 행: 탭 > 랜덤 풀기 풀이 (오늘 남은 문제 수는 상단 바 알약이 보여 줌, #966)
/// 한도 소진: 부제 > 더 여는 방법, 화살표 없음, 탭 > 안내 시트 (openRandomPractice)
class RandomPracticeRow extends ConsumerWidget {
  const RandomPracticeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final remainingCount = ref.watch(freeRemainingSolvesProvider);
    final isDailyLimitReached = remainingCount == 0;
    final dailyBonus = ref.watch(knownPlanProvider)?.dailyBonus;
    // 세트 완료·정답 보너스 둘 다 받았거나 세트를 끝내 정답 보너스를 못 받게 된 날은 세트로 더 받을 수 없음
    final canEarnFromDailySet =
        dailyBonus == null || !dailyBonus.isDailySetCompletionEarned;
    return PassqlListRow(
      title: _rowTitle,
      subtitle: isDailyLimitReached
          ? (canEarnFromDailySet
                ? _limitReachedSubtitle
                : _limitReachedAdOnlySubtitle)
          : RandomPracticeFlow.summary,
      leading: PassqlIconTile(
        icon: CupertinoIcons.shuffle,
        color: colors.accent,
      ),
      hasChevron: !isDailyLimitReached,
      hasHorizontalPadding: false,
      onTap: () => openRandomPractice(context, ref),
    );
  }
}
