import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_colors.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/text_styles.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/progress/wrong_questions_response.dart';
import '../../../router/app_routes.dart';
import '../../providers/wrong_questions_provider.dart';

/// 오답 노트 섹션. 최근에 틀린 문제를 보여주고, 누르면 그 문제로 이동한다.
class WrongNotesSection extends ConsumerWidget {
  const WrongNotesSection({super.key, this.showHeader = true});

  /// 앱바에 이미 제목이 있는 전용 화면에서는 카드 안 제목을 숨긴다.
  final bool showHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wrongQuestionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    '오답 노트',
                    style: AppTextStyles.label_16.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (async.valueOrNull case final data?)
                    Text(
                      '${data.totalCount}',
                      style: AppTextStyles.paragraph_14.copyWith(
                        color: AppColors.brandIndigo,
                      ),
                    ),
                ],
              ),
            ),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (e, _) => _Message(
              text: e.asAppException.message,
              actionLabel: '다시 시도',
              onAction: () => ref.invalidate(wrongQuestionsProvider),
            ),
            data: (data) => data.items.isEmpty
                ? const _Message(text: '아직 틀린 문제가 없어요. 문제를 풀면 오답이 여기에 쌓여요')
                : Column(
                    children: [
                      // 제목이 없으면 첫 행의 윗줄이 카드 테두리와 겹치므로 그리지 않는다.
                      for (final (i, item) in data.items.indexed)
                        _WrongRow(item: item, topBorder: showHeader || i > 0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _WrongRow extends StatelessWidget {
  const _WrongRow({required this.item, this.topBorder = true});

  final WrongQuestionItem item;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    final when = formatRelativeDay(item.lastWrongAt);
    final meta = [
      if (item.topicName != null) item.topicName!,
      if (when.isNotEmpty) when,
    ].join(' · ');

    return InkWell(
      onTap: () => context.push(AppRoutes.questionDetail(item.questionUuid)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          border: topBorder
              ? const Border(top: BorderSide(color: AppColors.borderDefault))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.stemPreview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.paragraph_14.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            if (meta.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                meta,
                style: AppTextStyles.tag_12.copyWith(
                  color: AppColors.textCaption,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.actionLabel, this.onAction});

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.paragraph_14.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.paragraph_14.copyWith(
                  color: AppColors.brandIndigo,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
