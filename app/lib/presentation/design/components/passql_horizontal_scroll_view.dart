import 'package:flutter/widgets.dart';

import '../tokens/passql_tokens.dart';

/// 가로 스크롤 공통: 오른쪽에 더 볼 내용이 있으면 오른쪽 끝을 흐리게 해 밀 수 있음을 알림
/// 흐림은 내용 자체에 적용 > 배경색(코드 상자·표 카드)과 무관
class PassqlHorizontalScrollView extends StatefulWidget {
  const PassqlHorizontalScrollView({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<PassqlHorizontalScrollView> createState() =>
      _PassqlHorizontalScrollViewState();
}

class _PassqlHorizontalScrollViewState
    extends State<PassqlHorizontalScrollView> {
  // 오른쪽 흐림 폭
  static const double _fadeWidthPixels = PassqlSpacing.xxl;
  // 끝까지 밀었다고 보는 남은 거리 (소수점 오차 흡수)
  static const double _scrollEndTolerancePixels = 1;
  // 마스크 알파 (색은 쓰이지 않음)
  static const Color _opaqueMaskColor = Color(0xFFFFFFFF);
  static const Color _transparentMaskColor = Color(0x00FFFFFF);

  bool _hasMoreContentToRight = false;

  /// 스크롤 위치·내용 폭 변화 > 오른쪽에 남은 내용 여부 갱신
  bool _onScrollMetricsChanged(ScrollMetrics metrics) {
    final hasMoreContentToRight =
        metrics.extentAfter > _scrollEndTolerancePixels;
    if (hasMoreContentToRight != _hasMoreContentToRight) {
      setState(() => _hasMoreContentToRight = hasMoreContentToRight);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = NotificationListener<ScrollMetricsNotification>(
      onNotification: (notification) =>
          _onScrollMetricsChanged(notification.metrics),
      child: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) =>
            _onScrollMetricsChanged(notification.metrics),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
    // 내용 불투명 > 오른쪽 끝 투명 (dstIn: 그라데이션 알파만큼 내용 유지)
    // 흐림 여부와 무관하게 ShaderMask 유지 (트리가 바뀌면 스크롤 위치가 초기화됨)
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) {
        final fadeStart = ((bounds.width - _fadeWidthPixels) / bounds.width)
            .clamp(0.0, 1.0);
        return LinearGradient(
          colors: [
            _opaqueMaskColor,
            _hasMoreContentToRight ? _transparentMaskColor : _opaqueMaskColor,
          ],
          stops: [fadeStart, 1],
        ).createShader(bounds);
      },
      child: scrollView,
    );
  }
}
