import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../data/models/community/community_models.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../../router/questions_tab_view.dart';
import '../../providers/community_providers.dart';
import 'community_feed_card_tile.dart';

/// 피드 탭 1개의 본문: 당겨서 새로고침 + 커서 무한 스크롤
/// 상태 4종: 로딩, 오류(다시 시도), 빈 목록, 목록
class CommunityFeedList extends ConsumerStatefulWidget {
  const CommunityFeedList({super.key, required this.source});

  final CommunityFeedSource source;

  @override
  ConsumerState<CommunityFeedList> createState() => _CommunityFeedListState();
}

class _CommunityFeedListState extends ConsumerState<CommunityFeedList> {
  final _scrollController = ScrollController();

  // 목록 끝까지 남은 거리가 이 값 이하면 다음 페이지 요청
  static const double _loadMoreTriggerPixels = 320;

  // 탭별 빈 목록 안내 + 행동 버튼 (문구는 웹 COMMUNITY_FEED_TABS 와 맞춤)
  static const Map<
    CommunityFeedSource,
    ({String title, String message, String actionLabel, bool isTrendAction})
  >
  _emptyTexts = {
    CommunityFeedSource.hot: (
      title: '첫 토론을 시작해 보세요',
      message: '문제를 풀고 첫 의견을 남겨 보세요',
      actionLabel: _solveActionLabel,
      isTrendAction: false,
    ),
    CommunityFeedSource.trend: (
      title: '최신 경향 문제의 의견이 아직 없어요',
      message: '출제 경향에서 최신 문제를 확인해 보세요',
      actionLabel: '출제 경향 보기',
      isTrendAction: true,
    ),
    CommunityFeedSource.solved: (
      title: '문제를 풀면 여기에 모여요',
      message: '풀어 본 문제의 의견이 이곳에 쌓여요',
      actionLabel: _solveActionLabel,
      isTrendAction: false,
    ),
    CommunityFeedSource.mine: (
      title: '아직 남긴 의견이 없어요',
      message: '푼 문제에서 헷갈린 점을 나눠 보세요',
      actionLabel: _solveActionLabel,
      isTrendAction: false,
    ),
  };

  static const String _solveActionLabel = '문제 풀러 가기';

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

  CommunityFeedNotifier get _notifier =>
      ref.read(communityFeedProvider(widget.source).notifier);

  void _loadMoreNearEnd() {
    if (_scrollController.position.extentAfter <= _loadMoreTriggerPixels) {
      _notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(communityFeedProvider(widget.source));
    final feedState = feed.valueOrNull;
    if (feedState == null) {
      return feed.hasError
          ? PassqlStatusView.error(
              message: _errorMessageOf(feed.error!),
              onRetry: () =>
                  ref.invalidate(communityFeedProvider(widget.source)),
            )
          : const PassqlStatusView.loading();
    }
    if (feedState.items.isEmpty) {
      final emptyText = _emptyTexts[widget.source]!;
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(onRefresh: _notifier.reload),
          SliverFillRemaining(
            hasScrollBody: false,
            child: PassqlStatusView.empty(
              icon: CupertinoIcons.chat_bubble_2,
              title: emptyText.title,
              message: emptyText.message,
              actionLabel: emptyText.actionLabel,
              onAction: () => emptyText.isTrendAction
                  ? context.go(QuestionsTabView.latestTrend.location)
                  : context.go(AppRoutes.questions),
            ),
          ),
        ],
      );
    }
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _notifier.reload),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            0,
          ),
          sliver: SliverList.separated(
            itemCount: feedState.items.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: PassqlSpacing.sm),
            itemBuilder: (_, index) {
              final card = feedState.items[index];
              return CommunityFeedCardTile(
                key: ValueKey(card.questionUuid),
                card: card,
                shouldShowMyActivity: widget.source == CommunityFeedSource.mine,
                onTap: () => context.push(
                  AppRoutes.communityQuestion(card.questionUuid),
                ),
              );
            },
          ),
        ),
        if (feedState.isLoadingMore)
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

  static String _errorMessageOf(Object error) =>
      error is AppException ? error.message : '토론을 불러오지 못했어요.';
}
