import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'social_login_appearance.dart';

/// 소셜 로그인 버튼 공통 모양. 로고는 왼쪽에 고정하고 문구는 가운데에 둬서
/// 제공자마다 로고 폭이 달라도 문구 위치가 흔들리지 않게 한다.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.appearance,
    required this.isLoading,
    required this.onPressed,
  });

  final SocialLoginAppearance appearance;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = appearance.borderColor;
    // 다른 버튼이 로그인 중이면 흐리게: 브랜드 색은 바꾸지 않고(제공자 가이드) 눌리지 않는 상태만 보여 준다
    final isDimmed = onPressed == null && !isLoading;
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: appearance.label,
      // 라벨은 semanticLabel 하나로만 읽힘 (안쪽 문구·로고 합쳐지면 라벨 두 번)
      child: Opacity(
        opacity: isDimmed ? _disabledOpacity : 1,
        child: ExcludeSemantics(
          child: Container(
            width: double.infinity,
            height: PassqlSize.buttonLarge,
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.lg),
            decoration: BoxDecoration(
              color: appearance.backgroundColor,
              borderRadius: BorderRadius.circular(PassqlRadius.md),
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor),
            ),
            child: isLoading
                ? Center(
                    child: PassqlLoadingIndicator(
                      color: appearance.foregroundColor,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: _logoSlotWidth,
                          child: Center(child: appearance.logo),
                        ),
                      ),
                      Text(
                        appearance.label,
                        style: PassqlTypography.headline.copyWith(
                          color: appearance.foregroundColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// 로고 칸 폭 (문구 위치 고정)
const double _logoSlotWidth = 24;

// 비활성 버튼 불투명도
const double _disabledOpacity = 0.4;
