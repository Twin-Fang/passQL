import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/meta/topic_tree.dart';
import '../../../data/models/progress/topic_stat.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/topic_providers.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import 'topic_accuracy_radar.dart';
import 'topic_accuracy_rows.dart';

// 처음 보이는 줄 수 (나머지는 "전체 N개 영역 보기"로 펼침)
const int _collapsedRowCount = 4;
// 잠금 자리표시 막대 크기 (값 대신 회색 막대, 화면에서 블러 금지 규칙)
const double _placeholderValueWidth = 36;
const double _placeholderHeight = 10;
// 꼭짓점이 3개는 돼야 면이 생긴다 (그보다 적으면 차트 없이 목록만)
const int _minChartTopicCount = 3;

// 영역별 정답률 판정 기간 표기 (서버 topic-analysis 최근 7일, DEC-0043)
const String _periodLabel = '최근 7일';

/// 내 프로필 영역별 정답률 (#749, #909): 위 8각 차트(꼭짓점 = 토픽 순서) + 아래 목록(정렬 토글은 목록 바로 위).
/// 줄 = 토픽 타일 + 영역 이름 + 푼 수 + 오른쪽 정답률(약한 영역은 빨강). 누르면 그 영역 문제로.
/// 차트는 영역 3개 이상이고 기간 안에 푼 영역이 있을 때만 (없으면 안내 한 줄 + 목록)
/// [isLocked] (무료·결제 켜짐): topic-analysis 를 부르지 않으므로 토픽 목록으로 이름만 보이고 값은 자리표시
class TopicAccuracySection extends ConsumerStatefulWidget {
  const TopicAccuracySection({
    super.key,
    required this.topicStats,
    required this.isLocked,
  });

  final List<TopicStat>? topicStats;
  final bool isLocked;

  @override
  ConsumerState<TopicAccuracySection> createState() =>
      _TopicAccuracySectionState();
}

class _TopicAccuracySectionState extends ConsumerState<TopicAccuracySection> {
  TopicAccuracySort _sort = TopicAccuracySort.lowestRate;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 토픽 목록은 문제 탭과 같은 캐시 (실패해도 줄은 그리고 아이콘만 기본값)
    final topics = ref.watch(topicsProvider).valueOrNull ?? const <TopicTree>[];
    if (widget.isLocked) return _LockedTopicAccuracy(topics: topics);
    final stats = widget.topicStats;
    if (stats == null || stats.isEmpty) return const SizedBox.shrink();
    final rows = buildTopicAccuracyRows(
      stats: stats,
      topics: topics,
      sort: _sort,
    );
    final hasSolvedTopic = rows.any((row) => !row.isUnsolved);
    final canShowChart = stats.length >= _minChartTopicCount && hasSolvedTopic;
    final visibleRows = _isExpanded
        ? rows
        : rows.take(_collapsedRowCount).toList();
    final colors = context.passqlColors;
    return PassqlSection(
      title: '영역별 정답률',
      trailing: Text(
        _periodLabel,
        style: PassqlTypography.footnote.copyWith(color: colors.secondaryLabel),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (canShowChart)
            TopicAccuracyRadar(
              key: const Key('topic-accuracy-radar'),
              rows: buildTopicChartRows(stats: stats, topics: topics),
            )
          else if (!hasSolvedTopic)
            Text(
              '$_periodLabel 동안 푼 문제가 없어요. 영역을 눌러 바로 풀어 보세요',
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          const SizedBox(height: PassqlSpacing.sm),
          // 정렬은 목록에만 걸리므로 목록 바로 위 (차트 꼭짓점 순서는 고정)
          if (hasSolvedTopic)
            Align(
              alignment: Alignment.centerRight,
              child: _SortToggle(
                sort: _sort,
                onToggle: () => setState(
                  () => _sort = _sort == TopicAccuracySort.lowestRate
                      ? TopicAccuracySort.mostSolved
                      : TopicAccuracySort.lowestRate,
                ),
              ),
            ),
          Column(
            key: const ValueKey('topic-accuracy-list'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final row in visibleRows) _TopicAccuracyRowTile(row: row),
              if (rows.length > _collapsedRowCount && !_isExpanded)
                PassqlPressable(
                  onTap: () => setState(() => _isExpanded = true),
                  hasMinimumTouchTarget: true,
                  semanticLabel: '전체 ${rows.length}개 영역 보기',
                  child: Center(
                    child: Text(
                      '전체 ${rows.length}개 영역 보기',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 정렬 토글: 누를 때마다 정답률 낮은 순 <-> 많이 푼 순 (토론 의견 화면 토글과 같은 모양, #741)
class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.sort, required this.onToggle});

  final TopicAccuracySort sort;
  final VoidCallback onToggle;

  String get _label => switch (sort) {
    TopicAccuracySort.lowestRate => '정답률 낮은 순',
    TopicAccuracySort.mostSolved => '많이 푼 순',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlPressable(
      onTap: onToggle,
      semanticLabel: '정렬: $_label, 바꾸기',
      hasMinimumTouchTarget: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(width: PassqlSpacing.hairlineGap),
          Icon(
            CupertinoIcons.arrow_up_arrow_down,
            size: PassqlIconSize.xs,
            color: colors.iconSecondary,
          ),
        ],
      ),
    );
  }
}

/// 영역 한 줄: 누르면 그 영역 문제(챕터 흐름)로. 코드를 모르면 이동 없음
class _TopicAccuracyRowTile extends StatelessWidget {
  const _TopicAccuracyRowTile({required this.row});

  final TopicAccuracyRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final code = row.code;
    final percent = '${(row.correctRate * 100).round()}%';
    return PassqlListRow(
      title: row.name,
      subtitle: row.isUnsolved ? '아직 안 풀었어요' : '${row.solvedCount}문제 풀었어요',
      hasHorizontalPadding: false,
      leading: PassqlIconTile(
        icon: topicIconFor(code ?? ''),
        color: topicColorFor(code ?? '', context.themeBrightness),
      ),
      trailing: row.isUnsolved
          ? null
          : Text(
              percent,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: row.isWeak ? colors.wrongText : colors.label,
              ),
            ),
      onTap: code == null
          ? null
          : () => context.push(
              AppRoutes.questionChapterOf(topicCode: code, topicName: row.name),
            ),
    );
  }
}

/// 잠금(무료·결제 켜짐): 다른 잠금 자리와 같은 모양 (흐린 미리보기 + 한 줄 + PRO로 보기, #966)
/// 미리보기는 토픽 이름·타일만 진짜 값, 값 자리는 회색 막대
class _LockedTopicAccuracy extends StatelessWidget {
  const _LockedTopicAccuracy({required this.topics});

  final List<TopicTree> topics;

  @override
  Widget build(BuildContext context) {
    final previewTopics =
        ([...topics]
              ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0)))
            .take(_collapsedRowCount)
            .toList();
    return PassqlSection(
      title: '영역별 정답률',
      child: ProLockedSection(
        caption: LockedPreviewCaptions.topicAccuracy,
        preview: Column(
          children: [
            for (final topic in previewTopics)
              PassqlListRow(
                title: topic.displayName,
                hasHorizontalPadding: false,
                leading: PassqlIconTile(
                  icon: topicIconFor(topic.code),
                  color: topicColorFor(topic.code, context.themeBrightness),
                ),
                trailing: const PassqlSkeletonBox(
                  width: _placeholderValueWidth,
                  height: _placeholderHeight,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
