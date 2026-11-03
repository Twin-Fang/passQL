import '../../design/design.dart';

/// 개념 결과 연출 시각 공통 (결과 화면·점수판): 문제 칸 > 원 차오름 > 체크. 단위는 Duration
abstract class ConceptRingTimeline {
  const ConceptRingTimeline({required this.questionCount});

  final int questionCount;

  Duration stepAt(int index) =>
      PassqlMotion.conceptResultStartDelay +
      PassqlMotion.conceptResultStep * index;

  Duration get stepsEndAt =>
      stepAt(questionCount - 1) + PassqlMotion.conceptResultFill;

  Duration get diskEndAt => stepsEndAt + PassqlMotion.conceptResultDiskFill;

  Duration get checkDoneAt => diskEndAt + PassqlMotion.conceptResultCheckDraw;

  /// 연출 전체 길이 (애니메이션 컨트롤러 길이)
  Duration get total;

  /// 문제 칸 [index] 가 차오르는 진행 0~1 (곡선 적용 전)
  double stepProgressAt(Duration elapsed, int index) => progressBetween(
    elapsed,
    stepAt(index),
    stepAt(index) + PassqlMotion.conceptResultFill,
  );

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

/// 결과 화면 시각표: 문제 칸 > (다 맞힘이면 원·체크) > 제목 > 다시 볼 줄 차례로 > 단원 +1 > 숫자 굴림 > 버튼
class ConceptResultTimeline extends ConceptRingTimeline {
  const ConceptResultTimeline({
    required super.questionCount,
    required this.isPerfect,
    required this.isUnitCompleted,
  });

  final bool isPerfect;
  final bool isUnitCompleted;

  Duration get headlineAt => isPerfect ? checkDoneAt : stepsEndAt;

  /// 다시 볼 문제 줄이 위에서부터 차례로 나오는 시각
  Duration rowAt(int position) =>
      headlineAt + PassqlMotion.fast + PassqlMotion.staggerDelayOf(position);

  Duration get unitPlusAt => headlineAt + PassqlMotion.conceptResultUnitStep;

  Duration get unitRollAt => unitPlusAt + PassqlMotion.conceptResultUnitStep;

  Duration get buttonsAt => unitRollAt + PassqlMotion.conceptResultUnitStep;

  @override
  Duration get total => buttonsAt + PassqlMotion.standard;
}

/// 점수판 시각표: 문제 칸 > 원·체크 > 제목 > 카드 n장 > 버튼
class ConceptPerfectTimeline extends ConceptRingTimeline {
  const ConceptPerfectTimeline({
    required super.questionCount,
    required this.cardCount,
  });

  final int cardCount;

  Duration get headlineAt => checkDoneAt;

  Duration cardAt(int index) =>
      headlineAt + PassqlMotion.conceptResultUnitStep * (index + 1);

  Duration get buttonsAt => cardAt(cardCount - 1) + PassqlMotion.emphasized;

  @override
  Duration get total => buttonsAt + PassqlMotion.standard;

  /// 카드가 톡 튀어나오는 진행 0~1 (튀는 곡선 적용 전)
  double cardPop(Duration elapsed, int index) =>
      ConceptRingTimeline.progressBetween(
        elapsed,
        cardAt(index),
        cardAt(index) + PassqlMotion.emphasized,
      );
}
