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
    return {for (final entry in entries) entry.date: entry};
  }

  /// solvedCount → 히트맵 색상 (5단계). 0단계는 fill, 나머지는 accent 알파 단계.
  Color _colorForCount(PassqlColors colors, int count) {
    if (count == 0) return colors.fill;
    if (count <= 1) return colors.accent.withValues(alpha: 0.25);
    if (count <= 3) return colors.accent.withValues(alpha: 0.5);
    if (count <= 6) return colors.accent.withValues(alpha: 0.75);
    return colors.accent;
  }

  /// 오늘 기준 35일 전부터 날짜 리스트 생성.
  List<DateTime> _buildDays() {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 34));
    return List.generate(35, (i) => start.add(Duration(days: i)));
  }

  /// 색칸 그리드 > 스크린리더 요약 문구 (기간, 학습한 날 수, 푼 문제 수)
  String _describeForScreenReader(
    List<DateTime> days,
    Map<String, HeatmapEntry> entryMap,
  ) {
    final solvedCounts = days
        .map((day) => entryMap[_toDateKey(day)]?.solvedCount ?? 0)
        .toList();
    final studiedDayCount = solvedCounts.where((count) => count > 0).length;
    final solvedTotal = solvedCounts.fold<int>(0, (sum, count) => sum + count);
    return '최근 ${days.length}일 학습 기록, 학습한 날 $studiedDayCount일, 푼 문제 $solvedTotal개';
  }

  String _toDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final entryMap = _buildEntryMap();
    final days = _buildDays();
    const weekLabels = ['일', '월', '화', '수', '목', '금', '토'];

    // 월 레이블 열 너비
    const double monthLabelWidth = 28;

    return PassqlCard(
      title: '학습 현황',
      // 불꽃 아이콘은 태그(warning)가 함께 그린다
      trailing: streakDays > 0
          ? PassqlBadge(text: '$streakDays일 연속', kind: PassqlBadgeKind.warning)
          : null,
      // 날짜 칸 35개를 하나씩 읽지 않고 요약 1문장으로 전달
      child: Semantics(
        label: _describeForScreenReader(days, entryMap),
        container: true,
        excludeSemantics: true,
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
                        style: PassqlTypography.caption.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xxs),

            // 5주 그리드 — 각 행 왼쪽에 월 레이블
            ...List.generate(5, (week) {
              final firstDay = days[week * 7];
              final prevFirstDay = week > 0 ? days[(week - 1) * 7] : null;

              // 첫 주이거나 월이 바뀌는 주에 월 레이블 표시
              final showMonth =
                  week == 0 || prevFirstDay?.month != firstDay.month;
              final monthLabel = showMonth ? '${firstDay.month}월' : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
                child: Row(
                  children: [
                    // 월 레이블
                    SizedBox(
                      width: monthLabelWidth,
                      child: Text(
                        monthLabel,
                        style: PassqlTypography.caption.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),

                    // 7개 날짜 셀
                    ...List.generate(7, (dayOfWeek) {
                      final dayIndex = week * 7 + dayOfWeek;
                      final date = days[dayIndex];
                      final key = _toDateKey(date);
                      final count = entryMap[key]?.solvedCount ?? 0;

                      // 진한 배경(75% 이상)일 때만 반전 글자
                      final isDeep = count > 3;

                      return Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            margin: const EdgeInsets.all(
                              PassqlSpacing.hairlineGap,
                            ),
                            decoration: BoxDecoration(
                              color: _colorForCount(colors, count),
                              borderRadius: BorderRadius.circular(
                                PassqlRadius.sm,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: PassqlTypography.caption.copyWith(
                                  color: isDeep
                                      ? colors.onAccent
                                      : colors.secondaryLabel,
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
      ),
    );
  }
}
