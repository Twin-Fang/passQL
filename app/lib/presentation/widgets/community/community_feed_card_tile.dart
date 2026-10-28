import 'package:flutter/material.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';

/// 피드 문제 한 줄 (게시판 목록 모양, #741): 주제 아이콘 타일, 주제 이름, 지문 2줄, 시각·의견 수
/// 풀지 않은 문제는 메타 줄 오른쪽에 '풀면 볼 수 있어요'. 내 의견 탭 줄은 의견 수 대신 내 글 수·받은 좋아요
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

  /// 줄 사이 구분선 왼쪽 들여쓰기: 아이콘 타일 오른쪽 글자 시작선에 맞춘다
  static const double separatorIndent =
      PassqlSpacing.md + PassqlSize.iconTile + PassqlSpacing.sm;

  static const String _lockedText = '풀면 볼 수 있어요';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final topicName = card.topicName;
    final elapsed = formatNotificationElapsed(card.lastActivityAt);
    final activity = _activityText();
    // 주제 코드가 없으면 topicIconFor·topicColorFor 가 물음표·기본 색으로 대체한다
    final topicCode = card.topicCode ?? '';
    final captionStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: [
        ?topicName,
        card.stemPreview,
        activity,
        elapsed,
        if (!card.isSolvedByMe) _lockedText,
      ].join(', '),
      child: ColoredBox(
        color: colors.card,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PassqlSpacing.md,
            vertical: PassqlSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PassqlIconTile(
                icon: topicIconFor(topicCode),
                color: topicColorFor(
                  topicCode,
                  context.isDark ? Brightness.dark : Brightness.light,
                ),
              ),
              const SizedBox(width: PassqlSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (topicName != null) ...[
                      Text(
                        topicName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PassqlTypography.footnoteSemibold.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: PassqlSpacing.xxs),
                    ],
                    Text(
                      card.stemPreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        color: colors.label,
                      ),
                    ),
                    const SizedBox(height: PassqlSpacing.xs),
                    Row(
                      children: [
                        // 잠금 문구를 오른쪽 끝에 붙이려고 시각·활동을 한 덩어리(Expanded)로 둔다
                        // (Flexible + Spacer 면 남는 폭을 나눠 가져 문구가 가운데에 뜬다)
                        Expanded(
                          child: Row(
                            children: [
                              Text(elapsed, style: captionStyle),
                              const SizedBox(width: PassqlSpacing.xs),
                              Flexible(
                                child: Text(
                                  activity,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PassqlTypography.footnoteSemibold
                                      .copyWith(color: colors.accentText),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!card.isSolvedByMe)
                          Text(_lockedText, style: captionStyle),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // "의견 12" / 내 의견 탭: "내 의견 2 · 받은 좋아요 5" (시각은 메타 줄 앞에 따로)
  String _activityText() {
    if (!shouldShowMyActivity) return '의견 ${card.postCount}';
    return '내 의견 ${card.myPostCount ?? 0}'
        ' · 받은 좋아요 ${card.receivedLikeCount ?? 0}';
  }
}
