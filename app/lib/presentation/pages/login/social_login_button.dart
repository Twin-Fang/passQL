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
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: appearance.label,
      child: Container(
        width: double.infinity,
        height: PassqlSize.buttonLarge,
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.lg),
        decoration: BoxDecoration(
          color: appearance.backgroundColor,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
          border: borderColor == null ? null : Border.all(color: borderColor),
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
    );
  }
}

// 로고 칸 폭 (문구 위치 고정)
const double _logoSlotWidth = 24;
