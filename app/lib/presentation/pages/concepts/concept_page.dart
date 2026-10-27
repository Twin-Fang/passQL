import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../data/models/concept/concept_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../flows/concept_related_flow.dart';
import '../../providers/concept_providers.dart';
import '../../widgets/concept/concept_read_view.dart';
import '../../widgets/concept/concept_solve_view.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 개념 학습 (#577): 읽기 | 풀기 전환 (둘 다 살려 두어 위치·진행 유지)
/// 읽기 하단: 문제 풀기 · 다음 개념. 풀기는 자체 하단 버튼, 결과에서 관련 실전 문제로. 잠긴 단원(403)은 블러 잠금, 없는 개념(404)은 안내
class ConceptPage extends ConsumerWidget {
  const ConceptPage({super.key, required this.conceptUuid});

  final String conceptUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(conceptDetailProvider(conceptUuid));
    return detail.when(
      loading: () => const Scaffold(
        appBar: PassqlNavBar(leading: PassqlNavLeading.back),
        body: PassqlStatusView.loading(),
      ),
      error: (error, _) => Scaffold(
        appBar: const PassqlNavBar(leading: PassqlNavLeading.back),
        body: _ConceptLoadError(
          error: error,
          onRetry: () => ref.invalidate(conceptDetailProvider(conceptUuid)),
        ),
      ),
      data: (loadedDetail) => _ConceptStudyScaffold(detail: loadedDetail),
    );
  }
}

/// 상세 불러오기 실패: 잠김 > 블러 잠금, 없음 > 안내, 그 외 > 다시 시도
class _ConceptLoadError extends StatelessWidget {
  const _ConceptLoadError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final errorCode = error is AppException
        ? (error as AppException).code
        : null;
    if (errorCode == ErrorCode.proRequired) {
      return const Padding(
        padding: EdgeInsets.all(PassqlSpacing.lg),
        child: ProLockedSection(
          preview: ConceptTopicsLockedSample(),
          caption: LockedPreviewCaptions.conceptTopics,
        ),
      );
    }
    if (errorCode == ErrorCode.notFound) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.lightbulb,
        title: '개념을 찾을 수 없어요',
        message: '아직 공개되지 않았거나 내려간 개념이에요.',
      );
    }
    return PassqlStatusView.error(message: '개념을 불러오지 못했어요.', onRetry: onRetry);
  }
}

/// 상단 바 + 모드 전환 + 본문(읽기·풀기 겹쳐 두고 하나만 보임) + 읽기 하단 버튼
class _ConceptStudyScaffold extends ConsumerWidget {
  const _ConceptStudyScaffold({required this.detail});

  final ConceptDetailResponse detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptUuid = detail.conceptUuid;
    final study = ref.watch(conceptStudyProvider(conceptUuid));
    final notifier = ref.read(conceptStudyProvider(conceptUuid).notifier);
    final questionCount = ref
        .watch(conceptCheckQuestionsProvider(conceptUuid))
        .valueOrNull
        ?.length;

    // 서버에 남은 마지막 모드·깊이로 처음 한 번 맞춤
    if (!study.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => notifier.initializeFrom(detail),
      );
    }

    final isReading = study.mode == ConceptStudyMode.read;
    final relatedQuestionCount = detail.relatedQuestionUuids.length.clamp(
      0,
      ConceptRelatedFlow.maximumQuestionCount,
    );
    final nextActionLabel = detail.nextConceptUuid == null ? '단원으로' : '다음 개념';
    final solveLabel = questionCount == null
        ? '풀기'
        : '풀기 ${study.resultByQuestion.length}/$questionCount';

    /// 다음 개념으로 (같은 단원 안), 없으면 단원 목록으로
    void goToNextConcept() {
      final nextConceptUuid = detail.nextConceptUuid;
      if (nextConceptUuid == null) {
        context.pop();
        return;
      }
      context.pushReplacement(AppRoutes.conceptStudy(nextConceptUuid));
    }

    return Scaffold(
      appBar: PassqlNavBar(title: detail.title, leading: PassqlNavLeading.back),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.lg,
              PassqlSpacing.xs,
              PassqlSpacing.lg,
              PassqlSpacing.xs,
            ),
            child: PassqlSegmentedControl<ConceptStudyMode>(
              segments: [
                const PassqlSegment(value: ConceptStudyMode.read, label: '읽기'),
                PassqlSegment(value: ConceptStudyMode.solve, label: solveLabel),
              ],
              selectedValue: study.mode,
              onSelected: notifier.selectMode,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: isReading ? 0 : 1,
              children: [
                ConceptReadView(
                  detail: detail,
                  depth: study.depth,
                  pendingAnchor: study.pendingAnchor,
                  onDepthSelected: notifier.selectDepth,
                  onAnchorScrolled: notifier.consumePendingAnchor,
                  onReachedDetailEnd: notifier.markRead,
                ),
                ConceptSolveView(
                  conceptUuid: conceptUuid,
                  finishLabel: nextActionLabel,
                  onFinished: goToNextConcept,
                  relatedQuestionCount: relatedQuestionCount,
                  onRelatedQuestionsPressed: () => context.push(
                    AppRoutes.conceptRelated(conceptUuid, detail.title),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isReading
          ? PassqlBottomActionBar(
              actions: [
                PassqlButton(
                  label: '문제 풀기',
                  variant: PassqlButtonVariant.tinted,
                  onPressed: () => notifier.selectMode(ConceptStudyMode.solve),
                ),
                PassqlButton(
                  label: nextActionLabel,
                  onPressed: () {
                    // 핵심만 읽고 넘어가도 읽음 (자세히는 끝까지 내리면 읽음)
                    notifier.markRead();
                    goToNextConcept();
                  },
                ),
              ],
            )
          : null,
    );
  }
}
