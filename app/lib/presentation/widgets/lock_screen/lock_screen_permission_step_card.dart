import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 권한 단계 카드 1개: 번호(끝나면 체크) > 제목(+권장 배지) > 이유 한 줄 > (현재 단계) 설정 열기·건너뛰기
/// 현재 단계는 강조 테두리, 끝난 단계는 초록 체크
class LockScreenPermissionStepCard extends StatelessWidget {
  const LockScreenPermissionStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.reason,
    required this.isRequired,
    required this.isDone,
    required this.isCurrent,
    required this.onOpenSettings,
    this.onSkip,
  });

  final int number;
  final String title;
  final String reason;
  final bool isRequired;
  final bool isDone;
  final bool isCurrent;
  final VoidCallback onOpenSettings;

  /// 권장 단계 건너뛰기 (없으면 버튼 없음)
  final VoidCallback? onSkip;

  // 현재 단계 테두리 두께
  static const double _currentBorderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return AnimatedContainer(
      duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
      padding: const EdgeInsets.all(PassqlSpacing.md),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(PassqlRadius.lg),
        border: Border.all(
          color: isCurrent ? colors.accent : colors.card,
          width: _currentBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepNumber(number: number, isDone: isDone),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: PassqlTypography.headline.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    if (!isRequired) ...[
                      const SizedBox(width: PassqlSpacing.xs),
                      const PassqlBadge(
                        text: '권장',
                        kind: PassqlBadgeKind.neutral,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                PassqlKeepAllText(
                  reason,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(height: PassqlSpacing.sm),
                  Row(
                    children: [
                      PassqlButton(
                        label: '설정 열기',
                        size: PassqlButtonSize.small,
                        isFullWidth: false,
                        onPressed: onOpenSettings,
                      ),
                      if (onSkip != null) ...[
                        const SizedBox(width: PassqlSpacing.xs),
                        PassqlButton(
                          label: '건너뛰기',
                          size: PassqlButtonSize.small,
                          variant: PassqlButtonVariant.plain,
                          isFullWidth: false,
                          onPressed: onSkip,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 단계 번호 원 (끝나면 초록 체크)
class _StepNumber extends StatelessWidget {
  const _StepNumber({required this.number, required this.isDone});

  final int number;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      width: PassqlSize.choiceKeyBadge,
      height: PassqlSize.choiceKeyBadge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDone ? colors.correct : colors.fill,
        shape: BoxShape.circle,
      ),
      child: isDone
          ? Icon(
              CupertinoIcons.checkmark,
              size: PassqlIconSize.xs,
              color: colors.onSemantic,
              semanticLabel: '완료',
            )
          : Text(
              '$number',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
    );
  }
}
