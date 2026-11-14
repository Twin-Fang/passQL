import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 온보딩 마지막 장 기능 한눈에 (#945): 2열 4칸(모의고사, 오답 노트, 개념, 통계) > 넓은 칸(오늘의 세트)
/// 칸마다 차례로 떠오름 (동작 줄이기면 바로)
class OnboardingFeatureGrid extends StatelessWidget {
  const OnboardingFeatureGrid({super.key});

  // 2열 칸: (기능 이름, 한 줄 설명) 2줄 x 2칸
  static const List<List<_Feature>> _featureRows = [
    [
      _Feature(name: '모의고사', description: '50문항 90분, 과락까지'),
      _Feature(name: '오답 노트', description: '틀린 문제만 다시'),
    ],
    [
      _Feature(name: '개념', description: '단원별 핵심만'),
      _Feature(name: '통계', description: '약한 영역 한눈에'),
    ],
  ];

  // 첫 문제로 이어지는 기능이라 아래 넓은 칸 하나로 따로 둠
  static const _dailySetFeature = _Feature(
    name: '오늘의 세트',
    description: '매일 5문제, 크레딧 없이',
  );

  @override
  Widget build(BuildContext context) {
    var revealIndex = 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final featureRow in _featureRows) ...[
          // 한 줄 두 칸 높이 맞춤 (설명이 두 줄로 접혀도 나란히)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < featureRow.length; column++) ...[
                  if (column > 0) const SizedBox(width: PassqlSpacing.xs),
                  Expanded(
                    child: PassqlReveal(
                      index: revealIndex++,
                      child: _FeatureCell(feature: featureRow[column]),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
        ],
        PassqlReveal(
          index: revealIndex,
          child: const _FeatureCell(feature: _dailySetFeature),
        ),
      ],
    );
  }
}

/// 기능 한 칸 값: 이름 + 한 줄 설명
class _Feature {
  const _Feature({required this.name, required this.description});

  final String name;
  final String description;
}

/// 기능 한 칸: 강조색 이름 > 보조색 설명 (스크린리더는 한 번에 읽음)
class _FeatureCell extends StatelessWidget {
  const _FeatureCell({required this.feature});

  final _Feature feature;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return MergeSemantics(
      child: PassqlCard(
        isCardTapExposedToScreenReader: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature.name,
              style: PassqlTypography.headline.copyWith(
                color: colors.accentText,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xxs),
            // 좁은 칸에서 낱말 중간 줄바꿈 방지 (예: 과락까 / 지)
            PassqlKeepAllText(
              feature.description,
              style: PassqlTypography.subheadline.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
