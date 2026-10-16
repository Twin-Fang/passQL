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
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_solving_body.dart';
import '../../widgets/question/question_solving_skeleton.dart';

/// 문제 상세 + 풀기 화면 (풀스크린).
/// 진입 시 GET /questions/{uuid}, 선택지 없으면 SSE 자동 시작.
class QuestionDetailPage extends ConsumerStatefulWidget {
  final String questionUuid;

  const QuestionDetailPage({super.key, required this.questionUuid});

  @override
  ConsumerState<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends ConsumerState<QuestionDetailPage> {
  bool _isChoicesInitialized = false;

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
          error: (error, _) => KeyedSubtree(
            key: const ValueKey('error'),
            child: PassqlStatusView.error(
              message: '문제를 불러올 수 없어요',
              onRetry: () =>
                  ref.invalidate(questionDetailProvider(widget.questionUuid)),
            ),
          ),
          data: (question) {
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
    context.push(
      AppRoutes.questionResult(widget.questionUuid),
      extra: submitResult,
    );
  }
}
