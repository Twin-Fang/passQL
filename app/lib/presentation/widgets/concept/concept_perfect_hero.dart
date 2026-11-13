import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_perfect_timeline.dart';
import 'concept_result_appear_once.dart';
import 'concept_result_ring.dart';

/// 점수판 가운데: 큰 고리(숫자 > 보라 원 > 체크 > 빛줄기) + 제목·부제
class ConceptPerfectHero extends StatelessWidget {
  const ConceptPerfectHero({
    super.key,
    required this.ringKey,
    required this.questionCount,
    required this.filledCount,
    required this.ringScale,
    required this.diskProgress,
    required this.checkProgress,
    required this.shineProgress,
    required this.isHeadlineVisible,
    required this.headline,
    required this.subtitle,
  });

  /// 빛 번짐 출발점(원 가운데)을 재는 키
  final GlobalKey ringKey;
  final int questionCount;

  /// 지금까지 찬 칸 수 (소수, 칸이 차오르는 중간값 포함)
  final double filledCount;

  /// 고리 전체 배율 (문제마다 커짐 + 원이 찰 때 튐)
  final double ringScale;
  final double diskProgress;
  final double checkProgress;
  final double shineProgress;
  final bool isHeadlineVisible;
  final String headline;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final total = questionCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '$total문제 모두 맞힘',
          excludeSemantics: true,
          child: Stack(
            key: ringKey,
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: ConceptResultRing(
                  filledFraction: total == 0 ? 0 : filledCount / total,
                  diskProgress: diskProgress,
                  checkProgress: checkProgress,
                  centerLabel: '${filledCount.round()}/$total',
                  size: PassqlSize.scoreRing,
                  stroke: PassqlSize.scoreRingStroke,
                  centerStyle: PassqlTypography.scoreNumber,
                  // 점수판은 파랑 계열(강조색)로, 체크는 그 위에 흰색
                  isAccentOnly: true,
                  checkColor: colors.onAccent,
                  // 원은 탑승권과 같은 보라 그라데이션, 빛줄기가 한 번 스침
                  diskGradientEnd: colors.passGradientEnd,
                  shineProgress: shineProgress,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.lg),
        ConceptResultAppearOnce(
          isVisible: isHeadlineVisible,
          riseFraction: ConceptPerfectTimeline.appearRiseFraction,
          child: Column(
            children: [
              Text(
                headline,
                textAlign: TextAlign.center,
                style: PassqlTypography.title1.copyWith(color: colors.label),
              ),
              const SizedBox(height: PassqlSpacing.xxs),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PassqlSpacing.xl,
                ),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  // 개념 이름이 읽혀야 해서 본문 크기·본문 색 (보조 글자 아님)
                  style: PassqlTypography.body.copyWith(color: colors.label),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
