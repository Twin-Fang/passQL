import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../data/models/community/community_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/common/load_more_scroll_metrics.dart';
import '../../widgets/community/community_compose_bar.dart';
import '../../widgets/community/community_compose_sheet.dart';
import '../../widgets/community/community_post_menu.dart';
import '../../widgets/community/community_question_header.dart';
import '../../widgets/community/community_post_tile.dart';

/// 문제 1개의 의견 목록: 정렬(최신/좋아요순), 좋아요, 글 메뉴(삭제·신고·차단), 작성 시트
/// 풀기 전이면 의견 대신 '풀고 나서 볼 수 있어요' 안내 + 풀기 버튼 (정답 노출 방지)
class CommunityQuestionPage extends ConsumerStatefulWidget {
  const CommunityQuestionPage({super.key, required this.questionUuid});

  final String questionUuid;

  @override
  ConsumerState<CommunityQuestionPage> createState() =>
      _CommunityQuestionPageState();
}

class _CommunityQuestionPageState extends ConsumerState<CommunityQuestionPage> {
  final _scrollController = ScrollController();
  CommunityPostSort _sort = CommunityPostSort.latest;

  CommunityPostsQuery get _query =>
      (questionUuid: widget.questionUuid, sort: _sort);

  CommunityPostsNotifier get _notifier =>
      ref.read(communityQuestionPostsProvider(_query).notifier);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreNearEnd);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreNearEnd() {
    if (_scrollController.position.isNearLoadMoreEnd) {
      _notifier.loadMore();
    }
  }

  Future<void> _toggleLike(CommunityPost post) async {
    try {
      await _notifier.toggleLike(post);
    } on AppException catch (exception) {
      if (mounted) showAppToast(context, exception.message);
    }
  }

  Future<void> _openComposeSheet() async {
    final isPosted = await CommunityComposeSheet.show(context, _query);
    if (isPosted == true && mounted) showAppToast(context, '의견을 등록했어요');
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(communityQuestionPostsProvider(_query));
    final error = posts.error;
    final isSolveRequired =
        error is AppException && error.code == ErrorCode.communitySolveRequired;
    return Scaffold(
      appBar: const PassqlNavBar(title: '의견', leading: PassqlNavLeading.back),
      bottomNavigationBar: posts.hasValue
          ? CommunityComposeBar(onTap: _openComposeSheet)
          : null,
      body: isSolveRequired
          ? _SolveRequiredView(
              questionUuid: widget.questionUuid,
              onSolveTap: () =>
                  context.push(AppRoutes.questionDetail(widget.questionUuid)),
            )
          : Column(
              children: [
                CommunityQuestionHeader(questionUuid: widget.questionUuid),
                _SortRow(
                  sort: _sort,
                  onToggle: () => setState(
                    () => _sort = _sort == CommunityPostSort.latest
                        ? CommunityPostSort.likes
                        : CommunityPostSort.latest,
                  ),
                ),
                Expanded(child: _buildPosts(posts)),
              ],
            ),
    );
  }

  Widget _buildPosts(AsyncValue<CommunityPostsState> posts) {
    final postsState = posts.valueOrNull;
    if (postsState == null) {
      final error = posts.error;
      return error == null
          ? const PassqlStatusView.loading()
          : PassqlStatusView.error(
              message: error is AppException ? error.message : '의견을 불러오지 못했어요.',
              onRetry: () =>
                  ref.invalidate(communityQuestionPostsProvider(_query)),
            );
    }
    final separatorColor = context.passqlColors.separator;
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _notifier.reload),
        if (postsState.items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: PassqlStatusView.empty(
              icon: CupertinoIcons.chat_bubble_2,
              title: '아직 의견이 없어요',
              message: '첫 의견을 남겨 보세요',
            ),
          )
        else
          SliverList.separated(
            itemCount: postsState.items.length,
            separatorBuilder: (_, _) => Padding(
              padding: const EdgeInsets.only(left: PassqlSpacing.md),
              child: Container(
                height: PassqlSize.hairline,
                color: separatorColor,
              ),
            ),
            itemBuilder: (_, index) {
              final post = postsState.items[index];
              return CommunityPostTile(
                key: ValueKey(post.postUuid),
                post: post,
                onLikeTap: () => _toggleLike(post),
                onMenuTap: () => openCommunityPostMenu(
                  context,
                  ref,
                  post: post,
                  query: _query,
                ),
              );
            },
          ),
        if (postsState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(PassqlSpacing.md),
              child: Center(child: PassqlLoadingIndicator()),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + PassqlSpacing.xl,
          ),
        ),
      ],
    );
  }
}

/// 문제 블록과 의견 목록 사이 회색 띠 (#741): 왼쪽 운영 정책 안내, 오른쪽 정렬 토글(최신순 <-> 좋아요순)
/// 위 여백을 넓게, 아래를 좁게 둬 의견 목록의 머리말로 읽힌다
class _SortRow extends StatelessWidget {
  const _SortRow({required this.sort, required this.onToggle});

  final CommunityPostSort sort;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ColoredBox(
      color: colors.background,
      child: Padding(
        // 시안 값 위 24: 토글의 누르는 영역 44가 글자 줄 위로 넘치는 만큼 뺀다.
        // 아래는 그 넘침(약 13)이 여백 노릇을 해 따로 두지 않는다 (시안 10과 거의 같음)
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.xl - _toggleTouchOverflow,
          PassqlSpacing.md,
          0,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                CommunityComposeSheet.policyNotice,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.footnote.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
            PassqlPressable(
              onTap: onToggle,
              semanticLabel: '정렬: ${sort.label}, 바꾸기',
              hasMinimumTouchTarget: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sort.label,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.hairlineGap),
                  Icon(
                    CupertinoIcons.arrow_up_arrow_down,
                    size: PassqlIconSize.xs,
                    color: colors.label,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 44pt 누르는 영역이 글자 줄보다 위아래로 넘치는 만큼 (footnote 한 줄 약 18 > (44 - 18) / 2)
  static const double _toggleTouchOverflow = 13;
}

/// 풀기 전 안내: 의견 대신 풀기 유도
class _SolveRequiredView extends StatelessWidget {
  const _SolveRequiredView({
    required this.questionUuid,
    required this.onSolveTap,
  });

  final String questionUuid;
  final VoidCallback onSolveTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommunityQuestionHeader(questionUuid: questionUuid),
        Expanded(
          child: PassqlStatusView.empty(
            icon: CupertinoIcons.lock,
            title: '풀고 나서 의견을 볼 수 있어요',
            message: '먼저 문제를 풀어 보면 다른 수험생의 의견이 열려요',
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            0,
            PassqlSpacing.md,
            MediaQuery.paddingOf(context).bottom + PassqlSpacing.md,
          ),
          child: PassqlButton(label: '문제 풀기', onPressed: onSolveTap),
        ),
      ],
    );
  }
}
