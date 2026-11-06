import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// AI 코멘트를 기다리는 동안의 자리: 머리 + 진단 한 줄 + 예상 점수 상자 + 약한 토픽 2묶음 + 버튼 (구조화 분석과 비슷한 높이)
class AiAnalysisCardSkeleton extends StatelessWidget {
  const AiAnalysisCardSkeleton({super.key});

  // 막대 높이: 글 줄·진단 줄·칩 (각 글자 크기 근처)
  static const double _lineHeight = 12;
  static const double _headlineHeight = 18;
  static const double _chipHeight = 18;
  static const double _titleWidth = 96;
  static const double _chipWidth = 40;
  static const double _topicNameWidth = 88;
  // 예상 점수 상자 높이 (머리·큰 점수·과목 막대 2줄·설명, 안쪽 여백 포함 어림값)
  static const double _forecastBoxHeight = 156;
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
            // 예상 점수 상자
            const SizedBox(height: PassqlSpacing.md),
            const PassqlSkeletonBox(
              height: _forecastBoxHeight,
              radius: PassqlRadius.lg,
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
