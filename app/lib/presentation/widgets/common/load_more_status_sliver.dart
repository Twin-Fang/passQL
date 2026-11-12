import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 무한 스크롤 목록 끝 상태 줄: 다음 페이지 받는 중 > 로딩, 실패 > 안내 + '다시 불러오기', 그 외 > 없음
/// 알림함·공지 목록·토론 피드·문제 의견 목록 공통 (#995)
class LoadMoreStatusSliver extends StatelessWidget {
  const LoadMoreStatusSliver({
    super.key,
    required this.isLoadingMore,
    required this.hasLoadMoreFailed,
    required this.onRetry,
  });

  final bool isLoadingMore;
  final bool hasLoadMoreFailed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!isLoadingMore && !hasLoadMoreFailed) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    final colors = context.passqlColors;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.md),
        child: Center(
          child: isLoadingMore
              ? const PassqlLoadingIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      PassqlLoadFailureCopy.loadMoreFailedMessage,
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                    PassqlButton(
                      label: PassqlLoadFailureCopy.reloadLabel,
                      onPressed: onRetry,
                      variant: PassqlButtonVariant.plain,
                      size: PassqlButtonSize.small,
                      isFullWidth: false,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
