import 'package:flutter/cupertino.dart';
import '../../../data/models/progress/heatmap_response.dart';
import '../../design/design.dart';

/// 최근 35일(5주) 학습 히트맵.
/// 7열(일~토) × 5행(주) 그리드.
/// solvedCount 기준으로 5단계 색상 적용.
class HeatmapWidget extends StatelessWidget {
  final HeatmapResponse? heatmap;
  final int streakDays;

  const HeatmapWidget({super.key, this.heatmap, this.streakDays = 0});

  /// 날짜 문자열 키로 빠른 조회를 위한 Map 생성.
  Map<String, HeatmapEntry> _buildEntryMap() {
    final entries = heatmap?.entries ?? [];
    return {for (final e in entries) e.date: e};
  }

  /// solvedCount → 히트맵 색상 (5단계). 0단계는 fill, 나머지는 accent 알파 단계.
  Color _colorForCount(PqColors c, int count) {
    if (count == 0) return c.fill;
    if (count <= 1) return c.accent.withValues(alpha: 0.25);
    if (count <= 3) return c.accent.withValues(alpha: 0.5);
    if (count <= 6) return c.accent.withValues(alpha: 0.75);
    return c.accent;
  }

  /// 오늘 기준 35일 전부터 날짜 리스트 생성.
  List<DateTime> _buildDays() {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 34));
    return List.generate(35, (i) => start.add(Duration(days: i)));
  }

  String _toDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    final entryMap = _buildEntryMap();
    final days = _buildDays();
    const weekLabels = ['일', '월', '화', '수', '목', '금', '토'];

    // 월 레이블 열 너비
    const double monthLabelWidth = 28;

    return PqCard(
      title: '학습 현황',
      trailing: streakDays > 0
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.flame_fill, size: 12, color: c.warning),
                const SizedBox(width: PqSpace.xxs),
                PqBadge(text: '$streakDays일 연속', color: c.warning),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요일 헤더 — 월 레이블 너비만큼 왼쪽 여백
          Row(
            children: [
              const SizedBox(width: monthLabelWidth),
              ...weekLabels.map((label) {
                return Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: PqType.caption.copyWith(color: c.secondaryLabel),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: PqSpace.xxs),

          // 5주 그리드 — 각 행 왼쪽에 월 레이블
          ...List.generate(5, (week) {
            final firstDay = days[week * 7];
            final prevFirstDay = week > 0 ? days[(week - 1) * 7] : null;

            // 첫 주이거나 월이 바뀌는 주에 월 레이블 표시
            final showMonth =
                week == 0 || prevFirstDay?.month != firstDay.month;
            final monthLabel = showMonth ? '${firstDay.month}월' : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: PqSpace.xxs),
              child: Row(
                children: [
                  // 월 레이블
                  SizedBox(
                    width: monthLabelWidth,
                    child: Text(
                      monthLabel,
                      style: PqType.caption.copyWith(color: c.secondaryLabel),
                    ),
                  ),

                  // 7개 날짜 셀
                  ...List.generate(7, (dayOfWeek) {
                    final idx = week * 7 + dayOfWeek;
                    final date = days[idx];
                    final key = _toDateKey(date);
                    final count = entryMap[key]?.solvedCount ?? 0;

                    // 진한 배경(75% 이상)일 때만 반전 글자
                    final isDeep = count > 3;

                    return Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _colorForCount(c, count),
                            borderRadius: BorderRadius.circular(PqRadius.sm),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: PqType.caption.copyWith(
                                color: isDeep
                                    ? c.onAccent
                                    : c.secondaryLabel,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
