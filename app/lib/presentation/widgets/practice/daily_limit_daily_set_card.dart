import 'package:flutter/cupertino.dart';

import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../daily_set/daily_set_bonus_check_rows.dart';

/// 크레딧 시트의 오늘의 세트 카드: 머리(제목·한 줄 설명) > 보너스 2줄(받을 수 있음·받았어요·오늘은 못 받음) > 세트를 끝내기 전이면 풀러 가기 버튼
class DailyLimitDailySetCard extends StatelessWidget {
  const DailyLimitDailySetCard({
    super.key,
    required this.dailyBonus,
    required this.bonusQuestionCount,
    required this.onOpenDailySet,
  });

  /// 오늘 받은 보너스 (등급을 모르면 null > 둘 다 안 받음으로 표시)
  final DailyFreeBonus? dailyBonus;
  final int bonusQuestionCount;
  final VoidCallback onOpenDailySet;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final isCompletionEarned = dailyBonus?.isDailySetCompletionEarned ?? false;
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 머리: 광고 카드와 같은 구성 (아이콘 타일 + 제목 + 한 줄 설명)
          Row(
            children: [
              PassqlIconTile(
                icon: CupertinoIcons.square_list_fill,
                color: colors.accent,
              ),
              const SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 세트로 크레딧 받기',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    Text(
                      '하루 한 번, 최대 ${bonusQuestionCount * 2}개',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          DailySetBonusCheckRows(
            dailyBonus: dailyBonus,
            bonusQuestionCount: bonusQuestionCount,
          ),
          // 세트를 끝냈으면 두 보너스 판정이 끝나 갈 곳 없음
          if (!isCompletionEarned) ...[
            const SizedBox(height: PassqlSpacing.md),
            PassqlButton(
              label: '오늘의 세트 풀러 가기',
              variant: PassqlButtonVariant.tinted,
              size: PassqlButtonSize.regular,
              onPressed: onOpenDailySet,
            ),
          ],
        ],
      ),
    );
  }
}
