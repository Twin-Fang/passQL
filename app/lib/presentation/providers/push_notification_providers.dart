import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/push/push_link.dart';
import '../../data/push/push_notification_service.dart';
import '../../router/push_link_routes.dart';
import '../widgets/common/app_toast.dart';
import 'auth_provider.dart';

/// 이 기기 알림 수신 동의 (설정 토글). null: 로그아웃·권한 없음·등록 전
/// 로그인 회원이 바뀌면 다시 등록 (권한 요청은 기기당 처음 1회)
class PushEnabledNotifier extends AsyncNotifier<bool?> {
  @override
  Future<bool?> build() async {
    final memberUuid = ref.watch(
      authProvider.select((session) => session.valueOrNull?.memberUuid),
    );
    if (memberUuid == null) return null;
    return ref
        .read(pushNotificationServiceProvider)
        .registerDeviceForSignedInMember();
  }

  /// 토글 즉시 반영 > 서버 저장 > 실패 시 이전 값 복원 후 예외 그대로 (PushSettingException·AppException)
  Future<void> setPushEnabled(bool isEnabled) async {
    final previous = state.valueOrNull;
    state = AsyncData(isEnabled);
    try {
      state = AsyncData(
        await ref
            .read(pushNotificationServiceProvider)
            .updatePushEnabled(isEnabled),
      );
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final pushEnabledProvider = AsyncNotifierProvider<PushEnabledNotifier, bool?>(
  PushEnabledNotifier.new,
);

/// 푸시 연결 (main 에서 1회): 첫 프레임 뒤 기기 등록 유지, 포그라운드 알림 토스트, 알림 탭 이동(백그라운드·종료 상태)
/// 첫 프레임 뒤에 시작해 권한 대화상자가 시작 화면 위에 뜨지 않게 함
void startPushNotificationSync(ProviderContainer container, GoRouter router) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final service = container.read(pushNotificationServiceProvider);
    // 로그인·회원 변경 시 등록 (provider 유지)
    container.listen(pushEnabledProvider, (_, _) {}, fireImmediately: true);

    service.foregroundMessages.listen(
      (message) => _showForegroundMessage(router, message),
    );
    service.openedLinks.listen((link) => openPushLink(router, link));
    final initialLink = await service.takeInitialLink();
    if (initialLink != null) openPushLink(router, initialLink);
  });
}

/// 포그라운드 알림 > 앱 토스트 (이동 정보 있으면 '보기')
void _showForegroundMessage(GoRouter router, ReceivedPushMessage message) {
  final context = router.routerDelegate.navigatorKey.currentContext;
  final text = [
    message.title,
    message.body,
  ].whereType<String>().where((part) => part.isNotEmpty).join('\n');
  if (context == null || text.isEmpty) return;
  final link = message.link;
  showAppToast(
    context,
    text,
    actionLabel: link == null ? null : '보기',
    onAction: link == null ? null : () => openPushLink(router, link),
  );
}
