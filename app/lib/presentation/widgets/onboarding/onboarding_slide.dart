import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 온보딩 한 장의 공통 배치: 위 시각 요소(남는 높이 전부) > 아래 제목·보조 문구
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.visual,
    required this.title,
    required this.subtitle,
    this.backdrop,
  });

  final Widget visual;

  /// 시각 요소 뒤에 화면 좌우 끝까지 깔리는 장식 (키워드 스티커). 제목·버튼은 가리지 않는다.
  final Widget? backdrop;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (backdrop != null)
                  // 좌우 여백 밖(화면 끝)까지 넓혀 스티커가 가장자리에서 잘려 보이게
                  Positioned(
                    left: -PassqlSpacing.md,
                    right: -PassqlSpacing.md,
                    top: 0,
                    bottom: 0,
                    child: backdrop!,
                  ),
                Positioned.fill(child: visual),
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.lg),
          Text(
            title,
            style: PassqlTypography.title1.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            subtitle,
            style: PassqlTypography.callout.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
        ],
      ),
    );
  }
}
