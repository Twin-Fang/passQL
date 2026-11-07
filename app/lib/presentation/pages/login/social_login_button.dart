import 'package:flutter/material.dart';

import '../../design/design.dart';
import 'social_login_appearance.dart';

/// 소셜 로그인 버튼 공통 모양. 로고는 왼쪽에 고정하고 문구는 가운데에 둬서
/// 제공자마다 로고 폭이 달라도 문구 위치가 흔들리지 않게 한다.
/// 최근 로그인 버튼은 오른쪽 위 테두리에 걸친 "최근 로그인" 배지 (#908)
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.appearance,
    required this.isLoading,
    required this.onPressed,
    this.isRecentLogin = false,
  });

  final SocialLoginAppearance appearance;
  final bool isLoading;
  final VoidCallback? onPressed;
  final bool isRecentLogin;

  @override
  Widget build(BuildContext context) {
    final borderColor = appearance.borderColor;
    // 다른 버튼이 로그인 중이면 흐리게: 브랜드 색은 바꾸지 않고(제공자 가이드) 눌리지 않는 상태만 보여 준다
    final isDimmed = onPressed == null && !isLoading;
    final button = Container(
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
              child: PassqlLoadingIndicator(color: appearance.foregroundColor),
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
    );
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: isRecentLogin
          ? '${appearance.label}, $recentLoginBadgeLabel'
          : appearance.label,
      // 라벨은 semanticLabel 하나로만 읽힘 (안쪽 문구·로고 합쳐지면 라벨 두 번)
      child: Opacity(
        opacity: isDimmed ? _disabledOpacity : 1,
        child: ExcludeSemantics(
          child: isRecentLogin
              // 배지가 위 버튼과 겹치지 않게 걸친 높이만큼 위 여백
              ? Padding(
                  padding: const EdgeInsets.only(top: _recentBadgeOverlap),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      button,
                      const Positioned(
                        top: -_recentBadgeOverlap,
                        right: PassqlSpacing.md,
                        child: _RecentLoginBadge(),
                      ),
                    ],
                  ),
                )
              : button,
        ),
      ),
    );
  }
}

/// "최근 로그인" 배지 문구 (화면·스크린리더 공통)
const String recentLoginBadgeLabel = '최근 로그인';

/// 최근 로그인 배지: 강조색 알약 + 흰 글자
class _RecentLoginBadge extends StatelessWidget {
  const _RecentLoginBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.xs,
        vertical: PassqlSpacing.hairlineGap,
      ),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: BorderRadius.circular(PassqlRadius.capsule),
      ),
      child: Text(
        recentLoginBadgeLabel,
        style: PassqlTypography.captionSemibold.copyWith(
          color: colors.onAccent,
        ),
      ),
    );
  }
}

// 로고 칸 폭 (문구 위치 고정)
const double _logoSlotWidth = 24;

// 비활성 버튼 불투명도
const double _disabledOpacity = 0.4;

// 배지가 버튼 위 테두리 밖으로 걸치는 높이 (배지 높이 절반: 캡션 줄 16 + 위아래 2)
const double _recentBadgeOverlap = 10;
