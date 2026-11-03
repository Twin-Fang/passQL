import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_unit_progress.dart';
import '../../design/design.dart';
import 'concept_result_ring.dart';
import 'concept_result_timeline.dart';
import 'concept_rise_in.dart';

/// 점수판 영웅: 커지며 차오르는 고리(원·체크·빛줄기) > 제목·부제 (단원 끝이면 단원 끝 문구)
class ConceptPerfectHero extends StatelessWidget {
  const ConceptPerfectHero({
    super.key,
    required this.ringKey,
    required this.timeline,
    required this.elapsed,
    required this.questionCount,
    required this.unitProgress,
    required this.isUnitCompleted,
    required this.shineProgress,
  });

  // 원이 찰 때 고리 전체가 커지는 최대 비율
  static const double _bounceScale = 0.14;
  // 고리 시작 크기(한 문제 맞힐 때마다 1까지 커짐)와 한 칸 찰 때 잠깐 더 커지는 비율
  static const double _ringStartScale = 0.7;
  static const double _stepBumpScale = 0.06;

  /// 빛 번짐 출발점(원 가운데)을 재려고 고리에 붙이는 키 (점수판이 소유)
  final GlobalKey ringKey;
  final ConceptPerfectTimeline timeline;
  final Duration elapsed;
  final int questionCount;
  final ConceptUnitProgress? unitProgress;
  final bool isUnitCompleted;

  /// 원 위를 스치는 빛줄기 진행 0~1
  final double shineProgress;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final unit = unitProgress;
    final total = questionCount;
    // 고리는 문제마다 1/총 만큼 차오르고 숫자도 같이 오름
    // 한 문제 맞힐 때마다 고리가 한 단계 커지고, 그 순간 잠깐 더 부풀었다 돌아옴
    var filled = 0.0;
    var stepBump = 0.0;
    for (var index = 0; index < total; index++) {
      final stepProgress = timeline.stepProgressAt(elapsed, index);
      filled += PassqlMotion.curve.transform(stepProgress);
      stepBump += _stepBumpScale * (1 - (2 * stepProgress - 1).abs());
    }
    final diskRaw = ConceptRingTimeline.progressBetween(
      elapsed,
      timeline.stepsEndAt,
      timeline.diskEndAt,
    );
    final grow =
        _ringStartScale +
        (1 - _ringStartScale) * (total == 0 ? 1 : filled / total);
    // 원이 다 차는 순간 고리 전체가 한 번 살짝 커졌다 돌아옴 (0 > 1 > 0)
    final bounce =
        grow + stepBump + _bounceScale * (1 - (2 * diskRaw - 1).abs());
    final checkProgress = PassqlMotion.curve.transform(
      ConceptRingTimeline.progressBetween(
        elapsed,
        timeline.diskEndAt,
        timeline.checkDoneAt,
      ),
    );
    final headline = isUnitCompleted && unit != null
        ? '${unit.shortLabel}을 끝냈어요'
        : '완벽해요';
    final subtitle = isUnitCompleted && unit != null
        ? '개념 ${unit.total}개를 모두 끝냈어요'
        : '$total문제 모두 정답';
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
                scale: bounce,
                child: ConceptResultRing(
                  filledFraction: total == 0 ? 0 : filled / total,
                  diskProgress: PassqlMotion.springCurve.transform(diskRaw),
                  checkProgress: checkProgress,
                  centerLabel: '${filled.round()}/$total',
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
        ConceptRiseIn(
          isVisible: elapsed >= timeline.headlineAt,
          riseFraction: ConceptRiseIn.subtleRiseFraction,
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
