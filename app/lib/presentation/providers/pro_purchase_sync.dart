import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/billing/pro_purchase_port.dart';
import '../../data/billing/play_purchase_service.dart';
import '../../data/sources/api_providers.dart';
import '../../router/app_routes.dart';
import '../widgets/common/app_toast.dart';
import '../widgets/pro/pro_purchase_feedback.dart';
import 'plan_providers.dart';
import 'session_reset.dart';

/// Play 결제 어댑터 (Android, 앱 수명 1개): 확인된 구매 > 등급 다시 받기 > 프로인지
/// 구매 스트림 구독을 끊지 않도록 API 는 watch 하지 않고 1회 read
final playPurchaseServiceProvider = Provider<PlayPurchaseService>((ref) {
  final service = PlayPurchaseService(
    billingApi: ref.read(billingApiProvider),
    refreshPlan: () async {
      await ref.read(planProvider.notifier).refresh();
      return ref.read(isProProvider);
    },
  );
  ref.onDispose(service.dispose);
  return service;
});

/// 결제 포트 교체 (main 컨테이너 생성 때): Android 만 Play 어댑터, 그 외 결제 없음
final Override proPurchasePortOverride = proPurchasePortProvider.overrideWith(
  (ref) => ref.watch(targetPlatformProvider) == TargetPlatform.android
      ? ref.watch(playPurchaseServiceProvider)
      : const UnavailableProPurchasePort(),
);

/// 등급·결제 연결 (main 에서 1회)
/// 전 플랫폼: 등급 앱 수명 유지(로그인·회원 전환 때 다시 받음) > 앱 복귀 때 등급 갱신(첫 조회 실패 복구 포함)
/// Android 만: 구매 스트림 구독 > 로그인·복귀 때 미확인 구매 재전송 > 결제 창 밖 결제 완료 토스트
void startProPurchaseSync(ProviderContainer container, GoRouter router) {
  container.listen(planProvider, (_, _) {});
  final isAndroid =
      container.read(targetPlatformProvider) == TargetPlatform.android;
  final service = isAndroid
      ? (container.read(playPurchaseServiceProvider)..startListening())
      : null;
  // 앱 수명 동안 유지 (해제하지 않음)
  AppLifecycleListener(
    onResume: () => unawaited(_refreshOnResume(container, service)),
  );
  if (service == null) return;
  container.listen<String?>(currentMemberUuidProvider, (previous, next) {
    if (next != null && next != previous) {
      unawaited(service.resendUnverifiedPurchases());
    }
  }, fireImmediately: true);
  service.backgroundProUnlocks.listen(
    (_) => _showBackgroundUnlockToast(router),
  );
}

/// 앱 복귀: 로그인 상태면 등급 갱신 > (Android) 미확인 구매 재전송
Future<void> _refreshOnResume(
  ProviderContainer container,
  PlayPurchaseService? service,
) async {
  if (container.read(currentMemberUuidProvider) == null) return;
  try {
    await container.read(planProvider.notifier).refresh();
  } on Object catch (error) {
    // 인증 만료는 인터셉터가 세션 만료 신호로 처리
    debugPrint('[billing] plan refresh on resume failed : $error');
  }
  await service?.resendUnverifiedPurchases();
}

/// 결제 창 밖 결제 완료(지연 결제 등) 토스트 (로그인 화면이면 생략)
void _showBackgroundUnlockToast(GoRouter router) {
  final context = router.routerDelegate.navigatorKey.currentContext;
  if (context == null || router.state.matchedLocation == AppRoutes.login) {
    return;
  }
  showAppToast(context, proPurchaseSucceededMessage);
}
