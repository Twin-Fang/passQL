import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/relative_time.dart';
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
    final captionStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    final hasBadgeRow = card.topicName != null || !card.isSolvedByMe;
    return PassqlPressable(
      onTap: () => context.push(AppRoutes.communityQuestion(card.questionUuid)),
      child: PassqlSection(
        title: '오늘의 토론',
        trailing: PassqlSectionLink(
          label: '더 보기',
          semanticLabel: '토론 더 보기',
          onTap: () => context.go(AppRoutes.community),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주제 + 안 푼 문제 표시: 커뮤니티 피드 행과 같은 표기 (community_feed_card_tile)
            if (hasBadgeRow) ...[
              Row(
                children: [
                  if (card.topicName != null)
                    Flexible(child: PassqlBadge(text: card.topicName!)),
                  const Spacer(),
                  if (!card.isSolvedByMe) ...[
                    Icon(
                      CupertinoIcons.lock_fill,
                      size: PassqlIconSize.xs,
                      color: colors.iconSecondary,
                    ),
                    const SizedBox(width: PassqlSpacing.xxs),
                    Text('풀면 볼 수 있어요', style: captionStyle),
                  ],
                ],
              ),
              const SizedBox(height: PassqlSpacing.xs),
            ],
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
                Flexible(
                  child: Text(
                    '의견 ${card.postCount} · '
                    '${formatNotificationElapsed(card.lastActivityAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: captionStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
