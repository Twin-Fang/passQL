import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';
import 'concept_confetti.dart';
import 'concept_perfect_page.dart';
import 'concept_result_ring.dart';

/// 결과 화면 단원 줄 값: "N단원 · 이름", 이 개념을 열었을 때와 지금의 끝낸 개념 수, 단원 개념 수, 다음 단원 이름
class ConceptUnitProgress {
  const ConceptUnitProgress({
    required this.label,
    required this.solvedCountBefore,
    required this.solvedCount,
    required this.total,
    this.nextUnitLabel,
    this.overallSolvedCount = 0,
    this.overallTotal = 0,
  });

  final String label;
  final int solvedCountBefore;
  final int solvedCount;
  final int total;

  /// 전체 단원의 끝낸 개념 수와 개념 수 (점수판 "전체" 카드)
  final int overallSolvedCount;
  final int overallTotal;

  /// 이 개념을 열었을 때의 전체 끝낸 수 (단원 증가분만큼 되돌림)
  int get overallSolvedCountBefore =>
      overallSolvedCount - (solvedCount - solvedCountBefore);

  /// 다음 단원 짧은 이름 ("3단원"). 없으면 마지막 단원
  final String? nextUnitLabel;

  bool get hasIncrease => solvedCount > solvedCountBefore;

  /// 이번 개념으로 단원을 다 끝냈는가 (단원 끝 한 장을 띄우는 조건)
  bool get isCompletedNow => hasIncrease && total > 0 && solvedCount >= total;

  /// "2단원 · SELECT 기본" > "2단원" (없으면 전체 이름)
  String get shortLabel => label.split(' · ').first;
}

/// 개념 풀기 결과 (#764): 머리(한 줄 제목 + 작은 고리) > 다시 볼 문제 목록(줄을 누르면 그 자리에서 풀이) > 단원 칸 막대 > 실전 문제 줄.
/// 연출: 문제마다 고리 한 칸(진동) > 제목 > 줄 차례로 > 단원 +1·칸 하나 튐 > 버튼. 다 맞히면 고리가 원·체크로 끝.
/// 단원을 다 끝낸 순간에만 제목이 "N단원을 끝냈어요"로 바뀌며 화면 가득 폭죽. 스크롤하면 머리가 접혀 제목 옆에 작은 고리만 남음.
/// 화면을 누르면 끝으로 건너뛰고, 동작 줄이기면 처음부터 끝 화면만
class ConceptResultView extends StatefulWidget {
  const ConceptResultView({
    super.key,
    required this.questions,
    required this.resultByQuestion,
    required this.selectedKeyByQuestion,
    required this.unitProgress,
    required this.rereadLabelByAnchor,
    required this.rereadAnchors,
    required this.relatedQuestionCount,
    required this.onRelatedQuestionsPressed,
    required this.finishLabel,
    required this.onFinished,
    required this.onRestart,
    required this.onRestartWrong,
    required this.onReread,
    this.onNextUnitPressed,
    required this.conceptTitle,
  });

  final List<ConceptCheckQuestionResponse> questions;
  final Map<String, ConceptCheckAnswerResponse> resultByQuestion;
  final Map<String, String> selectedKeyByQuestion;
  final ConceptUnitProgress? unitProgress;

  /// 다시 읽기 글자에 붙일 문단 이름 ("4. SQL 명령어의 종류")
  final Map<String, String> rereadLabelByAnchor;

  /// 이미 다시 읽고 돌아온 문단 (그 문제 줄에 읽음 표시)
  final Set<String> rereadAnchors;
  final int relatedQuestionCount;
  final VoidCallback? onRelatedQuestionsPressed;
  final String finishLabel;
  final VoidCallback onFinished;
  final VoidCallback onRestart;
  final VoidCallback onRestartWrong;
  final ValueChanged<String> onReread;

  /// 단원을 다 끝냈을 때 오른쪽 버튼 "다음 단원 시작하기" (없으면 [onFinished])
  final VoidCallback? onNextUnitPressed;

  /// 점수판 부제에 쓸 개념 이름
  final String conceptTitle;

  @override
  State<ConceptResultView> createState() => _ConceptResultViewState();
}

