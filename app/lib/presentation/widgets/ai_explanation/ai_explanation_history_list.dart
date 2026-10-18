import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/choice_explanation_providers.dart';

/// 해설함 목록: 최근 해설 순, 행마다 정오답 표시 + 문제 순번 + 해설 상태. 누르면 그 해설 열기
class AiExplanationHistoryList extends ConsumerWidget {
  const AiExplanationHistoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(aiExplanationSessionProvider);
    final sessionNotifier = ref.read(aiExplanationSessionProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < session.entries.length; index++) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.xs),
          _HistoryRow(
            entry: session.entries[index],
            isOpened: session.entries[index].id == session.openedEntryId,
            onTap: () => sessionNotifier.openEntry(session.entries[index].id),
          ),
        ],
      ],
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({
    required this.entry,
    required this.isOpened,
    required this.onTap,
  });

  final AiExplanationEntry entry;
  final bool isOpened;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final explanationState = ref.watch(
      choiceExplanationProvider(entry.request),
    );
    final statusText = switch (explanationState.phase) {
      ChoiceExplanationPhase.loading => '정리 중',
      ChoiceExplanationPhase.ready => '해설 보기',
      ChoiceExplanationPhase.failed => '다시 시도 필요',
    };
    return PassqlPressable(
      onTap: onTap,
      semanticLabel:
          '${entry.questionTitle}, ${entry.isCorrect ? '정답' : '오답'}, $statusText',
      child: Container(
        constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isOpened ? colors.accentTint : colors.card,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Row(
          children: [
            PassqlResultMark(
              isCorrect: entry.isCorrect,
              label: entry.questionTitle,
            ),
            const Spacer(),
            if (explanationState.isLoading) ...[
              const PassqlLoadingIndicator(),
              const SizedBox(width: PassqlSpacing.xs),
            ],
            Text(
              statusText,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
