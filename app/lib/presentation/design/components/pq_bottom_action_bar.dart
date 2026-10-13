import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../tokens/pq_metrics.dart';
import 'pq_glass.dart';

/// 화면 하단 고정 버튼 영역. 홈 인디케이터·제스처 바 위로 버튼을 올리고 뒤 콘텐츠는 흐린다.
class PqBottomActionBar extends StatelessWidget {
  const PqBottomActionBar({super.key, this.top, required this.actions});
  final Widget? top;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return PqGlass(
      topHairline: true,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: PqSpace.md),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PqSpace.md,
            PqSpace.sm,
            PqSpace.md,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (top != null) ...[top!, const SizedBox(height: PqSpace.sm)],
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: PqSpace.sm),
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
