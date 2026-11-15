import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/bookmark_providers.dart';
import '../common/app_toast.dart';

/// 풀이·해설 화면 상단 별 버튼 (#1082): 누르면 즐겨찾기 추가·해제, 실패하면 되돌리고 토스트
/// 상세를 불러오기 전에는 자리 없음
class QuestionBookmarkButton extends ConsumerWidget {
  const QuestionBookmarkButton({super.key, required this.questionUuid});

  final String questionUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarked = ref.watch(isQuestionBookmarkedProvider(questionUuid));
    if (isBookmarked == null) return const SizedBox.shrink();
    final colors = context.passqlColors;

    Future<void> toggleBookmark() async {
      PassqlHaptics.playSelection();
      try {
        await ref
            .read(questionBookmarkOverridesProvider.notifier)
            .toggle(questionUuid, isBookmarked: !isBookmarked);
      } catch (error) {
        if (context.mounted) {
          showAppToast(context, error.asAppException.message);
        }
        return;
      }
      if (context.mounted) {
        showAppToast(context, isBookmarked ? '즐겨찾기에서 뺐어요' : '즐겨찾기에 담았어요');
      }
    }

    return PassqlSemanticButton(
      label: '즐겨찾기',
      isSelected: isBookmarked,
      onTap: toggleBookmark,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xs),
        minimumSize: const Size.square(PassqlSize.minTouchTarget),
        onPressed: toggleBookmark,
        child: Icon(
          isBookmarked ? CupertinoIcons.star_fill : CupertinoIcons.star,
          size: PassqlIconSize.md,
          color: isBookmarked ? colors.warning : colors.iconSecondary,
        ),
      ),
    );
  }
}
