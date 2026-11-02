import 'package:flutter/foundation.dart';

/// 미리 불러 둔 전체 화면 광고 1개(전면·앱 오프닝 공통): 로드 시각·표시·해제
class LoadedFullScreenAd {
  const LoadedFullScreenAd({
    required this.loadedAt,
    required this.show,
    required this.dispose,
  });

  final DateTime loadedAt;

  /// 표시 요청. 실제로 화면에 뜨면 onShown, 닫히거나 표시 실패하면 onClosed (어느 쪽이든 1회)
  final void Function({
    required VoidCallback onShown,
    required VoidCallback onClosed,
  })
  show;

  final VoidCallback dispose;
}
