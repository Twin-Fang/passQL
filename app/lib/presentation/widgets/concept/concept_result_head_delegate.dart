import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_result_ring.dart';
import 'concept_result_timeline.dart';
import 'concept_unit_progress.dart';

/// 머리: 왼쪽 큰 제목 + 부제, 오른쪽 작은 고리. 스크롤로 접히면 한 줄 제목 + 아주 작은 고리만 남음
class ConceptResultHeadDelegate extends SliverPersistentHeaderDelegate {
  ConceptResultHeadDelegate({
    required this.timeline,
    required this.elapsed,
    required this.correctFlags,
    required this.isHeadlineVisible,
    required this.unitProgress,
    required this.isUnitHeadline,
    required this.backgroundColor,
  });

  // 펼친 높이·접힌 높이
  static const double _expandedExtent = 120;
  static const double _collapsedExtent = 44;
  // 마지막 칸이 찬 순간 숫자가 커지는 최대 배율
  static const double _popScale = 1.12;

  final ConceptResultTimeline timeline;
  final Duration elapsed;
  final List<bool> correctFlags;
  final bool isHeadlineVisible;
  final ConceptUnitProgress? unitProgress;

  /// 단원을 다 끝낸 제목으로 바꿔 보여 줄지
  final bool isUnitHeadline;
  final Color backgroundColor;

  @override
  double get maxExtent => _expandedExtent;

  @override
  double get minExtent => _collapsedExtent;

  @override
  bool shouldRebuild(ConceptResultHeadDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.passqlColors;
    final total = correctFlags.length;
    final collapse = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    // 맞힌 문제는 자기 칸 시각에 1/총 만큼 차오름 (틀린 문제는 멈춤)
    var filled = 0.0;
    for (var index = 0; index < total; index++) {
      if (!correctFlags[index]) continue;
      filled += PassqlMotion.curve.transform(
        ConceptResultTimeline.progressBetween(
          elapsed,
          timeline.stepAt(index),
          timeline.stepAt(index) + PassqlMotion.conceptResultFill,
        ),
      );
    }
    final isPerfect = timeline.isPerfect;
    final diskProgress = isPerfect
        ? PassqlMotion.springCurve.transform(
            ConceptResultTimeline.progressBetween(
              elapsed,
              timeline.stepsEndAt,
              timeline.diskEndAt,
            ),
          )
        : 0.0;
    final checkProgress = isPerfect
        ? PassqlMotion.curve.transform(
            ConceptResultTimeline.progressBetween(
              elapsed,
              timeline.diskEndAt,
              timeline.checkDoneAt,
            ),
          )
        : 0.0;
    // 마지막 칸 직후 짧게 커졌다 돌아옴 (0 > 1 > 0)
    final pop = ConceptResultTimeline.progressBetween(
      elapsed,
      timeline.stepsEndAt,
      timeline.stepsEndAt + PassqlMotion.fast,
    );
    final centerScale = 1 + (_popScale - 1) * (1 - (2 * pop - 1).abs());
    final correctCount = correctFlags.where((flag) => flag).length;
    final wrongCount = total - correctCount;
    final unit = unitProgress;
    final headline = isUnitHeadline && unit != null
        ? '${unit.shortLabel}을 끝냈어요'
        : switch (wrongCount) {
            0 => '이 개념은 확실히 잡았어요',
            1 => '한 문제만 다시 보면 돼요',
            _ when wrongCount == total => '다시 읽고 풀어 봐요',
            _ => '$wrongCount문제만 다시 보면 돼요',
          };
    final subtitle = isUnitHeadline && unit != null
        ? '개념 ${unit.total}개를 모두 끝냈어요'
        : switch (wrongCount) {
            0 => '$total문제 모두 맞혔어요',
            _ when wrongCount == total => '$total문제 중 맞힌 문제가 없어요',
            _ => '$total문제 중 $correctCount문제 맞혔어요',
          };
    final filledFraction = total == 0 ? 0.0 : filled / total;
    final ringSemantics = '$total문제 중 $correctCount문제 맞힘';
    final fadeDuration = PassqlMotion.durationOf(context, PassqlMotion.fast);

    final expanded = Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.lg,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: AnimatedOpacity(
              opacity: isHeadlineVisible ? 1 : 0,
              duration: fadeDuration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 단원 끝으로 바뀔 때 글자가 교체되며 페이드
                  AnimatedSwitcher(
                    duration: fadeDuration,
                    child: Text(
                      headline,
                      key: ValueKey(headline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: PassqlTypography.title2.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.xxs),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Semantics(
            label: ringSemantics,
            excludeSemantics: true,
            child: ConceptResultRing(
              filledFraction: filledFraction,
              diskProgress: diskProgress,
              checkProgress: checkProgress,
              centerLabel: '${filled.round()}/$total',
              centerScale: centerScale,
            ),
          ),
        ],
      ),
    );
    final collapsed = Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              headline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          ConceptResultRing(
            filledFraction: filledFraction,
            diskProgress: diskProgress,
            checkProgress: checkProgress,
            centerLabel: '',
            size: PassqlSize.scoreRingMini,
            stroke: PassqlSize.scoreRingMiniStroke,
          ),
        ],
      ),
    );
    // 펼친 머리는 위로 밀려 올라가며 흐려지고, 접힌 한 줄이 그 자리에 남는다
    return ColoredBox(
      color: backgroundColor,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: maxExtent,
              child: Opacity(opacity: 1 - collapse, child: expanded),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: minExtent,
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: Opacity(opacity: collapse, child: collapsed),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
