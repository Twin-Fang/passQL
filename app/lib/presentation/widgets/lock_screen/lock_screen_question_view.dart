import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/choice_explanation_providers.dart';
import '../../providers/lock_screen_question_providers.dart';
import '../ai_explanation/ai_explanation_content.dart';
import '../question/choice_display_label.dart';
import '../question/choice_item_card.dart';
import '../question/execute_result_card.dart';
import '../question/question_sections.dart';
import '../question/sse_loading_widget.dart';
import 'lock_screen_question_actions.dart';

/// 잠금화면 문제 본문 (실제 잠금화면·미리보기 공통): 캡션 > 태그 > 지문 카드 > 보기(탭 = 제출) > 채점 마크·실행 결과·해설
/// 실행형 결과: 정답 실행 결과가 오면 표, 무료라 빠졌으면 생략 (PRO 안내는 해설 한 곳만)
/// 해설: 앱 AI 해설과 같은 규칙 (무료는 판정 > 기본 해설 > 짧게 흐린 상세, 프로는 상세 해설 전체)
/// PRO 잠금 자리 누름은 모두 [onProUnlock] (잠금 엔진에는 구매 시트가 없어 앱을 열어 처리)
/// 메모 층은 바깥 [PassqlMemoScope] 가 있을 때만 동작 (미리보기는 없음)
class LockScreenQuestionView extends ConsumerStatefulWidget {
  const LockScreenQuestionView({
    super.key,
    required this.state,
    required this.onChoiceTap,
    required this.onProUnlock,
    this.onOpenDiscussion,
    this.caption = defaultCaption,
  });

  static const String defaultCaption = '오늘의 잠금 문제';

  final LockScreenQuestionState state;
  final ValueChanged<String> onChoiceTap;
  final VoidCallback onProUnlock;

  /// 채점 뒤 토론 보기 (null 이면 토론·신고 줄 없음: 미리보기)
  final VoidCallback? onOpenDiscussion;
  final String caption;

  @override
  ConsumerState<LockScreenQuestionView> createState() =>
      _LockScreenQuestionViewState();
}

