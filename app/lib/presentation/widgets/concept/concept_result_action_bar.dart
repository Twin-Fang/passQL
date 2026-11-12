import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_result_appear_once.dart';

/// 개념 결과 아래 버튼 2개: 왼쪽 다시 풀기(틀린 문제·전체), 오른쪽 다음 단원 시작·끝내기.
/// 연출 끝에 아래에서 올라옴 (그 전에는 누를 수 없음)
class ConceptResultActionBar extends StatelessWidget {
  const ConceptResultActionBar({
    super.key,
    required this.isVisible,
    required this.hasWrongAnswer,
    required this.nextUnitLabel,
    required this.finishLabel,
    required this.onRestartWrong,
    required this.onRestart,
    required this.onNextUnitPressed,
    required this.onFinished,
  });

  final bool isVisible;
  final bool hasWrongAnswer;

  /// 단원을 다 끝냈을 때만 다음 단원 짧은 이름 ("3단원"), 아니면 null
  final String? nextUnitLabel;
  final String finishLabel;
  final VoidCallback onRestartWrong;
  final VoidCallback onRestart;
  final VoidCallback? onNextUnitPressed;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    final nextUnit = nextUnitLabel;
    return ConceptResultAppearOnce(
      isVisible: isVisible,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: PassqlBottomActionBar(
          // 버튼 위 내용은 바 뒤로 지나가지 않는 흰 면이라 구분선이 필요 없다
          hasTopHairline: false,
          actions: [
            hasWrongAnswer
                ? PassqlButton(
                    // 틀린 수는 제목·목록에 이미 있어 버튼은 짧게
                    label: '틀린 문제 풀기',
                    variant: PassqlButtonVariant.tinted,
                    onPressed: onRestartWrong,
                  )
                : PassqlButton(
                    label: '다시 풀기',
                    variant: PassqlButtonVariant.tinted,
                    onPressed: onRestart,
                  ),
            // 단원을 다 끝냈으면 다음 단원으로 바로
            nextUnit != null
                ? PassqlButton(
                    label: '$nextUnit 시작하기',
                    onPressed: onNextUnitPressed ?? onFinished,
                  )
                : PassqlButton(label: finishLabel, onPressed: onFinished),
          ],
        ),
      ),
    );
  }
}
