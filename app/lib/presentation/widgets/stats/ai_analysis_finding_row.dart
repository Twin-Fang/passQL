import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../question/markdown_lite_text.dart';

/// 약한 토픽 한 줄 (#861, #862): 토픽 이름 + (선택) 개념 보기 › > 판정 의미색 글자 | 숫자 근거 > (선택) AI 오답 패턴
/// 판정은 칩 없이 글자색만 (DEC-0116, #1136). 개념 보기는 서버가 열 수 있는 단원을 알려 줄 때만
class AiAnalysisFindingRow extends StatelessWidget {
  const AiAnalysisFindingRow({super.key, required this.finding});

  final AiAnalysisFinding finding;

  /// 판정 > (문구, 글자색): 약점 빨강, 불안정 주황, 판단 이름 회색. 모르는 판정은 표시 없음
  static (String text, Color color)? verdictOf(
    AiFindingKind kind,
    PassqlColors colors,
  ) => switch (kind) {
    AiFindingKind.weak => ('약점', colors.wrongText),
    AiFindingKind.shaky => ('불안정', colors.warningText),
    AiFindingKind.untried => ('판단 이름', colors.secondaryLabel),
    AiFindingKind.unknown => null,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final verdict = verdictOf(finding.kind, colors);
    final insight = finding.insight;
    final conceptTopicUuid = finding.conceptTopicUuid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 토픽 이름 + 개념 보기
        Row(
          children: [
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
        // 판정 글자 | 숫자 근거 (예: 약점 | 6문제 중 3문제 정답 (50%))
        if (verdict != null || finding.evidence.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          Text.rich(
            TextSpan(
              children: [
                if (verdict != null)
                  TextSpan(
                    text: verdict.$1,
                    style: PassqlTypography.footnoteSemibold.copyWith(
                      color: verdict.$2,
                    ),
                  ),
                if (verdict != null && finding.evidence.isNotEmpty)
                  const TextSpan(text: ' | '),
                if (finding.evidence.isNotEmpty)
                  TextSpan(text: finding.evidence),
              ],
            ),
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
