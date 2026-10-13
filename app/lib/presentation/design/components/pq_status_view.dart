import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

import '../pq_theme.dart';
import '../tokens/pq_metrics.dart';
import '../tokens/pq_type.dart';
import 'pq_button.dart';

/// 로딩·빈 상태·오류를 한 모양으로. 화면마다 오류 뷰를 따로 만들지 않는다.
class PqStatusView extends StatelessWidget {
  const PqStatusView._({
    this.icon,
    this.title,
    this.message,
    this.onRetry,
    this.loading = false,
  });

  const factory PqStatusView.loading() = _Loading;

  factory PqStatusView.empty({
    required IconData icon,
    required String title,
    String? message,
  }) => PqStatusView._(icon: icon, title: title, message: message);

  factory PqStatusView.error({
    required String message,
    VoidCallback? onRetry,
  }) => PqStatusView._(
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
    final c = context.pq;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(PqSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: c.tertiaryLabel),
            const SizedBox(height: PqSpace.sm),
            Text(
              title!,
              style: PqType.headline.copyWith(color: c.label),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: PqSpace.xxs),
              Text(
                message!,
                style: PqType.subheadline.copyWith(color: c.secondaryLabel),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: PqSpace.md),
              PqButton(
                label: '다시 시도',
                onPressed: onRetry,
                variant: PqButtonVariant.tinted,
                size: PqButtonSize.small,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Loading extends PqStatusView {
  const _Loading() : super._(loading: true);

  @override
  Widget build(BuildContext context) =>
      const Center(child: CupertinoActivityIndicator(radius: 12));
}

/// 스켈레톤 한 조각. 화면별 스켈레톤은 이것을 배치만 한다.
class PqSkeletonBox extends StatelessWidget {
  const PqSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = PqRadius.sm,
  });
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.pq;
    return Shimmer.fromColors(
      baseColor: Color.alphaBlend(c.fill, c.card),
      highlightColor: c.card,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
