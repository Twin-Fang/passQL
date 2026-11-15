import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/utils/relative_time.dart';
import '../../../data/models/bookmark/question_bookmark_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/bookmark_providers.dart';
import '../../widgets/mock_exam/mock_exam_number_grid.dart';
import '../../widgets/question/question_preview_row.dart';

/// 즐겨찾기 화면 (#1082): 즐겨찾기 풀기 버튼 > 최근 추가 순 목록 (누르면 그 문제 풀기)
/// 프로필 즐겨찾기 행에서 진입, 등급 제한 없음
class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    return Scaffold(
      appBar: PassqlNavBar(title: '즐겨찾기', leading: PassqlNavLeading.back),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          // 로딩 자리 스켈레톤 > 목록·빈·오류 페이드 교체
          child: PassqlFadeSwitcher(
            child: bookmarksAsync.when(
              loading: () => const PassqlListSkeleton(key: ValueKey('loading')),
              error: (error, _) => KeyedSubtree(
                key: const ValueKey('error'),
                child: PassqlStatusView.error(
                  message: error.asAppException.message,
                  onRetry: () => ref.invalidate(bookmarksProvider),
                ),
              ),
              data: (response) => KeyedSubtree(
                key: const ValueKey('data'),
                child: response.items.isEmpty
                    ? PassqlStatusView.empty(
                        icon: CupertinoIcons.star,
                        title: '즐겨찾기한 문제가 없어요',
                        message: '풀이 화면 위 별을 누르면 여기에 모여요',
                      )
                    : _BookmarkContent(response: response),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 풀기 버튼 > 목록 > (더 있으면) 안내 한 줄
class _BookmarkContent extends StatelessWidget {
  const _BookmarkContent({required this.response});

  final QuestionBookmarksResponse response;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final practiceCount = response.totalCount < bookmarkPracticeSetSize
        ? response.totalCount
        : bookmarkPracticeSetSize;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlButton(
          label: '즐겨찾기 $practiceCount문제 풀기',
          icon: CupertinoIcons.play_fill,
          onPressed: () => context.push(AppRoutes.bookmarkPractice),
        ),
        const SizedBox(height: PassqlSpacing.md),
        PassqlGroupedSection(
          header: '최근 추가한 순 ${response.totalCount}문제',
          children: [
            for (final item in response.items) _BookmarkRow(item: item),
          ],
        ),
        if (response.hasNext) ...[
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            '최근 추가한 $bookmarkListPageSize문제까지 보여요',
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
      ],
    );
  }
}

class _BookmarkRow extends StatelessWidget {
  const _BookmarkRow({required this.item});

  final QuestionBookmarkItem item;

  @override
  Widget build(BuildContext context) {
    return QuestionPreviewRow(
      leading: Icon(
        CupertinoIcons.star_fill,
        size: PassqlIconSize.lg,
        color: context.passqlColors.warning,
      ),
      leadingSemanticLabel: '즐겨찾기',
      stemPreview: item.stemPreview,
      // 메타 한 줄: 토픽 | 과목 | 추가 시점
      metaParts: [
        item.topicName ?? '',
        mockExamSubjectShortName(item.subject),
        formatRelativeDay(item.bookmarkedAt),
      ],
      onTap: () => context.push(AppRoutes.questionDetail(item.questionUuid)),
    );
  }
}
