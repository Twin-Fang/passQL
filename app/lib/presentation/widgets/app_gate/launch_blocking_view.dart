import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 앱 사용을 막는 안내 화면 틀 (강제 업데이트·점검 공용)
/// 아이콘 > 제목 > 안내 문구 > 보조 문구 > 버튼, 뒤로가기 막음
class LaunchBlockingView extends StatelessWidget {
  const LaunchBlockingView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.detail,
    this.actionLabel,
    this.onActionPressed,
    this.isActionLoading = false,
  });

  final IconData icon;
  final String title;
  final String message;

  /// 버전 같은 작은 보조 문구 (없으면 숨김)
  final String? detail;

  /// 버튼 문구 (없으면 버튼 숨김)
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  icon,
                  size: PassqlIconSize.statusPlaceholder,
                  color: colors.accent,
                ),
                const SizedBox(height: PassqlSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: PassqlTypography.title2.copyWith(color: colors.label),
                ),
                const SizedBox(height: PassqlSpacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: PassqlTypography.callout.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: PassqlSpacing.md),
                  Text(
                    detail!,
                    textAlign: TextAlign.center,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
                const Spacer(),
                if (actionLabel != null)
                  PassqlButton(
                    label: actionLabel!,
                    onPressed: onActionPressed,
                    isLoading: isActionLoading,
                    size: PassqlButtonSize.large,
                  ),
                const SizedBox(height: PassqlSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
