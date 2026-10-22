import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_pressable.dart';

enum PassqlChoiceState { idle, selected, correct, wrong, dimmed }

/// 선택지 카드. 채점 후에는 정답/오답/흐림으로 바뀌고 더 이상 눌리지 않는다.
class PassqlChoiceCard extends StatelessWidget {
  const PassqlChoiceCard({
    super.key,
    required this.keyLabel,
    required this.child,
    required this.state,
    this.onTap,
    this.onGradedTap,
  });
  final String keyLabel;
  final Widget child;
  final PassqlChoiceState state;
  final VoidCallback? onTap;

  /// 채점 뒤(정답/오답/흐림) 탭 동작. 없으면 채점 뒤에는 눌리지 않는다. 시각 상태는 바뀌지 않는다.
  final VoidCallback? onGradedTap;

  bool get _isGraded =>
      state == PassqlChoiceState.correct ||
      state == PassqlChoiceState.wrong ||
      state == PassqlChoiceState.dimmed;

  // 색·아이콘으로만 전달되던 채점 상태를 스크린리더용 문구로 옮긴다.
  String get _semanticLabel => switch (state) {
    PassqlChoiceState.selected => '선택지 $keyLabel, 선택됨',
    PassqlChoiceState.correct => '선택지 $keyLabel, 정답',
    PassqlChoiceState.wrong => '선택지 $keyLabel, 오답',
    _ => '선택지 $keyLabel',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (
      Color borderColor,
      Color backgroundColor,
      Color keyBackgroundColor,
      Color keyForegroundColor,
    ) = switch (state) {
      PassqlChoiceState.idle || PassqlChoiceState.dimmed => (
        colors.separator,
        colors.card,
        Colors.transparent,
        colors.secondaryLabel,
      ),
      PassqlChoiceState.selected => (
        colors.accent,
        Color.alphaBlend(colors.accentTint, colors.card),
        colors.accent,
        colors.onAccent,
      ),
      // 정답·오답 키: 진한 초록·빨강 위 흰 글자는 대비 2~3.5 > onSemantic
      PassqlChoiceState.correct => (
        colors.correct,
        Color.alphaBlend(colors.correctTint, colors.card),
        colors.correct,
        colors.onSemantic,
      ),
      PassqlChoiceState.wrong => (
        colors.wrong,
        Color.alphaBlend(colors.wrongTint, colors.card),
        colors.wrong,
        colors.onSemantic,
      ),
    };
    final isEmphasized =
        state != PassqlChoiceState.idle && state != PassqlChoiceState.dimmed;
    final colorTransitionDuration = PassqlMotion.durationOf(
      context,
      PassqlMotion.fast,
    );
    final card = AnimatedContainer(
      duration: colorTransitionDuration,
      curve: PassqlMotion.curve,
      padding: const EdgeInsets.all(PassqlSpacing.sm + 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
        border: Border.all(color: borderColor, width: isEmphasized ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: PassqlSize.choiceKeyBadge,
            height: PassqlSize.choiceKeyBadge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: keyBackgroundColor,
              border: isEmphasized
                  ? null
                  : Border.all(color: colors.iconSecondary, width: 1.5),
            ),
            // 키 문자는 시맨틱 라벨('선택지 A')에 이미 있어 두 번 읽지 않게
            child: ExcludeSemantics(
              child: Text(
                keyLabel,
                style: PassqlTypography.captionSemibold.copyWith(
                  color: keyForegroundColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(child: child),
          const SizedBox(width: PassqlSpacing.xs),
          // 채점 아이콘 자리 항상 확보: 채점 순간 내용 폭이 줄며 표 열·줄바꿈이 밀리지 않게 (#554)
          // 상태는 시맨틱 라벨로 전달하므로 아이콘 낭독은 막는다.
          SizedBox.square(
            dimension: PassqlIconSize.xl,
            child: switch (state) {
              PassqlChoiceState.correct => ExcludeSemantics(
                child: Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: PassqlIconSize.xl,
                  color: colors.correct,
                ),
              ),
              PassqlChoiceState.wrong => ExcludeSemantics(
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: PassqlIconSize.xl,
                  color: colors.wrong,
                ),
              ),
              _ => null,
            },
          ),
        ],
      ),
    );
    // 상태 문구 + 선택지 내용(자식 글자) 순서로 한 번에 읽음
    return AnimatedOpacity(
      duration: colorTransitionDuration,
      opacity: state == PassqlChoiceState.dimmed ? 0.5 : 1,
      child: Semantics(
        selected: state == PassqlChoiceState.selected,
        label: _semanticLabel,
        child: PassqlPressable(
          onTap: _isGraded ? onGradedTap : onTap,
          child: card,
        ),
      ),
    );
  }
}
