import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/error/app_exception.dart';
import '../../../data/models/question/submit_result.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_solving_body.dart';
import '../../widgets/question/question_solving_skeleton.dart';
import '../../widgets/question/choice_display_label.dart';
import '../../../router/result_route_arguments.dart';

/// 문제 상세 + 풀기 화면 (풀스크린).
/// 진입 시 GET /questions/{uuid}, 선택지 없으면 SSE 자동 시작.
class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionUuid;

  /// 알림 탭으로 들어왔는지: 첫 로드 실패에 프로 안내 시트를 띄우지 않음 (다시 시도부터는 띄움)
  final bool isPushEntry;

  const QuestionDetailPage({
    super.key,
    required this.questionUuid,
    this.isPushEntry = false,
  });

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  bool _isChoicesInitialized = false;

  /// 이번 로드 실패의 프로 접근 안내를 띄웠는지 (다시 시도하면 내림)
  late bool _isProAccessNoticed = widget.isPushEntry;

  /// 상세 실패 1회 안내: 프로 접근 오류면 시트·토스트 > 시트로 프로가 됐을 때만 다시 받기
  void _showProAccessFeedbackOnce(Object error) {
    if (_isProAccessNoticed) return;
    _isProAccessNoticed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final feedbackResult = await showProAccessFeedback(context, ref, error);
      if (feedbackResult == ProAccessFeedbackResult.sheetUnlockedPro &&
          mounted) {
        _retryDetail();
      }
    });
  }

  /// 문제 상세 다시 받기 (오류 안내도 다시 가능)
  void _retryDetail() {
    _isProAccessNoticed = false;
    ref.invalidate(questionDetailProvider(widget.questionUuid));
  }

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
      // 로딩 자리 스켈레톤 > 내용 페이드 교체
      body: PassqlFadeSwitcher(
        child: detailAsync.when(
          loading: () =>
              const QuestionSolvingSkeleton(key: ValueKey('loading')),
          error: (error, _) {
            _showProAccessFeedbackOnce(error);
            return KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: '문제를 불러올 수 없어요',
                onRetry: _retryDetail,
              ),
            );
          },
          data: (question) {
            // 로드 성공 > 알림 진입 억제 해제 (이후 실패는 일반 진입처럼 안내)
            _isProAccessNoticed = false;
            // 최초 1회: 선택지 준비(재사용·생성 판단은 notifier 몫)
            if (!_isChoicesInitialized) {
              _isChoicesInitialized = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.initializeChoices(question);
              });
            }

            return QuestionSolvingBody(
              key: const ValueKey('data'),
              questionUuid: widget.questionUuid,
              question: question,
              interaction: interaction,
              notifier: notifier,
            );
          },
        ),
      ),
      bottomNavigationBar: detailAsync.hasValue
          ? QuestionSubmitBar(
              interaction: interaction,
              onSubmit: () => _submitAnswer(context, notifier),
            )
          : null,
    );
  }

  Future<void> _submitAnswer(
    BuildContext context,
    QuestionInteractionNotifier notifier,
  ) async {
    final SubmitResult? submitResult;
    try {
      submitResult = await notifier.submit();
    } on AppException catch (exception) {
      // 실패 원인별 문구 (네트워크, 서버 오류, 입력 오류 등)
      if (context.mounted) showAppToast(context, exception.message);
      return;
    }
    if (!context.mounted || submitResult == null) return;
    // 풀이 결과가 홈과 통계에 반영되도록 캐시를 비운다.
    refreshLearningData(ref.invalidate);
    final interaction = ref.read(
      questionInteractionProvider(widget.questionUuid),
    );
    context.push(
      AppRoutes.questionResult(widget.questionUuid),
      extra: QuestionResultArguments(
        result: submitResult,
        correctDisplayLabel: findChoiceDisplayLabel(
          interaction.activeChoices,
          submitResult.correctKey,
        ),
        selectedChoiceKey: interaction.selectedChoiceKey,
        displayLabelByChoiceKey: choiceDisplayLabelsOf(
          interaction.activeChoices,
        ),
      ),
    );
  }
}
