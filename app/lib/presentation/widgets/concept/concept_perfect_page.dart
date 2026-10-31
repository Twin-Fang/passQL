import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'concept_confetti.dart';
import 'concept_glow.dart';
import 'concept_result_ring.dart';
import 'concept_result_view.dart';

/// 다 맞혔을 때만 뜨는 전체 화면 점수판 (#764, 듀오링고 레슨 완료 참고).
/// 큰 고리가 한 칸씩 차며 숫자가 오르고 > 초록 원·체크 > 제목 > 지표 카드 3장이 하나씩 톡 > 버튼.
/// 단원까지 끝냈으면 제목·단원 카드·버튼이 단원 끝으로 바뀌고 폭죽.
/// 화면을 누르면 건너뛰고, 동작 줄이기면 처음부터 끝 화면. 닫기 버튼은 없고 아래 버튼으로만 나감
class ConceptPerfectPage extends StatefulWidget {
  const ConceptPerfectPage({
    super.key,
    required this.questionCount,
    required this.conceptTitle,
    required this.unitProgress,
    required this.finishLabel,
    required this.onFinished,
    required this.onRestart,
    this.onNextUnitPressed,
  });

  final int questionCount;
  final String conceptTitle;
  final ConceptUnitProgress? unitProgress;
  final String finishLabel;

  /// 닫은 뒤 부를 동작들 (페이지 자신이 먼저 닫힌다)
  final VoidCallback onFinished;
  final VoidCallback onRestart;
  final VoidCallback? onNextUnitPressed;

  /// 아래에서 올라오는 전체 화면으로 띄움
  static Future<void> show(
    BuildContext context, {
    required int questionCount,
    required String conceptTitle,
    required ConceptUnitProgress? unitProgress,
    required String finishLabel,
    required VoidCallback onFinished,
    required VoidCallback onRestart,
    VoidCallback? onNextUnitPressed,
  }) {
    // 화면 전환 없이 바로 바뀜 (연출은 안에서 시작하므로 전환 애니메이션이 겹치면 어수선함)
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        fullscreenDialog: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => ConceptPerfectPage(
          questionCount: questionCount,
          conceptTitle: conceptTitle,
          unitProgress: unitProgress,
          finishLabel: finishLabel,
          onFinished: onFinished,
          onRestart: onRestart,
          onNextUnitPressed: onNextUnitPressed,
        ),
      ),
    );
  }

  @override
  State<ConceptPerfectPage> createState() => _ConceptPerfectPageState();
}

