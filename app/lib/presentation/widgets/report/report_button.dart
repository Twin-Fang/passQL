import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/report_providers.dart';
import '../common/app_toast.dart';
import 'report_sheet.dart';

/// 제출 결과 화면에 붙이는 "문제 신고" 아이콘 버튼 (글자 없음, 스크린리더·툴팁에 문구).
///
/// 이미 신고한 제출이면 비활성화하고 채운 깃발 + "신고 완료"로 알린다.
class ReportButton extends ConsumerWidget {
  const ReportButton({
    super.key,
    required this.questionUuid,
    required this.submissionUuid,
    this.choiceSetUuid,
  });

  final String questionUuid;
  final String submissionUuid;
  final String? choiceSetUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final target = (questionUuid: questionUuid, submissionUuid: submissionUuid);
    final reported =
        ref.watch(reportStatusProvider(target)).valueOrNull ?? false;
    // 신고 완료는 문구로 구분 (흐린 색은 대비 미달)
    final color = colors.secondaryLabel;

    final label = reported ? '신고 완료' : '문제 신고';
    return Semantics(
      label: label,
      button: true,
      enabled: !reported,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: const Size.square(PassqlSize.minTouchTarget),
          onPressed: reported ? null : () => _open(context, target),
          child: Icon(
            reported ? CupertinoIcons.flag_fill : CupertinoIcons.flag,
            size: PassqlIconSize.md,
            color: color,
          ),
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, ReportTarget target) async {
    final sent = await ReportSheet.show(
      context,
      target: target,
      choiceSetUuid: choiceSetUuid,
    );
    if (sent == true && context.mounted) {
      showAppToast(context, '신고가 접수됐어요. 확인 후 반영할게요');
    }
  }
}
