import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 온보딩 한 장의 공통 배치: 위 시각 요소(남는 높이 전부) > 아래 제목·보조 문구
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.visual,
    required this.title,
    this.subtitle,
    this.backdrop,
  });

  final Widget visual;

  /// 시각 요소 뒤에 화면 좌우 끝까지 깔리는 장식 (키워드 스티커). 제목·버튼은 가리지 않는다.
  final Widget? backdrop;
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
                // 세로 가운데. 스크롤 뷰로 감싸 카드가 남은 높이를 다 채우지 않고 내용 높이만 차지하게 한다
                // (작은 화면에서 넘치면 잘림, 넘김은 페이지 스와이프와 겹치지 않게 막음)
                Positioned.fill(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: visual,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PassqlSpacing.lg),
          Text(
            title,
            style: PassqlTypography.title1.copyWith(color: colors.label),
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
          const SizedBox(height: PassqlSpacing.md),
        ],
      ),
    );
  }
}
