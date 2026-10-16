import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 태그 의미 5종 > 색·아이콘 (화면은 의미만 고른다)
enum PassqlBadgeKind {
  topic, // 주제·분류 (강조색, 아이콘 없음)
  neutral, // 보조 정보 (회색)
  success, // 완료·정답
  warning, // 연속 학습·시험 임박
  important, // 중요 공지
  ai, // AI 생성 내용
}

/// 작은 캡슐 태그: 옅은 배경 + 얇은 테두리 + (선택) 아이콘
class PassqlBadge extends StatelessWidget {
  const PassqlBadge({
    super.key,
    required this.text,
    this.kind = PassqlBadgeKind.topic,
    this.icon,
  });

  final String text;
  final PassqlBadgeKind kind;

  /// 기본 아이콘 대신 쓸 아이콘 (null 이면 kind 기본값)
  final IconData? icon;

  /// 캡션 글자 위아래 여백 (캡슐이 글자에 붙지 않을 만큼만)
  static const double _verticalPadding = 3;
  // 배경·테두리 진하기
  static const double _backgroundAlpha = 0.12;
  static const double _borderAlpha = 0.28;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (Color tone, IconData? defaultIcon) = switch (kind) {
      PassqlBadgeKind.topic => (colors.accent, null),
      PassqlBadgeKind.neutral => (colors.secondaryLabel, null),
      PassqlBadgeKind.success => (colors.correctText, CupertinoIcons.checkmark_alt),
      PassqlBadgeKind.warning => (colors.warning, CupertinoIcons.flame_fill),
      PassqlBadgeKind.important => (colors.wrong, CupertinoIcons.exclamationmark_circle_fill),
      PassqlBadgeKind.ai => (colors.accent, CupertinoIcons.sparkles),
    };
    final badgeIcon = icon ?? defaultIcon;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: _backgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        border: Border.all(
          color: tone.withValues(alpha: _borderAlpha),
          width: PassqlSize.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(badgeIcon, size: PassqlIconSize.xxs, color: tone),
            const SizedBox(width: PassqlSpacing.xxs),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.captionSemibold.copyWith(color: tone),
            ),
          ),
        ],
      ),
    );
  }
}
