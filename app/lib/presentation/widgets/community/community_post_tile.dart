import 'package:flutter/cupertino.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import 'community_post_images.dart';

/// 의견 1건: 닉네임·시각·글 메뉴, 풀이 스냅샷 배지, 본문, 첨부 썸네일, 좋아요
class CommunityPostTile extends StatelessWidget {
  const CommunityPostTile({
    super.key,
    required this.post,
    required this.onLikeTap,
    required this.onMenuTap,
  });

  final CommunityPost post;
  final VoidCallback onLikeTap;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final snapshot = post.solveSnapshot;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.sm,
        PassqlSpacing.xxs,
        PassqlSpacing.xxs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  post.authorNickname,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.label,
                  ),
                ),
              ),
              if (post.isMine) ...[
                const SizedBox(width: PassqlSpacing.xs),
                const PassqlBadge(text: '내 글', kind: PassqlBadgeKind.neutral),
              ],
              const SizedBox(width: PassqlSpacing.xs),
              Text(
                formatNotificationElapsed(post.createdAt),
                style: PassqlTypography.footnote.copyWith(
                  color: colors.tertiaryLabel,
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                label: '글 메뉴',
                excludeSemantics: true,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(
                    PassqlSize.minTouchTarget,
                    PassqlSize.minTouchTarget,
                  ),
                  onPressed: onMenuTap,
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    size: PassqlIconSize.lg,
                    color: colors.tertiaryLabel,
                  ),
                ),
              ),
            ],
          ),
          if (snapshot != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: PassqlBadge(
                text: snapshot.badgeText,
                kind: snapshot.isCorrect
                    ? PassqlBadgeKind.success
                    : PassqlBadgeKind.neutral,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
          ],
          Padding(
            padding: const EdgeInsets.only(right: PassqlSpacing.sm),
            child: Text(
              post.content,
              style: PassqlTypography.body.copyWith(color: colors.label),
            ),
          ),
          if (post.images.isNotEmpty) CommunityPostImages(images: post.images),
          _LikeButton(post: post, onTap: onLikeTap),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.post, required this.onTap});

  final CommunityPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final tone = post.isLikedByMe ? colors.accent : colors.secondaryLabel;
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        selected: post.isLikedByMe,
        label: '좋아요 ${post.likeCount}개',
        excludeSemantics: true,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size(
            PassqlSize.minTouchTarget,
            PassqlSize.minTouchTarget,
          ),
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                post.isLikedByMe
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                size: PassqlIconSize.md,
                color: tone,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '${post.likeCount}',
                style: PassqlTypography.subheadline.copyWith(color: tone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
