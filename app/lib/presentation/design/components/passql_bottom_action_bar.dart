import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/passql_tokens.dart';
import 'passql_glass.dart';

/// 화면 하단 고정 버튼 영역. 홈 인디케이터·제스처 바 위로 버튼을 올리고 뒤 콘텐츠는 흐린다.
class PassqlBottomActionBar extends StatelessWidget {
  const PassqlBottomActionBar({
    super.key,
    this.top,
    required this.actions,
    this.hasTopHairline = true,
  });
  final Widget? top;
  final List<Widget> actions;

  /// 위 구분선. 뒤로 지나가는 내용이 없는 화면(온보딩)에서는 끈다.
  final bool hasTopHairline;

  @override
  Widget build(BuildContext context) {
    return PassqlGlass(
      hasTopHairline: hasTopHairline,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: PassqlSpacing.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.sm,
            PassqlSpacing.md,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (top != null) ...[
                top!,
                const SizedBox(height: PassqlSpacing.sm),
              ],
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: PassqlSpacing.sm),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
