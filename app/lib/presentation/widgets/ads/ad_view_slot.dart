import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/loaded_ad_view.dart';
import '../../providers/ad_providers.dart';

/// 화면 안 광고 자리 공통(배너·네이티브): 폭 측정 > 로드 > 성공 시 틀과 함께 표시
/// 로드 전·실패 시 높이 0 (빈 자리 없음). 실패하면 30초·60초 뒤 1회씩만 재시도
class AdViewSlot extends ConsumerStatefulWidget {
  const AdViewSlot({
    super.key,
    required this.loadAd,
    required this.frameBuilder,
  });

  /// 폭(dp) > 로드된 광고. 실패면 null
  final Future<LoadedAdView?> Function(
    BuildContext context,
    WidgetRef ref,
    int widthDp,
  )
  loadAd;

  /// 로드된 광고 > 화면에 둘 틀 (여백·라벨 포함)
  final Widget Function(BuildContext context, LoadedAdView adView) frameBuilder;

  @override
  ConsumerState<AdViewSlot> createState() => _AdViewSlotState();
}

class _AdViewSlotState extends ConsumerState<AdViewSlot> {
  // 실패 뒤 재시도 간격 (2회 뒤 중단)
  static const _retryDelays = [Duration(seconds: 30), Duration(seconds: 60)];

  LoadedAdView? _adView;
  Timer? _retryTimer;
  int _retryAttemptCount = 0;
  bool _isDisposed = false;
  bool _isLoading = false;
  int _measuredWidthDp = 0;

  @override
  void dispose() {
    _isDisposed = true;
    _retryTimer?.cancel();
    _adView?.dispose();
    super.dispose();
  }

  /// 로드 1회: 중복 방지 > 로드 > 화면 사라짐이면 해제 > 성공 표시 또는 재시도 예약
  Future<void> _load() async {
    if (_isLoading || _adView != null || _isDisposed) return;
    _isLoading = true;
    LoadedAdView? loadedAdView;
    try {
      loadedAdView = await widget.loadAd(context, ref, _measuredWidthDp);
    } catch (_) {
      // 로더 예외도 실패로 취급 (화면은 유지)
      loadedAdView = null;
    }
    _isLoading = false;
    if (_isDisposed) {
      loadedAdView?.dispose();
      return;
    }
    if (loadedAdView != null) {
      setState(() => _adView = loadedAdView);
      return;
    }
    if (_retryAttemptCount < _retryDelays.length) {
      _retryTimer = Timer(_retryDelays[_retryAttemptCount++], _load);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(adsEnabledProvider)) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final widthDp = constraints.maxWidth.isFinite
            ? constraints.maxWidth.floor()
            : MediaQuery.sizeOf(context).width.floor();
        if (widthDp > 0 && _measuredWidthDp == 0) {
          _measuredWidthDp = widthDp;
          // 빌드 중 상태 변경 금지 > 첫 프레임 뒤 로드
          WidgetsBinding.instance.addPostFrameCallback((_) => _load());
        }
        final adView = _adView;
        if (adView == null) return const SizedBox.shrink();
        return widget.frameBuilder(context, adView);
      },
    );
  }
}
