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

/// 피드 보기 1개의 본문 sliver (#741: 큰 제목 틀 안에 들어가 스크롤·새로고침·더 불러오기는 페이지가 맡음)
/// 상태 4종: 로딩, 오류(다시 시도), 빈 목록, 목록
class CommunityFeedList extends ConsumerWidget {
  const CommunityFeedList({super.key, required this.source});

  final CommunityFeedSource source;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(communityFeedProvider(source));
    final feedState = feed.valueOrNull;
    if (feedState == null) {
      return PassqlSliverFillStatus(
        child: feed.hasError
            ? PassqlStatusView.error(
                message: _errorMessageOf(feed.error!),
                onRetry: () => ref.invalidate(communityFeedProvider(source)),
              )
            : const PassqlStatusView.loading(),
      );
    }
    if (feedState.items.isEmpty) {
      final emptyText = _emptyTexts[source]!;
      return PassqlSliverFillStatus(
        child: PassqlStatusView.empty(
          icon: CupertinoIcons.chat_bubble_2,
          title: emptyText.title,
          message: emptyText.message,
          actionLabel: emptyText.actionLabel,
          onAction: () => emptyText.isTrendAction
              ? context.go(QuestionsTabView.latestTrend.location)
              : context.go(AppRoutes.questions),
        ),
      );
    }
    final colors = context.passqlColors;
    return SliverMainAxisGroup(
      slivers: [
        // 카드 대신 좌우 끝까지 닿는 목록 + 글자 시작선부터 그은 얇은 구분선 (#741)
        SliverList.separated(
          itemCount: feedState.items.length,
          separatorBuilder: (_, _) => ColoredBox(
            color: colors.card,
            child: Padding(
              padding: const EdgeInsets.only(
                left: CommunityFeedCardTile.separatorIndent,
              ),
              child: Container(
                height: PassqlSize.hairline,
                color: colors.separator,
              ),
            ),
          ),
          itemBuilder: (_, index) {
            final card = feedState.items[index];
            return CommunityFeedCardTile(
              key: ValueKey(card.questionUuid),
              card: card,
              shouldShowMyActivity: source == CommunityFeedSource.mine,
              onTap: () =>
                  context.push(AppRoutes.communityQuestion(card.questionUuid)),
            );
          },
        ),
        if (feedState.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(PassqlSpacing.md),
              child: Center(child: PassqlLoadingIndicator()),
            ),
          ),
      ],
    );
  }

  static String _errorMessageOf(Object error) =>
      error is AppException ? error.message : '토론을 불러오지 못했어요.';
}
