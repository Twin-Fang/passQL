import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/concept_providers.dart';
import '../../widgets/concept/concept_status_mark.dart';
import '../../widgets/pro/locked_preview_samples.dart';
import '../../widgets/pro/pro_locked_section.dart';

/// 단원 상세 (#577, #764): 머리 구간(남은 개념 큰 글자·막대) > 개념 구간(상태별 줄) > 하단 이어서 학습 버튼
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

/// 머리 구간 + 개념 구간 (다른 탭처럼 위·사이 회색 띠)
class _ConceptListBody extends StatelessWidget {
  const _ConceptListBody({required this.list});

  final ConceptListResponse list;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + PassqlSpacing.xxl,
      ),
      children: [
        const PassqlSectionGap(),
        PassqlReveal(child: _TopicProgressSection(list: list)),
        const PassqlSectionGap(),
        PassqlReveal(
          index: 1,
          child: PassqlSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, concept) in list.concepts.indexed)
                  _ConceptRow(order: index + 1, concept: concept),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 머리 구간: "N단원 · 이름" > 남은 개념 큰 글자 > 막대.
/// "건너뛰어도 돼요" 안내는 아직 아무것도 안 본 단원에서만 (올 때마다 같은 문장을 반복하지 않게)
class _TopicProgressSection extends ConsumerWidget {
  const _TopicProgressSection({required this.list});

  final ConceptListResponse list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    // 단원 순번은 단원 목록에만 있음 (개념 탭에서 왔으면 이미 불러온 값, 없으면 이름만)
    final topicOrder = ref
        .watch(conceptTopicsProvider)
        .valueOrNull
        ?.topics
        .where((topic) => topic.topicUuid == list.topicUuid)
        .firstOrNull
        ?.orderIndex;
    final total = list.concepts.length;
    final solvedCount = list.concepts
        .where((concept) => concept.status == ConceptStatus.solved)
        .length;
    final remainingCount = total - solvedCount;
    final isUntouched = list.concepts.every(
      (concept) => concept.status == ConceptStatus.notStarted,
    );
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            topicOrder == null
                ? list.displayName
                : '${topicOrder + 1}단원 · ${list.displayName}',
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.hairlineGap),
          Text(
            remainingCount == 0 ? '이 단원을 모두 끝냈어요' : '남은 개념 $remainingCount개',
            style: PassqlTypography.title1.copyWith(color: colors.label),
          ),
          if (isUntouched) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              '아는 개념은 읽기를 건너뛰고 문제만 풀어도 돼요.',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.sm),
          PassqlProgressBar(
            value: total == 0 ? 0 : solvedCount / total,
            semanticValue: '개념 $total개 중 $solvedCount개 끝냄',
          ),
        ],
      ),
    );
  }
}

/// 개념 한 줄: 상태 원(완료 체크·읽음 보라 번호·안 함 회색 번호) > 제목(두 줄까지) > 오른쪽 짧은 상태
class _ConceptRow extends StatelessWidget {
  const _ConceptRow({required this.order, required this.concept});

  final int order;
  final ConceptSummary concept;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final (markKind, trailingText, trailingColor) = switch (concept.status) {
      ConceptStatus.solved => (
        ConceptStatusMarkKind.done,
        '${concept.checkCorrectCount}/${concept.checkQuestionCount}',
        colors.correctText,
      ),
      ConceptStatus.read => (
        ConceptStatusMarkKind.active,
        '읽음',
        colors.accentText,
      ),
      ConceptStatus.notStarted => (
        ConceptStatusMarkKind.idle,
        null,
        colors.secondaryLabel,
      ),
    };
    return PassqlListRow(
      hasHorizontalPadding: false,
      leading: ConceptStatusMark(
        shape: ConceptStatusMarkShape.circle,
        status: markKind,
        order: order,
      ),
      title: concept.title,
      titleMaxLines: 2,
      trailing: trailingText == null
          ? null
          : Text(
              trailingText,
              style: PassqlTypography.subheadline.copyWith(
                color: trailingColor,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
      hasChevron: true,
      onTap: () => context.push(AppRoutes.conceptStudy(concept.conceptUuid)),
    );
  }
}
