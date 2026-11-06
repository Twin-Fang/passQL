import 'package:flutter/cupertino.dart';

import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../design/design.dart';
import 'ai_analysis_forecast_block.dart';

/// 데이터 부족 안내 (#862): 서버 문구 > 진행 대상 토픽 + "지금 N/5" > 목표 칸 N개 (푼 칸만 강조색)
/// 칸은 왼쪽부터 순서대로 켜짐 (동작 줄이기면 바로)
class AiAnalysisReadinessBlock extends StatelessWidget {
  const AiAnalysisReadinessBlock({super.key, required this.readiness});

  final AiAnalysisReadiness readiness;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final targetCount = readiness.targetCount;
    final solvedCount = readiness.solvedCount.clamp(0, targetCount);
    final progressText = '지금 $solvedCount/$targetCount';
    return AiAnalysisInsetBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (readiness.message.isNotEmpty)
            Text(
              readiness.message,
              style: PassqlTypography.subheadline.copyWith(color: colors.label),
            ),
          if (targetCount > 0) ...[
            const SizedBox(height: PassqlSpacing.sm),
            // 진행 대상 토픽 + 지금 N/목표
            Semantics(
              container: true,
              label: '${readiness.topicName ?? ''} $progressText',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            readiness.topicName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PassqlTypography.footnote.copyWith(
                              color: colors.secondaryLabel,
                            ),
                          ),
                        ),
                        Text(
                          progressText,
                          style: PassqlTypography.footnoteSemibold.copyWith(
                            color: colors.accentText,
                            fontFeatures: PassqlTypography.tabular,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: PassqlSpacing.xs),
                    _ReadinessSegments(
                      solvedCount: solvedCount,
                      targetCount: targetCount,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 목표 칸 막대: 칸마다 순번 지연으로 켜짐
class _ReadinessSegments extends StatelessWidget {
  const _ReadinessSegments({
    required this.solvedCount,
    required this.targetCount,
  });

  final int solvedCount;
  final int targetCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        for (var index = 0; index < targetCount; index++) ...[
          if (index > 0) const SizedBox(width: PassqlSpacing.xxs),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PassqlRadius.capsule),
              child: SizedBox(
                height: PassqlSize.unitSegmentHeight,
                child: ColoredBox(
                  color: colors.fill,
                  child: index < solvedCount
                      ? PassqlReveal(
                          index: index,
                          child: ColoredBox(color: colors.accent),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
