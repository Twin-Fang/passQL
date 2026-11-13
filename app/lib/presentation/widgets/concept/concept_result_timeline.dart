import '../../design/design.dart';

/// 연출 시각표 (문제 수·다 맞힘·단원 끝 여부로 계산). 단위는 Duration
class ConceptResultTimeline {
  ConceptResultTimeline({
    required this.questionCount,
    required this.isPerfect,
    required this.isUnitCompleted,
  });

  final int questionCount;
  final bool isPerfect;
  final bool isUnitCompleted;

  Duration stepAt(int index) =>
      PassqlMotion.conceptResultStartDelay +
      PassqlMotion.conceptResultStep * index;

  Duration get stepsEndAt =>
      stepAt(questionCount - 1) + PassqlMotion.conceptResultFill;

  Duration get diskEndAt => stepsEndAt + PassqlMotion.conceptResultDiskFill;

  Duration get checkDoneAt => diskEndAt + PassqlMotion.conceptResultCheckDraw;

  Duration get headlineAt => isPerfect ? checkDoneAt : stepsEndAt;

  /// 다시 볼 문제 줄이 위에서부터 차례로 나오는 시각
  Duration rowAt(int position) =>
      headlineAt + PassqlMotion.fast + PassqlMotion.staggerDelayOf(position);

  Duration get unitPlusAt => headlineAt + PassqlMotion.conceptResultUnitStep;

  Duration get unitRollAt => unitPlusAt + PassqlMotion.conceptResultUnitStep;

  Duration get buttonsAt => unitRollAt + PassqlMotion.conceptResultUnitStep;

  Duration get total => buttonsAt + PassqlMotion.standard;

  /// 시각 구간 안에서의 진행률 0~1
  static double progressBetween(
    Duration elapsed,
    Duration start,
    Duration end,
  ) {
    if (elapsed <= start) return 0;
    if (elapsed >= end) return 1;
    return (elapsed - start).inMicroseconds / (end - start).inMicroseconds;
  }
}
