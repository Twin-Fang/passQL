import 'package:flutter/cupertino.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_answer_review_sheet.dart';
import 'concept_confetti.dart';
import 'concept_result_ring.dart';

/// 결과 화면 단원 줄 값: "N단원 · 이름", 이 개념을 열었을 때와 지금의 끝낸 개념 수, 단원 개념 수
class ConceptUnitProgress {
  const ConceptUnitProgress({
    required this.label,
    required this.solvedCountBefore,
    required this.solvedCount,
    required this.total,
  });

  final String label;
  final int solvedCountBefore;
  final int solvedCount;
  final int total;
}

/// 개념 풀기 결과 (#764): 고리 > 한 줄 제목 > 문제 칩 > 단원 줄 > 실전 문제 줄 > 하단 버튼.
/// 약 3초 연출: 문제마다 고리가 한 칸씩(진동) > 다 맞히면 원·체크·폭죽 > 단원 +1·숫자 굴림 > 버튼 등장.
/// 화면을 누르면 끝으로 건너뛰고, 동작 줄이기면 처음부터 끝 화면만
class ConceptResultView extends StatefulWidget {
  const ConceptResultView({
    super.key,
    required this.questions,
    required this.resultByQuestion,
    required this.selectedKeyByQuestion,
    required this.unitProgress,
    required this.rereadLabelByAnchor,
    required this.relatedQuestionCount,
    required this.onRelatedQuestionsPressed,
    required this.finishLabel,
    required this.onFinished,
    required this.onRestart,
    required this.onRestartWrong,
    required this.onReread,
  });

  final List<ConceptCheckQuestionResponse> questions;
  final Map<String, ConceptCheckAnswerResponse> resultByQuestion;
  final Map<String, String> selectedKeyByQuestion;
  final ConceptUnitProgress? unitProgress;

  /// 다시 읽기 버튼에 붙일 문단 이름 ("4. SQL 명령어의 종류")
  final Map<String, String> rereadLabelByAnchor;
  final int relatedQuestionCount;
  final VoidCallback? onRelatedQuestionsPressed;
  final String finishLabel;
  final VoidCallback onFinished;
  final VoidCallback onRestart;
  final VoidCallback onRestartWrong;
  final ValueChanged<String> onReread;

  @override
  State<ConceptResultView> createState() => _ConceptResultViewState();
}

