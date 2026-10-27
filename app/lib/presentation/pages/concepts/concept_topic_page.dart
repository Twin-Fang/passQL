import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 단원 상세 (#577): 단원 진행 머리 > 개념 목록(상태별 표시) > 하단 이어서 학습 버튼
/// 순서를 강제하지 않음: 어떤 개념이든 바로 열 수 있음. 잠긴 단원은 블러 잠금
class ConceptTopicPage extends ConsumerWidget {
  const ConceptTopicPage({super.key, required this.topicUuid});

  final String topicUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conceptList = ref.watch(conceptListProvider(topicUuid));
    final loadedList = conceptList.valueOrNull;
    final nextConcept = loadedList == null
        ? null
        : _findNextConcept(loadedList);
    return Scaffold(
      appBar: PassqlNavBar(
        title: loadedList?.displayName ?? '단원',
        leading: PassqlNavLeading.back,
      ),
      body: conceptList.when(
        loading: () => const PassqlListSkeleton(),
        error: (_, _) => PassqlStatusView.error(
          message: '개념 목록을 불러오지 못했어요.',
          onRetry: () => ref.invalidate(conceptListProvider(topicUuid)),
        ),
        data: (list) => list.isLocked
            ? const Padding(
                padding: EdgeInsets.all(PassqlSpacing.lg),
                child: ProLockedSection(
                  preview: ConceptTopicsLockedSample(),
                  caption: LockedPreviewCaptions.conceptTopics,
                ),
              )
            : _ConceptListBody(list: list),
      ),
      bottomNavigationBar:
          loadedList == null || loadedList.isLocked || nextConcept == null
          ? null
          : PassqlBottomActionBar(
              actions: [
                PassqlButton(
                  label: '${nextConcept.title} 이어서',
                  onPressed: () => context.push(
                    AppRoutes.conceptStudy(nextConcept.conceptUuid),
                  ),
                ),
              ],
            ),
    );
  }

  /// 이어서 볼 개념: 아직 풀이를 끝내지 않은 첫 개념 (모두 끝났으면 없음)
  static ConceptSummary? _findNextConcept(ConceptListResponse list) {
    for (final concept in list.concepts) {
      if (concept.status != ConceptStatus.solved) return concept;
    }
    return null;
  }
}

/// 진행 머리 카드 + 개념 목록
class _ConceptListBody extends StatelessWidget {
  const _ConceptListBody({required this.list});

  final ConceptListResponse list;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final solvedCount = list.concepts
        .where((concept) => concept.status == ConceptStatus.solved)
        .length;
    final remainingCount = list.concepts.length - solvedCount;
    final progress = list.concepts.isEmpty
        ? 0.0
        : solvedCount / list.concepts.length;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        PassqlSpacing.lg,
        PassqlSpacing.sm,
        PassqlSpacing.lg,
        MediaQuery.paddingOf(context).bottom + PassqlSpacing.xxl,
      ),
      children: [
        PassqlCard(
          child: Row(
            children: [
              PassqlProgressRing(
                value: progress,
                centerText: '$solvedCount/${list.concepts.length}',
              ),
              const SizedBox(width: PassqlSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remainingCount == 0
                          ? '이 단원을 모두 끝냈어요'
                          : '남은 개념 $remainingCount개',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
                    ),
                    const SizedBox(height: PassqlSpacing.xxs),
                    Text(
                      '아는 개념은 읽기를 건너뛰고 문제만 풀어도 돼요.',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PassqlSpacing.lg),
        PassqlGroupedSection(
          children: [
            for (final (index, concept) in list.concepts.indexed)
              _ConceptRow(order: index + 1, concept: concept),
          ],
        ),
      ],
    );
  }
}

/// 개념 한 줄: 상태 아이콘(완료 체크, 읽음 책, 안 함 순번) > 제목 > 상태 문구
class _ConceptRow extends StatelessWidget {
  const _ConceptRow({required this.order, required this.concept});

  final int order;
  final ConceptSummary concept;

  @override
  Widget build(BuildContext context) {
    return PassqlListRow(
      leading: _ConceptStatusIcon(order: order, status: concept.status),
      title: concept.title,
      subtitle: _statusTextOf(concept),
      hasChevron: true,
      onTap: () => context.push(AppRoutes.conceptStudy(concept.conceptUuid)),
    );
  }

  /// 상태 > 한 줄 문구 (확인 문제 정답 수 포함)
  static String _statusTextOf(ConceptSummary concept) {
    final checkText =
        '확인 ${concept.checkCorrectCount}/${concept.checkQuestionCount}';
    return switch (concept.status) {
      ConceptStatus.solved => '풀이 완료 · $checkText',
      ConceptStatus.read => '읽음 · 확인 문제 남음',
      ConceptStatus.notStarted => concept.summary ?? '아직 안 봤어요',
    };
  }
}

/// 상태 아이콘 (스크린리더는 행 문구로 읽음)
class _ConceptStatusIcon extends StatelessWidget {
  const _ConceptStatusIcon({required this.order, required this.status});

  final int order;
  final ConceptStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final Widget icon = switch (status) {
      ConceptStatus.solved => Icon(
        CupertinoIcons.checkmark_circle_fill,
        color: colors.correct,
        size: PassqlIconSize.lg,
      ),
      ConceptStatus.read => Icon(
        CupertinoIcons.book_fill,
        color: colors.accent,
        size: PassqlIconSize.lg,
      ),
      ConceptStatus.notStarted => Text(
        '$order',
        style: PassqlTypography.subheadlineSemibold.copyWith(
          color: colors.secondaryLabel,
          fontFeatures: PassqlTypography.tabular,
        ),
      ),
    };
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: PassqlIconSize.lg,
        child: Center(child: icon),
      ),
    );
  }
}
