import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_pressable.dart';

enum PqChoiceState { idle, selected, correct, wrong, dimmed }

/// 선택지 카드. 채점 후에는 정답/오답/흐림으로 바뀌고 더 이상 눌리지 않는다.
class PqChoiceCard extends StatelessWidget {
  const PqChoiceCard({super.key, required this.keyLabel, required this.child, required this.state, this.onTap});
  final String keyLabel;
  final Widget child;
  final PqChoiceState state;
  final VoidCallback? onTap;

  bool get _graded => state == PqChoiceState.correct || state == PqChoiceState.wrong || state == PqChoiceState.dimmed;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final (Color border, Color bg, Color keyBg, Color keyFg) = switch (state) {
      PqChoiceState.idle || PqChoiceState.dimmed => (c.separator, c.card, Colors.transparent, c.secondaryLabel),
      PqChoiceState.selected => (c.accent, Color.alphaBlend(c.accentTint, c.card), c.accent, c.onAccent),
      PqChoiceState.correct => (c.correct, Color.alphaBlend(c.correctTint, c.card), c.correct, c.onAccent),
      PqChoiceState.wrong => (c.wrong, Color.alphaBlend(c.wrongTint, c.card), c.wrong, c.onAccent),
    };
    final emphasized = state != PqChoiceState.idle && state != PqChoiceState.dimmed;
    final card = AnimatedContainer(
      duration: PqMotion.fast,
      curve: PqMotion.curve,
      padding: const EdgeInsets.all(PqSpace.sm + 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PqRadius.md),
        border: Border.all(color: border, width: emphasized ? 1.5 : 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: keyBg,
            border: emphasized ? null : Border.all(color: c.tertiaryLabel, width: 1.5),
          ),
          child: Text(keyLabel, style: PqType.captionSemibold.copyWith(color: keyFg)),
        ),
        const SizedBox(width: PqSpace.sm),
        Expanded(child: child),
        if (state == PqChoiceState.correct) ...[
          const SizedBox(width: PqSpace.xs),
          Icon(CupertinoIcons.checkmark_circle_fill, size: 22, color: c.correct),
        ],
        if (state == PqChoiceState.wrong) ...[
          const SizedBox(width: PqSpace.xs),
          Icon(CupertinoIcons.xmark_circle_fill, size: 22, color: c.wrong),
        ],
      ]),
    );
    return AnimatedOpacity(
      duration: PqMotion.fast,
      opacity: state == PqChoiceState.dimmed ? 0.5 : 1,
      child: PqPressable(
        semanticLabel: '선택지 $keyLabel',
        onTap: _graded ? null : onTap,
        child: card,
      ),
    );
  }
}
