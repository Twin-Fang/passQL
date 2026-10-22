import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/progress/wrong_questions_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/wrong_questions_provider.dart';
import '../question/stem_text.dart';

/// 오답 노트 섹션. 최근에 틀린 문제를 보여주고, 누르면 그 문제로 이동한다.
class WrongNotesSection extends ConsumerWidget {
  const WrongNotesSection({super.key, this.shouldShowHeader = true});

  /// 내비게이션 바에 이미 제목이 있는 전용 화면에서는 섹션 제목을 숨긴다.
  final bool shouldShowHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final wrongQuestionsAsync = ref.watch(wrongQuestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldShowHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              0,
              PassqlSpacing.md,
              PassqlSpacing.xs,
            ),
            child: Row(
              children: [
                Text(
                  '오답 노트',
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                const SizedBox(width: PassqlSpacing.xs),
                if (wrongQuestionsAsync.valueOrNull case final data?)
                  Text(
                    '${data.totalCount}',
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.accentText,
                    ),
                  ),
              ],
            ),
          ),
        // 로딩 자리 스켈레톤 > 목록·빈·오류 페이드 교체
        PassqlFadeSwitcher(
          child: wrongQuestionsAsync.when(
            loading: () => const PassqlListSkeleton(key: ValueKey('loading')),
            error: (error, _) => KeyedSubtree(
              key: const ValueKey('error'),
              child: PassqlStatusView.error(
                message: error.asAppException.message,
                onRetry: () => ref.invalidate(wrongQuestionsProvider),
              ),
            ),
            data: (data) => KeyedSubtree(
              key: const ValueKey('data'),
              child: data.items.isEmpty
                  ? PassqlStatusView.empty(
                      icon: CupertinoIcons.checkmark_seal,
                      title: '아직 틀린 문제가 없어요',
                      message: '문제를 풀면 오답이 여기에 쌓여요',
                    )
                  : PassqlGroupedSection(
                      children: [
                        for (final item in data.items) _WrongRow(item: item),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WrongRow extends StatelessWidget {
  const _WrongRow({required this.item});

  final WrongQuestionItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final when = formatRelativeDay(item.lastWrongAt);
    final meta = [
      if (item.topicName != null) item.topicName!,
      if (when.isNotEmpty) when,
    ].join(' · ');

    return PassqlPressable(
      onTap: () => context.push(AppRoutes.questionDetail(item.questionUuid)),
      // 읽는 순서: 오답 > 지문 > 토픽·시점 (화면 글자는 덮음)
      semanticLabel: [
        '오답',
        stripCodeFences(item.stemPreview),
        if (meta.isNotEmpty) meta,
      ].join(', '),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.md,
          vertical: PassqlSpacing.sm,
        ),
        child: Row(
          children: [
            // 아이콘만 쓰면 오답 표식이 글자 없이 들어간다(PassqlResultMark 는 라벨이 붙는다).
            Icon(
              CupertinoIcons.xmark_circle_fill,
              size: PassqlIconSize.lg,
              color: colors.wrong,
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stripCodeFences(item.stemPreview),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: PassqlSpacing.xxs),
                    Text(
                      meta,
                      style: PassqlTypography.caption.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Icon(
              CupertinoIcons.chevron_forward,
              size: PassqlIconSize.xs,
              color: colors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
