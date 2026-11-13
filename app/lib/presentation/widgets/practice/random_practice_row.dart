import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../flows/random_practice_flow.dart';
import '../../providers/plan_providers.dart';
import 'open_random_practice.dart';

// 크레딧 0 부제 (광고·오늘의 세트로 더 받을 수 있음)
const String _limitReachedSubtitle = '광고나 오늘의 세트로 크레딧을 받을 수 있어요';
// 크레딧 0 + 오늘의 세트 보너스를 다 받음 (세트로는 더 못 받음)
const String _limitReachedAdOnlySubtitle = '광고를 보면 크레딧을 받을 수 있어요';

/// 랜덤 풀기 행 부제: 크레딧 있음·모름 > 흐름 설명, 0 > 크레딧 받는 방법 (세트 보너스가 남았는지에 따라 2종)
/// [remainingCredits] null = 크레딧 개념이 적용되지 않음(프로·결제 꺼짐)
String randomPracticeSubtitleOf({
  required int? remainingCredits,
  required DailyFreeBonus? dailyBonus,
}) {
  if (remainingCredits != 0) return RandomPracticeFlow.summary;
  // 세트 완료 보너스를 받은 날은 세트로 더 받을 수 없음 (정답 보너스 판정도 끝남)
  final canEarnFromDailySet =
      dailyBonus == null || !dailyBonus.isDailySetCompletionEarned;
  return canEarnFromDailySet
      ? _limitReachedSubtitle
      : _limitReachedAdOnlySubtitle;
}

/// 랜덤 풀기 진입 행 (홈 구간·문제 탭 풀기 방식 공용): 탭 > 랜덤 풀기 풀이 (남은 크레딧 수는 상단 바 알약이 보여 줌, #966)
/// 크레딧 0: 부제 > 받는 방법, 화살표 없음, 탭 > 크레딧 시트 (openRandomPractice)
class RandomPracticeRow extends ConsumerWidget {
  const RandomPracticeRow({
    super.key,
    this.title = RandomPracticeFlow.displayName,
    this.hasHorizontalPadding = true,
  });

  /// 행 제목 (홈은 구간 제목이 `랜덤 풀기` 라 풀이 방식을 말함)
  final String title;
  final bool hasHorizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingCredits = ref.watch(freeRemainingSolvesProvider);
    return PassqlListRow(
      title: title,
      subtitle: randomPracticeSubtitleOf(
        remainingCredits: remainingCredits,
        dailyBonus: ref.watch(knownPlanProvider)?.dailyBonus,
      ),
      leading: PassqlIconTile(
        icon: CupertinoIcons.shuffle,
        color: context.passqlColors.accent,
      ),
      hasChevron: remainingCredits != 0,
      hasHorizontalPadding: hasHorizontalPadding,
      onTap: () => openRandomPractice(context, ref),
    );
  }
}
