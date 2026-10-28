import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/question/question_schema_table.dart';
import '../../design/design.dart';
import 'sql_input_assist_bar.dart';
import 'sql_practice_schema_reference.dart';

/// 실습 SQL 고치기 시트 열기 > 실행을 누르면 true (고친 내용은 [onDraftChanged] 로 계속 전달, #727)
Future<bool?> showSqlPracticeEditorSheet(
  BuildContext context, {
  required String initialSql,
  required List<QuestionSchemaTable> schemaTables,
  required ValueChanged<String> onDraftChanged,
}) {
  // 제목은 시트 본문 머리 줄이 실행 버튼과 함께 그림
  return showPassqlSheet<bool>(
    context,
    builder: (_) => _SqlPracticeEditor(
      initialSql: initialSql,
      schemaTables: schemaTables,
      onDraftChanged: onDraftChanged,
    ),
  );
}

/// 표·열 이름 목록: 표 먼저, 중복 없이 (입력 보조 3줄째)
List<String> _toSchemaNames(List<QuestionSchemaTable> tables) => {
  for (final table in tables) table.tableName,
  for (final table in tables)
    for (final column in table.columns) column.name,
}.toList();

/// 시트 본문: 머리(제목 + 실행) > 테이블 안내 > 편집기 > 입력 보조 막대 (키보드 바로 위)
class _SqlPracticeEditor extends StatefulWidget {
  const _SqlPracticeEditor({
    required this.initialSql,
    required this.schemaTables,
    required this.onDraftChanged,
  });

  final String initialSql;
  final List<QuestionSchemaTable> schemaTables;
  final ValueChanged<String> onDraftChanged;

  @override
  State<_SqlPracticeEditor> createState() => _SqlPracticeEditorState();
}

class _SqlPracticeEditorState extends State<_SqlPracticeEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialSql,
  );

  // 편집기 보이는 줄 수 (키보드 + 보조 막대 위에 남는 높이 기준)
  static const int _minVisibleLines = 4;
  static const int _maxVisibleLines = 8;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _notifyDraftChanged() => widget.onDraftChanged(_controller.text);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final canRun = _controller.text.trim().isNotEmpty;
    // 키보드가 올라와 높이가 모자라면 위쪽(테이블 안내·편집기)만 스크롤, 입력 보조 막대는 키보드 위 고정
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EditorHeader(
                  onRun: canRun ? () => Navigator.of(context).pop(true) : null,
                ),
                const SizedBox(height: PassqlSpacing.sm),
                SqlPracticeSchemaReference(tables: widget.schemaTables),
                const SizedBox(height: PassqlSpacing.xs),
                Container(
                  padding: const EdgeInsets.all(PassqlSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.fill,
                    borderRadius: BorderRadius.circular(PassqlRadius.md),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    minLines: _minVisibleLines,
                    maxLines: _maxVisibleLines,
                    // SQL 입력: 영문 키보드, 자동 고침·추천·대문자·둥근 따옴표 끔 (' 가 ’ 로 바뀌면 실행 오류)
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.newline,
                    autocorrect: false,
                    enableSuggestions: false,
                    smartQuotesType: SmartQuotesType.disabled,
                    smartDashesType: SmartDashesType.disabled,
                    textCapitalization: TextCapitalization.none,
                    style: PassqlTypography.code.copyWith(color: colors.label),
                    cursorColor: colors.accent,
                    onChanged: (_) {
                      setState(() {});
                      _notifyDraftChanged();
                    },
                    decoration: InputDecoration.collapsed(
                      hintText: 'SELECT 부터 써 보세요',
                      hintStyle: PassqlTypography.code.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
          child: SqlInputAssistBar(
            controller: _controller,
            schemaNames: _toSchemaNames(widget.schemaTables),
            onInserted: () {
              PassqlHaptics.playSelection();
              setState(() {});
              _notifyDraftChanged();
            },
          ),
        ),
      ],
    );
  }
}

/// 시트 머리 줄: 제목(왼쪽) + 작은 실행 버튼(오른쪽, 엄지가 닿는 위치)
class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.onRun});

  /// null 이면 실행 비활성 (SQL 이 비었음)
  final VoidCallback? onRun;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              '직접 실행해보기',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
        ),
        PassqlButton(
          label: '실행',
          icon: CupertinoIcons.play_fill,
          onPressed: onRun,
          size: PassqlButtonSize.small,
          isFullWidth: false,
        ),
      ],
    );
  }
}
