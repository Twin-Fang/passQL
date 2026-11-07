import 'package:flutter/material.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'question_data_table.dart';

/// 테이블 1개 미리보기: 이름·샘플 행 수 > 컬럼 머리글(이름, PK·FK, 타입) + 샘플 행 표 (처음 5행 + 더 보기)
/// 열이 많거나 글자가 커도 잘리지 않게 가로 스크롤
class SchemaTablePreview extends StatefulWidget {
  const SchemaTablePreview({super.key, required this.table});

  final QuestionSchemaTable table;

  /// 처음에 보여 줄 샘플 행 수 (웹 SchemaViewer 와 같은 값)
  static const int initialSampleRowCount = 5;

  @override
  State<SchemaTablePreview> createState() => _SchemaTablePreviewState();
}

class _SchemaTablePreviewState extends State<SchemaTablePreview> {
  bool _isShowingAllRows = false;

  @override
  Widget build(BuildContext context) {
    final table = widget.table;
    final visibleRows = _isShowingAllRows
        ? table.sampleRows
        : table.sampleRows.take(SchemaTablePreview.initialSampleRowCount).toList();
    final hiddenRowCount = table.sampleRows.length - visibleRows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableTitle(table: table),
        const SizedBox(height: PassqlSpacing.xxs),
        QuestionDataTable(
          columns: table.columns,
          rows: visibleRows,
          isShowingColumnTypes: true,
        ),
        if (hiddenRowCount > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: PassqlButton(
              label: '$hiddenRowCount행 더 보기',
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.small,
              isFullWidth: false,
              onPressed: () => setState(() => _isShowingAllRows = true),
            ),
          ),
      ],
    );
  }
}

/// 테이블 이름 + 샘플 행 수 (없으면 '샘플 데이터 없음')
class _TableTitle extends StatelessWidget {
  const _TableTitle({required this.table});

  final QuestionSchemaTable table;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final sampleRowCount = table.sampleRows.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: Text(
            table.tableName,
            style: PassqlTypography.codeEmphasis.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Text(
          sampleRowCount > 0 ? '샘플 $sampleRowCount행' : '샘플 데이터 없음',
          style: PassqlTypography.caption.copyWith(color: colors.secondaryLabel),
        ),
      ],
    );
  }
}
