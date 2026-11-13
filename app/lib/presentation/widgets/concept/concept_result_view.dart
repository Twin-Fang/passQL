import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_perfect_page.dart';
import 'concept_result_action_bar.dart';
import 'concept_result_appear_once.dart';
import 'concept_result_head_delegate.dart';
import 'concept_result_section_title.dart';
import 'concept_result_timeline.dart';
import 'concept_unit_progress.dart';
import 'concept_unit_row.dart';
import 'concept_wrong_question_row.dart';

/// 개념 풀기 결과 (#764): 머리(한 줄 제목 + 작은 고리) > 다시 볼 문제 목록(줄을 누르면 그 자리에서 풀이) > 단원 칸 막대 > 실전 문제 줄.
/// 연출: 문제마다 고리 한 칸(진동) > 제목 > 줄 차례로 > 단원 +1·칸 하나 튐 > 버튼. 다 맞히면 고리가 원·체크로 끝.
/// 단원을 다 끝낸 순간에만 제목이 "N단원을 끝냈어요"로 바뀌고 가장 센 진동. 스크롤하면 머리가 접혀 제목 옆에 작은 고리만 남음.
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
  late final ConceptResultTimeline _timeline = ConceptResultTimeline(
    questionCount: widget.questions.length,
    isPerfect: _wrongCount == 0,
    isUnitCompleted: widget.unitProgress?.isCompletedNow ?? false,
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _timeline.total,
  )..addListener(_onTick);

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
      // 동작 줄이기: 단계·진동 없이 끝 화면
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
    super.dispose();
  }

  /// 시간에 맞춰 진동 (한 번씩만)
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
    // 단원 끝: 제목이 바뀌는 순간 가장 센 진동 (63개마다가 아니라 단원마다 한 번)
    if (_timeline.isUnitCompleted &&
        elapsed >= _timeline.unitRollAt &&
        _playedHapticSteps.add(-3)) {
      PassqlHaptics.playWrongAnswer();
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

  /// 화면을 누르면 연출 끝으로
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
      animation: _controller,
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
                        delegate: ConceptResultHeadDelegate(
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
                              ConceptResultAppearOnce(
                                isVisible: isHeadlineVisible,
                                child: ConceptResultSectionTitle(
                                  title: '다시 볼 문제',
                                  count: wrongIndexes.length,
                                ),
                              ),
                              for (final (position, index)
                                  in wrongIndexes.indexed) ...[
                                if (position > 0) const ConceptResultHairline(),
                                ConceptResultAppearOnce(
                                  isVisible:
                                      elapsed >= _timeline.rowAt(position),
                                  child: _buildWrongRow(index),
                                ),
                              ],
                            ],
                            if (unit != null) ...[
                              const SizedBox(height: PassqlSpacing.xl),
                              ConceptUnitRow(
                                unit: unit,
                                isPlusVisible:
                                    _hasUnitIncrease &&
                                    elapsed >= _timeline.unitPlusAt &&
                                    elapsed < _timeline.unitRollAt,
                                isRolled:
                                    !_hasUnitIncrease ||
                                    elapsed >= _timeline.unitRollAt,
                                // 새로 찬 칸이 한 번 커졌다 돌아오는 진행(0 > 1)
                                pulse: ConceptResultTimeline.progressBetween(
                                  elapsed,
                                  _timeline.unitRollAt,
                                  _timeline.unitRollAt +
                                      PassqlMotion.emphasized,
                                ),
                              ),
                            ],
                            if (hasRelatedQuestions) ...[
                              const SizedBox(height: PassqlSpacing.xs),
                              ConceptResultAppearOnce(
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
            ConceptResultActionBar(
              isVisible: isButtonsVisible,
              hasWrongAnswer: _wrongCount > 0,
              nextUnitLabel: _timeline.isUnitCompleted ? nextUnit : null,
              finishLabel: widget.finishLabel,
              onRestartWrong: widget.onRestartWrong,
              onRestart: widget.onRestart,
              onNextUnitPressed: widget.onNextUnitPressed,
              onFinished: widget.onFinished,
            ),
          ],
        );
        return content;
      },
    );
  }

  Widget _buildWrongRow(int index) {
    final question = widget.questions[index];
    final result = widget.resultByQuestion[question.questionUuid]!;
    return ConceptWrongQuestionRow(
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
