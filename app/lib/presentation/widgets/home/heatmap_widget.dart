import 'package:flutter/cupertino.dart';
import '../../../data/models/progress/heatmap_response.dart';
import '../../design/design.dart';

/// 최근 5주 학습 히트맵.
/// 7열(일~토) × 5행(주) 그리드. 첫 칸은 4주 전 일요일, 오늘 칸 테두리 강조, 오늘 뒤 칸은 비움.
/// solvedCount 기준으로 5단계 색상 적용.
class HeatmapWidget extends StatelessWidget {
  final HeatmapResponse? heatmap;
  final int streakDays;

  /// 기준 날짜 (기본: 지금, 테스트에서 고정용)
  final DateTime? today;

  const HeatmapWidget({
    super.key,
    this.heatmap,
    this.streakDays = 0,
    this.today,
  });

  // 그리드 규격: 5주 × 7일
  static const _weekCount = 5;
  static const _daysPerWeek = 7;

  // 오늘 칸 테두리 두께
  static const double _todayBorderWidth = 1.5;

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

  /// 기준 날짜(시각 제거) > 그리드 35칸 날짜: 4주 전 일요일부터 이번 주 토요일까지
  /// 머리글(일~토)과 열을 맞추려고 시작을 일요일로 당김. 날짜 단위 생성이라 서머타임 영향 없음
  static List<DateTime> buildGridDays(DateTime today) {
    // DateTime.weekday: 월 1 ~ 일 7 > 일요일부터 지난 일수 0~6
    final daysSinceSunday = today.weekday % _daysPerWeek;
    final firstSundayDay =
        today.day - daysSinceSunday - (_weekCount - 1) * _daysPerWeek;
    return List.generate(
      _weekCount * _daysPerWeek,
      (index) => DateTime(today.year, today.month, firstSundayDay + index),
    );
  }

  DateTime get _todayDate {
    final now = today ?? DateTime.now();
    return DateTime(now.year, now.month, now.day);
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
    final todayDate = _todayDate;
    final days = buildGridDays(todayDate);
    // 스크린리더 요약은 오늘까지 지난 날만
    final pastDays = days.where((day) => !day.isAfter(todayDate)).toList();
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
        label: _describeForScreenReader(pastDays, entryMap),
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
            ...List.generate(_weekCount, (week) {
              final firstDay = days[week * _daysPerWeek];
              final prevFirstDay = week > 0
                  ? days[(week - 1) * _daysPerWeek]
                  : null;

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
                    ...List.generate(_daysPerWeek, (dayOfWeek) {
                      final dayIndex = week * _daysPerWeek + dayOfWeek;
                      final date = days[dayIndex];
                      // 오늘 뒤 칸: 자리만 (열 정렬 유지)
                      if (date.isAfter(todayDate)) {
                        return const Expanded(
                          child: AspectRatio(aspectRatio: 1),
                        );
                      }
                      final key = _toDateKey(date);
                      final count = entryMap[key]?.solvedCount ?? 0;
                      final isToday = date == todayDate;

                      // 진한 배경(75% 이상)일 때만 반전 글자
                      final isDeep = count > 3;

                      return Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            key: isToday
                                ? const ValueKey('heatmap-today')
                                : null,
                            margin: const EdgeInsets.all(
                              PassqlSpacing.hairlineGap,
                            ),
                            decoration: BoxDecoration(
                              color: _colorForCount(colors, count),
                              borderRadius: BorderRadius.circular(
                                PassqlRadius.sm,
                              ),
                              border: isToday
                                  ? Border.all(
                                      color: colors.accent,
                                      width: _todayBorderWidth,
                                    )
                                  : null,
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
