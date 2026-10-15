import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/validation/report_validator.dart';
import '../../../data/models/report/report_models.dart';
import '../../design/design.dart';
import '../../providers/report_providers.dart';

/// 문제 신고 바텀시트.
///
/// 사유를 하나 이상 고르고, '기타'를 고르면 상세 내용을 적는다.
/// 접수되면 true 를 돌려주며 닫힌다.
class ReportSheet extends ConsumerStatefulWidget {
  const ReportSheet({super.key, required this.target, this.choiceSetUuid});

  final ReportTarget target;
  final String? choiceSetUuid;

  static Future<bool?> show(
    BuildContext context, {
    required ReportTarget target,
    String? choiceSetUuid,
  }) {
    return showPqSheet<bool>(
      context,
      title: '문제 신고',
      builder: (_) => ReportSheet(target: target, choiceSetUuid: choiceSetUuid),
    );
  }

  @override
  ConsumerState<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<ReportSheet> {
  final _detail = TextEditingController();
  final _selected = <ReportCategory>{};
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _detail.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_sending && ReportValidator.isValid(_selected, _detail.text);

  void _toggle(ReportCategory category) {
    setState(() {
      _selected.contains(category)
          ? _selected.remove(category)
          : _selected.add(category);
      _error = null;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ref
          .read(reportSubmitterProvider)
          .submit(
            target: widget.target,
            choiceSetUuid: widget.choiceSetUuid,
            categories: _selected,
            detail: _detail.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final showDetail = _selected.contains(ReportCategory.etc);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        PqSpace.md,
        PqSpace.xxs,
        PqSpace.md,
        PqSpace.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: PqSpace.sm),
              child: Text(
                '해당되는 내용을 모두 골라 주세요',
                style: PqType.subheadline.copyWith(color: c.secondaryLabel),
              ),
            ),
            // 사유는 grouped 행으로, 고른 항목에는 오른쪽에 체크 표시를 붙인다.
            PqGroupedSection(
              children: [
                for (final category in ReportCategory.values)
                  PqCheckRow(
                    title: category.label,
                    selected: _selected.contains(category),
                    onTap: _sending ? null : () => _toggle(category),
                  ),
              ],
            ),
            if (showDetail) ...[
              const SizedBox(height: PqSpace.sm),
              Container(
                padding: const EdgeInsets.all(PqSpace.sm),
                decoration: BoxDecoration(
                  color: c.fill,
                  borderRadius: BorderRadius.circular(PqRadius.md),
                ),
                child: TextField(
                  controller: _detail,
                  enabled: !_sending,
                  maxLines: 3,
                  maxLength: ReportValidator.maxDetailLength,
                  style: PqType.body.copyWith(color: c.label),
                  cursorColor: c.accent,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration.collapsed(
                    hintText: '구체적인 내용을 입력해주세요',
                    hintStyle: PqType.body.copyWith(color: c.tertiaryLabel),
                  ),
                ),
              ),
            ],
            SizedBox(
              height: 28,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _error == null
                    ? null
                    : Text(
                        _error!,
                        style: PqType.caption.copyWith(color: c.wrongText),
                      ),
              ),
            ),
            PqButton(
              label: '신고하기',
              loading: _sending,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}
