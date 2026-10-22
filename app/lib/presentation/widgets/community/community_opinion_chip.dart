import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';

/// 문제 결과 화면 '의견 N' 칩: 탭 > 그 문제의 의견 목록 (정답 확인 후 노출)
/// 개수는 최신순 첫 페이지 기준, 다음 페이지가 있으면 "N+", 조회 전·실패면 개수 없이 '의견'
class CommunityOpinionChip extends ConsumerWidget {
  const CommunityOpinionChip({super.key, required this.questionUuid});

  final String questionUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final opinionCount = ref.watch(communityOpinionCountProvider(questionUuid));
    final label = opinionCount == null
        ? '의견'
        : opinionCount.count == 0
        ? '의견 남기기'
        : '의견 ${opinionCount.count}${opinionCount.hasMore ? '+' : ''}';
    return PassqlPressable(
      onTap: () => context.push(AppRoutes.communityQuestion(questionUuid)),
      semanticLabel: label,
      // 보이는 칩은 34, 누르는 영역은 44
      hasMinimumTouchTarget: true,
      child: Container(
        height: PassqlSize.buttonSmall,
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: BorderRadius.circular(PassqlRadius.capsule),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_2,
              size: PassqlIconSize.sm,
              color: colors.accentText,
            ),
            const SizedBox(width: PassqlSpacing.xxs),
            Text(
              label,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
