import 'package:flutter/cupertino.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_button.dart';

/// 로딩·빈 상태·오류를 한 모양으로. 화면마다 오류 뷰를 따로 만들지 않는다.
class PassqlStatusView extends StatelessWidget {
  const PassqlStatusView._({
    this.icon,
    this.title,
    this.message,
    this.onRetry,
    this.loading = false,
  });

  const factory PassqlStatusView.loading() = _Loading;

  factory PassqlStatusView.empty({
    required IconData icon,
    required String title,
    String? message,
  }) => PassqlStatusView._(icon: icon, title: title, message: message);

  factory PassqlStatusView.error({
    required String message,
    VoidCallback? onRetry,
  }) => PassqlStatusView._(
    icon: CupertinoIcons.exclamationmark_triangle,
    title: '문제가 생겼어요',
    message: message,
    onRetry: onRetry,
  );

  final IconData? icon;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PassqlSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: colors.tertiaryLabel),
            const SizedBox(height: PassqlSpacing.sm),
            Text(
              title!,
              style: PassqlTypography.headline.copyWith(color: colors.label),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: PassqlSpacing.xxs),
              Text(
                message!,
                style: PassqlTypography.subheadline.copyWith(color: colors.secondaryLabel),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: PassqlSpacing.md),
              PassqlButton(
                label: '다시 시도',
                onPressed: onRetry,
                variant: PassqlButtonVariant.tinted,
                size: PassqlButtonSize.small,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Loading extends PassqlStatusView {
  const _Loading() : super._(loading: true);

  @override
  Widget build(BuildContext context) =>
      const Center(child: CupertinoActivityIndicator(radius: 12));
}
