import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 홈 출제 경향 진입 카드 (#523). 서버 호출 없음 (문구 고정), 탭 > 출제 경향 화면
class ExamTrendEntryCard extends StatelessWidget {
  const ExamTrendEntryCard({super.key});

  static const String title = '2026 SQLD 출제 경향';
  static const String subtitle = '최근 시험에서 늘어난 유형과 최신 경향 문제를 모았어요';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      onTap: () => context.push(AppRoutes.examTrend),
      child: Row(
        children: [
          PassqlIconTile(icon: CupertinoIcons.flame_fill, color: colors.accent),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    const SizedBox(width: PassqlSpacing.xs),
                    const PassqlLatestTrendBadge(),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                Text(
                  subtitle,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          Icon(
            CupertinoIcons.chevron_forward,
            size: PassqlIconSize.xs,
            color: colors.tertiaryLabel,
          ),
        ],
      ),
    );
  }
}
