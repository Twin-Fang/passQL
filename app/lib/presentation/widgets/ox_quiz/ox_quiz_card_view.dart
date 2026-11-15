import 'package:flutter/cupertino.dart';

import '../../../data/models/ox_quiz/ox_quiz_models.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// OX 카드 1장 (#1083): 개념 이름 > 문장 > O·X 큰 버튼 > 고르면 정오 + 해설 + 다음 버튼
/// 고르기 전후 상태는 호출부(OxQuizSessionNotifier, 잠금화면 LockScreenOxCardNotifier)가 가짐
class OxQuizCardView extends StatelessWidget {
  const OxQuizCardView({
    super.key,
    required this.card,
    required this.pickedIsTrue,
    required this.isLastCard,
    required this.onPicked,
    this.onNextPressed,
    this.resultNote,
  });

  final OxCardItem card;

  /// 고른 답 (null: 아직 안 고름, true: O, false: X)
  final bool? pickedIsTrue;
  final bool isLastCard;
  final ValueChanged<bool> onPicked;

  /// 다음 버튼 (null 이면 버튼 없음: 잠금화면은 하단 바가 다음 동작)
  final VoidCallback? onNextPressed;

  /// 해설 아래 한 줄 (잠금화면 다음 복습일 등, null 이면 없음)
  final String? resultNote;

  bool get _hasPicked => pickedIsTrue != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                [
                  card.topicName,
                  card.conceptTitle,
                ].where((part) => part.isNotEmpty).join(' | '),
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.accentText,
                ),
              ),
              const SizedBox(height: PassqlSpacing.sm),
              Text(
                card.statement,
                style: PassqlTypography.title3.copyWith(color: colors.label),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.md),
        Row(
          children: [
            Expanded(child: _answerButton(context, isTrue: true)),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(child: _answerButton(context, isTrue: false)),
          ],
        ),
        // 고른 뒤 정오 + 해설 + 다음 (높이가 부드럽게 늘어남)
        AnimatedSize(
          duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
          curve: PassqlMotion.curve,
          alignment: Alignment.topCenter,
          child: _hasPicked ? _resultView(colors) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// O·X 버튼: 고르기 전 기본, 고른 뒤 정답 버튼은 정답색, 내가 고른 오답은 오답색
  Widget _answerButton(BuildContext context, {required bool isTrue}) {
    final colors = context.passqlColors;
    final isAnswer = card.isTrue == isTrue;
    final isPicked = pickedIsTrue == isTrue;
    final (background, foreground) = !_hasPicked
        ? (colors.card, colors.label)
        : isAnswer
        ? (colors.correctTint, colors.correctText)
        : isPicked
        ? (colors.wrongTint, colors.wrongText)
        : (colors.card, colors.secondaryLabel);
    return PassqlPressable(
      onTap: _hasPicked ? null : () => onPicked(isTrue),
      semanticLabel: isTrue ? '맞다 O' : '틀리다 X',
      child: AnimatedContainer(
        duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
        height: PassqlSize.oxQuizAnswerButtonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: colors.separator),
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Text(
          isTrue ? 'O' : 'X',
          style: PassqlTypography.largeTitle.copyWith(color: foreground),
        ),
      ),
    );
  }

  /// 정오 한 줄 + 해설 + 다음 버튼
  Widget _resultView(PassqlColors colors) {
    final isCorrect = pickedIsTrue == card.isTrue;
    final answerMark = card.isTrue ? 'O' : 'X';
    return Padding(
      padding: const EdgeInsets.only(top: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.xmark_circle_fill,
                size: PassqlIconSize.xl,
                color: isCorrect ? colors.correct : colors.wrong,
              ),
              const SizedBox(width: PassqlSpacing.xs),
              Text(
                isCorrect ? '맞았어요' : '정답은 $answerMark예요',
                style: PassqlTypography.headline.copyWith(
                  color: isCorrect ? colors.correctText : colors.wrongText,
                ),
              ),
            ],
          ),
          if (card.reason.isNotEmpty) ...[
            const SizedBox(height: PassqlSpacing.xs),
            MarkdownLiteText(card.reason, style: MarkdownLiteStyle.lesson),
          ],
          if (resultNote case final note?) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              note,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          if (onNextPressed case final onNext?) ...[
            const SizedBox(height: PassqlSpacing.lg),
            PassqlButton(
              label: isLastCard ? '결과 보기' : '다음 카드',
              onPressed: onNext,
            ),
          ],
        ],
      ),
    );
  }
}
