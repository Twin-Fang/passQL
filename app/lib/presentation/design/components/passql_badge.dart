import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

class PassqlBadge extends StatelessWidget {
  const PassqlBadge({super.key, required this.text, this.color});
  final String text;
  final Color? color;

  /// 캡션 글자 위아래 여백 (캡슐이 글자에 붙지 않을 만큼만)
  static const double _verticalPadding = 3;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.passqlColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: _verticalPadding,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        text,
        style: PassqlTypography.captionSemibold.copyWith(color: tone),
      ),
    );
  }
}
