import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/progress/wrong_questions_response.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/wrong_questions_provider.dart';
import 'question_preview_row.dart';

/// 오답 노트 섹션. 필터에 맞는 오답을 보여주고, 누르면 그 문제로 이동한다.
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
                      title: '남은 오답이 없어요',
                      message: '틀린 문제를 다시 맞히면 목록에서 빠져요',
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
    return QuestionPreviewRow(
      // 아이콘만 쓰면 오답 표식이 글자 없이 들어간다(PassqlResultMark 는 라벨이 붙는다).
      // 정리된 문제(다시 맞힘)는 정답 표식
      leading: Icon(
        item.isResolved
            ? CupertinoIcons.checkmark_circle_fill
            : CupertinoIcons.xmark_circle_fill,
        size: PassqlIconSize.lg,
        color: item.isResolved ? colors.correct : colors.wrong,
      ),
      leadingSemanticLabel: '오답',
      stemPreview: item.stemPreview,
      // 메타 한 줄: 정리됨 | 토픽 | N번 틀림 | 시점 (#1081)
      metaParts: [
        if (item.isResolved) '정리됨',
        item.topicName ?? '',
        if (item.wrongCount > 0) '${item.wrongCount}번 틀림',
        formatRelativeDay(item.lastWrongAt),
      ],
      onTap: () => context.push(AppRoutes.wrongNoteRetry(item.questionUuid)),
    );
  }
}
