import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_section_header.dart';

/// 홈식 구간 면: 좌우 끝까지 닿는 card 배경. 구간 사이는 [PassqlSectionGap] 띠로 나눈다.
/// 카드처럼 띄우지 않고 면과 띠의 밝기 차이로만 구분한다 (TDS 구간 나누기).
class PassqlSection extends StatelessWidget {
  const PassqlSection({
    super.key,
    required this.child,
    this.title,
    this.leading,
    this.trailing,
    this.isCompactTitle = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: PassqlSpacing.md,
      vertical: PassqlSpacing.lg,
    ),
  });

  final Widget child;
  final String? title;
  final Widget? leading;
  final Widget? trailing;

  /// 15pt 제목 줄 (작은 타일과 함께, #726)
  // ponytail: 위 여백은 17pt 줄 기준 verticalSlack(11) 그대로라 15pt(줄 20)면 1pt 넓다. 맞추려면 헤더가 글자 크기별 slack 을 내야 함
  final bool isCompactTitle;
  final EdgeInsetsGeometry padding;

  static const double _gapBelowHeader =
      PassqlSpacing.sm - PassqlSectionHeader.verticalSlack;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 제목 줄(44) 안 글자 위 빈 공간만큼 위 여백을 줄여, 보이는 간격은 글자만 있을 때와 같게
    final resolved = padding.resolve(Directionality.of(context));
    final effectivePadding = title == null
        ? resolved
        : resolved.copyWith(
            top: math.max(0, resolved.top - PassqlSectionHeader.verticalSlack),
          );
    return Container(
      width: double.infinity,
      color: colors.card,
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            PassqlSectionHeader(
              title: title!,
              leading: leading,
              trailing: trailing,
              isCompact: isCompactTitle,
            ),
            // 제목 > 내용 sm(12) 중 글자 아래 빈 공간(11)이 이미 차지한 만큼 뺌
            const SizedBox(height: _gapBelowHeader),
          ],
          child,
        ],
      ),
    );
  }
}
