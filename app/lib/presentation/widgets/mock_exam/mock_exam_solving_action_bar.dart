import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 모의고사 풀이 하단 줄: 도구 3개(이전·표시·문항 목록, 아이콘 + 짧은 글자) + 넓은 다음·제출 버튼
/// 좁은 폭(320)·큰 글자(1.4배)에서도 버튼 글자가 두 줄로 깨지지 않게 도구는 아이콘 위주 (#995)
class MockExamSolvingActionBar extends StatelessWidget {
  const MockExamSolvingActionBar({
    super.key,
    required this.isFirstQuestion,
    required this.isLastQuestion,
    required this.isFlagged,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onToggleFlag,
    required this.onOpenQuestionList,
    required this.onSubmit,
  });

  final bool isFirstQuestion;
  final bool isLastQuestion;
  final bool isFlagged;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToggleFlag;
  final VoidCallback onOpenQuestionList;
  final VoidCallback onSubmit;

  // 다음·제출 버튼 폭 = 도구 버튼 폭의 2배
  static const int _primaryFlex = 2;

  @override
  Widget build(BuildContext context) {
    return PassqlBottomActionBar(
      actions: [
        // 도구·주 버튼 높이 맞춤 (큰 글자에서 도구 버튼이 높아지면 함께)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ToolButton(
                  icon: CupertinoIcons.chevron_left,
                  label: '이전',
                  onPressed: isFirstQuestion ? null : onPrevious,
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: _ToolButton(
                  icon: isFlagged
                      ? CupertinoIcons.flag_fill
                      : CupertinoIcons.flag,
                  label: isFlagged ? '표시됨' : '표시',
                  onPressed: onToggleFlag,
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                child: _ToolButton(
                  icon: CupertinoIcons.square_grid_2x2,
                  label: '문항 목록',
                  onPressed: onOpenQuestionList,
                ),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Expanded(
                flex: _primaryFlex,
                child: PassqlButton(
                  label: isLastQuestion ? '제출' : '다음',
                  size: PassqlButtonSize.regular,
                  isLoading: isSubmitting,
                  onPressed: isLastQuestion ? onSubmit : onNext,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 아이콘 위 짧은 글자 버튼 (옅은 강조 바탕, 비활성은 회색)
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = PassqlButton.colorsOf(
      PassqlButtonVariant.tinted,
      context.passqlColors,
      isEnabled: onPressed != null,
    );
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: PassqlSize.buttonRegular),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(PassqlRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PassqlSpacing.xxs,
              vertical: PassqlSpacing.xxs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: PassqlIconSize.md, color: foregroundColor),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                // 한 줄 고정, 칸보다 길면 글자만 줄임 (큰 글자 배율)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: PassqlTypography.captionSemibold.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
