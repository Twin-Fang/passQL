import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ads/app_open_ad_controller.dart';
import '../../providers/ad_providers.dart';

/// 탭 화면 복귀 시 앱 오프닝 광고 (#787): 광고 켜짐 > 미리 불러오기, 백그라운드 > 복귀 시 1회 시도
/// 풀이·결과처럼 탭 화면을 덮은 전체 화면 위에서는 띄우지 않음 (셸 라우트가 맨 위일 때만)
class AppOpenAdOnResume extends ConsumerStatefulWidget {
  const AppOpenAdOnResume({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppOpenAdOnResume> createState() => _AppOpenAdOnResumeState();
}

class _AppOpenAdOnResumeState extends ConsumerState<AppOpenAdOnResume> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onPause: _onAppPaused,
      onResume: _onAppResumed,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadIfEnabled());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _preloadIfEnabled() {
    if (!mounted || !ref.read(adsEnabledProvider)) return;
    unawaited(ref.read(appOpenAdControllerProvider).preload());
  }

  void _onAppPaused() {
    if (!mounted) return;
    ref.read(appOpenAdControllerProvider).recordBackgrounded();
  }

  void _onAppResumed() {
    if (!mounted) return;
    final isShellOnTop = ModalRoute.of(context)?.isCurrent ?? true;
    if (!ref.read(adsEnabledProvider) || !isShellOnTop) return;
    unawaited(ref.read(appOpenAdControllerProvider).showIfAllowedOnResume());
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
