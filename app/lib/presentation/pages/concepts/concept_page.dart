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
import '../../widgets/concept/concept_result_view.dart';
import '../../widgets/concept/concept_solve_view.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 개념 학습 (#577, #764): 핵심 | 자세히 | 문제 전환 (읽기·풀기 둘 다 살려 두어 위치·진행 유지)
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

/// 위 세그먼트 3칸 (#764): 읽기 깊이 2개 + 풀기를 한 줄로 (값 = 모드·깊이 조합)
enum _ConceptStudyTab { core, detail, quiz }

/// 상단 바 + 세그먼트(핵심·자세히·문제) + 본문(읽기·풀기 겹쳐 두고 하나만 보임) + 읽기 하단 버튼
class _ConceptStudyScaffold extends ConsumerWidget {
  const _ConceptStudyScaffold({required this.detail});

  final ConceptDetailResponse detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptUuid = detail.conceptUuid;
    final study = ref.watch(conceptStudyProvider(conceptUuid));
    final notifier = ref.read(conceptStudyProvider(conceptUuid).notifier);
    final topicConcepts = ref
        .watch(conceptListProvider(detail.topicUuid))
        .valueOrNull;
    final topicSolvedCount = topicConcepts?.concepts
        .where((concept) => concept.status == ConceptStatus.solved)
        .length;

    // 서버에 남은 마지막 모드·깊이로 처음 한 번 맞춤, 결과의 단원 +1 연출용으로 처음 단원 완료 수 기억
    if (!study.isInitialized ||
        (topicSolvedCount != null && study.topicSolvedCountAtStart == null)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.initializeFrom(detail);
        if (topicSolvedCount != null) {
          notifier.rememberTopicSolvedCount(topicSolvedCount);
        }
      });
    }

    final isReading = study.mode == ConceptStudyMode.read;
    final selectedTab = !isReading
        ? _ConceptStudyTab.quiz
        : study.depth == ConceptReadingDepth.detail
        ? _ConceptStudyTab.detail
        : _ConceptStudyTab.core;
    final relatedQuestionCount = detail.relatedQuestionUuids.length.clamp(
      0,
      ConceptRelatedFlow.maximumQuestionCount,
    );
    final nextActionLabel = detail.nextConceptUuid == null ? '단원으로' : '다음 개념';
    final topicOrder = ref
        .watch(conceptTopicsProvider)
        .valueOrNull
        ?.topics
        .where((topic) => topic.topicUuid == detail.topicUuid)
        .firstOrNull
        ?.orderIndex;
    final unitProgress = topicConcepts == null || topicSolvedCount == null
        ? null
        : ConceptUnitProgress(
            label: topicOrder == null
                ? topicConcepts.displayName
                : '${topicOrder + 1}단원 · ${topicConcepts.displayName}',
            solvedCountBefore:
                study.topicSolvedCountAtStart ?? topicSolvedCount,
            solvedCount: topicSolvedCount,
            total: topicConcepts.concepts.length,
          );

    /// 세그먼트 선택 > 모드·깊이로 나눠 저장
    void selectTab(_ConceptStudyTab tab) {
      switch (tab) {
        case _ConceptStudyTab.quiz:
          notifier.selectMode(ConceptStudyMode.solve);
        case _ConceptStudyTab.core || _ConceptStudyTab.detail:
          notifier.selectMode(ConceptStudyMode.read);
          notifier.selectDepth(
            tab == _ConceptStudyTab.core
                ? ConceptReadingDepth.core
                : ConceptReadingDepth.detail,
          );
      }
    }

    /// 다음 개념으로 (같은 단원 안), 없으면 단원 목록으로
    void goToNextConcept() {
      final nextConceptUuid = detail.nextConceptUuid;
      if (nextConceptUuid == null) {
        context.pop();
        return;
      }
      context.pushReplacement(AppRoutes.conceptStudy(nextConceptUuid));
    }

    final colors = context.passqlColors;
    return Scaffold(
      appBar: PassqlNavBar(title: detail.title, leading: PassqlNavLeading.back),
      body: Column(
        children: [
          // 세그먼트도 본문과 같은 흰 면 위 (다른 탭 구간과 같은 톤)
          ColoredBox(
            color: colors.card,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.xs,
                PassqlSpacing.md,
                PassqlSpacing.xs,
              ),
              child: PassqlSegmentedControl<_ConceptStudyTab>(
                segments: const [
                  PassqlSegment(value: _ConceptStudyTab.core, label: '핵심'),
                  PassqlSegment(value: _ConceptStudyTab.detail, label: '자세히'),
                  PassqlSegment(value: _ConceptStudyTab.quiz, label: '문제'),
                ],
                selectedValue: selectedTab,
                onSelected: selectTab,
              ),
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
                  onAnchorScrolled: notifier.consumePendingAnchor,
                  onReachedDetailEnd: notifier.markRead,
                ),
                ConceptSolveView(
                  conceptUuid: conceptUuid,
                  finishLabel: nextActionLabel,
                  onFinished: goToNextConcept,
                  unitProgress: unitProgress,
                  // 풀이 시트의 다시 읽기 버튼에 "4. 문단 제목"을 보여 주려고 (자세히 칸 번호와 같게)
                  rereadLabelByAnchor: {
                    for (final (i, section) in detail.detailSections.indexed)
                      section.anchor: '${i + 1}. ${section.title}',
                  },
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
      // 순서는 지금 앱 그대로: 왼쪽 문제 풀기(보조) · 오른쪽 다음 개념(주)
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
