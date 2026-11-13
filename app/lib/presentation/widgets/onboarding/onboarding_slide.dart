import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 온보딩 한 장의 공통 배치: 위 시각 요소(남는 높이 전부) > 아래 제목·보조 문구
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.visual,
    required this.title,
    this.subtitle,
  });

  final Widget visual;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 제목·부제가 위, 그림이 아래 (읽는 순서대로, #975)
          const SizedBox(height: PassqlSpacing.md),
          Semantics(
            header: true,
            child: Text(
              title,
              style: PassqlTypography.title1.copyWith(color: colors.label),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              subtitle!,
              style: PassqlTypography.callout.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.lg),
          // 그림 무대: 남는 높이 전부를 옅은 강조색 바탕으로 (화면 절반 이상, #945)
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentTint,
                borderRadius: BorderRadius.circular(PassqlRadius.lg),
              ),
              child: Padding(
                padding: const EdgeInsets.all(PassqlSpacing.md),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 세로 가운데. 스크롤 뷰로 감싸 카드가 남은 높이를 다 채우지 않고 내용 높이만 차지하게 한다
                    // (작은 화면에서 넘치면 잘림, 넘김은 페이지 스와이프와 겹치지 않게 막음)
                    Positioned.fill(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          // 장을 처음 볼 때 그림이 아래에서 살짝 떠오름 (제목 다음 순서, 동작 줄이기면 바로)
                          child: PassqlReveal(index: 1, child: visual),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
        ],
      ),
    );
  }
}
