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
    void showHistory() =>
        ref.read(aiExplanationSessionProvider.notifier).showHistory();
    // 개수 숫자를 라벨과 두 번 읽지 않게 라벨 하나로
    return PassqlSemanticButton(
      label: '해설함, $entryCount개',
      onTap: showHistory,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size.square(PassqlSize.minTouchTarget),
        onPressed: showHistory,
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
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
