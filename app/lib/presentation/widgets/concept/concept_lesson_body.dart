import 'package:flutter/widgets.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import '../question/result_rows_table.dart';
import 'concept_lesson_block.dart';
import 'concept_join_diagram.dart';
import 'concept_lesson_block_parser.dart';
import 'concept_memorize_card.dart';
import 'concept_mnemonic_card.dart';
import 'concept_quick_check_card.dart';
import 'concept_refutation_cards.dart';
import 'concept_row_filter_diagram.dart';
import 'concept_set_diagram.dart';
import 'concept_step_timeline.dart';
import 'concept_term_cards.dart';

/// 개념 문단 본문 (#848·#853): 마크다운 > 레슨 블록 > 블록마다 스크롤 등장 (그림 블록은 들어온 뒤 움직임)
/// 표는 화면 폭에 맞춰 칸 안 줄바꿈, 그래도 넘치면 가로 스크롤 (#876). 코드는 줄바꿈 없이 가로 스크롤
class ConceptLessonBody extends StatelessWidget {
  const ConceptLessonBody(this.markdown, {super.key});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final blocks = ConceptLessonBlockParser.parse(markdown);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, block) in blocks.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.md),
          PassqlScrollReveal(index: index, child: _blockWidgetOf(block)),
        ],
      ],
    );
  }

  /// 블록 종류 > 화면 조각
  static Widget _blockWidgetOf(ConceptLessonBlock block) => switch (block) {
    ConceptTextBlock(:final markdown) => MarkdownLiteText(
      markdown,
      style: MarkdownLiteStyle.lesson,
    ),
    // 교재형 SQL 예시는 들여쓰기·결과 주석 정렬이 중요 > 줄바꿈 대신 가로 스크롤
    ConceptCodeBlock(:final code) => PassqlCodeBlock(
      code: code,
      shouldWrap: false,
    ),
    ConceptTableBlock(:final columns, :final rows) =>
      ResultRowsTable.positional(
        columns: columns,
        rows: rows,
        shouldWrapCellsToFit: true,
      ),
    ConceptTermCardsBlock(:final terms) => ConceptTermCards(terms: terms),
    ConceptStepsBlock(:final steps) => ConceptStepTimeline(steps: steps),
    ConceptMnemonicBlock() => ConceptMnemonicCard(mnemonic: block),
    ConceptMemorizeBlock() => ConceptMemorizeCard(memorize: block),
    ConceptRefutationBlock(:final refutations) => ConceptRefutationCards(
      refutations: refutations,
    ),
    ConceptJoinBlock() => ConceptJoinDiagram(join: block),
    ConceptRowFilterBlock() => ConceptRowFilterDiagram(filter: block),
    ConceptSetBlock() => ConceptSetDiagram(set: block),
    ConceptQuickCheckBlock(:final checks) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, check) in checks.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.sm),
          ConceptQuickCheckCard(check: check),
        ],
      ],
    ),
  };
}
