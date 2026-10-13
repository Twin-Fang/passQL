import 'package:flutter/material.dart';

import '../../../core/topic_icons.dart';
import '../../../data/models/meta/topic_tree.dart';
import '../../design/design.dart';

/// 토픽 선택 행. displayName + 서브토픽 개수 표시.
/// PqGroupedSection 안에서 쓰는 목록 행이다.
class TopicCard extends StatelessWidget {
  final TopicTree topic;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeSubtopicCount = topic.subtopics
        .where((s) => s.isActive == true)
        .length;

    return PqListRow(
      leading: PqIconTile(
        icon: topicIconFor(topic.code),
        color: topicColor(topic.code, Theme.of(context).brightness),
      ),
      title: topic.displayName,
      // 서브토픽이 있을 때만 개수를 보여 준다(없으면 "0개"만 반복돼 의미가 없다)
      subtitle: activeSubtopicCount > 0 ? '$activeSubtopicCount개 서브토픽' : null,
      chevron: true,
      onTap: onTap,
    );
  }
}
