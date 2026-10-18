import 'package:flutter/cupertino.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';

/// 피드 문제 카드: 토픽, 지문 일부, 의견 수·최근 활동 (풀지 않은 문제는 잠금 표시)
/// 내 의견 탭 카드는 내 글 수·받은 좋아요를 보여 줌
class CommunityFeedCardTile extends StatelessWidget {
  const CommunityFeedCardTile({
    super.key,
    required this.card,
    required this.onTap,
    this.shouldShowMyActivity = false,
  });

  final CommunityFeedCard card;
  final VoidCallback onTap;

  /// true 면 의견 수 대신 내 글 수·받은 좋아요 표시 (내 의견 탭)
  final bool shouldShowMyActivity;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final captionStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    return PassqlCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (card.topicName != null)
                Flexible(child: PassqlBadge(text: card.topicName!)),
              const Spacer(),
              if (!card.isSolvedByMe) ...[
                Icon(
                  CupertinoIcons.lock_fill,
                  size: PassqlIconSize.xs,
                  color: colors.tertiaryLabel,
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '풀면 볼 수 있어요',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.tertiaryLabel,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            card.stemPreview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PassqlTypography.callout.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.sm),
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
                  _activityText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // "의견 12 · 3시간 전" / 내 의견 탭: "내 의견 2 · 받은 좋아요 5 · 3시간 전"
  String _activityText() {
    final elapsed = formatNotificationElapsed(card.lastActivityAt);
    if (!shouldShowMyActivity) return '의견 ${card.postCount} · $elapsed';
    return '내 의견 ${card.myPostCount ?? 0}'
        ' · 받은 좋아요 ${card.receivedLikeCount ?? 0} · $elapsed';
  }
}
