import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';
import 'ai_explain_sheet.dart';
import 'execute_failure_card.dart';
import 'execute_result_card.dart';
import 'question_sections.dart';
import 'schema_section.dart';
import 'reveal_above_bottom_bar.dart';

/// 문제 풀이 본문 스크롤: 머리 > 지문 > 테이블(실행형) > 선택지 > 실행 중 표시 > 실행 결과 또는 실패
/// 챕터 풀이(ChapterPage)와 단건 풀이(QuestionDetailPage)가 함께 쓴다. 제출 바는 Scaffold 하단에 따로 붙는다.
class QuestionSolvingBody extends StatelessWidget {
  const QuestionSolvingBody({
    super.key,
    required this.questionUuid,
    required this.question,
    required this.interaction,
    required this.notifier,
    this.submitResult,
    this.gradedSelectedKey,
    this.shouldAlwaysAllowRetry = false,
  });

  final String questionUuid;
  final QuestionDetail question;
  final QuestionInteractionState interaction;
  final QuestionInteractionNotifier notifier;

  /// 채점 결과. 있으면 선택지에 정답/오답을 표시한다.
  final SubmitResult? submitResult;

  /// 채점 당시 선택 키 (채점 뒤 탭으로 선택이 바뀌어도 표시는 고정)
  final String? gradedSelectedKey;

  /// 재시도가 소용없는 선택지 생성 오류여도 "다시 시도"를 보여 막다른 길을 만들지 않을지
  final bool shouldAlwaysAllowRetry;

  /// 서버 실행 모드 값: SQL 을 실제로 실행해 볼 수 있는 문제
  static const _executableMode = 'EXECUTABLE';

  bool get _isExecutable => question.executionMode == _executableMode;

  /// 실행 오류 AI 해설 열기 (선택한 선택지 SQL + 오류 메시지)
  void _openExecutionErrorExplanation(BuildContext context) {
    final selectedChoice = interaction.activeChoices
        .where((choice) => choice.key == interaction.selectedChoiceKey)
        .firstOrNull;
    AiExplainSheet.show(
      context,
      payload: {
        'questionUuid': questionUuid,
        'sql': selectedChoice?.body ?? '',
        'errorMessage': interaction.currentExecuteResult?.errorMessage ?? '',
      },
      isErrorExplain: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 안쪽 context 여야 extendBody 가 더한 하단 바 높이를 읽는다.
    // 전부 미리 그림 (화면 밖 실행 결과도 자리를 알아야 스크롤로 보여 줄 수 있음)
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + PassqlSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 난이도 + 실행 모드 뱃지
          QuestionHeader(question: question),
          QuestionStem(stem: question.stem),
          // 테이블 컬럼·샘플 행 (EXECUTABLE 모드에서만, 지문 바로 아래 기본 펼침)
          if (_isExecutable)
            SchemaSection(
              tables: question.schemaTables,
              schemaDdl: question.schemaDdl,
              schemaSampleData: question.schemaSampleData,
            ),
          QuestionChoices(
            interaction: interaction,
            notifier: notifier,
            isExecutable: _isExecutable,
            submitResult: submitResult,
            gradedSelectedKey: gradedSelectedKey,
            shouldAlwaysAllowRetry: shouldAlwaysAllowRetry,
          ),
          _ExecutionOutcomeSection(
            outcomeKey: _executionOutcomeKey,
            outcome: _buildExecutionOutcome(context),
          ),
        ],
      ),
    );
  }

  /// 실행 영역 상태 4개: 없음, 실행 중, 결과, 요청 실패 (상태가 바뀔 때만 교체 연출)
  Object get _executionOutcomeKey {
    if (interaction.isExecuting) return 'executing';
    if (interaction.currentExecuteResult != null) {
      return interaction.currentExecuteResult!;
    }
    if (interaction.executeFailure != null) return 'failure';
    return 'none';
  }

  /// 실행 영역 내용: 실행 중 로딩 > 결과(오류면 AI 해설 버튼) > 요청 실패. 없으면 null
  Widget? _buildExecutionOutcome(BuildContext context) {
    final executeResult = interaction.currentExecuteResult;
    final hasExecutionError = executeResult?.errorCode?.isNotEmpty == true;
    // SQL 실행 중 로딩
    if (interaction.isExecuting) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.xs,
        ),
        child: PassqlLoadingIndicator(),
      );
    }
    // SQL 실행 결과와 요청 실패(네트워크·5xx·SANDBOX_TIMEOUT 등)
    if (executeResult == null && interaction.executeFailure == null) {
      return null;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (executeResult != null)
          ExecuteResultCard(
            result: executeResult,
            onAiExplainTap: hasExecutionError
                ? () => _openExecutionErrorExplanation(context)
                : null,
          ),
        if (interaction.executeFailure != null)
          ExecuteFailureCard(
            message: interaction.executeFailure!.message,
            onRetry: notifier.retryExecution,
          ),
      ],
    );
  }
}

/// 실행 결과 자리: 높이가 부드럽게 늘고 내용은 페이드 교체, 새 결과·실패면 그 위치까지 스크롤
class _ExecutionOutcomeSection extends StatefulWidget {
  const _ExecutionOutcomeSection({
    required this.outcomeKey,
    required this.outcome,
  });

  /// 상태 구분 값 (바뀔 때만 교체·스크롤)
  final Object outcomeKey;

  /// 보여 줄 내용. null 이면 접힘
  final Widget? outcome;

  @override
  State<_ExecutionOutcomeSection> createState() =>
      _ExecutionOutcomeSectionState();
}

class _ExecutionOutcomeSectionState extends State<_ExecutionOutcomeSection> {
  /// 높이 연출이 끝난 뒤 스크롤 (끝난 크기 기준으로 보이게)
  Timer? _revealTimer;

  @override
  void didUpdateWidget(covariant _ExecutionOutcomeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hasNewSettledOutcome =
        widget.outcomeKey != oldWidget.outcomeKey &&
        widget.outcome != null &&
        widget.outcomeKey != 'executing';
    if (hasNewSettledOutcome) _scheduleRevealOutcome();
  }

  /// 결과 자리를 화면 안으로 스크롤 (동작 줄이기면 즉시)
  void _scheduleRevealOutcome() {
    _revealTimer?.cancel();
    final isReduced = PassqlMotion.isReduced(context);
    _revealTimer = Timer(
      isReduced ? Duration.zero : PassqlMotion.standard,
      () {
        if (!mounted) return;
        // 이미 보이면 그대로, 가려져 있으면 하단 바 바로 위까지
        revealAboveBottomBar(context);
      },
    );
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = KeyedSubtree(
      key: ValueKey(widget.outcomeKey),
      child: widget.outcome ?? const SizedBox.shrink(),
    );
    if (PassqlMotion.isReduced(context)) return content;
    return AnimatedSize(
      duration: PassqlMotion.standard,
      curve: PassqlMotion.curve,
      alignment: Alignment.topCenter,
      child: PassqlFadeSwitcher(child: content),
    );
  }
}
