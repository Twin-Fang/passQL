import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_lesson_block.dart';

/// 헷갈리는 말 카드 묶음 (#848): 카드마다 오해(X, 흐린 글) > 실제(체크, 굵은 글), 차례로 등장
/// 색만으로 구분하지 않게 아이콘·라벨을 함께 씀
class ConceptRefutationCards extends StatelessWidget {
  const ConceptRefutationCards({super.key, required this.refutations});

  final List<ConceptRefutation> refutations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, refutation) in refutations.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.sm),
          PassqlScrollReveal(
            index: index,
            child: _RefutationCard(refutation: refutation),
          ),
        ],
      ],
    );
  }
}

/// 한 장: 위 오해 줄 + 아래 실제 줄 (사이 헤어라인)
class _RefutationCard extends StatelessWidget {
  const _RefutationCard({required this.refutation});

  final ConceptRefutation refutation;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.separator),
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RefutationLine(
              icon: CupertinoIcons.xmark_circle_fill,
              iconColor: colors.wrong,
              label: '헷갈리는 말',
              text: refutation.myth,
              textColor: colors.secondaryLabel,
            ),
            Container(height: PassqlSize.hairline, color: colors.separator),
            _RefutationLine(
              icon: CupertinoIcons.checkmark_circle_fill,
              iconColor: colors.correct,
              label: '실제로는',
              text: refutation.fact,
              textColor: colors.label,
              isEmphasized: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// 아이콘 + 작은 라벨 + 글 한 줄 묶음
class _RefutationLine extends StatelessWidget {
  const _RefutationLine({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.text,
    required this.textColor,
    this.isEmphasized = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String text;
  final Color textColor;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.all(PassqlSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: PassqlIconSize.md, color: iconColor),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PassqlTypography.captionSemibold.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                DefaultTextStyle.merge(
                  style: TextStyle(color: textColor),
                  child: isEmphasized
                      ? Text(
                          text,
                          style: PassqlTypography.headline.copyWith(
                            color: textColor,
                          ),
                        )
                      : MarkdownLiteText(
                          text,
                          style: MarkdownLiteStyle.lesson,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
