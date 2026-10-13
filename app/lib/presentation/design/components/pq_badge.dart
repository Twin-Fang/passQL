import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';

class PqBadge extends StatelessWidget {
  const PqBadge({super.key, required this.text, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? context.pq.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PqSpace.xs, vertical: 3),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(PqRadius.capsule),
      ),
      child: Text(text, style: PqType.captionSemibold.copyWith(color: tone)),
    );
  }
}

class PqProgressBar extends StatelessWidget {
  const PqProgressBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return ClipRRect(
      borderRadius: BorderRadius.circular(PqRadius.capsule),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: c.fill)),
            AnimatedFractionallySizedBox(
              duration: PqMotion.fast,
              curve: PqMotion.curve,
              widthFactor: value.clamp(0, 1),
              heightFactor: 1,
              alignment: Alignment.centerLeft,
              child: ColoredBox(color: c.accent),
            ),
          ],
        ),
      ),
    );
  }
}