class _LockScreenQuestionViewState
    extends ConsumerState<LockScreenQuestionView> {
  // 무료 응답에서 실행 결과가 빠졌다는 표시 (서버 lockedSections 값)

  final GlobalKey _resultKey = GlobalKey();

  @override
  void didUpdateWidget(covariant LockScreenQuestionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 채점 직후 결과 자리를 화면 안으로
    if (oldWidget.state.submitResult == null &&
        widget.state.submitResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealResult());
    }
  }

  void _revealResult() {
    final resultContext = _resultKey.currentContext;
    if (resultContext == null || !mounted) return;
    Scrollable.ensureVisible(
      resultContext,
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
      curve: PassqlMotion.curve,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final state = widget.state;
    final question = state.question;
    if (question == null) return const SizedBox.shrink();
    final topicName = question.topicName;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.md),
      // 메모 층: 앱 풀이 화면과 같은 낙서 (문제마다 따로)
      child: PassqlMemoCanvas(
        pageKey: question.questionUuid,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 캡션 + 주제 태그
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.xs,
                PassqlSpacing.md,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.caption,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  if (topicName != null && topicName.isNotEmpty)
                    PassqlBadge(text: topicName, kind: PassqlBadgeKind.neutral),
                ],
              ),
            ),
            QuestionStem(
              stem: question.stem,
              schemaTables: question.schemaTables,
            ),
            // AI 선택지 생성 대기: 선택지 자리에 기존 생성 로딩
            if (state.isGeneratingChoices)
              const SseLoadingWidget(statusMessage: 'AI가 선택지를 만드는 중이에요'),
            for (final (displayIndex, choice) in state.choices.indexed)
              ChoiceItemCard(
                item: choice,
                displayLabel: toChoiceDisplayLabel(displayIndex),
                state: resolveChoiceState(
                  key: choice.key,
                  selectedKey: state.selectedKey,
                  result: state.submitResult,
                ),
                onTap: () => widget.onChoiceTap(choice.key),
                isRunning:
                    state.isSubmitting && state.selectedKey == choice.key,
              ),
            if (state.submitErrorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PassqlSpacing.md,
                  vertical: PassqlSpacing.xs,
                ),
                child: PassqlKeepAllText(
                  state.submitErrorMessage!,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.wrongText,
                  ),
                ),
              ),
            if (state.submitResult != null)
              KeyedSubtree(
                key: _resultKey,
                child: _buildGradedSection(context),
              ),
          ],
        ),
      ),
    );
  }

  /// 채점 뒤: 정답/오답 마크·토론·신고 > (실행형) 실행 결과 표 > 해설
  Widget _buildGradedSection(BuildContext context) {
    final state = widget.state;
    final submitResult = state.submitResult!;
    return PassqlReveal(
      index: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.sm,
          PassqlSpacing.md,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 채점 마크 + (실제 잠금화면) 조용한 토론·신고
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PassqlPopIn(
                      child: PassqlResultMark(
                        isCorrect: submitResult.isCorrect,
                      ),
                    ),
                  ),
                ),
                if (widget.onOpenDiscussion != null)
                  LockScreenQuestionActions(
                    questionUuid: state.question!.questionUuid,
                    submissionUuid: submitResult.submissionUuid,
                    // 서버 채점 응답에는 세트 UUID 가 없어 화면이 쓴 세트 기준
                    choiceSetUuid: state.choiceSetId,
                    onOpenDiscussion: widget.onOpenDiscussion!,
                  ),
              ],
            ),
            if (state.isExecutable) ...[
              const SizedBox(height: PassqlSpacing.sm),
              _buildExecutionResult(context, submitResult.correctResult),
            ],
            const SizedBox(height: PassqlSpacing.sm),
            _buildExplanation(context),
          ],
        ),
      ),
    );
  }

  /// 해설: 해설 조회 가능(세트 있음) > AI 해설 본문 / 세트 모름(미리보기 샘플 등) > 생성 근거 한 단락
  Widget _buildExplanation(BuildContext context) {
    final explanationEntry = _explanationEntryOf(widget.state);
    if (explanationEntry != null) {
      return AiExplanationContent(
        entry: explanationEntry,
        onProUnlock: widget.onProUnlock,
        lockedPreviewMaxHeight: PassqlSize.lockedPreviewPeekHeight,
      );
    }
    final rationale = widget.state.submitResult!.rationale?.trim();
    if (rationale == null || rationale.isEmpty) return const SizedBox.shrink();
    return PassqlCard(
      child: PassqlKeepAllText(
        rationale,
        style: PassqlTypography.explanationBody.copyWith(
          color: context.passqlColors.label,
        ),
      ),
    );
  }

  /// 잠금화면 상태 > 해설 항목 (문제·세트를 모르면 null)
  /// 보기 표시 라벨은 화면 순서(A~D) 기준이라 판정 줄·보기별 판단이 화면과 맞음
  static AiExplanationEntry? _explanationEntryOf(
    LockScreenQuestionState state,
  ) {
    final question = state.question;
    final submitResult = state.submitResult;
    if (question == null || submitResult == null) return null;
    final request = ChoiceExplanationRequest.fromSubmission(
      questionUuid: question.questionUuid,
      result: submitResult,
      selectedChoiceKey: state.selectedKey,
    );
    if (request == null) return null;
    return AiExplanationEntry(
      request: request,
      isCorrect: submitResult.isCorrect,
      displayLabelByChoiceKey: {
        for (final (displayIndex, choice) in state.choices.indexed)
          choice.key: toChoiceDisplayLabel(displayIndex),
      },
      rationale: submitResult.rationale,
      correctChoiceKey: submitResult.correctKey,
    );
  }

  /// 실행 결과: 정답 실행 결과 표 (무료로 빠졌으면 없음, PRO 안내는 해설 쪽 한 곳만)
  Widget _buildExecutionResult(
    BuildContext context,
    ExecuteResult? correctResult,
  ) {
    if (correctResult == null) return const SizedBox.shrink();
    return ExecuteResultCard(
      result: correctResult,
      subjectLabel: '정답 SQL',
      margin: EdgeInsets.zero,
    );
  }
}
