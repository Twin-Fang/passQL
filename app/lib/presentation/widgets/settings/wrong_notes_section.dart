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
  const WrongNotesSection({super.key, this.showHeader = true});

  /// 내비게이션 바에 이미 제목이 있는 전용 화면에서는 섹션 제목을 숨긴다.
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.pq;
    final async = ref.watch(wrongQuestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PqSpace.md,
              0,
              PqSpace.md,
              PqSpace.xs,
            ),
            child: Row(
              children: [
                Text('오답 노트', style: PqType.headline.copyWith(color: c.label)),
                const SizedBox(width: PqSpace.xs),
                if (async.valueOrNull case final data?)
                  Text(
                    '${data.totalCount}',
                    style: PqType.subheadline.copyWith(color: c.accent),
                  ),
              ],
            ),
          ),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(PqSpace.xl),
            child: PqStatusView.loading(),
          ),
          error: (e, _) => PqStatusView.error(
            message: e.asAppException.message,
            onRetry: () => ref.invalidate(wrongQuestionsProvider),
          ),
          data: (data) => data.items.isEmpty
              ? PqStatusView.empty(
                  icon: CupertinoIcons.checkmark_seal,
                  title: '아직 틀린 문제가 없어요',
                  message: '문제를 풀면 오답이 여기에 쌓여요',
                )
              : PqGroupedSection(
                  children: [
                    for (final item in data.items) _WrongRow(item: item),
                  ],
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
    final c = context.pq;
    final when = formatRelativeDay(item.lastWrongAt);
    final meta = [
      if (item.topicName != null) item.topicName!,
      if (when.isNotEmpty) when,
    ].join(' · ');

    return PqPressable(
      onTap: () => context.push(AppRoutes.questionDetail(item.questionUuid)),
      semanticLabel: item.stemPreview,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PqSpace.md,
          vertical: PqSpace.sm,
        ),
        child: Row(
          children: [
            // 아이콘만 쓰면 오답 표식이 글자 없이 들어간다(PqResultMark 는 라벨이 붙는다).
            Icon(CupertinoIcons.xmark_circle_fill, size: 20, color: c.wrong),
            const SizedBox(width: PqSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stripCodeFences(item.stemPreview),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PqType.subheadline.copyWith(color: c.label),
                  ),
                  if (meta.isNotEmpty) ...[
                    const SizedBox(height: PqSpace.xxs),
                    Text(
                      meta,
                      style: PqType.caption.copyWith(color: c.tertiaryLabel),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: PqSpace.xs),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: c.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
