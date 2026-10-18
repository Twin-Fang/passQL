import 'package:flutter/material.dart';

import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../widgets/community/community_choice_chips.dart';
import '../../widgets/community/community_feed_list.dart';

/// 토론 탭 첫 화면(탭 루트라 뒤로가기 없음) 커뮤니티 피드: 탭 4개(뜨는 토론·최신 경향·내가 푼 문제·내 의견), 본문은 [CommunityFeedList]
/// [initialSource]: 시작 탭 (?source=mine 진입 시 mine)
class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({
    super.key,
    this.initialSource = CommunityFeedSource.hot,
  });

  final CommunityFeedSource initialSource;

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  late CommunityFeedSource _selectedSource = widget.initialSource;

  @override
  void didUpdateWidget(CommunityFeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 탭 유지 중 ?source= 가 바뀐 진입이면 칩 갱신
    if (oldWidget.initialSource != widget.initialSource) {
      _selectedSource = widget.initialSource;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PassqlNavBar(title: '토론', leading: PassqlNavLeading.none),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
            child: CommunityChoiceChips<CommunityFeedSource>(
              values: CommunityFeedSource.values,
              labelOf: (source) => source.label,
              selectedValue: _selectedSource,
              onSelected: (source) => setState(() => _selectedSource = source),
            ),
          ),
          Expanded(
            child: CommunityFeedList(
              key: ValueKey(_selectedSource),
              source: _selectedSource,
            ),
          ),
        ],
      ),
    );
  }
}
