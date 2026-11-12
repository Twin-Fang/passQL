import 'package:flutter/cupertino.dart';

import '../../../core/utils/date_format.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../design/design.dart';
import 'exam_schedule_labels.dart';

/// "YYYY년 일정" 세로 타임라인 (#991 B안): 회차별 접수 시작·시험·합격 발표 날짜순
/// 지난 이벤트 흐림, 시험 이벤트 굵게·큰 점, 오늘 위치에 빨간 "오늘 M.D" 선
/// 지난 이벤트는 최근 [visiblePastEventCount]건만, 나머지는 "지난 일정 N건 더 보기"로 펼침
class ExamScheduleTimeline extends StatefulWidget {
  const ExamScheduleTimeline({
    super.key,
    required this.year,
    required this.schedules,
    required this.today,
  });

  final int year;
  final List<ExamScheduleResponse> schedules;
  final DateTime today;

  // 접힘 상태에서 보이는 지난 이벤트 수
  static const int visiblePastEventCount = 3;

  @override
  State<ExamScheduleTimeline> createState() => _ExamScheduleTimelineState();
}

class _ExamScheduleTimelineState extends State<ExamScheduleTimeline> {
  bool _isPastExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final events = examTimelineEventsOf(widget.schedules);
    if (events.isEmpty) return const SizedBox.shrink();
    final today = DateTime(
      widget.today.year,
      widget.today.month,
      widget.today.day,
    );
    // 오늘 선 위치: 오늘 이후(오늘 포함) 첫 이벤트 앞
    final firstUpcomingIndex = events.indexWhere(
      (event) => !event.date.isBefore(today),
    );
    final pastCount = firstUpcomingIndex == -1
        ? events.length
        : firstUpcomingIndex;
    final hiddenPastCount = _isPastExpanded
        ? 0
        : (pastCount - ExamScheduleTimeline.visiblePastEventCount).clamp(
            0,
            pastCount,
          );

    // 행 조립 (숨긴 지난 이벤트 > 보이는 이벤트, 오늘 선은 첫 다가올 이벤트 앞·모두 지났으면 맨 끝)
    final rows = <Widget>[];
    for (var index = hiddenPastCount; index < events.length; index++) {
      if (index == firstUpcomingIndex) rows.add(_TodayLine(today: today));
      rows.add(
        _TimelineEventRow(
          event: events[index],
          isPast: index < pastCount,
          isFirst: index == hiddenPastCount,
          isLast: index == events.length - 1,
        ),
      );
    }
    if (firstUpcomingIndex == -1) rows.add(_TodayLine(today: today));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PassqlGroupedSection(
          header: '${widget.year}년 일정',
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.xs,
              ),
              child: Column(children: rows),
            ),
          ],
        ),
        if (hiddenPastCount > 0)
          PassqlPressable(
            onTap: () => setState(() => _isPastExpanded = true),
            hasMinimumTouchTarget: true,
            semanticLabel: '지난 일정 $hiddenPastCount건 더 보기',
            child: Padding(
              padding: const EdgeInsets.only(top: PassqlSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '지난 일정 $hiddenPastCount건 더 보기',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(width: PassqlSpacing.xxs),
                  Icon(
                    CupertinoIcons.chevron_down,
                    size: PassqlIconSize.xxs,
                    color: colors.iconSecondary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 이벤트 한 줄: 날짜 | 점(위아래 세로선) | 문구
class _TimelineEventRow extends StatelessWidget {
  const _TimelineEventRow({
    required this.event,
    required this.isPast,
    required this.isFirst,
    required this.isLast,
  });

  final ExamTimelineEvent event;
  final bool isPast;
  final bool isFirst;
  final bool isLast;

  // 지난 이벤트 점 흐림 정도
  static const double _pastDotAlpha = 0.45;
  // 줄 위아래 여백 (점 사이 간격)
  static const double _rowVerticalPadding = 9;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final dotSize = event.isExam
        ? PassqlSize.examTimelineExamDot
        : PassqlSize.examTimelineDot;
    final Color dotColor;
    if (event.isExam && !isPast) {
      dotColor = colors.accent;
    } else if (isPast) {
      dotColor = colors.accent.withValues(alpha: _pastDotAlpha);
    } else {
      dotColor = colors.fill;
    }
    final textColor = isPast ? colors.secondaryLabel : colors.label;
    final titleStyle = event.isExam
        ? PassqlTypography.subheadlineSemibold
        : PassqlTypography.subheadline;
    return Semantics(
      label:
          '${formatMonthDay(event.date)} ${event.title}${isPast ? ', 지남' : ''}',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: PassqlSize.examTimelineDateColumn,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _rowVerticalPadding,
                ),
                child: Text(
                  formatCompactDottedMonthDay(event.date),
                  textAlign: TextAlign.right,
                  style: PassqlTypography.footnoteSemibold.copyWith(
                    color: colors.secondaryLabel,
                    fontFeatures: PassqlTypography.tabular,
                  ),
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            // 점 칸: 위·아래 세로선 (첫 줄은 위, 마지막 줄은 아래 없음)
            SizedBox(
              width: PassqlSize.examTimelineExamDot,
              child: Column(
                children: [
                  Expanded(child: _verticalLine(colors, isVisible: !isFirst)),
                  Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(child: _verticalLine(colors, isVisible: !isLast)),
                ],
              ),
            ),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: _rowVerticalPadding,
                ),
                child: Text(
                  event.title,
                  style: titleStyle.copyWith(color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalLine(PassqlColors colors, {required bool isVisible}) =>
      Center(
        child: Container(
          width: PassqlSize.examStepLine,
          color: isVisible ? colors.fill : null,
        ),
      );
}

/// 오늘 위치 선: 빨간 "오늘 M.D" + 오른쪽 끝까지 선
class _TodayLine extends StatelessWidget {
  const _TodayLine({required this.today});

  final DateTime today;

  // 선 두께
  static const double _lineThickness = 1.5;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      label: '오늘 ${formatMonthDay(today)}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: PassqlSpacing.hairlineGap,
        ),
        child: Row(
          children: [
            Text(
              '오늘 ${formatCompactDottedMonthDay(today)}',
              style: PassqlTypography.captionSemibold.copyWith(
                color: colors.wrongText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Expanded(
              child: Container(height: _lineThickness, color: colors.wrong),
            ),
          ],
        ),
      ),
    );
  }
}
