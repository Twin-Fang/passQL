import 'package:flutter/material.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import '../question/result_rows_table.dart';
import '../question/stem_markdown_table.dart';

/// 코드 펜스(```sql ... ```) 분리용
final RegExp _codeFenceRe = RegExp(r'```[A-Za-z]*\r?\n?([\s\S]*?)```');

/// 개념 본문 마크다운: 코드 블록 > 코드 상자, 표 > 결과 표, 나머지 > 글(굵게·인라인 코드·목록)
/// 표는 화면 폭 안에서 칸 글 줄바꿈, 코드는 줄바꿈 없이 가로 스크롤 (넘치면 오른쪽 끝 흐림)
class ConceptMarkdownBody extends StatelessWidget {
  const ConceptMarkdownBody(this.markdown, {super.key});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];

    // 글 조각 > 표와 글 (빈 조각은 건너뜀)
    void addTextBlocks(String raw) {
      for (final segment in splitStemMarkdownTables(raw)) {
        if (segment is StemMarkdownTable) {
          blocks.add(
            ResultRowsTable.positional(
              columns: segment.columns,
              rows: segment.rows,
              shouldWrapCells: true,
            ),
          );
          continue;
        }
        final text = (segment as String).trim();
        if (text.isNotEmpty) {
          blocks.add(MarkdownLiteText(text, style: MarkdownLiteStyle.article));
        }
      }
    }

    var cursor = 0;
    for (final match in _codeFenceRe.allMatches(markdown)) {
      addTextBlocks(markdown.substring(cursor, match.start));
      // 교재형 SQL 예시는 들여쓰기·결과 주석 정렬이 중요 > 줄바꿈 대신 가로 스크롤
      blocks.add(
        PassqlCodeBlock(
          code: (match.group(1) ?? '').trimRight(),
          shouldWrap: false,
        ),
      );
      cursor = match.end;
    }
    addTextBlocks(markdown.substring(cursor));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, block) in blocks.indexed) ...[
          if (index > 0) const SizedBox(height: PassqlSpacing.md),
          block,
        ],
      ],
    );
  }
}
