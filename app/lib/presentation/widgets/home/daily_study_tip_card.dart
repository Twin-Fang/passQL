import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 홈 오늘의 공부 팁 카드: 전구 아이콘 + 제목 + 팁 본문
class DailyStudyTipCard extends StatelessWidget {
  const DailyStudyTipCard({super.key, required this.studyTip});

  final String studyTip;

  /// 카드 제목 문구 원본
  static const String title = '오늘의 공부 팁';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.lightbulb_fill,
            size: PassqlIconSize.lg,
            color: colors.warning,
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                Text(
                  studyTip,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.label,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
