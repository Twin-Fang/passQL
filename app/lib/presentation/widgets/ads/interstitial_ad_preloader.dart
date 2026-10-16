import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/interstitial_ad_controller.dart';
import '../../providers/ad_providers.dart';

/// 전면 광고 미리 불러오기: 광고가 켜지는 순간(로그인 후 탭 화면) 1회
/// 결과 화면에서 바로 보일 수 있게 풀이 전에 준비 (닫힌 뒤 다음 것은 컨트롤러가 불러옴)
class InterstitialAdPreloader extends ConsumerStatefulWidget {
  const InterstitialAdPreloader({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InterstitialAdPreloader> createState() =>
      _InterstitialAdPreloaderState();
}

class _InterstitialAdPreloaderState
    extends ConsumerState<InterstitialAdPreloader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadIfEnabled());
  }

  void _preloadIfEnabled() {
    if (!mounted || !ref.read(adsEnabledProvider)) return;
    unawaited(ref.read(interstitialAdControllerProvider).preload());
  }

  @override
  Widget build(BuildContext context) {
    // 탭 화면에 있는 동안 로그인 상태가 켜지면 그때 불러옴
    ref.listen<bool>(adsEnabledProvider, (_, isEnabled) {
      if (isEnabled) _preloadIfEnabled();
    });
    return widget.child;
  }
}
