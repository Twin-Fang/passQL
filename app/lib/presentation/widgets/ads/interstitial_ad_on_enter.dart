import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/interstitial_ad_controller.dart';
import '../../providers/ad_providers.dart';

/// 결과 화면 진입 시 전면 광고 1회 시도 (첫 프레임 뒤, 기다리지 않음)
/// 준비 안 됨·빈도 제한·광고 꺼짐이면 아무것도 하지 않음 > 결과 화면은 그대로
class InterstitialAdOnEnter extends ConsumerStatefulWidget {
  const InterstitialAdOnEnter({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<InterstitialAdOnEnter> createState() =>
      _InterstitialAdOnEnterState();
}

class _InterstitialAdOnEnterState extends ConsumerState<InterstitialAdOnEnter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !ref.read(adsEnabledProvider)) return;
      unawaited(ref.read(interstitialAdControllerProvider).showIfAllowed());
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