class _ConceptPerfectPageState extends State<ConceptPerfectPage>
    with TickerProviderStateMixin {
  late final _PerfectTimeline _timeline = _PerfectTimeline(
    questionCount: widget.questionCount,
    cardCount: _cardCount,
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _timeline.total,
  )..addListener(_onTick);
  late final AnimationController _confettiController = AnimationController(
    vsync: this,
    duration: PassqlMotion.confetti,
  );
  late final AnimationController _glowController = AnimationController(
    vsync: this,
    duration: PassqlMotion.conceptGlowSpread,
  );
  // 화면 끝까지 번지는 빛의 출발점(원 가운데)을 재려고 점수판 층과 원에 붙이는 키
  final GlobalKey _layerKey = GlobalKey();
  final GlobalKey _ringKey = GlobalKey();
  Offset _glowCenter = Offset.zero;
  // 이미 울린 진동 단계 (프레임마다 같은 진동을 다시 울리지 않게)
  final Set<int> _playedHapticSteps = {};
  bool _isStarted = false;
  // 영웅(고리·제목)을 세로 가운데보다 올리는 정도 (-1 위 ~ 1 아래)
  static const double _heroVerticalBias = 0.0;
  // 원이 찰 때 고리 전체가 커지는 최대 비율
  static const double _bounceScale = 0.14;
  // 고리 시작 크기(한 문제 맞힐 때마다 1까지 커짐)와 한 칸 찰 때 잠깐 더 커지는 비율
  static const double _ringStartScale = 0.7;
  static const double _stepBumpScale = 0.06;
  // 빛줄기가 원을 다 지나가는 시점 (빛 번짐 진행률 기준)
  static const double _shineEndFraction = 0.5;

  // 카드: 정답 · 단원 · 전체 (단원 값이 없으면 정답 하나)
  int get _cardCount => widget.unitProgress == null ? 1 : 3;

  bool get _isUnitCompleted => widget.unitProgress?.isCompletedNow ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isStarted) return;
    _isStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTick() {
    final elapsed = _timeline.total * _controller.value;
    for (var index = 0; index < widget.questionCount; index++) {
      if (elapsed >= _timeline.stepAt(index) && _playedHapticSteps.add(index)) {
        // 뒤로 갈수록 세게
        if (index < widget.questionCount ~/ 2) {
          PassqlHaptics.playLight();
        } else {
          PassqlHaptics.playCorrectAnswer();
        }
      }
    }
    if (elapsed >= _timeline.checkDoneAt && _playedHapticSteps.add(-1)) {
      PassqlHaptics.playCorrectAnswer();
    }
    for (var index = 0; index < _cardCount; index++) {
      if (elapsed >= _timeline.cardAt(index) &&
          _playedHapticSteps.add(100 + index)) {
        PassqlHaptics.playLight();
      }
    }
    // 제목이 뜨는 순간 원에서 빛이 화면 끝까지 번지고 원 위로 빛줄기가 스침.
    // 단원 끝이면 거기에 폭죽 + 가장 센 진동 (큰 연출은 드문 순간에만)
    if (elapsed >= _timeline.headlineAt && _playedHapticSteps.add(-2)) {
      _measureGlowCenter();
      _glowController.forward(from: 0);
      if (_isUnitCompleted) {
        PassqlHaptics.playWrongAnswer();
        _confettiController.forward(from: 0);
      }
    }
  }

  /// 원 가운데를 점수판 층 기준 좌표로 잼 (원은 움직이지 않아 시작 때 한 번이면 됨)
  void _measureGlowCenter() {
    final layer = _layerKey.currentContext?.findRenderObject() as RenderBox?;
    final ring = _ringKey.currentContext?.findRenderObject() as RenderBox?;
    if (layer == null || ring == null) return;
    _glowCenter = ring.localToGlobal(
      ring.size.center(Offset.zero),
      ancestor: layer,
    );
  }

  void _skipToEnd() {
    if (_controller.isCompleted) return;
    _controller.value = 1;
  }

  /// 닫고 나서 동작 (뒤 결과 화면이 그 동작을 이어받음)
  void _closeThen(VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final unit = widget.unitProgress;
    final nextUnit = unit?.nextUnitLabel;
    final total = widget.questionCount;
    return Scaffold(
      // 카드 색 바탕(흰 판) 위에 색 테두리 카드가 읽히도록 (회색 바탕은 카드 흰색과 겹침)
      backgroundColor: colors.card,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _skipToEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _controller,
            _confettiController,
            _glowController,
          ]),
          builder: (context, _) {
            final elapsed = _timeline.total * _controller.value;
            // 고리는 문제마다 1/총 만큼 차오르고 숫자도 같이 오름
            var filled = 0.0;
            for (var index = 0; index < total; index++) {
              filled += PassqlMotion.curve.transform(
                _PerfectTimeline.progressBetween(
                  elapsed,
                  _timeline.stepAt(index),
                  _timeline.stepAt(index) + PassqlMotion.conceptResultFill,
                ),
              );
            }
            final diskRaw = _PerfectTimeline.progressBetween(
              elapsed,
              _timeline.stepsEndAt,
              _timeline.diskEndAt,
            );
            final diskProgress = PassqlMotion.springCurve.transform(diskRaw);
            // 한 문제 맞힐 때마다 고리가 한 단계 커지고, 그 순간 잠깐 더 부풀었다 돌아옴
            var stepBump = 0.0;
            for (var index = 0; index < total; index++) {
              final p = _PerfectTimeline.progressBetween(
                elapsed,
                _timeline.stepAt(index),
                _timeline.stepAt(index) + PassqlMotion.conceptResultFill,
              );
              stepBump += _stepBumpScale * (1 - (2 * p - 1).abs());
            }
            final grow =
                _ringStartScale +
                (1 - _ringStartScale) * (total == 0 ? 1 : filled / total);
            // 원이 다 차는 순간 고리 전체가 한 번 살짝 커졌다 돌아옴 (0 > 1 > 0)
            final bounce =
                grow + stepBump + _bounceScale * (1 - (2 * diskRaw - 1).abs());
            final checkProgress = PassqlMotion.curve.transform(
              _PerfectTimeline.progressBetween(
                elapsed,
                _timeline.diskEndAt,
                _timeline.checkDoneAt,
              ),
            );
            // 빛줄기는 빛이 번지기 시작하고 조금 뒤 원을 한 번 스침
            final shineProgress = (_glowController.value / _shineEndFraction)
                .clamp(0.0, 1.0);
            final isHeadlineVisible = elapsed >= _timeline.headlineAt;
            final isButtonsVisible = elapsed >= _timeline.buttonsAt;
            final isRolled = elapsed >= _timeline.cardAt(1);
            final headline = _isUnitCompleted && unit != null
                ? '${unit.shortLabel}을 끝냈어요'
                : '완벽해요';
            // 위계: 맨 위 무엇을 공부했나(단원 · 개념 이름) > 결과(원·완벽해요·몇 문제) > 지표 > 버튼
            final subtitle = _isUnitCompleted && unit != null
                ? '개념 ${unit.total}개를 모두 끝냈어요'
                : '$total문제 모두 정답';
            return Stack(
              key: _layerKey,
              children: [
                // 맨 아래: 원에서 화면 끝까지 번지는 빛 (글자·카드 뒤)
                Positioned.fill(
                  child: ConceptGlow(
                    progress: _glowController.value,
                    center: _glowCenter,
                    startRadius: PassqlSize.scoreRing / 2,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        // 상단 바가 없어 위 여백을 조금 둠 (상태 표시줄에 붙어 보이지 않게)
                        padding: const EdgeInsets.fromLTRB(
                          PassqlSpacing.xl,
                          PassqlSpacing.xl,
                          PassqlSpacing.xl,
                          0,
                        ),
                        child: Column(
                          children: [
                            if (unit != null)
                              Text(
                                unit.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PassqlTypography.footnote.copyWith(
                                  color: colors.secondaryLabel,
                                ),
                              ),
                            const SizedBox(height: PassqlSpacing.xxs),
                            Text(
                              widget.conceptTitle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: PassqlTypography.title3.copyWith(
                                color: colors.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        // 가운데보다 살짝 위 (아래 카드·버튼과 숨 쉴 간격)
                        child: Align(
                          alignment: const Alignment(0, _heroVerticalBias),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Semantics(
                                label: '$total문제 모두 맞힘',
                                excludeSemantics: true,
                                child: Stack(
                                  key: _ringKey,
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.scale(
                                      scale: bounce,
                                      child: ConceptResultRing(
                                        filledFraction: total == 0
                                            ? 0
                                            : filled / total,
                                        diskProgress: diskProgress,
                                        checkProgress: checkProgress,
                                        centerLabel: '${filled.round()}/$total',
                                        size: PassqlSize.scoreRing,
                                        stroke: PassqlSize.scoreRingStroke,
                                        centerStyle:
                                            PassqlTypography.scoreNumber,
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
                              _FadeUp(
                                isVisible: isHeadlineVisible,
                                child: Column(
                                  children: [
                                    Text(
                                      headline,
                                      textAlign: TextAlign.center,
                                      style: PassqlTypography.title1.copyWith(
                                        color: colors.label,
                                      ),
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
                                        style: PassqlTypography.body.copyWith(
                                          color: colors.label,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: PassqlSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: '정답',
                                value: total,
                                total: total,
                                pop: _timeline.cardPop(elapsed, 0),
                              ),
                            ),
                            if (unit != null) ...[
                              const SizedBox(width: PassqlSpacing.xs),
                              Expanded(
                                child: _StatCard(
                                  title: unit.shortLabel,
                                  value: isRolled
                                      ? unit.solvedCount
                                      : unit.solvedCountBefore,
                                  total: unit.total,
                                  pop: _timeline.cardPop(elapsed, 1),
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
                                  pop: _timeline.cardPop(elapsed, 2),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _FadeUp(
                        isVisible: isButtonsVisible,
                        child: IgnorePointer(
                          ignoring: !isButtonsVisible,
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
                                _isUnitCompleted && nextUnit != null
                                    ? PassqlButton(
                                        label: '$nextUnit 시작하기',
                                        onPressed: () => _closeThen(
                                          widget.onNextUnitPressed ??
                                              widget.onFinished,
                                        ),
                                      )
                                    : PassqlButton(
                                        label: widget.finishLabel,
                                        onPressed: () =>
                                            _closeThen(widget.onFinished),
                                      ),
                                PassqlButton(
                                  label: '다시 풀기',
                                  variant: PassqlButtonVariant.plain,
                                  onPressed: () => _closeThen(widget.onRestart),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: ConceptConfetti(progress: _confettiController.value),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 연출 시각표: 문제 칸 > 원·체크 > 제목 > 카드 n장 > 버튼
class _PerfectTimeline {
  _PerfectTimeline({required this.questionCount, required this.cardCount});

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

/// 아래에서 살짝 올라오며 나타남
class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.isVisible, required this.child});

  static const double _riseFraction = 0.2;

  final bool isVisible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return AnimatedSlide(
      offset: Offset(0, isVisible ? 0 : _riseFraction),
      duration: duration,
      curve: PassqlMotion.curve,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: duration,
        child: child,
      ),
    );
  }
}
