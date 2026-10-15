import 'package:flutter/material.dart';

import '../../../data/models/question/question_detail.dart';
import '../../../data/models/question/submit_result.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';
import 'ai_explain_sheet.dart';
import 'execute_result_card.dart';
import 'question_sections.dart';
import 'schema_section.dart';

/// 문제 풀이 본문 스크롤: 머리 > 스키마(실행형) > 지문 > 선택지 > 실행 중 표시 > 실행 결과
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
    final executeResult = interaction.currentExecuteResult;
    final hasExecutionError = executeResult?.errorCode?.isNotEmpty == true;
    // Scaffold 안쪽 context 여야 extendBody 가 더한 하단 바 높이를 읽는다.
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + PassqlSpacing.xl,
      ),
      children: [
        // 난이도 + 실행 모드 뱃지
        QuestionHeader(question: question),
        // 스키마 DDL (EXECUTABLE 모드에서만 표시)
        if (_isExecutable)
          SchemaSection(
            schemaDdl: question.schemaDdl,
            schemaSampleData: question.schemaSampleData,
          ),
        QuestionStem(stem: question.stem),
        QuestionChoices(
          interaction: interaction,
          notifier: notifier,
          isExecutable: _isExecutable,
          submitResult: submitResult,
          gradedSelectedKey: gradedSelectedKey,
          shouldAlwaysAllowRetry: shouldAlwaysAllowRetry,
        ),
        // SQL 실행 중 로딩
        if (interaction.isExecuting)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PassqlSpacing.md,
              vertical: PassqlSpacing.xs,
            ),
            child: PassqlLoadingIndicator(),
          ),
        // SQL 실행 결과 (오류면 AI 해설 버튼)
        if (executeResult != null)
          ExecuteResultCard(
            result: executeResult,
            onAiExplainTap: hasExecutionError
                ? () => _openExecutionErrorExplanation(context)
                : null,
          ),
      ],
    );
  }
}
