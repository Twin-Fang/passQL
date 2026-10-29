import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/markdown_preview.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/question_providers.dart';

/// 의견 목록 위 문제 블록 (게시글 자리, #741): 주제 이름 + 오른쪽 '문제 보기 ›', 지문 앞 3줄(마크다운 표기 제거)
/// 주제 아이콘 타일은 두지 않는다: 문제 상세 응답에 주제 코드가 없어 아이콘·색을 정할 수 없다
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
    final topicName = question.topicName;
    return ColoredBox(
      color: colors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xxs,
          PassqlSpacing.md,
          PassqlSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: topicName == null
                      ? const SizedBox.shrink()
                      : Text(
                          topicName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PassqlTypography.footnoteSemibold.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                ),
                // 작은 글자 링크라 누르는 영역만 44로 넓힌다
                PassqlPressable(
                  onTap: () =>
                      context.push(AppRoutes.questionDetail(questionUuid)),
                  semanticLabel: '문제 보기',
                  hasMinimumTouchTarget: true,
                  child: Text(
                    '문제 보기 ›',
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.accentText,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              toMarkdownPreviewText(question.stem),
              maxLines: _stemPreviewMaxLines,
              overflow: TextOverflow.ellipsis,
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ],
        ),
      ),
    );
  }
}
