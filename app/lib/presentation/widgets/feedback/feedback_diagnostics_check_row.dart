import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 진단 정보 체크 줄: 체크박스 + 라벨, 오른쪽 "포함되는 정보 보기"
class FeedbackDiagnosticsCheckRow extends StatelessWidget {
  const FeedbackDiagnosticsCheckRow({
    super.key,
    required this.isChecked,
    required this.onToggled,
    required this.onShowPressed,
  });

  final bool isChecked;
  final VoidCallback? onToggled;
  final VoidCallback onShowPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        Expanded(
          child: PassqlPressable(
            onTap: onToggled,
            semanticLabel: '진단 정보 같이 보내기',
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PassqlSize.minTouchTarget,
              ),
              child: Row(
                children: [
                  Icon(
                    isChecked
                        ? CupertinoIcons.checkmark_square_fill
                        : CupertinoIcons.square,
                    size: PassqlIconSize.xxl,
                    color: isChecked ? colors.accent : colors.secondaryLabel,
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  Flexible(
                    child: Text(
                      '진단 정보 같이 보내기',
                      style: PassqlTypography.subheadline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        PassqlButton(
          label: '포함되는 정보 보기',
          variant: PassqlButtonVariant.plain,
          size: PassqlButtonSize.small,
          isFullWidth: false,
          onPressed: onShowPressed,
        ),
      ],
    );
  }
}
