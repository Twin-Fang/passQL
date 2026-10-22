import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 태그 의미 7종 > 색·아이콘 (화면은 의미만 고른다)
enum PassqlBadgeKind {
  topic, // 주제·분류 (강조색, 아이콘 없음)
  neutral, // 보조 정보 (회색)
  success, // 완료·정답
  warning, // 연속 학습·시험 임박
  important, // 중요 공지
  ai, // AI 생성 내용
  latestTrend, // 최신 출제 경향 반영 문제 (#523)
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
  // 배경·테두리 진하기 (배경은 대비 테스트가 같은 값으로 계산)
  static const double backgroundAlpha = 0.12;
  static const double _borderAlpha = 0.28;

  /// 의미 > (채움 색, 글자·아이콘 색). 채움은 옅게 깔고 글자는 대비 4.5 이상인 글자 토큰
  static (Color fillTone, Color textTone) tonesOf(
    PassqlBadgeKind kind,
    PassqlColors colors,
  ) => switch (kind) {
    PassqlBadgeKind.topic ||
    PassqlBadgeKind.ai ||
    PassqlBadgeKind.latestTrend => (colors.accent, colors.accentText),
    PassqlBadgeKind.neutral => (colors.secondaryLabel, colors.secondaryLabel),
    PassqlBadgeKind.success => (colors.correct, colors.correctText),
    PassqlBadgeKind.warning => (colors.warning, colors.warningText),
    PassqlBadgeKind.important => (colors.wrong, colors.wrongText),
  };

  /// 의미 > 기본 아이콘 (topic·neutral 은 없음)
  static IconData? _defaultIconOf(PassqlBadgeKind kind) => switch (kind) {
    PassqlBadgeKind.topic || PassqlBadgeKind.neutral => null,
    PassqlBadgeKind.success => CupertinoIcons.checkmark_alt,
    PassqlBadgeKind.warning ||
    PassqlBadgeKind.latestTrend => CupertinoIcons.flame_fill,
    PassqlBadgeKind.important => CupertinoIcons.exclamationmark_circle_fill,
    PassqlBadgeKind.ai => CupertinoIcons.sparkles,
  };

  @override
  Widget build(BuildContext context) {
    final (fillTone, textTone) = tonesOf(kind, context.passqlColors);
    final badgeIcon = icon ?? _defaultIconOf(kind);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: fillTone.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        border: Border.all(
          color: fillTone.withValues(alpha: _borderAlpha),
          width: PassqlSize.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeIcon != null) ...[
            Icon(badgeIcon, size: PassqlIconSize.xxs, color: textTone),
            const SizedBox(width: PassqlSpacing.xxs),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.captionSemibold.copyWith(color: textTone),
            ),
          ),
        ],
      ),
    );
  }
}

/// '최신 경향' 배지: 최신 출제 경향 반영 문제·토픽 표시 (문제 머리·추천 행·토픽 행·홈 진입 카드 공통, #523)
class PassqlLatestTrendBadge extends StatelessWidget {
  const PassqlLatestTrendBadge({super.key});

  /// 배지 문구 원본
  static const String label = '최신 경향';

  @override
  Widget build(BuildContext context) =>
      const PassqlBadge(text: label, kind: PassqlBadgeKind.latestTrend);
}
