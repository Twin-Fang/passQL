import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 구간 제목: "다시 볼 문제" + 보라 개수
class ConceptResultSectionTitle extends StatelessWidget {
  const ConceptResultSectionTitle({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: PassqlSpacing.xxs),
      child: Text.rich(
        TextSpan(
          text: '$title ',
          style: PassqlTypography.title3.copyWith(color: colors.label),
          children: [
            TextSpan(
              text: '$count',
              style: TextStyle(
                color: colors.accentText,
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 줄 사이 머리카락 선 (iOS 목록과 같은 1물리픽셀)
class ConceptResultHairline extends StatelessWidget {
  const ConceptResultHairline({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(height: 0, thickness: 0, color: context.passqlColors.separator);
}