class _ConceptResultViewState extends State<ConceptResultView>
    with TickerProviderStateMixin {
  late final _ResultTimeline _timeline = _ResultTimeline(
    questionCount: widget.questions.length,
    isPerfect: _wrongCount == 0,
    isUnitCompleted: widget.unitProgress?.isCompletedNow ?? false,
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
  // 다 맞혀 점수판이 대신 연출하는 중이면 이 화면은 소리 없이 끝 상태로
  bool _isSilent = false;
  // 펼친 문제 줄 (한 번에 하나)
  int? _expandedIndex;

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

  List<int> get _wrongIndexes => [
    for (var index = 0; index < widget.questions.length; index++)
      if (!_isCorrectAt(index)) index,
  ];

  bool get _hasUnitIncrease => widget.unitProgress?.hasIncrease ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isStarted) return;
    _isStarted = true;
    if (_wrongCount == 0) {
      // 다 맞힘: 연출은 전체 화면 점수판이 맡고, 뒤에 남는 이 화면은 바로 끝 상태
      _isSilent = true;
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showScoreboard());
      return;
    }
    if (PassqlMotion.isReduced(context)) {
      // 동작 줄이기: 단계·폭죽·진동 없이 끝 화면
      _controller.value = 1;
      return;
    }
    _controller.forward();
  }

  void _showScoreboard() {
    if (!mounted) return;
    ConceptPerfectPage.show(
      context,
      questionCount: widget.questions.length,
      conceptTitle: widget.conceptTitle,
      unitProgress: widget.unitProgress,
      finishLabel: widget.finishLabel,
      onFinished: widget.onFinished,
      onRestart: widget.onRestart,
      onNextUnitPressed: widget.onNextUnitPressed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// 시간에 맞춰 진동·폭죽 시작 (한 번씩만)
  void _onTick() {
    if (_isSilent) return;
    final elapsed = _timeline.total * _controller.value;
    for (var index = 0; index < widget.questions.length; index++) {
      if (elapsed >= _timeline.stepAt(index) && _playedHapticSteps.add(index)) {
        _playStepHaptic(index);
      }
    }
    if (elapsed >= _timeline.headlineAt && _playedHapticSteps.add(-1)) {
      PassqlHaptics.playCorrectAnswer();
    }
    if (_hasUnitIncrease &&
        elapsed >= _timeline.unitRollAt &&
        _playedHapticSteps.add(-2)) {
      PassqlHaptics.playLight();
    }
    // 단원 끝: 제목이 바뀌는 순간 가장 센 진동 + 화면 가득 폭죽 (63개마다가 아니라 단원마다 한 번)
    if (_timeline.isUnitCompleted &&
        elapsed >= _timeline.unitRollAt &&
        _playedHapticSteps.add(-3)) {
      PassqlHaptics.playWrongAnswer();
      _confettiController.forward(from: 0);
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

  /// 화면을 누르면 연출 끝으로 (폭죽은 남은 만큼 그대로)
  void _skipToEnd() {
    if (_controller.isCompleted) return;
    _controller.value = 1;
  }

  void _toggleRow(int index) {
    setState(() => _expandedIndex = _expandedIndex == index ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final total = widget.questions.length;
    final hasRelatedQuestions =
        widget.relatedQuestionCount > 0 &&
        widget.onRelatedQuestionsPressed != null;
    final unit = widget.unitProgress;
    final nextUnit = unit?.nextUnitLabel;
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _confettiController]),
      builder: (context, _) {
        final elapsed = _timeline.total * _controller.value;
        final isButtonsVisible = elapsed >= _timeline.buttonsAt;
        final isHeadlineVisible = elapsed >= _timeline.headlineAt;
        // 단원을 다 끝냈으면 단원 숫자가 바뀌는 순간 제목도 단원 끝으로 바뀜
        final isUnitHeadline =
            _timeline.isUnitCompleted && elapsed >= _timeline.unitRollAt;
        final wrongIndexes = _wrongIndexes;
        final content = Column(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _skipToEnd,
                // 결과 한 장은 회색 띠로 나누지 않고 흰 면 하나에 이어서 둔다
                child: ColoredBox(
                  color: colors.card,
                  child: CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _ResultHeadDelegate(
                          timeline: _timeline,
                          elapsed: elapsed,
                          correctFlags: [
                            for (var index = 0; index < total; index++)
                              _isCorrectAt(index),
                          ],
                          isHeadlineVisible: isHeadlineVisible,
                          unitProgress: unit,
                          isUnitHeadline: isUnitHeadline,
                          backgroundColor: colors.card,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          PassqlSpacing.md,
                          0,
                          PassqlSpacing.md,
                          PassqlSpacing.xxl,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            if (wrongIndexes.isNotEmpty) ...[
                              const SizedBox(height: PassqlSpacing.md),
                              _AppearOnce(
                                isVisible: isHeadlineVisible,
                                child: _SectionTitle(
                                  title: '다시 볼 문제',
                                  count: wrongIndexes.length,
                                ),
                              ),
                              for (final (position, index)
                                  in wrongIndexes.indexed) ...[
                                if (position > 0) const _Hairline(),
                                _AppearOnce(
                                  isVisible:
                                      elapsed >= _timeline.rowAt(position),
                                  child: _buildWrongRow(index),
                                ),
                              ],
                            ],
                            if (unit != null) ...[
                              const SizedBox(height: PassqlSpacing.xl),
                              _UnitRow(
                                unit: unit,
                                isPlusVisible:
                                    _hasUnitIncrease &&
                                    elapsed >= _timeline.unitPlusAt &&
                                    elapsed < _timeline.unitRollAt,
                                isRolled:
                                    !_hasUnitIncrease ||
                                    elapsed >= _timeline.unitRollAt,
                                // 새로 찬 칸이 한 번 커졌다 돌아오는 진행(0 > 1)
                                pulse: _ResultTimeline.progressBetween(
                                  elapsed,
                                  _timeline.unitRollAt,
                                  _timeline.unitRollAt +
                                      PassqlMotion.emphasized,
                                ),
                              ),
                            ],
                            if (hasRelatedQuestions) ...[
                              const SizedBox(height: PassqlSpacing.xs),
                              _AppearOnce(
                                isVisible: isButtonsVisible,
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
                            ],
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 버튼은 연출 끝에 아래에서 올라옴 (그 전에는 누를 수 없음)
            _AppearOnce(
              isVisible: isButtonsVisible,
              child: IgnorePointer(
                ignoring: !isButtonsVisible,
                child: PassqlBottomActionBar(
                  // 버튼 위 내용은 바 뒤로 지나가지 않는 흰 면이라 구분선이 필요 없다
                  hasTopHairline: false,
                  actions: [
                    _wrongCount > 0
                        ? PassqlButton(
                            // 틀린 수는 제목·목록에 이미 있어 버튼은 짧게
                            label: '틀린 문제 풀기',
                            variant: PassqlButtonVariant.tinted,
                            onPressed: widget.onRestartWrong,
                          )
                        : PassqlButton(
                            label: '다시 풀기',
                            variant: PassqlButtonVariant.tinted,
                            onPressed: widget.onRestart,
                          ),
                    // 단원을 다 끝냈으면 다음 단원으로 바로
                    _timeline.isUnitCompleted && nextUnit != null
                        ? PassqlButton(
                            label: '$nextUnit 시작하기',
                            onPressed:
                                widget.onNextUnitPressed ?? widget.onFinished,
                          )
                        : PassqlButton(
                            label: widget.finishLabel,
                            onPressed: widget.onFinished,
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
        if (!_timeline.isUnitCompleted) return content;
        return Stack(
          children: [
            content,
            Positioned.fill(
              child: ConceptConfetti(progress: _confettiController.value),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWrongRow(int index) {
    final question = widget.questions[index];
    final result = widget.resultByQuestion[question.questionUuid]!;
    return _WrongQuestionRow(
      order: index + 1,
      question: question,
      result: result,
      selectedKey: widget.selectedKeyByQuestion[question.questionUuid],
      rereadLabel: widget.rereadLabelByAnchor[result.rereadAnchor],
      isReread: widget.rereadAnchors.contains(result.rereadAnchor),
      isExpanded: _expandedIndex == index,
      onToggle: () => _toggleRow(index),
      onReread: () => widget.onReread(result.rereadAnchor),
    );
  }
}

/// 연출 시각표 (문제 수·다 맞힘·단원 끝 여부로 계산). 단위는 Duration
class _ResultTimeline {
  _ResultTimeline({
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

/// 머리: 왼쪽 큰 제목 + 부제, 오른쪽 작은 고리. 스크롤로 접히면 한 줄 제목 + 아주 작은 고리만 남음
class _ResultHeadDelegate extends SliverPersistentHeaderDelegate {
  _ResultHeadDelegate({
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

  final _ResultTimeline timeline;
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
  bool shouldRebuild(_ResultHeadDelegate oldDelegate) => true;

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

/// 구간 제목: "다시 볼 문제" + 보라 개수
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
      child: Text.rich(
        TextSpan(
          text: '$title ',
          style: PassqlTypography.title3.copyWith(color: colors.label),
          children: [
            TextSpan(
              text: '$count',
              style: TextStyle(
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 줄 사이 머리카락 선 (iOS 목록과 같은 1물리픽셀)
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 0, thickness: 0, color: context.passqlColors.separator);
}

/// 틀린 문제 한 줄: 번호 배지 + 지문 한 줄 + 쉐브론. 누르면 그 자리에서 내 답·정답·풀이·다시 읽기가 펼쳐짐.
/// 다시 읽고 돌아오면 배지가 보라 체크, 아래에 "N. 제목 읽음"
class _WrongQuestionRow extends StatelessWidget {
  const _WrongQuestionRow({
    required this.order,
    required this.question,
    required this.result,
    required this.selectedKey,
    required this.rereadLabel,
    required this.isReread,
    required this.isExpanded,
    required this.onToggle,
    required this.onReread,
  });

  // 번호 배지 지름 (펼친 내용의 왼쪽 들여쓰기 기준)
  static const double _badgeSize = 22;

  final int order;
  final ConceptCheckQuestionResponse question;
  final ConceptCheckAnswerResponse result;
  final String? selectedKey;
  final String? rereadLabel;
  final bool isReread;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onReread;

  String? _bodyOf(String? choiceKey) => question.choices
      .where((choice) => choice.choiceKey == choiceKey)
      .firstOrNull
      ?.body;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    final rereadLabelText = rereadLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlPressable(
          semanticLabel:
              '$order번 ${question.stem}, ${isExpanded ? '풀이 접기' : '풀이 펼치기'}',
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundBadge(
                  size: _badgeSize,
                  background: isReread ? colors.accentTint : colors.wrongTint,
                  foreground: isReread ? colors.accentText : colors.wrongText,
                  child: isReread
                      ? Icon(
                          CupertinoIcons.checkmark,
                          size: PassqlIconSize.xxs,
                          color: colors.accentText,
                        )
                      : Text(
                          '$order',
                          style: PassqlTypography.captionSemibold.copyWith(
                            color: colors.wrongText,
                            fontFeatures: PassqlTypography.tabular,
                          ),
                        ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.stem,
                        maxLines: isExpanded ? null : 1,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                        style:
                            (isExpanded
                                    ? PassqlTypography.subheadlineSemibold
                                    : PassqlTypography.subheadline)
                                .copyWith(color: colors.label),
                      ),
                      if (isReread && rereadLabelText != null)
                        Text(
                          '$rereadLabelText 읽음',
                          style: PassqlTypography.caption.copyWith(
                            color: colors.accentText,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                // 쉐브론: 접힘은 아래(펼쳐진다 예고), 펼침은 위
                AnimatedRotation(
                  turns: isExpanded ? -0.25 : 0.25,
                  duration: duration,
                  curve: PassqlMotion.curve,
                  child: Icon(
                    CupertinoIcons.chevron_forward,
                    size: PassqlIconSize.xs,
                    color: colors.tertiaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: PassqlMotion.curve,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: _badgeSize + PassqlSpacing.sm,
                    bottom: PassqlSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (question.stemSql != null) ...[
                        PassqlCodeBlock(code: question.stemSql!),
                        const SizedBox(height: PassqlSpacing.sm),
                      ],
                      if (selectedKey != null)
                        _AnswerLine(
                          label: '내 답 $selectedKey',
                          body: _bodyOf(selectedKey) ?? '',
                          isCorrect: false,
                        ),
                      const SizedBox(height: PassqlSpacing.xs),
                      _AnswerLine(
                        label: '정답 ${result.correctKey}',
                        body: _bodyOf(result.correctKey) ?? '',
                        isCorrect: true,
                      ),
                      const SizedBox(height: PassqlSpacing.sm),
                      MarkdownLiteText(
                        result.explanation,
                        style: MarkdownLiteStyle.article,
                      ),
                      if (result.rereadAnchor.isNotEmpty) ...[
                        const SizedBox(height: PassqlSpacing.xs),
                        PassqlPressable(
                          hasMinimumTouchTarget: true,
                          onTap: onReread,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.book,
                                size: PassqlIconSize.xs,
                                color: colors.accentText,
                              ),
                              const SizedBox(width: PassqlSpacing.xxs),
                              Flexible(
                                child: Text(
                                  rereadLabelText == null
                                      ? '이 부분 다시 읽기'
                                      : '$rereadLabelText 다시 읽기',
                                  style: PassqlTypography.subheadlineSemibold
                                      .copyWith(color: colors.accentText),
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_forward,
                                size: PassqlIconSize.xxs,
                                color: colors.accentText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// 내 답(빨강 ×) · 정답(초록 ✓) 한 줄: 작은 라벨 + 보기 글
class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.body,
    required this.isCorrect,
  });

  final String label;
  final String body;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final foreground = isCorrect ? colors.correctText : colors.wrongText;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoundBadge(
          size: _WrongQuestionRow._badgeSize,
          background: isCorrect ? colors.correctTint : colors.wrongTint,
          foreground: foreground,
          child: Icon(
            isCorrect ? CupertinoIcons.checkmark : CupertinoIcons.xmark,
            size: PassqlIconSize.xxs,
            color: foreground,
          ),
        ),
        const SizedBox(width: PassqlSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
              Text(
                body,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 작은 원 배지 (번호·×·✓)
class _RoundBadge extends StatelessWidget {
  const _RoundBadge({
    required this.size,
    required this.background,
    required this.foreground,
    required this.child,
  });

  final double size;
  final Color background;
  final Color foreground;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: child,
  );
}

/// 단원 줄: "N단원 · 이름" 과 "n / 총", 아래에 개념 수만큼 칸 막대.
/// 이번에 끝냈으면 +1 이 떠오른 뒤 숫자가 굴러 바뀌고, 새로 찬 칸이 한 번 커졌다 돌아옴
class _UnitRow extends StatelessWidget {
  const _UnitRow({
    required this.unit,
    required this.isPlusVisible,
    required this.isRolled,
    required this.pulse,
  });

  // +1 이 떠오르는 거리 (자기 높이 비율)
  static const double _plusRiseFraction = 0.3;

  final ConceptUnitProgress unit;
  final bool isPlusVisible;
  final bool isRolled;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final shownCount = isRolled ? unit.solvedCount : unit.solvedCountBefore;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.standard);
    return Semantics(
      label: '${unit.label}, 개념 ${unit.total}개 중 ${unit.solvedCount}개 끝냄',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    unit.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
                const SizedBox(width: PassqlSpacing.sm),
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
                      style: PassqlTypography.headline.copyWith(
                        color: colors.accentText,
                        fontFeatures: PassqlTypography.tabular,
                      ),
                    ),
                  ),
                ),
                Text(
                  ' / ${unit.total}',
                  style: PassqlTypography.subheadline.copyWith(
                    color: colors.secondaryLabel,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xxs),
                AnimatedSlide(
                  offset: Offset(0, isPlusVisible ? -_plusRiseFraction : 0),
                  duration: duration,
                  curve: PassqlMotion.springCurve,
                  child: AnimatedOpacity(
                    opacity: isPlusVisible ? 1 : 0,
                    duration: duration,
                    child: Text(
                      '+${unit.solvedCount - unit.solvedCountBefore}',
                      style: PassqlTypography.footnoteSemibold.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xs),
            _SegmentBar(
              total: unit.total,
              filledCount: shownCount,
              pulsingIndex: isRolled && unit.hasIncrease
                  ? unit.solvedCount - 1
                  : null,
              pulse: pulse,
            ),
          ],
        ),
      ),
    );
  }
}

/// 칸 막대: 개념 하나가 칸 하나. 새로 찬 칸은 세로로 한 번 커졌다 돌아옴
class _SegmentBar extends StatelessWidget {
  const _SegmentBar({
    required this.total,
    required this.filledCount,
    required this.pulsingIndex,
    required this.pulse,
  });

  // 칸 사이 간격, 튈 때 최대 세로 배율
  static const double _gap = 3;
  static const double _pulseScale = 1.9;

  final int total;
  final int filledCount;
  final int? pulsingIndex;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final duration = PassqlMotion.durationOf(context, PassqlMotion.fast);
    return Row(
      children: [
        for (var index = 0; index < total; index++) ...[
          if (index > 0) const SizedBox(width: _gap),
          Expanded(
            child: Transform.scale(
              scaleY: index == pulsingIndex
                  ? 1 + (_pulseScale - 1) * (1 - (2 * pulse - 1).abs())
                  : 1,
              child: AnimatedContainer(
                duration: duration,
                curve: PassqlMotion.curve,
                height: PassqlSize.unitSegmentHeight,
                decoration: BoxDecoration(
                  color: index < filledCount ? colors.accent : colors.fill,
                  borderRadius: BorderRadius.circular(PassqlRadius.capsule),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 처음 한 번 아래에서 올라오며 나타남 (제목·줄·버튼)
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
