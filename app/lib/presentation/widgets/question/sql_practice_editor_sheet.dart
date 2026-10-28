import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'sql_input_assist_bar.dart';

/// 실습 SQL 고치기 시트 열기 > 실행을 누르면 true (고친 내용은 [onDraftChanged] 로 계속 전달, #727)
Future<bool?> showSqlPracticeEditorSheet(
  BuildContext context, {
  required String initialSql,
  required List<String> schemaNames,
  required ValueChanged<String> onDraftChanged,
}) {
  return showPassqlSheet<bool>(
    context,
    title: '직접 실행해보기',
    builder: (_) => _SqlPracticeEditor(
      initialSql: initialSql,
      schemaNames: schemaNames,
      onDraftChanged: onDraftChanged,
    ),
  );
}

/// 편집기 + 입력 보조 막대 + 실행 버튼 (키보드가 올라오면 시트가 그만큼 올라감)
class _SqlPracticeEditor extends StatefulWidget {
  const _SqlPracticeEditor({
    required this.initialSql,
    required this.schemaNames,
    required this.onDraftChanged,
  });

  final String initialSql;
  final List<String> schemaNames;
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
          child: Container(
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
        ),
        const SizedBox(height: PassqlSpacing.xs),
        SqlInputAssistBar(
          controller: _controller,
          schemaNames: widget.schemaNames,
          onInserted: () {
            PassqlHaptics.playSelection();
            setState(() {});
            _notifyDraftChanged();
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.sm,
          ),
          child: PassqlButton(
            label: '실행',
            icon: CupertinoIcons.play_fill,
            onPressed: canRun ? () => Navigator.of(context).pop(true) : null,
            size: PassqlButtonSize.regular,
          ),
        ),
      ],
    );
  }
}
