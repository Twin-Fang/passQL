import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_pressable.dart';

/// 그림자 없이 배경 대비로만 구분되는 카드.
class PassqlCard extends StatelessWidget {
  const PassqlCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(PassqlSpacing.md),
    this.isCardTapExposedToScreenReader = true,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  /// false: 카드 안에 같은 동작 버튼이 있어 스크린리더에는 안쪽 버튼만 노출 (포커스 중복 방지)
  final bool isCardTapExposedToScreenReader;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final body = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                // 제목 이동(로터·제목 탐색)용 머리글
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      title!,
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
          ],
          child,
        ],
      ),
    );
    if (onTap == null) return body;
    return PassqlPressable(
      onTap: onTap,
      isTapExposedToScreenReader: isCardTapExposedToScreenReader,
      child: body,
    );
  }
}
