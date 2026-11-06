import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// 약한 토픽 한 줄 (#861, #862): 판정 칩 + 토픽 이름 + (선택) 개념 보기 › > 숫자 근거 > (선택) AI 오답 패턴
/// 개념 보기는 서버가 열 수 있는 단원을 알려 줄 때만 (같은 토픽의 개념 학습 단원)
class AiAnalysisFindingRow extends StatelessWidget {
  const AiAnalysisFindingRow({super.key, required this.finding});

  final AiAnalysisFinding finding;

  /// 판정 > 칩 (문구, 의미, 아이콘). 모르는 판정은 칩 없음
  static (String text, PassqlBadgeKind kind, IconData? icon)? chipOf(
    AiFindingKind kind,
  ) => switch (kind) {
    AiFindingKind.weak => ('약점', PassqlBadgeKind.important, null),
    // warning 기본 아이콘(불꽃)은 연속 학습 전용 > 불안정은 삼각 경고
    AiFindingKind.shaky => (
      '불안정',
      PassqlBadgeKind.warning,
      CupertinoIcons.exclamationmark_triangle_fill,
    ),
    AiFindingKind.untried => ('판단 이름', PassqlBadgeKind.neutral, null),
    AiFindingKind.unknown => null,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final chip = chipOf(finding.kind);
    final insight = finding.insight;
    final conceptTopicUuid = finding.conceptTopicUuid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 판정 칩 + 토픽 이름
        Row(
          children: [
            if (chip != null) ...[
              PassqlBadge(text: chip.$1, kind: chip.$2, icon: chip.$3),
              const SizedBox(width: PassqlSpacing.xs),
            ],
            Expanded(
              child: Text(
                finding.topicName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                ),
              ),
            ),
            if (conceptTopicUuid != null)
              PassqlSectionLink(
                label: '개념 보기',
                semanticLabel: '${finding.topicName} 개념 학습 보기',
                onTap: () =>
                    context.push(AppRoutes.conceptTopic(conceptTopicUuid)),
              ),
          ],
        ),
        // 숫자 근거 (예: 6문제 중 3문제 정답 (50%))
        if (finding.evidence.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          Text(
            finding.evidence,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
        // AI 오답 패턴: `용어` 같은 표기를 강조로 바꿔 표시
        if (insight != null && insight.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          MarkdownLiteText(insight, isAnimated: true),
        ],
      ],
    );
  }
}
