import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/markdown_preview.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';

/// 의견 목록 상단 문제 카드: 토픽 배지 + 지문 앞 3줄(마크다운 표기 제거) + '문제 다시 보기'
/// 문제 상세 조회 전·실패면 숨김 (의견 목록은 그대로 사용 가능)
class CommunityQuestionHeader extends ConsumerWidget {
  const CommunityQuestionHeader({super.key, required this.questionUuid});

  final String questionUuid;

  // 지문 미리보기 최대 줄 수
  static const int _stemPreviewMaxLines = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final question = ref
        .watch(questionDetailProvider(questionUuid))
        .valueOrNull;
    if (question == null) return const SizedBox.shrink();
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        0,
      ),
      child: PassqlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.topicName != null)
              PassqlBadge(text: question.topicName!),
            if (question.topicName != null)
              const SizedBox(height: PassqlSpacing.xs),
            Text(
              toMarkdownPreviewText(question.stem),
              maxLines: _stemPreviewMaxLines,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.callout.copyWith(color: colors.label),
            ),
            // 본문과 왼쪽 선을 맞춘 텍스트 링크 (터치 영역 44pt)
            PassqlPressable(
              onTap: () => context.push(AppRoutes.questionDetail(questionUuid)),
              semanticLabel: '문제 다시 보기',
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: PassqlSize.minTouchTarget,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.arrow_uturn_left,
                      size: PassqlIconSize.sm,
                      color: colors.accent,
                    ),
                    const SizedBox(width: PassqlSpacing.xxs),
                    Text(
                      '문제 다시 보기',
                      style: PassqlTypography.subheadlineSemibold.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
