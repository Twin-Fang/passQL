import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lock_screen_providers.dart';
import '../practice/daily_limit_reward_sheet.dart';
import '../pro/pro_offer_sheet.dart';

/// 잠금화면·상태 알림에서 연 앱 경로 처리 (앱 엔진, MaterialApp builder 에 1개)
/// 경로 5종: 크레딧 받기 시트, 이용권 시트, 문제 상세, 문제별 의견 목록, 설정. 로그인 전이면 무시
/// 시작 경로(앱이 꺼져 있었음)는 첫 프레임 뒤 1회, 떠 있을 때는 채널 신호로
class LockScreenRouteHandler extends ConsumerStatefulWidget {
  const LockScreenRouteHandler({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  /// 시트를 띄울 최상위 Navigator (빌더 context 는 Navigator 위라 직접 못 씀)
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<LockScreenRouteHandler> createState() =>
      _LockScreenRouteHandlerState();
}

class _LockScreenRouteHandlerState
    extends ConsumerState<LockScreenRouteHandler> {
  StreamSubscription<String>? _routeSubscription;

  @override
  void initState() {
    super.initState();
    final bridge = ref.read(lockScreenBridgeProvider);
    if (!bridge.isLockScreenSupported) return;
    _routeSubscription = bridge.openedRoutes.listen(_open);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pendingRoute = await bridge.takePendingRoute();
      if (pendingRoute != null) _open(pendingRoute);
    });
  }

  @override
  void dispose() {
    _routeSubscription?.cancel();
    super.dispose();
  }

  /// 경로 열기 (다음 프레임: 앱 복귀 직후 라우터가 자리를 잡은 뒤)
  void _open(String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigatorContext = widget.navigatorKey.currentContext;
      if (!mounted || navigatorContext == null) return;
      if (ref.read(authProvider).valueOrNull == null) return;
      final questionUuid = LockScreenRoutes.questionUuidOf(route);
      if (questionUuid != null) {
        navigatorContext.push(AppRoutes.questionDetail(questionUuid));
        return;
      }
      final discussionQuestionUuid = LockScreenRoutes.discussionQuestionUuidOf(
        route,
      );
      if (discussionQuestionUuid != null) {
        navigatorContext.push(
          AppRoutes.communityQuestion(discussionQuestionUuid),
        );
        return;
      }
      switch (route) {
        case LockScreenRoutes.creditReward:
          unawaited(showDailyLimitRewardSheet(navigatorContext));
        case LockScreenRoutes.passSheet:
          unawaited(showProOfferSheet(navigatorContext, ref));
        case LockScreenRoutes.settings:
          navigatorContext.push(AppRoutes.settings);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
