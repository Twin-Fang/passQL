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
import '../../widgets/community/community_choice_chips.dart';
import '../../widgets/community/community_compose_sheet.dart';
import '../../widgets/community/community_post_menu.dart';
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

  // 목록 끝까지 남은 거리가 이 값 이하면 다음 페이지 요청
  static const double _loadMoreTriggerPixels = 320;

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
    if (_scrollController.position.extentAfter <= _loadMoreTriggerPixels) {
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
          ? PassqlBottomActionBar(
              actions: [
                PassqlButton(label: '의견 쓰기', onPressed: _openComposeSheet),
              ],
            )
          : null,
      body: isSolveRequired
          ? _SolveRequiredView(
              onSolveTap: () =>
                  context.push(AppRoutes.questionDetail(widget.questionUuid)),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: PassqlSpacing.xs),
                  child: CommunityChoiceChips<CommunityPostSort>(
                    values: CommunityPostSort.values,
                    labelOf: (sort) => sort.label,
                    selectedValue: _sort,
                    onSelected: (sort) => setState(() => _sort = sort),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PassqlSpacing.md,
                    PassqlSpacing.xs,
                    PassqlSpacing.md,
                    PassqlSpacing.xxs,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CommunityComposeSheet.policyNotice,
                      style: PassqlTypography.footnote.copyWith(
                        color: context.passqlColors.tertiaryLabel,
                      ),
                    ),
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
              message: error is AppException
                  ? error.message
                  : '의견을 불러오지 못했어요.',
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

/// 풀기 전 안내: 의견 대신 풀기 유도
class _SolveRequiredView extends StatelessWidget {
  const _SolveRequiredView({required this.onSolveTap});

  final VoidCallback onSolveTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
