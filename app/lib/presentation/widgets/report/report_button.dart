import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/app_colors.dart';
import '../../../core/text_styles.dart';
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
    final target = (questionUuid: questionUuid, submissionUuid: submissionUuid);
    final reported = ref.watch(reportStatusProvider(target)).valueOrNull ?? false;
    final color = reported ? AppColors.textCaption : AppColors.textSecondary;

    return TextButton.icon(
      onPressed: reported ? null : () => _open(context, target),
      icon: FaIcon(FontAwesomeIcons.flag, size: 13, color: color),
      label: Text(
        reported ? '신고 완료' : '문제 신고',
        style: AppTextStyles.tag_12.copyWith(color: color),
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
