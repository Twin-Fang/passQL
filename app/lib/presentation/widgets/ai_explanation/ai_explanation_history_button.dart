import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';

/// 상단 바 해설함 버튼: 해설이 쌓였고 패널이 닫혀 있을 때만 (닫은 뒤 다시 여는 길)
class AiExplanationHistoryButton extends ConsumerWidget {
  const AiExplanationHistoryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final entryCount = ref.watch(
      aiExplanationSessionProvider.select((session) => session.entries.length),
    );
    final isPanelOpen = ref.watch(
      aiExplanationSessionProvider.select((session) => session.isPanelOpen),
    );
    if (entryCount == 0 || isPanelOpen) return const SizedBox.shrink();
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(PassqlSize.minTouchTarget),
      onPressed: () =>
          ref.read(aiExplanationSessionProvider.notifier).showHistory(),
      child: Semantics(
        label: '해설함, $entryCount개',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.sparkles,
              size: PassqlIconSize.md,
              color: colors.accent,
            ),
            const SizedBox(width: PassqlSpacing.hairlineGap),
            Text(
              '$entryCount',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.accent,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