class _ConceptResultViewState extends State<ConceptResultView>
    with TickerProviderStateMixin {
  late final _ResultTimeline _timeline = _ResultTimeline(
    questionCount: widget.questions.length,
    isPerfect: _wrongCount == 0,
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _timeline.total,
  )..addListener(_onTick);
  late final AnimationController _confettiController = AnimationController(
    vsync: this,
    duration: PassqlMotion.confetti,
  );

  // 이미 울린 진동 단계 (프레임마다 같은 진동을 다시 울리지 않게)
  final Set<int> _playedHapticSteps = {};
  bool _isStarted = false;

  bool _isCorrectAt(int index) =>
      widget
          .resultByQuestion[widget.questions[index].questionUuid]
          ?.isCorrect ==
      true;

  int get _correctCount => [
    for (var index = 0; index < widget.questions.length; index++)
      if (_isCorrectAt(index)) index,
  ].length;

  int get _wrongCount => widget.questions.length - _correctCount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isStarted) return;
    _isStarted = true;
    if (PassqlMotion.isReduced(context)) {
      // 동작 줄이기: 단계·폭죽·진동 없이 끝 화면
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 시간에 맞춰 진동·폭죽 시작 (한 번씩만)
  void _onTick() {
    final elapsed = _timeline.total * _controller.value;
    for (var index = 0; index < widget.questions.length; index++) {
      if (elapsed >= _timeline.stepAt(index) && _playedHapticSteps.add(index)) {
        _playStepHaptic(index);
      }
    }
    if (_timeline.isPerfect) {
      if (elapsed >= _timeline.checkDoneAt && _playedHapticSteps.add(-1)) {
        PassqlHaptics.playWrongAnswer();
        _confettiController.forward(from: 0);
      }
    } else if (elapsed >= _timeline.stepsEndAt && _playedHapticSteps.add(-1)) {
      PassqlHaptics.playCorrectAnswer();
    }
    if (_hasUnitIncrease &&
        elapsed >= _timeline.unitRollAt &&
        _playedHapticSteps.add(-2)) {
      PassqlHaptics.playLight();
    }
  }

  /// 문제 칸 진동: 맞으면 가볍게 > 뒤로 갈수록 중간, 틀리면 다른 느낌(선택 틱)
  void _playStepHaptic(int index) {
    if (!_isCorrectAt(index)) {
      PassqlHaptics.playSelection();
    } else if (index < widget.questions.length ~/ 2) {
      PassqlHaptics.playLight();
    } else {
      PassqlHaptics.playCorrectAnswer();
    }
  }

  bool get _hasUnitIncrease {
    final unit = widget.unitProgress;
    return unit != null && unit.solvedCount > unit.solvedCountBefore;
  }

  /// 화면을 누르면 연출 끝으로 (폭죽은 남은 만큼 그대로)
  void _skipToEnd() {
    if (_controller.isCompleted) return;
    _controller.value = 1;
  }

  void _openReview(int index) {
    final question = widget.questions[index];
    final result = widget.resultByQuestion[question.questionUuid];
    if (result == null) return;
    showConceptAnswerReviewSheet(
      context,
      order: index + 1,
      question: question,
      result: result,
      selectedKey: widget.selectedKeyByQuestion[question.questionUuid],
      rereadLabel: widget.rereadLabelByAnchor[result.rereadAnchor],
      onReread: () => widget.onReread(result.rereadAnchor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final hasRelatedQuestions =
        widget.relatedQuestionCount > 0 &&
        widget.onRelatedQuestionsPressed != null;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _confettiController]),
      builder: (context, _) {
        final elapsed = _timeline.total * _controller.value;
        final isButtonsVisible = elapsed >= _timeline.buttonsAt;
        final isHeadlineVisible = elapsed >= _timeline.headlineAt;
        return Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _skipToEnd,
                      child: ListView(
                        padding: const EdgeInsets.only(
                          bottom: PassqlSpacing.xxl,
                        ),
                        children: [
                          PassqlSection(
                            padding: const EdgeInsets.fromLTRB(
                              PassqlSpacing.md,
                              PassqlSpacing.xl,
                              PassqlSpacing.md,
                              PassqlSpacing.lg,
                            ),
                            child: _ScoreBlock(
                              timeline: _timeline,
                              elapsed: elapsed,
                              correctFlags: [
                                for (var index = 0; index < total; index++)
                                  _isCorrectAt(index),
                              ],
                              correctCount: _correctCount,
                              wrongCount: _wrongCount,
                              isHeadlineVisible: isHeadlineVisible,
                              onChipTap: _openReview,
                            ),
                          ),
                          if (widget.unitProgress case final unit?) ...[
                            const PassqlSectionGap(),
                            _UnitProgressSection(
                              unit: unit,
                              isPlusVisible:
                                  _hasUnitIncrease &&
                                  elapsed >= _timeline.unitPlusAt &&
                                  elapsed < _timeline.unitRollAt,
                              isRolled:
                                  !_hasUnitIncrease ||
                                  elapsed >= _timeline.unitRollAt,
                            ),
                          ],
                          if (hasRelatedQuestions) ...[
                            const PassqlSectionGap(),
                            _AppearOnce(
                              isVisible: isButtonsVisible,
                              child: PassqlSection(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: PassqlSpacing.md,
                                  vertical: PassqlSpacing.xxs,
                                ),
                                child: PassqlListRow(
                                  hasHorizontalPadding: false,
                                  title:
                                      '실전 문제 ${widget.relatedQuestionCount}개 더 풀기',
                                  hasChevron: true,
                                  onTap: isButtonsVisible
                                      ? widget.onRelatedQuestionsPressed
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ConceptConfetti(progress: _confettiController.value),
                  ),
                ],
              ),
            ),
            // 버튼은 연출 끝에 아래에서 올라옴 (그 전에는 누를 수 없음)
            _AppearOnce(
              isVisible: isButtonsVisible,
              child: IgnorePointer(
                ignoring: !isButtonsVisible,
                child: PassqlBottomActionBar(
                  actions: [
                    _wrongCount > 0
                        ? PassqlButton(
                            label: '틀린 $_wrongCount문제 다시 풀기',
                            variant: PassqlButtonVariant.tinted,
                            onPressed: widget.onRestartWrong,
                          )
                        : PassqlButton(
                            label: '다시 풀기',
                            variant: PassqlButtonVariant.tinted,
                            onPressed: widget.onRestart,
                          ),
                    PassqlButton(
                      label: widget.finishLabel,
                      onPressed: widget.onFinished,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 연출 시각표 (문제 수·다 맞힘 여부로 계산). 단위는 Duration
class _ResultTimeline {
  _ResultTimeline({required this.questionCount, required this.isPerfect});

  final int questionCount;
  final bool isPerfect;

  Duration stepAt(int index) =>
      PassqlMotion.conceptResultStartDelay +
      PassqlMotion.conceptResultStep * index;

  Duration get stepsEndAt =>
      stepAt(questionCount - 1) + PassqlMotion.conceptResultFill;

  Duration get diskEndAt => stepsEndAt + PassqlMotion.conceptResultDiskFill;

  Duration get checkDoneAt => diskEndAt + PassqlMotion.conceptResultCheckDraw;

  Duration get headlineAt => isPerfect ? checkDoneAt : stepsEndAt;

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

/// 고리 + 한 줄 제목 + 문제 칩. 스크린리더는 결과 한 문장으로 읽음
class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.timeline,
    required this.elapsed,
    required this.correctFlags,
    required this.correctCount,
    required this.wrongCount,
    required this.isHeadlineVisible,
    required this.onChipTap,
  });

  // 마지막 칸이 찬 순간 숫자가 커지는 최대 배율
  static const double _popScale = 1.12;

  final _ResultTimeline timeline;
  final Duration elapsed;
  final List<bool> correctFlags;
  final int correctCount;
  final int wrongCount;
  final bool isHeadlineVisible;
  final ValueChanged<int> onChipTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final total = correctFlags.length;
    // 맞힌 문제는 자기 칸 시각에 1/총 만큼 차오름 (틀린 문제는 멈춤)
    var filled = 0.0;
    for (var index = 0; index < total; index++) {
      if (!correctFlags[index]) continue;
      filled += PassqlMotion.curve.transform(
        _ResultTimeline.progressBetween(
          elapsed,
          timeline.stepAt(index),
          timeline.stepAt(index) + PassqlMotion.conceptResultFill,
        ),
      );
    }
    final isPerfect = timeline.isPerfect;
    final diskProgress = isPerfect
        ? PassqlMotion.springCurve.transform(
            _ResultTimeline.progressBetween(
              elapsed,
              timeline.stepsEndAt,
              timeline.diskEndAt,
            ),
          )
        : 0.0;
    final checkProgress = isPerfect
        ? PassqlMotion.curve.transform(
            _ResultTimeline.progressBetween(
              elapsed,
              timeline.diskEndAt,
              timeline.checkDoneAt,
            ),
          )
        : 0.0;
    // 마지막 칸 직후 짧게 커졌다 돌아옴 (0 > 1 > 0)
    final pop = _ResultTimeline.progressBetween(
      elapsed,
      timeline.stepsEndAt,
      timeline.stepsEndAt + PassqlMotion.fast,
    );
    final centerScale = 1 + (_popScale - 1) * (1 - (2 * pop - 1).abs());
    final headline = switch (wrongCount) {
      0 => '이 개념은 확실히 잡았어요',
      1 => '한 문제만 다시 보면 돼요',
      _ when wrongCount == total => '다시 읽고 풀어 봐요',
      _ => '$wrongCount문제만 다시 보면 돼요',
    };
    final wrongOrders = [
      for (var index = 0; index < total; index++)
        if (!correctFlags[index]) '${index + 1}번',
    ];
    final summary = wrongOrders.isEmpty
        ? '$total문제 중 $correctCount문제 맞힘'
        : '$total문제 중 $correctCount문제 맞힘, ${wrongOrders.join(', ')} 틀림';
    return Column(
      children: [
        Semantics(
          label: summary,
          excludeSemantics: true,
          child: ConceptResultRing(
            filledFraction: total == 0 ? 0 : filled / total,
            diskProgress: diskProgress,
            checkProgress: checkProgress,
            centerLabel: '${filled.round()}/$total',
            centerScale: centerScale,
          ),
        ),
        const SizedBox(height: PassqlSpacing.md),
        AnimatedOpacity(
          opacity: isHeadlineVisible ? 1 : 0,
          duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
          child: Text(
            headline,
            textAlign: TextAlign.center,
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(height: PassqlSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: PassqlSpacing.xs,
          runSpacing: PassqlSpacing.xs,
          children: [
            for (var index = 0; index < total; index++)
              _QuestionChip(
                order: index + 1,
                isRevealed: elapsed >= timeline.stepAt(index),
                isCorrect: correctFlags[index],
                // 연출 끝에 틀린 칩이 한 번 통 튀어 누를 수 있음을 알림
                bounce: correctFlags[index]
                    ? 0
                    : _ResultTimeline.progressBetween(
                        elapsed,
                        timeline.headlineAt,
                        timeline.headlineAt + PassqlMotion.emphasized,
                      ),
                onTap: () => onChipTap(index),
              ),
          ],
        ),
      ],
    );
  }
}

/// 문제 칩: 차례 전엔 회색 번호, 맞음 초록 ✓, 틀림 빨강 ✕ + › (누르면 풀이)
class _QuestionChip extends StatelessWidget {
  const _QuestionChip({
    required this.order,
    required this.isRevealed,
    required this.isCorrect,
    required this.bounce,
    required this.onTap,
  });

  // 칩 높이 (누르는 영역은 PassqlPressable 최소 44 로 넓힘)
  static const double _height = 32;
  // 틀린 칩이 튀어 오르는 높이
  static const double _bounceHeight = 6;

  final int order;
  final bool isRevealed;
  final bool isCorrect;
  final double bounce;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (background, foreground) = !isRevealed
        ? (colors.fill, colors.secondaryLabel)
        : isCorrect
        ? (colors.correctTint, colors.correctText)
        : (colors.wrongTint, colors.wrongText);
    final lift = -_bounceHeight * (1 - (2 * bounce - 1).abs());
    final chip = AnimatedContainer(
      duration: PassqlMotion.durationOf(context, PassqlMotion.fast),
      curve: PassqlMotion.curve,
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isRevealed) ...[
            Icon(
              isCorrect ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
              size: PassqlIconSize.xxs,
              color: foreground,
            ),
            const SizedBox(width: PassqlSpacing.xxs),
          ],
          Text(
            '$order',
            style: PassqlTypography.subheadlineSemibold.copyWith(
              color: foreground,
              fontFeatures: PassqlTypography.tabular,
            ),
          ),
          if (isRevealed && !isCorrect)
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xxs,
              color: foreground,
            ),
        ],
      ),
    );
    return Transform.translate(
      offset: Offset(0, lift),
      child: PassqlPressable(
        hasMinimumTouchTarget: true,
        semanticLabel: '$order번 ${isCorrect ? '맞음' : '틀림'}, 풀이 보기',
        onTap: isRevealed ? onTap : null,
        child: chip,
      ),
    );
  }
}

/// 단원 줄: "N단원 · 이름" > 큰 숫자 n / 총 개념 + 막대.
/// 이번에 끝냈으면 숫자 오른쪽에 보라 글자 +1 이 떠오른 뒤, 숫자가 굴러 바뀌고 막대가 참
class _UnitProgressSection extends StatelessWidget {
  const _UnitProgressSection({
    required this.unit,
    required this.isPlusVisible,
    required this.isRolled,
  });

  // +1 이 떠오르는 거리 (자기 높이 비율)
  static const double _plusRiseFraction = 0.3;

  final ConceptUnitProgress unit;
  final bool isPlusVisible;
  final bool isRolled;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final shownCount = isRolled ? unit.solvedCount : unit.solvedCountBefore;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return PassqlSection(
      child: Semantics(
        label: '${unit.label}, 개념 ${unit.total}개 중 ${unit.solvedCount}개 끝냄',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              unit.label,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.hairlineGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // 숫자 굴림: 이전 숫자는 위로 밀려나고 새 숫자가 아래에서 올라옴
                ClipRect(
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: PassqlMotion.curve,
                    switchOutCurve: PassqlMotion.curve,
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == ValueKey<int>(shownCount);
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, isIncoming ? 1 : -1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      '$shownCount',
                      key: ValueKey<int>(shownCount),
                      style: PassqlTypography.title1.copyWith(
                        color: colors.label,
                        fontFeatures: PassqlTypography.tabular,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                Text(
                  '/ ${unit.total} 개념',
                  style: PassqlTypography.title3.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                AnimatedSlide(
                  offset: Offset(0, isPlusVisible ? -_plusRiseFraction : 0),
                  duration: duration,
                  curve: PassqlMotion.springCurve,
                  child: AnimatedOpacity(
                    opacity: isPlusVisible ? 1 : 0,
                    duration: duration,
                    child: Text(
                      '+${unit.solvedCount - unit.solvedCountBefore}',
                      style: PassqlTypography.title3.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
            PassqlProgressBar(
              value: unit.total == 0 ? 0 : shownCount / unit.total,
            ),
          ],
        ),
      ),
    );
  }
}

/// 처음 한 번 아래에서 올라오며 나타남 (버튼·실전 문제 줄)
class _AppearOnce extends StatelessWidget {
  const _AppearOnce({required this.isVisible, required this.child});

  // 올라오는 거리 (자기 높이 비율)
  static const double _riseFraction = 0.3;

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
