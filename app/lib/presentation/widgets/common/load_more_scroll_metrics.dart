import 'package:flutter/widgets.dart';

/// 무한 스크롤 다음 페이지 요청 시점 판정 공통 (목록 끝까지 남은 거리 기준)
/// ScrollController.position·ScrollUpdateNotification.metrics 모두 ScrollMetrics
extension LoadMoreScrollMetrics on ScrollMetrics {
  // 목록 끝까지 남은 거리가 이 값 이하면 다음 페이지 요청
  static const double loadMoreTriggerPixels = 320;

  /// 다음 페이지를 요청할 만큼 끝에 가까운지
  bool get isNearLoadMoreEnd => extentAfter <= loadMoreTriggerPixels;
}
