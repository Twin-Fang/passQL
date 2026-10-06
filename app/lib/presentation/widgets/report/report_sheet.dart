import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../core/validation/report_validator.dart';
import '../../../data/models/report/report_models.dart';
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
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
    final showDetail = _selected.contains(ReportCategory.etc);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('문제 신고', style: AppTextStyles.heading_24),
            const SizedBox(height: 4),
            Text(
              '해당되는 내용을 모두 골라 주세요',
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            for (final category in ReportCategory.values)
              CheckboxListTile(
                value: _selected.contains(category),
                onChanged: _sending ? null : (_) => _toggle(category),
                title: Text(category.label, style: AppTextStyles.paragraph_14),
                activeColor: AppColors.brandIndigo,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            if (showDetail) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _detail,
                enabled: !_sending,
                maxLines: 3,
                maxLength: ReportValidator.maxDetailLength,
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  hintText: '구체적인 내용을 입력해주세요',
                  filled: true,
                  fillColor: AppColors.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderDefault),
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
                        style: AppTextStyles.tag_12.copyWith(
                          color: AppColors.red,
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandIndigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('신고하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
