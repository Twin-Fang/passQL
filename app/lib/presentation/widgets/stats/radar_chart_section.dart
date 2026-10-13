import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/progress/topic_stat.dart';
import '../../design/design.dart';

/// 영역별 분석 레이더(스파이더) 차트 섹션.
/// topicStats가 없으면 빈 상태 메시지 표시.
class RadarChartSection extends StatelessWidget {
  final List<TopicStat>? topicStats;

  const RadarChartSection({super.key, required this.topicStats});

  @override
  Widget build(BuildContext context) {
    return PqCard(title: '영역별 분석', child: _buildChart(context));
  }

  Widget _buildChart(BuildContext context) {
    final c = context.pq;
    final stats = topicStats;

    if (stats == null || stats.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Text(
            '아직 학습 데이터가 없습니다',
            style: PqType.subheadline.copyWith(color: c.secondaryLabel),
          ),
        ),
      );
    }

    // correctRate 0.0~1.0 → 0~5 스케일 변환 (RadarChart 최대값 기준)
    final values = stats.map((s) => s.correctRate * 5).toList();
    final labels = stats.map((s) => s.displayName).toList();

    return SizedBox(
      height: 260,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          // tick 숫자 레이블 숨김 — 수치보다 형태로 파악
          ticksTextStyle: PqType.caption.copyWith(
            fontSize: 0,
            color: Colors.transparent,
          ),
          // 눈금 링·격자·외곽선 모두 separator 토큰의 얇은 선으로 통일
          tickBorderData: BorderSide(color: c.separator, width: 1),
          gridBorderData: BorderSide(color: c.separator, width: 1),
          radarBorderData: BorderSide(color: c.separator, width: 1),
          titlePositionPercentageOffset: 0.25,
          titleTextStyle: PqType.caption.copyWith(color: c.secondaryLabel),
          getTitle: (index, angle) {
            final label = labels[index];
            // '/' 기준으로 줄바꿈 처리 (긴 토픽명 대응)
            final parts = label.split(' / ');
            return RadarChartTitle(text: parts.join('\n'), angle: 0);
          },
          dataSets: [
            RadarDataSet(
              // 강조색 15% 불투명도로 채움
              fillColor: c.accent.withValues(alpha: 0.15),
              borderColor: c.accent,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
