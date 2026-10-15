import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/question/question_detail.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/question/ai_explain_sheet.dart';
import '../../widgets/question/execute_result_card.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/schema_section.dart';

/// 문제 상세 + 풀기 화면 (풀스크린).
/// 진입 시 GET /questions/{uuid}, 선택지 없으면 SSE 자동 시작.
class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionUuid;

  const QuestionDetailPage({super.key, required this.questionUuid});

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  bool _sseInitialized = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(questionDetailProvider(widget.questionUuid));
    final interaction = ref.watch(
      questionInteractionProvider(widget.questionUuid),
    );
    final notifier = ref.read(
      questionInteractionProvider(widget.questionUuid).notifier,
    );

    return Scaffold(
      // 하단 제출 바(글래스) 뒤로 본문이 비쳐 보이도록 body 를 바 아래까지 확장한다.
      extendBody: true,
      appBar: PassqlNavBar(
        title: detailAsync.valueOrNull?.topicName ?? '문제 풀기',
        leading: PassqlNavLeading.back,
        onLeadingTap: () => context.pop(),
      ),
      body: detailAsync.when(
        loading: () => PassqlStatusView.loading(),
        error: (error, _) => PassqlStatusView.error(
          message: '문제를 불러올 수 없어요',
          onRetry: () =>
              ref.invalidate(questionDetailProvider(widget.questionUuid)),
        ),
        data: (question) {
          // 최초 1회: 선택지 초기화 또는 SSE 시작
          if (!_sseInitialized) {
            _sseInitialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initChoices(question, notifier);
            });
          }

          return _QuestionDetailBody(
            question: question,
            interaction: interaction,
            notifier: notifier,
            questionUuid: widget.questionUuid,
          );
        },
      ),
      bottomNavigationBar: detailAsync.hasValue
          ? QuestionSubmitBar(
              interaction: interaction,
              onSubmit: () => _handleSubmit(context, notifier),
            )
          : null,
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    QuestionInteractionNotifier notifier,
  ) async {
    final result = await notifier.submit();
    if (!context.mounted) return;
    if (result != null) {
      // 풀이 결과가 홈과 통계에 반영되도록 캐시를 비운다.
      refreshLearningData(ref.invalidate);
      context.push(
        AppRoutes.questionResult(widget.questionUuid),
        extra: result,
      );
    } else {
      showAppToast(context, '제출에 실패했어요. 다시 시도해 주세요.');
    }
  }

  /// 선택지 세트 초기화. OK 세트가 있으면 바로 사용, 없으면 SSE 생성.
  void _initChoices(QuestionDetail q, QuestionInteractionNotifier notifier) {
    final okSet = q.choiceSets.where((cs) => cs.status == 'OK').toList();
    if (okSet.isNotEmpty) {
      notifier.useExistingChoiceSet(
        okSet.first.choiceSetUuid,
        okSet.first.items,
      );
    } else {
      notifier.startSseGeneration();
    }
  }
}

/// 문제 본문 스크롤 영역. 제출 바는 Scaffold 하단에 따로 붙는다.
class _QuestionDetailBody extends StatelessWidget {
  final QuestionDetail question;
  final QuestionInteractionState interaction;
  final QuestionInteractionNotifier notifier;
  final String questionUuid;

  const _QuestionDetailBody({
    required this.question,
    required this.interaction,
    required this.notifier,
    required this.questionUuid,
  });

  bool get _isExecutable => question.executionMode == 'EXECUTABLE';

  @override
  Widget build(BuildContext context) {
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

        // 문제 지문
        QuestionStem(stem: question.stem),

        // 선택지 영역
        QuestionChoices(
          interaction: interaction,
          notifier: notifier,
          isExecutable: _isExecutable,
        ),

        // 실행 결과 (선택지 클릭 후 EXECUTABLE 모드)
        if (interaction.isExecuting)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PassqlSpacing.md,
              vertical: PassqlSpacing.xs,
            ),
            child: CupertinoActivityIndicator(),
          ),
        if (interaction.currentExecuteResult != null)
          ExecuteResultCard(
            result: interaction.currentExecuteResult!,
            onAiExplainTap:
                (interaction.currentExecuteResult!.errorCode?.isNotEmpty ==
                    true)
                ? () {
                    final selectedKey = interaction.selectedChoiceKey;
                    final selectedChoice = interaction.activeChoices
                        .where((choice) => choice.key == selectedKey)
                        .firstOrNull;
                    AiExplainSheet.show(
                      context,
                      payload: {
                        'questionUuid': questionUuid,
                        'sql': selectedChoice?.body ?? '',
                        'errorMessage':
                            interaction.currentExecuteResult!.errorMessage ??
                            '',
                      },
                      isErrorExplain: true,
                    );
                  }
                : null,
          ),
      ],
    );
  }
}
