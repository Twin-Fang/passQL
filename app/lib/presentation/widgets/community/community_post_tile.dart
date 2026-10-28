import 'package:flutter/cupertino.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import 'community_avatar.dart';
import 'community_expandable_text.dart';
import 'community_post_images.dart';

/// 의견 1건 (댓글 모양, #741): 아바타·닉네임(아래 풀이 줄)·좋아요·메뉴, 닉네임 시작선에 맞춘 본문(3줄 넘으면 더 보기)·첨부, 시각·좋아요 수
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

  // 겹쳐 올린 좋아요·메뉴 두 칸 폭 (_IconAction 폭 x 2) - 오른쪽 여백 차이(md - xs)
  static const double _actionsWidth =
      _IconAction.width * 2 - (PassqlSpacing.md - PassqlSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final snapshot = post.solveSnapshot;
    // 누른 좋아요는 빨강 (#741: 강조 보라 대신 흔한 하트 색). 아이콘이라 채움 색 wrong
    final likeTone = post.isLikedByMe ? colors.wrong : colors.iconSecondary;
    // 댓글형 배치 (#741): 아바타는 왼쪽 위 고정, 오른쪽 한 열에 닉네임 > 풀이 줄 > 본문 > 시각이 이어진다.
    // 풀이 줄이 없으면 본문이 그만큼 올라와 빈 줄이 생기지 않는다
    // (아바타와 닉네임을 세로 가운데로 맞추면 풀이 줄 없는 글에서 닉네임 아래가 비어 보였다)
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.sm,
            PassqlSpacing.md,
            PassqlSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommunityAvatar(nickname: post.authorNickname),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 겹쳐 올린 좋아요·메뉴 자리만큼 닉네임 오른쪽을 비운다
                    Padding(
                      padding: const EdgeInsets.only(right: _actionsWidth),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorNickname,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: PassqlTypography.subheadlineSemibold
                                  .copyWith(color: colors.label),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 칩 대신 닉네임 아래 작은 글자 줄 (당근 댓글형): 상자·아이콘 없이 정답·오답 단어만 색
                    // 내 글의 '(나)'도 이 줄에 둔다: 풀이 정보가 없는 내 글은 '(나)'만, 있으면 앞에 붙임
                    if (post.isMine || snapshot != null)
                      _SolveLine(snapshot: snapshot, isMine: post.isMine),
                    // 닉네임·풀이 줄과 본문 사이
                    const SizedBox(height: PassqlSpacing.xs),
                    CommunityExpandableText(
                      text: post.content,
                      style: PassqlTypography.subheadline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    if (post.images.isNotEmpty)
                      CommunityPostImages(images: post.images),
                    const SizedBox(height: PassqlSpacing.xxs),
                    _MetaLine(post: post),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 좋아요·메뉴(누르는 높이 44)는 겹쳐 올려 닉네임 줄 가운데에 맞춘다:
        // 위 여백 sm(12) + 닉네임 줄 절반(10) = 22 = 44 의 절반
        Positioned(
          top: 0,
          right: PassqlSpacing.xs,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 테두리 없는 아이콘만
              _IconAction(
                icon: post.isLikedByMe
                    ? CupertinoIcons.heart_fill
                    : CupertinoIcons.heart,
                color: likeTone,
                label: '좋아요 ${post.likeCount}개',
                isSelected: post.isLikedByMe,
                onTap: onLikeTap,
              ),
              _IconAction(
                icon: CupertinoIcons.ellipsis_vertical,
                color: colors.iconSecondary,
                label: '글 메뉴',
                onTap: onMenuTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 닉네임 아래 줄: "(나) · 정답 · 한 번에 해결" (내 글이면 앞에 (나), 정답·오답 단어만 색, 나머지는 보조 글자색)
class _SolveLine extends StatelessWidget {
  const _SolveLine({required this.snapshot, required this.isMine});

  /// 풀이 공개를 안 한 글은 null (내 글이면 '(나)'만 나온다)
  final SolveSnapshot? snapshot;
  final bool isMine;

  // 내 글 표시
  static const String _mineText = '(나)';

  // badgeText "정답 · 한 번에 해결" 에서 앞 단어와 나머지를 가르는 구분자
  static const String _separator = ' · ';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final baseStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    final spans = <InlineSpan>[];
    if (isMine) spans.add(const TextSpan(text: _mineText));
    final shot = snapshot;
    if (shot != null) {
      final text = shot.badgeText;
      final splitIndex = text.indexOf(_separator);
      final verdict = splitIndex < 0 ? text : text.substring(0, splitIndex);
      final detail = splitIndex < 0 ? '' : text.substring(splitIndex);
      if (isMine) spans.add(const TextSpan(text: _separator));
      spans.add(
        TextSpan(
          text: verdict,
          style: PassqlTypography.footnoteSemibold.copyWith(
            color: shot.isCorrect ? colors.correctText : colors.wrongText,
          ),
        ),
      );
      spans.add(TextSpan(text: detail));
    }
    return Text.rich(
      TextSpan(children: spans),
      style: baseStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 머리 줄 오른쪽 아이콘 버튼 (좋아요·메뉴)
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
    this.isSelected,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  /// 좋아요처럼 켜고 끄는 버튼만 값이 있음 (스크린리더 선택 상태)
  final bool? isSelected;

  // 좋아요·메뉴 아이콘 칸 폭 (#741: 44 > 36 > 28, 세로 점 메뉴라 칸을 더 좁혀 하트와 붙임)
  static const double width = 28;

  @override
  Widget build(BuildContext context) {
    return PassqlSemanticButton(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        // 두 아이콘이 붙어 보이게 폭만 줄인다 (높이는 44 유지)
        minimumSize: const Size(width, PassqlSize.minTouchTarget),
        onPressed: onTap,
        child: Icon(icon, size: PassqlIconSize.md, color: color),
      ),
    );
  }
}

/// 본문 아래 작은 줄: "10/07 08:48 ♥ 12" (작성 시각은 늘 월/일 시:분, 좋아요가 없으면 하트·개수 숨김, #741)
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final captionStyle = PassqlTypography.footnote.copyWith(
      color: colors.secondaryLabel,
    );
    return Row(
      children: [
        Text(formatSlashMonthDayTime(post.createdAt), style: captionStyle),
        if (post.likeCount > 0) ...[
          const SizedBox(width: PassqlSpacing.xs),
          // 개수는 머리 줄 좋아요 버튼이 읽어 주므로 여기는 장식
          ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 하트는 채움 색 wrong, 숫자는 글자 대비를 맞춘 wrongText
                Icon(
                  CupertinoIcons.heart_fill,
                  size: PassqlIconSize.xs,
                  color: colors.wrong,
                ),
                const SizedBox(width: PassqlSpacing.hairlineGap),
                Text(
                  '${post.likeCount}',
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.wrongText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
