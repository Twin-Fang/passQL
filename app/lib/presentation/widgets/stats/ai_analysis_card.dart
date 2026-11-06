import 'package:flutter/cupertino.dart';

import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/progress/ai_comment_response.dart';
import '../../../data/models/progress/ai_stats_analysis.dart';
import '../../design/design.dart';
import '../pro/locked_preview_samples.dart';
import '../pro/pro_locked_section.dart';
import '../question/markdown_lite_text.dart';
import 'ai_analysis_action_buttons.dart';
import 'ai_analysis_finding_row.dart';

/// AI 영역 분석 구간 (#749 구간형): 반짝이 머리 + 본문 + 아래 작은 분석 시각
/// 본문: 구조화 분석(#861) 있으면 진단·약한 토픽·바로 풀기, 없으면 글 코멘트(단어 순차 등장). aiComment 가 null 이면 숨김
class AiAnalysisCard extends StatelessWidget {
  final AiCommentResponse? aiComment;

  const AiAnalysisCard({super.key, required this.aiComment});

  @override
  Widget build(BuildContext context) {
    final comment = aiComment?.comment;
    if (comment == null) return const SizedBox.shrink();
    final analysis = aiComment?.analysis;
    final analyzedLabel = aiAnalyzedLabel(aiComment?.generatedAt);

    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PassqlAiHeader(title: 'AI 분석'),
          const SizedBox(height: PassqlSpacing.sm),
          if (analysis != null)
            _AiStatsAnalysisBody(analysis: analysis)
          else
            // AI 코멘트의 `토픽명` 같은 마크다운 기호를 강조 표시로 바꿔 보여 준다.
            MarkdownLiteText(comment, isAnimated: true),
          if (analyzedLabel != null) ...[
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              analyzedLabel,
              style: PassqlTypography.caption.copyWith(
                color: context.passqlColors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 구조화 분석 본문: 한 줄 진단 > 약한 토픽 최대 2 > 추세·강점 한 줄씩 > 바로 풀기 버튼
class _AiStatsAnalysisBody extends StatelessWidget {
  const _AiStatsAnalysisBody({required this.analysis});

  final AiStatsAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final trend = analysis.trend;
    final strength = analysis.strength;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 한 줄 진단 (D-day·과락 위험 등, 서버 문구 그대로)
        if (analysis.headline.isNotEmpty)
          Text(
            analysis.headline,
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
        for (final finding in analysis.findings) ...[
          const SizedBox(height: PassqlSpacing.md),
          AiAnalysisFindingRow(finding: finding),
        ],
        // 추세·강점: 보조 정보라 아이콘 + 보조 글자 한 줄씩
        if (trend != null || strength != null)
          const SizedBox(height: PassqlSpacing.md),
        if (trend != null)
          _AiAnalysisNoteLine(icon: CupertinoIcons.chart_bar, text: trend),
        if (trend != null && strength != null)
          const SizedBox(height: PassqlSpacing.xxs),
        if (strength != null)
          _AiAnalysisNoteLine(
            icon: CupertinoIcons.star,
            text: '강점 · ${strength.topicName} ${strength.correctRatePercent}%',
          ),
        AiAnalysisActionButtons(actions: analysis.actions),
      ],
    );
  }
}

/// 보조 한 줄: 아이콘 + 보조 글자 (추세·강점)
class _AiAnalysisNoteLine extends StatelessWidget {
  const _AiAnalysisNoteLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: PassqlIconSize.sm, color: colors.iconSecondary),
        const SizedBox(width: PassqlSpacing.xxs),
        Expanded(
          child: Text(
            text,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ),
      ],
    );
  }
}

/// 무료(결제 켜짐) AI 분석 자리: 같은 머리 + 잠금 미리보기 (AI 코멘트 프로 전용, #860)
class AiAnalysisLockedSection extends StatelessWidget {
  const AiAnalysisLockedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlAiHeader(title: 'AI 분석'),
          SizedBox(height: PassqlSpacing.sm),
          ProLockedSection(
            preview: AiAnalysisLockedSample(),
            caption: LockedPreviewCaptions.aiAnalysis,
          ),
        ],
      ),
    );
  }
}

/// AI 코멘트를 기다리는 동안의 자리: 머리 + 진단 한 줄 + 약한 토픽 2묶음 + 버튼 (구조화 분석과 비슷한 높이)
class AiAnalysisCardSkeleton extends StatelessWidget {
  const AiAnalysisCardSkeleton({super.key});

  // 막대 높이: 글 줄·진단 줄·칩 (각 글자 크기 근처)
  static const double _lineHeight = 12;
  static const double _headlineHeight = 18;
  static const double _chipHeight = 18;
  static const double _titleWidth = 96;
  static const double _chipWidth = 40;
  static const double _topicNameWidth = 88;
  // 진단 줄 너비 비율
  static const double _headlineWidthFactor = 0.8;
  // 약한 토픽 묶음 수와 묶음 안 글 줄 너비 비율 (근거·패턴 2줄)
  static const int _findingCount = 2;
  static const List<double> _findingLineWidthFactors = [0.5, 0.9];

  @override
  Widget build(BuildContext context) {
    return PassqlLoadingSemantics(
      child: PassqlSection(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 머리: 아이콘 타일 + 제목
            Row(
              children: const [
                PassqlSkeletonBox(
                  width: PassqlSize.iconTile,
                  height: PassqlSize.iconTile,
                  radius: PassqlRadius.iconTile,
                ),
                SizedBox(width: PassqlSpacing.xs),
                PassqlSkeletonBox(width: _titleWidth, height: _lineHeight),
              ],
            ),
            const SizedBox(height: PassqlSpacing.sm),
            // 한 줄 진단
            const FractionallySizedBox(
              widthFactor: _headlineWidthFactor,
              child: PassqlSkeletonBox(height: _headlineHeight),
            ),
            // 약한 토픽: 칩 + 이름 > 근거 > 패턴
            for (var index = 0; index < _findingCount; index++) ...[
              const SizedBox(height: PassqlSpacing.md),
              Row(
                children: const [
                  PassqlSkeletonBox(
                    width: _chipWidth,
                    height: _chipHeight,
                    radius: PassqlRadius.capsule,
                  ),
                  SizedBox(width: PassqlSpacing.xs),
                  PassqlSkeletonBox(
                    width: _topicNameWidth,
                    height: _lineHeight,
                  ),
                ],
              ),
              for (final widthFactor in _findingLineWidthFactors) ...[
                const SizedBox(height: PassqlSpacing.xs),
                FractionallySizedBox(
                  widthFactor: widthFactor,
                  child: const PassqlSkeletonBox(height: _lineHeight),
                ),
              ],
            ],
            // 바로 풀기 버튼 1개 자리
            const SizedBox(height: PassqlSpacing.md),
            const PassqlSkeletonBox(
              height: PassqlSize.buttonRegular,
              radius: PassqlRadius.md,
            ),
          ],
        ),
      ),
    );
  }
}
