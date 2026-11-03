import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_unit_progress.dart';
import '../../design/design.dart';
import 'concept_perfect_hero.dart';
import 'concept_perfect_stat_card.dart';
import 'concept_result_timeline.dart';
import 'concept_rise_in.dart';

/// 다 맞혔을 때만 뜨는 전체 화면 점수판 (#764, 듀오링고 레슨 완료 참고).
/// 큰 고리가 한 칸씩 차며 숫자가 오르고 > 초록 원·체크 > 제목 > 지표 카드 3장이 하나씩 톡 > 버튼.
/// 체크가 그려지면 원에서 보라 빛이 화면 끝까지 번진다. 단원까지 끝냈으면 제목·단원 카드·버튼이 단원 끝으로 바뀐다.
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
  late final ConceptPerfectTimeline _timeline = ConceptPerfectTimeline(
    questionCount: widget.questionCount,
    cardCount: _cardCount,
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _timeline.total,
  )..addListener(_onTick);
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
    // 단원 끝이면 가장 센 진동을 더함
    if (elapsed >= _timeline.headlineAt && _playedHapticSteps.add(-2)) {
      _measureGlowCenter();
      _glowController.forward(from: 0);
      if (_isUnitCompleted) PassqlHaptics.playWrongAnswer();
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
    return Scaffold(
      // 카드 색 바탕(흰 판) 위에 색 테두리 카드가 읽히도록 (회색 바탕은 카드 흰색과 겹침)
      backgroundColor: context.passqlColors.card,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _skipToEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([_controller, _glowController]),
          builder: (context, _) {
            final elapsed = _timeline.total * _controller.value;
            return Stack(
              key: _layerKey,
              children: [
                // 맨 아래: 원에서 화면 끝까지 번지는 빛 (글자·카드 뒤)
                Positioned.fill(
                  child: PassqlGlow(
                    progress: _glowController.value,
                    center: _glowCenter,
                    startRadius: PassqlSize.scoreRing / 2,
                  ),
                ),
                // 위계: 맨 위 무엇을 공부했나(단원 · 개념 이름) > 결과(원·완벽해요·몇 문제) > 지표 > 버튼
                SafeArea(
                  child: Column(
                    children: [
                      _buildStudiedTitle(context),
                      Expanded(
                        // 가운데보다 살짝 위 (아래 카드·버튼과 숨 쉴 간격)
                        child: Align(
                          alignment: const Alignment(0, _heroVerticalBias),
                          child: ConceptPerfectHero(
                            ringKey: _ringKey,
                            timeline: _timeline,
                            elapsed: elapsed,
                            questionCount: widget.questionCount,
                            unitProgress: widget.unitProgress,
                            isUnitCompleted: _isUnitCompleted,
                            // 빛줄기는 빛이 번지기 시작하고 조금 뒤 원을 한 번 스침
                            shineProgress:
                                (_glowController.value / _shineEndFraction)
                                    .clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                      ConceptPerfectStatCardRow(
                        questionCount: widget.questionCount,
                        unitProgress: widget.unitProgress,
                        isRolled: elapsed >= _timeline.cardAt(1),
                        popOfCard: (index) => _timeline.cardPop(elapsed, index),
                      ),
                      _buildActions(elapsed),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 맨 위: "N단원 · 이름"(단원 값 있을 때) > 개념 이름
  Widget _buildStudiedTitle(BuildContext context) {
    final colors = context.passqlColors;
    final unit = widget.unitProgress;
    return Padding(
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
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
        ],
      ),
    );
  }

  /// 아래 버튼: 다음 단원 시작(단원 끝) 또는 끝내기 > 다시 풀기. 연출 끝에 나타나고 그 전에는 누를 수 없음
  Widget _buildActions(Duration elapsed) {
    final nextUnit = widget.unitProgress?.nextUnitLabel;
    final isButtonsVisible = elapsed >= _timeline.buttonsAt;
    return ConceptRiseIn(
      isVisible: isButtonsVisible,
      riseFraction: ConceptRiseIn.subtleRiseFraction,
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
                        widget.onNextUnitPressed ?? widget.onFinished,
                      ),
                    )
                  : PassqlButton(
                      label: widget.finishLabel,
                      onPressed: () => _closeThen(widget.onFinished),
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
    );
  }
}
