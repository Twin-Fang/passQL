import '../../design/design.dart';

/// 연출 시각표: 문제 칸 > 원·체크 > 제목 > 카드 n장 > 버튼
class ConceptPerfectTimeline {
  ConceptPerfectTimeline({
    required this.questionCount,
    required this.cardCount,
  });

  // 제목·버튼이 아래에서 올라오는 거리 (자기 높이 비율)
  static const double appearRiseFraction = 0.2;

  // 원이 찰 때 고리 전체가 커지는 최대 비율
  static const double _bounceScale = 0.14;
  // 고리 시작 크기(한 문제 맞힐 때마다 1까지 커짐)와 한 칸 찰 때 잠깐 더 커지는 비율
  static const double _ringStartScale = 0.7;
  static const double _stepBumpScale = 0.06;

  final int questionCount;
  final int cardCount;

  Duration stepAt(int index) =>
      PassqlMotion.conceptResultStartDelay +
      PassqlMotion.conceptResultStep * index;

  Duration get stepsEndAt =>
      stepAt(questionCount - 1) + PassqlMotion.conceptResultFill;

  Duration get diskEndAt => stepsEndAt + PassqlMotion.conceptResultDiskFill;

  Duration get checkDoneAt => diskEndAt + PassqlMotion.conceptResultCheckDraw;

  Duration get headlineAt => checkDoneAt;

  Duration cardAt(int index) =>
      headlineAt + PassqlMotion.conceptResultUnitStep * (index + 1);

  Duration get buttonsAt => cardAt(cardCount - 1) + PassqlMotion.emphasized;

  Duration get total => buttonsAt + PassqlMotion.standard;

  /// 카드가 톡 튀어나오는 진행 0~1 (튀는 곡선 적용 전)
  double cardPop(Duration elapsed, int index) => progressBetween(
    elapsed,
    cardAt(index),
    cardAt(index) + PassqlMotion.emphasized,
  );

  /// 고리에 찬 칸 수: 문제마다 1/총 만큼 차오르고 숫자도 같이 오름
  double filledCountAt(Duration elapsed) {
    var filled = 0.0;
    for (var index = 0; index < questionCount; index++) {
      filled += PassqlMotion.curve.transform(_stepProgressAt(elapsed, index));
    }
    return filled;
  }

  /// 원이 차는 진행 0~1 (곡선 적용 전)
  double diskRawAt(Duration elapsed) =>
      progressBetween(elapsed, stepsEndAt, diskEndAt);

  /// 체크가 그려지는 진행 0~1
  double checkProgressAt(Duration elapsed) => PassqlMotion.curve.transform(
    progressBetween(elapsed, diskEndAt, checkDoneAt),
  );

  /// 고리 전체 배율: 시작 크기 > 문제마다 한 단계 커짐(그 순간 잠깐 더 부풂) > 원이 다 차는 순간 한 번 튐
  double ringScaleAt(Duration elapsed) {
    var stepBump = 0.0;
    for (var index = 0; index < questionCount; index++) {
      final stepProgress = _stepProgressAt(elapsed, index);
      stepBump += _stepBumpScale * (1 - (2 * stepProgress - 1).abs());
    }
    final filled = filledCountAt(elapsed);
    final grow =
        _ringStartScale +
        (1 - _ringStartScale) *
            (questionCount == 0 ? 1 : filled / questionCount);
    final diskRaw = diskRawAt(elapsed);
    // 원이 다 차는 순간 고리 전체가 한 번 살짝 커졌다 돌아옴 (0 > 1 > 0)
    return grow + stepBump + _bounceScale * (1 - (2 * diskRaw - 1).abs());
  }

  /// 문제 칸 하나가 차는 진행 0~1
  double _stepProgressAt(Duration elapsed, int index) => progressBetween(
    elapsed,
    stepAt(index),
    stepAt(index) + PassqlMotion.conceptResultFill,
  );

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
