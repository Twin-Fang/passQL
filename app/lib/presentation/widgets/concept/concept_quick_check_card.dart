import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_lesson_block.dart';

/// 바로 확인 OX 한 장 (#848): 문장 > O·X 버튼 > 누르면 정오답 표시 + 이유 펼침 (다시 고르기 없음)
/// 기록은 남기지 않음 (읽는 중 스스로 확인용, 확인 문제 점수와 별개)
class ConceptQuickCheckCard extends StatefulWidget {
  const ConceptQuickCheckCard({super.key, required this.check});

  final ConceptQuickCheck check;

  @override
  State<ConceptQuickCheckCard> createState() => _ConceptQuickCheckCardState();
}

class _ConceptQuickCheckCardState extends State<ConceptQuickCheckCard> {
  // 고른 답 (null: 아직 안 고름, true: O, false: X)
  bool? _pickedIsTrue;

  bool get _hasPicked => _pickedIsTrue != null;

  bool get _isPickedCorrect => _pickedIsTrue == widget.check.isTrue;

  void _onPicked(bool isTrue) {
    if (_hasPicked) return;
    setState(() => _pickedIsTrue = isTrue);
    PassqlHaptics.playAnswerResult(isCorrect: _isPickedCorrect);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.hand_point_right_fill,
                size: PassqlIconSize.sm,
                color: colors.accentText,
              ),
              const SizedBox(width: PassqlSpacing.xxs),
              Text(
                '바로 확인',
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.accentText,
                ),
              ),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            widget.check.statement,
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          Row(
            children: [
              Expanded(child: _answerButton(isTrue: true)),
              const SizedBox(width: PassqlSpacing.sm),
              Expanded(child: _answerButton(isTrue: false)),
            ],
          ),
          // 고른 뒤 결과 + 이유 (높이가 부드럽게 늘어남)
          AnimatedSize(
            duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
            curve: PassqlMotion.curve,
            alignment: Alignment.topCenter,
            child: _hasPicked ? _resultView(colors) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// O·X 버튼: 고르기 전 기본, 고른 뒤 정답 버튼은 정답색·내가 고른 오답은 오답색
  Widget _answerButton({required bool isTrue}) {
    final colors = context.passqlColors;
    final isAnswer = widget.check.isTrue == isTrue;
    final isPicked = _pickedIsTrue == isTrue;
    final (background, foreground) = !_hasPicked
        ? (colors.card, colors.label)
        : isAnswer
        ? (colors.correctTint, colors.correctText)
        : isPicked
        ? (colors.wrongTint, colors.wrongText)
        : (colors.card, colors.secondaryLabel);
    final mark = isTrue ? 'O' : 'X';
    return PassqlPressable(
      onTap: _hasPicked ? null : () => _onPicked(isTrue),
      semanticLabel: isTrue ? '맞다 O' : '틀리다 X',
      child: AnimatedContainer(
        duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
        height: PassqlSize.buttonRegular,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: colors.separator),
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Text(
          mark,
          style: PassqlTypography.title3.copyWith(color: foreground),
        ),
      ),
    );
  }

  /// 정오답 한 줄 + 이유
  Widget _resultView(PassqlColors colors) {
    final isCorrect = _isPickedCorrect;
    final answerMark = widget.check.isTrue ? 'O' : 'X';
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.xmark_circle_fill,
                size: PassqlIconSize.md,
                color: isCorrect ? colors.correct : colors.wrong,
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Text(
                isCorrect ? '맞았어요' : '정답은 $answerMark예요',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: isCorrect ? colors.correctText : colors.wrongText,
                ),
              ),
            ],
          ),
          if (widget.check.reason.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            MarkdownLiteText(
              widget.check.reason,
              style: MarkdownLiteStyle.lesson,
            ),
          ],
        ],
      ),
    );
  }
}
