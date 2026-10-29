import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_providers.dart';
import '../../widgets/common/load_more_scroll_metrics.dart';
import '../../widgets/community/community_feed_list.dart';

/// 토론 탭 첫 화면(탭 루트라 뒤로가기 없음) 커뮤니티 피드: 문제 탭과 같은 큰 제목 + 세그먼트 4칸(뜨는 토론·최신 경향·내가 푼 문제·내 의견), 본문은 [CommunityFeedList]
/// [initialSource]: 시작 탭 (?source=mine 진입 시 mine)
class CommunityFeedPage extends ConsumerStatefulWidget {
  const CommunityFeedPage({
    super.key,
    this.initialSource = CommunityFeedSource.hot,
  });

  final CommunityFeedSource initialSource;

  @override
  ConsumerState<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends ConsumerState<CommunityFeedPage> {
  late CommunityFeedSource _selectedSource = widget.initialSource;

  @override
  void didUpdateWidget(CommunityFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 탭 유지 중 ?source= 가 바뀐 진입이면 세그먼트 갱신
    if (oldWidget.initialSource != widget.initialSource) {
      _selectedSource = widget.initialSource;
    }
  }

  CommunityFeedNotifier get _notifier =>
      ref.read(communityFeedProvider(_selectedSource).notifier);

  // 스크롤은 큰 제목 틀이 가지므로 알림으로 끝 근처를 감지한다.
  // 중복 요청은 notifier 가 hasMore·isLoadingMore 로 막는다
  bool _loadMoreNearEnd(ScrollUpdateNotification notification) {
    if (notification.metrics.isNearLoadMoreEnd) {
      _notifier.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: _loadMoreNearEnd,
        child: PassqlLargeTitleScrollView(
          title: '토론',
          onRefresh: () => _notifier.reload(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                PassqlSpacing.md,
                PassqlSpacing.xs,
                PassqlSpacing.md,
                PassqlSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: PassqlSegmentedControl<CommunityFeedSource>(
                  segments: [
                    for (final source in CommunityFeedSource.values)
                      PassqlSegment(value: source, label: source.label),
                  ],
                  selectedValue: _selectedSource,
                  onSelected: (source) =>
                      setState(() => _selectedSource = source),
                ),
              ),
            ),
            CommunityFeedList(
              key: ValueKey(_selectedSource),
              source: _selectedSource,
            ),
          ],
        ),
      ),
    );
  }
}
