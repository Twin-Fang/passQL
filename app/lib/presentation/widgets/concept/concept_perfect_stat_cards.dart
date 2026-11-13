import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_unit_progress.dart';

/// 점수판 지표 카드 줄: 정답 · 단원 · 전체 (단원 값이 없으면 정답 하나).
/// 단원·전체는 차례가 지나면([isRolled]) 이번 개념까지 센 값으로 바뀜
class ConceptPerfectStatCards extends StatelessWidget {
  const ConceptPerfectStatCards({
    super.key,
    required this.questionCount,
    required this.unitProgress,
    required this.isRolled,
    required this.popOf,
  });

  final int questionCount;
  final ConceptUnitProgress? unitProgress;
  final bool isRolled;

  /// 카드 순서 > 톡 튀어나오는 진행 0~1
  final double Function(int cardIndex) popOf;

  @override
  Widget build(BuildContext context) {
    final unit = unitProgress;
    final total = questionCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: '정답',
              value: total,
              total: total,
              pop: popOf(0),
            ),
          ),
          if (unit != null) ...[
            const SizedBox(width: PassqlSpacing.xs),
            Expanded(
              child: _StatCard(
                title: unit.shortLabel,
                value: isRolled ? unit.solvedCount : unit.solvedCountBefore,
                total: unit.total,
                pop: popOf(1),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Expanded(
              child: _StatCard(
                title: '전체',
                value: isRolled
                    ? unit.overallSolvedCount
                    : unit.overallSolvedCountBefore,
                total: unit.overallTotal,
                pop: popOf(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 지표 카드: 앱 공통 강조색 연한 바탕(이어서 학습 띠와 같은 톤)에 큰 숫자 n/총, 위에 작은 이름.
/// 색은 카드마다 다르지 않고 고리와 같은 강조색 하나. 차례가 오면 작게서 톡 커지며 나타남
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.total,
    required this.pop,
  });

  // 나타나기 시작할 때 크기
  static const double _startScale = 0.6;

  final String title;
  final int value;
  final int total;
  final double pop;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final scale =
        _startScale +
        (1 - _startScale) * PassqlMotion.springCurve.transform(pop);
    return Semantics(
      label: '$title $total개 중 $value개',
      excludeSemantics: true,
      child: Opacity(
        opacity: pop == 0 ? 0 : 1,
        child: Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: PassqlSpacing.sm,
              horizontal: PassqlSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.accentTint,
              borderRadius: BorderRadius.circular(PassqlRadius.lg),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
                const SizedBox(height: PassqlSpacing.hairlineGap),
                // 숫자가 카드의 주인공: 큰 제목 크기, 총수는 한 단계 작게
                Text.rich(
                  TextSpan(
                    text: '$value',
                    style: PassqlTypography.largeTitle.copyWith(
                      color: colors.label,
                      fontFeatures: PassqlTypography.tabular,
                    ),
                    children: [
                      TextSpan(
                        text: '/$total',
                        style: PassqlTypography.subheadlineSemibold.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ],
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
