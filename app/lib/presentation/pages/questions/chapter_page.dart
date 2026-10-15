import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../presentation/flows/question_flow.dart';
import '../../../presentation/providers/chapter_providers.dart';
import '../../../presentation/providers/learning_refresh.dart';
import '../../../presentation/providers/question_providers.dart';
import '../../widgets/chapter/chapter_app_bar.dart';
import '../../../data/models/question/question_detail.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/chapter/chapter_feedback_bar.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../widgets/question/question_sections.dart';
import '../../widgets/question/question_solving_body.dart';

/// 문제 풀이 플로우 메인 페이지 (풀스크린).
///
/// 문제 묶음을 순서대로 풀고 마지막 제출 후 흐름(`QuestionFlow`)이 정한 곳으로 이동한다.
/// 토픽 챕터, 데일리 세트가 이 화면을 함께 쓴다.
class ChapterPage extends ConsumerStatefulWidget {
  final QuestionFlow flow;

  const ChapterPage({super.key, required this.flow});

  @override
  ConsumerState<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends ConsumerState<ChapterPage> {
  /// 선택지를 이미 준비한 questionUuid — 중복 준비 방지.
  final Set<String> _choiceInitializedUuids = {};

  /// 이번 풀이의 세션 식별자. 화면이 다시 그려져도 바뀌지 않도록 상태에 둔다.
  final String _sessionUuid = const Uuid().v4();

  /// 마지막 문제 이후 완료 처리(점수 등록 등)가 진행 중인지. 중복 실행과 연타를 막는다.
  bool _isCompleting = false;

  /// 이 화면에서 답안을 한 번이라도 제출했는지. 벗어날 때 학습 현황을 갱신할지 정한다.
  bool _hasSubmittedAny = false;

  /// dispose 시점에는 ref 를 쓸 수 없으므로 컨테이너를 미리 잡아 둔다.
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    // 첫 프레임 이후 문제 목록 로드
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(chapterProvider(widget.flow.id).notifier)
          .load(() => widget.flow.loadQuestionUuids(ref));
    });
  }

  /// 현재 문제의 선택지 준비를 첫 프레임 뒤 한 번만 요청 (재사용·생성 판단은 notifier 몫)
  void _initializeChoicesOnce(String questionUuid, QuestionDetail question) {
    if (!_choiceInitializedUuids.add(questionUuid)) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(questionInteractionProvider(questionUuid).notifier)
          .initializeChoices(question);
    });
  }

  /// 제출: 선택 키 고정 > 서버 제출 > 결과 기록(성공) 또는 토스트(실패)
  Future<void> _submitCurrentQuestion(String currentUuid) async {
    // 선택 키 미리 저장 (제출 후 interaction state가 바뀔 수 있으므로)
    final selectedKey =
        ref.read(questionInteractionProvider(currentUuid)).selectedChoiceKey ??
        '';
    final submitResult = await ref
        .read(questionInteractionProvider(currentUuid).notifier)
        .submit(
          sessionUuid: widget.flow.shouldTrackSession ? _sessionUuid : null,
        );
    if (!mounted) return;

    if (submitResult != null) {
      _hasSubmittedAny = true;
      ref
          .read(chapterProvider(widget.flow.id).notifier)
          .recordSubmission(submitResult, selectedKey);
    } else {
      showAppToast(context, '제출에 실패했어요. 다시 시도해 주세요.');
    }
  }

  /// 마지막 문제까지 끝남 — 요약을 만들어 이후 처리는 흐름에 맡긴다.
  Future<void> _complete() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    final summary = ref
        .read(chapterProvider(widget.flow.id).notifier)
        .buildSummary(widget.flow.title);
    try {
      await widget.flow.onCompleted(context, ref, summary, _sessionUuid);
    } catch (_) {
      // 완료 처리에서 예상 밖 오류가 나도 화면이 멈추지 않게 하고, 다시 시도할 수 있게 잠금을 푼다.
      if (mounted) showAppToast(context, '완료 처리에 실패했어요. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  void dispose() {
    // 챕터는 문제를 여러 번 제출하므로 매번이 아니라 화면을 벗어날 때 한 번만 갱신한다.
    // (중간에 나가도, 끝까지 풀고 결과 화면으로 가도 같은 경로를 탄다.)
    if (_hasSubmittedAny) refreshLearningData(_container.invalidate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flowId = widget.flow.id;
    final chapter = ref.watch(chapterProvider(flowId));
    final chapterNotifier = ref.read(chapterProvider(flowId).notifier);

    // 로딩 중
    if (chapter.isLoadingList) {
      return PassqlStatusScaffold(
        title: widget.flow.title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => context.go(AppRoutes.home),
        body: PassqlStatusView.loading(),
      );
    }

    // 에러 또는 빈 목록
    if (chapter.listError != null || chapter.questionUuids.isEmpty) {
      return PassqlStatusScaffold(
        title: widget.flow.title,
        leading: PassqlNavLeading.close,
        onLeadingTap: () => context.go(AppRoutes.home),
        body: PassqlStatusView.error(
          message: chapter.listError ?? '문제가 없어요',
          // 문제 목록을 다시 불러온다. (오늘의 세트를 이미 끝냈다면 다시 불러도 같은 안내가 나온다)
          onRetry: () => ref
              .read(chapterProvider(widget.flow.id).notifier)
              .load(() => widget.flow.loadQuestionUuids(ref)),
        ),
      );
    }

    final currentUuid = chapter.questionUuids[chapter.currentIndex];
    final detailAsync = ref.watch(questionDetailProvider(currentUuid));
    final interaction = ref.watch(questionInteractionProvider(currentUuid));
    final interactionNotifier = ref.read(
      questionInteractionProvider(currentUuid).notifier,
    );

    // 한 문제라도 제출했거나 2번째 문제 이상이면 "풀이 시작"으로 본다.
    final hasStarted = chapter.currentIndex > 0 || chapter.isAnswered;

    final scaffold = Scaffold(
      // 하단 바(글래스) 뒤로 본문이 비쳐 보이도록 body 를 바 아래까지 확장한다.
      extendBody: true,
      appBar: ChapterAppBar(
        topicName: widget.flow.title,
        currentIndex: chapter.currentIndex,
        total: chapter.questionUuids.length,
        isAnswered: chapter.isAnswered,
        shouldConfirmExit: hasStarted,
      ),
      body: detailAsync.when(
        loading: () => PassqlStatusView.loading(),
        error: (error, _) => PassqlStatusView.error(
          message: '문제를 불러올 수 없어요',
          onRetry: () => ref.invalidate(questionDetailProvider(currentUuid)),
        ),
        data: (question) {
          _initializeChoicesOnce(currentUuid, question);
          // Scaffold 안쪽 context 여야 extendBody 가 더한 하단 바 높이를 읽는다.
          return Builder(
            builder: (context) => QuestionSolvingBody(
              questionUuid: currentUuid,
              question: question,
              interaction: interaction,
              notifier: interactionNotifier,
              // 제출 후에는 정답/오답을 선택지에 표시한다.
              submitResult: chapter.isAnswered
                  ? chapter.lastSubmitResult
                  : null,
              gradedSelectedKey: chapter.lastSelectedKey,
              // 재시도가 소용없는 오류여도 다시 눌러 볼 수 있게 두어 막다른 길을 만들지 않는다.
              shouldAlwaysAllowRetry: true,
            ),
          );
        },
      ),
      // 하단 바 — 미제출: 제출 버튼 / 제출 완료: 피드백 바
      bottomNavigationBar: detailAsync.hasValue
          ? (!chapter.isAnswered
                ? QuestionSubmitBar(
                    interaction: interaction,
                    onSubmit: () => _submitCurrentQuestion(currentUuid),
                  )
                : ChapterFeedbackBar(
                    // 문제가 바뀔 때마다 새로 만들어 햅틱이 다시 울리게 한다.
                    key: ValueKey(currentUuid),
                    result: chapter.lastSubmitResult!,
                    questionUuid: currentUuid,
                    selectedChoiceKey: chapter.lastSelectedKey ?? '',
                    isLastQuestion: chapter.isLastQuestion,
                    onNext: () {
                      if (_isCompleting) return;
                      if (chapter.isLastQuestion) {
                        _complete();
                      } else {
                        chapterNotifier.nextQuestion();
                      }
                    },
                  ))
          : null,
    );

    // 완료 처리(점수 등록)가 길어질 수 있어, 진행 중에는 화면을 잠그고 로딩을 보여준다.
    // 트리 모양을 고정한다. 완료 처리 여부로 Scaffold 의 부모가 바뀌면 피드백 바가 다시 만들어져 햅틱이 또 울린다.
    final body = Stack(
      children: [
        scaffold,
        if (_isCompleting) ...[
          ModalBarrier(
            dismissible: false,
            color: context.passqlColors.label.withValues(alpha: 0.2),
          ),
          const Center(
            child: PassqlLoadingIndicator(size: PassqlLoadingSize.blocking),
          ),
        ],
      ],
    );
    // 시스템 뒤로가기(Android 백 버튼, iOS 스와이프)도 홈 아이콘과 같은 확인을 거친다.
    return PopScope(
      canPop: !hasStarted,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmChapterExit(context) && context.mounted) {
          context.go(AppRoutes.home);
        }
      },
      child: body,
    );
  }
}
