import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;

import '../../design/design.dart';
import '../report/report_button.dart';

/// 잠금화면 채점 마크 옆 조용한 동작 2개: 토론 보기(앱에서 의견 목록), 문제 신고(잠금 엔진에서 바로 시트)
/// 신고는 어떤 제출인지 알아야 해서 [submissionUuid] 가 있을 때만
class LockScreenQuestionActions extends StatelessWidget {
  const LockScreenQuestionActions({
    super.key,
    required this.questionUuid,
    required this.submissionUuid,
    required this.choiceSetUuid,
    required this.onOpenDiscussion,
  });

  final String questionUuid;
  final String? submissionUuid;
  final String? choiceSetUuid;
  final VoidCallback onOpenDiscussion;

  @override
  Widget build(BuildContext context) {
    final submissionUuid = this.submissionUuid;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DiscussionButton(onTap: onOpenDiscussion),
        if (submissionUuid != null)
          ReportButton(
            questionUuid: questionUuid,
            submissionUuid: submissionUuid,
            choiceSetUuid: choiceSetUuid,
          ),
      ],
    );
  }
}

/// 토론 보기: 신고 버튼과 같은 모양 (말풍선 + 짧은 글자, 흐린 글자색)
class _DiscussionButton extends StatelessWidget {
  const _DiscussionButton({required this.onTap});

  static const String _label = '토론 보기';

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.passqlColors.secondaryLabel;
    return PassqlSemanticButton(
      label: _label,
      onTap: onTap,
      child: Tooltip(
        message: _label,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xs),
          minimumSize: const Size.square(PassqlSize.minTouchTarget),
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.chat_bubble_2,
                size: PassqlIconSize.md,
                color: color,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '토론',
                style: PassqlTypography.footnote.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
