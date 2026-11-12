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
import '../../widgets/concept/concept_reading_parser.dart';
import '../../widgets/concept/concept_unit_progress.dart';
import '../../widgets/concept/concept_solve_view.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 개념 학습 (#577, #764, #835): 개념 | 확인 문제 전환 (읽기·풀기 둘 다 살려 두어 위치·진행 유지)
/// 읽기는 한 스크롤(한 줄 핵심 > 기억할 것 > 문단 카드), 하단: 확인 문제 풀기 · 다음 개념. 풀기는 자체 하단 버튼, 결과에서 관련 실전 문제로. 잠긴 단원(403)은 블러 잠금, 없는 개념(404)은 안내
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
    return PassqlStatusView.error(
      message: PassqlLoadFailureCopy.messageOf('개념을'),
      onRetry: onRetry,
    );
  }
}

/// 위 세그먼트 2칸 (#835): 읽기(한 스크롤) · 풀기
enum _ConceptStudyTab { read, quiz }

/// 상단 바 + 세그먼트(개념·확인 문제) + 본문(읽기·풀기 겹쳐 두고 하나만 보임) + 읽기 하단 버튼
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
    final selectedTab = isReading
        ? _ConceptStudyTab.read
        : _ConceptStudyTab.quiz;
    final relatedQuestionCount = detail.relatedQuestionUuids.length.clamp(
      0,
      ConceptRelatedFlow.maximumQuestionCount,
    );
    final nextActionLabel = detail.nextConceptUuid == null ? '단원으로' : '다음 개념';
    final topics = ref.watch(conceptTopicsProvider).valueOrNull?.topics;
    final topicOrder = topics
        ?.where((topic) => topic.topicUuid == detail.topicUuid)
        .firstOrNull
        ?.orderIndex;
    // 단원을 다 끝낸 한 장에서 바로 이어 갈 다음 단원 (잠긴 단원은 건너뜀)
    final nextTopic = topicOrder == null
        ? null
        : topics
              ?.where(
                (topic) => topic.orderIndex > topicOrder && !topic.isLocked,
              )
              .fold<ConceptTopicSummary?>(
                null,
                (best, topic) =>
                    best == null || topic.orderIndex < best.orderIndex
                    ? topic
                    : best,
              );
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
            nextUnitLabel: nextTopic == null
                ? null
                : '${nextTopic.orderIndex + 1}단원',
            // 전체: 다른 단원은 목록 값, 이 단원은 방금 센 값 (목록 새로고침 시차를 피함)
            overallSolvedCount: topics == null
                ? 0
                : topics.fold<int>(
                    topicSolvedCount,
                    (sum, topic) => topic.topicUuid == detail.topicUuid
                        ? sum
                        : sum + topic.completedCount,
                  ),
            overallTotal: topics == null
                ? 0
                : topics.fold<int>(0, (sum, topic) => sum + topic.conceptCount),
          );

    /// 세그먼트 선택 > 모드 저장 (읽기 깊이는 한 스크롤로 합쳐 더 쓰지 않음)
    void selectTab(_ConceptStudyTab tab) => notifier.selectMode(
      tab == _ConceptStudyTab.quiz
          ? ConceptStudyMode.solve
          : ConceptStudyMode.read,
    );

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
                  PassqlSegment(value: _ConceptStudyTab.read, label: '개념'),
                  PassqlSegment(value: _ConceptStudyTab.quiz, label: '확인 문제'),
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
                  pendingAnchor: study.pendingAnchor,
                  onAnchorScrolled: notifier.consumePendingAnchor,
                  onReachedEnd: notifier.markRead,
                ),
                ConceptSolveView(
                  conceptUuid: conceptUuid,
                  conceptTitle: detail.title,
                  finishLabel: nextActionLabel,
                  onFinished: goToNextConcept,
                  unitProgress: unitProgress,
                  // 풀이 시트의 다시 읽기 버튼에 "4. 문단 제목"을 보여 주려고 (읽기 문단 카드 번호와 같게)
                  rereadLabelByAnchor: {
                    for (final (i, section) in detail.detailSections.indexed)
                      section.anchor:
                          '${i + 1}. ${ConceptReadingParser.splitTitle(section.title).title}',
                  },
                  relatedQuestionCount: relatedQuestionCount,
                  onRelatedQuestionsPressed: () => context.push(
                    AppRoutes.conceptRelated(conceptUuid, detail.title),
                  ),
                  // 다음 단원 상세로 바꿔치기 (뒤로 가면 지금 단원 목록)
                  onNextUnitPressed: nextTopic == null
                      ? null
                      : () => context.pushReplacement(
                          AppRoutes.conceptTopic(nextTopic.topicUuid),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 왼쪽 확인 문제 풀기(보조) · 오른쪽 다음 개념(주)
      bottomNavigationBar: isReading
          ? PassqlBottomActionBar(
              actions: [
                PassqlButton(
                  label: '확인 문제 풀기',
                  variant: PassqlButtonVariant.tinted,
                  onPressed: () => notifier.selectMode(ConceptStudyMode.solve),
                ),
                PassqlButton(
                  label: nextActionLabel,
                  onPressed: () {
                    // 끝까지 내리지 않고 넘어가도 읽음
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
