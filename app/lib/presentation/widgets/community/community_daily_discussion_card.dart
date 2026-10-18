import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/community/community_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 홈 '오늘의 토론' 카드: 뜨는 토론 1위 문제, 탭 > 그 문제의 의견 목록 (더 보기 > 피드)
class CommunityDailyDiscussionCard extends StatelessWidget {
  const CommunityDailyDiscussionCard({super.key, required this.card});

  final CommunityFeedCard card;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      title: '오늘의 토론',
      trailing: PassqlButton(
        label: '더 보기',
        variant: PassqlButtonVariant.plain,
        size: PassqlButtonSize.small,
        isFullWidth: false,
        onPressed: () => context.push(AppRoutes.community),
      ),
      onTap: () => context.push(AppRoutes.communityQuestion(card.questionUuid)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.stemPreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.callout.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Row(
            children: [
              Icon(
                CupertinoIcons.chat_bubble_2,
                size: PassqlIconSize.xs,
                color: colors.secondaryLabel,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '의견 ${card.postCount}',
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
