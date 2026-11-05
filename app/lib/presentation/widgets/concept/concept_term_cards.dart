import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_lesson_block.dart';

/// 용어 카드 묶음 (#848): 용어 크게(강조색) > 뜻 한 줄, 카드마다 차례로 등장
class ConceptTermCards extends StatelessWidget {
  const ConceptTermCards({super.key, required this.terms});

  final List<ConceptTerm> terms;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, term) in terms.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.xs),
          PassqlScrollReveal(
            index: index,
            child: _TermCard(term: term),
          ),
        ],
      ],
    );
  }
}

/// 용어 한 장: 옅은 회색 바탕 + 용어(제목 굵기) + 뜻(본문)
class _TermCard extends StatelessWidget {
  const _TermCard({required this.term});

  final ConceptTerm term;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              term.term,
              style: PassqlTypography.title3.copyWith(color: colors.accentText),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            MarkdownLiteText(term.meaning, style: MarkdownLiteStyle.article),
          ],
        ),
      ),
    );
  }
}
