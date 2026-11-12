import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_perfect_timeline.dart';
import 'concept_result_appear_once.dart';

/// 점수판 아래 버튼 2개: 다음 단원 시작·끝내기 > 다시 풀기. 연출 끝에 올라옴 (그 전에는 누를 수 없음)
class ConceptPerfectActions extends StatelessWidget {
  const ConceptPerfectActions({
    super.key,
    required this.isVisible,
    required this.nextUnitLabel,
    required this.finishLabel,
    required this.onNextUnitPressed,
    required this.onFinished,
    required this.onRestart,
  });

  final bool isVisible;

  /// 단원을 다 끝냈을 때만 다음 단원 짧은 이름 ("3단원"), 아니면 null
  final String? nextUnitLabel;
  final String finishLabel;
  final VoidCallback onNextUnitPressed;
  final VoidCallback onFinished;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final nextUnit = nextUnitLabel;
    return ConceptResultAppearOnce(
      isVisible: isVisible,
      riseFraction: ConceptPerfectTimeline.appearRiseFraction,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Padding(
          // 카드와 버튼 사이를 넉넉히 띄워 지표 묶음과 행동 묶음이 분리돼 읽히게
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xxl + PassqlSpacing.lg,
            PassqlSpacing.md,
            PassqlSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              nextUnit != null
                  ? PassqlButton(
                      label: '$nextUnit 시작하기',
                      onPressed: onNextUnitPressed,
                    )
                  : PassqlButton(label: finishLabel, onPressed: onFinished),
              PassqlButton(
                label: '다시 풀기',
                variant: PassqlButtonVariant.plain,
                onPressed: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
