import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/report_providers.dart';
import '../common/app_toast.dart';
import 'report_sheet.dart';

/// 제출 결과 화면에 붙이는 "문제 신고" 버튼.
///
/// 이미 신고한 제출이면 비활성화하고 "신고 완료"로 보여준다.
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
    final c = context.pq;
    final target = (questionUuid: questionUuid, submissionUuid: submissionUuid);
    final reported =
        ref.watch(reportStatusProvider(target)).valueOrNull ?? false;
    final color = reported ? c.tertiaryLabel : c.secondaryLabel;

    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: PqSpace.sm,
        vertical: PqSpace.xs,
      ),
      minimumSize: const Size(44, 44),
      onPressed: reported ? null : () => _open(context, target),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.flag, size: 14, color: color),
          const SizedBox(width: PqSpace.xxs),
          Text(
            reported ? '신고 완료' : '문제 신고',
            style: PqType.caption.copyWith(color: color),
          ),
        ],
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
