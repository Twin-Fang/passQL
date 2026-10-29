import 'package:flutter/cupertino.dart';

import '../../../data/models/meta/topic_tree.dart';
import '../../design/design.dart';

/// 토픽 선택 행. displayName + 서브토픽 개수 + (최신 경향 문제 있으면) 불꽃 아이콘 표시.
/// PassqlGroupedSection 안에서 쓰는 목록 행이다.
class TopicCard extends StatelessWidget {
  final TopicTree topic;
  final VoidCallback onTap;

  /// 이 토픽에 최신 출제 경향 문제가 있는지 (#523)
  final bool hasLatestTrendQuestion;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
    this.hasLatestTrendQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeSubtopicCount = topic.subtopics
        .where((subtopic) => subtopic.isActive == true)
        .length;

    return PassqlListRow(
      leading: PassqlIconTile(
        icon: topicIconFor(topic.code),
        color: topicColorFor(topic.code, context.themeBrightness),
      ),
      title: topic.displayName,
      // 서브토픽이 있을 때만 개수를 보여 준다(없으면 "0개"만 반복돼 의미가 없다)
      subtitle: activeSubtopicCount > 0 ? '$activeSubtopicCount개 서브토픽' : null,
      // 9개 중 대부분에 붙어 글자 배지는 소음이 되므로 불꽃 아이콘만 (스크린리더는 '최신 경향')
      trailing: hasLatestTrendQuestion
          ? Semantics(
              label: '최신 경향',
              excludeSemantics: true,
              child: Icon(
                CupertinoIcons.flame_fill,
                size: PassqlIconSize.sm,
                color: context.passqlColors.warning,
              ),
            )
          : null,
      hasChevron: true,
      onTap: onTap,
    );
  }
}
