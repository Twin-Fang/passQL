import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/push/push_link.dart';
import '../../core/push/push_permission_prompt_store.dart';
import '../../data/push/push_notification_service.dart';
import '../../router/push_link_routes.dart';
import '../widgets/common/app_toast.dart';
import 'auth_provider.dart';
import 'unread_notification_providers.dart';

/// 이 기기 알림 수신 동의 (설정 토글). null: 로그아웃·권한 없음·등록 전
/// 로그인 회원이 바뀌면 다시 등록 (이미 허용한 경우만, 시스템 권한 창은 안내 시트·토글에서만)
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

/// 알림 권한 안내 "나중에" 기록 (테스트는 SharedPreferences 모의값 사용)
final pushPermissionPromptStoreProvider = Provider<PushPermissionPromptStore>(
  (ref) => const PushPermissionPromptStore(),
);

/// 푸시 연결 (main 에서 1회): 첫 프레임 뒤 기기 등록 유지, 포그라운드 알림 토스트·안 읽은 개수 갱신, 알림 탭 이동(백그라운드·종료 상태)
void startPushNotificationSync(ProviderContainer container, GoRouter router) {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final service = container.read(pushNotificationServiceProvider);
    // 로그인·회원 변경 시 등록 (provider 유지)
    container.listen(pushEnabledProvider, (_, _) {}, fireImmediately: true);

    service.foregroundMessages.listen((message) {
      _showForegroundMessage(router, message);
      // 새 알림이 알림함에 쌓였으므로 개수 갱신
      container.read(unreadNotificationCountProvider.notifier).refresh();
    });
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
