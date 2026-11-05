import 'dart:async';

import '../config/app_build_flavor.dart';
import 'push_link.dart';
import 'push_messaging_client.dart';

/// 개발자 도구 푸시 흉내 (#819): 가짜 알림을 실제 수신·탭 스트림에 끼워 넣음 (서버·FCM 발송 없음)
/// 나머지(권한·토큰)는 실제 클라이언트에 그대로 위임 > 수신 토스트·탭 이동은 실제 알림과 같은 경로
class DevSimulatedPushMessagingClient extends PushMessagingClient {
  const DevSimulatedPushMessagingClient(this._delegate);

  final PushMessagingClient _delegate;

  // 흉내 알림 2종 통로: 앱 사용 중 수신, 알림 탭으로 열림
  static final StreamController<ReceivedPushMessage>
  _simulatedForegroundMessages =
      StreamController<ReceivedPushMessage>.broadcast();
  static final StreamController<PushLink> _simulatedOpenedLinks =
      StreamController<PushLink>.broadcast();

  /// 개발 장치 빌드만 감쌈 (스토어 빌드는 상수 false > 실제 클라이언트 그대로)
  static PushMessagingClient wrapIfAllowed(PushMessagingClient client) =>
      AppBuildFlavor.canUseDevTools
      ? DevSimulatedPushMessagingClient(client)
      : client;

  /// 앱 사용 중 알림 받은 것처럼 (토스트 + '보기')
  static void simulateForegroundMessage(ReceivedPushMessage message) {
    if (!AppBuildFlavor.canUseDevTools) return;
    _simulatedForegroundMessages.add(message);
  }

  /// 시스템 알림을 탭한 것처럼 (바로 이동)
  static void simulateOpenedLink(PushLink link) {
    if (!AppBuildFlavor.canUseDevTools) return;
    _simulatedOpenedLinks.add(link);
  }

  @override
  String get platformName => _delegate.platformName;

  @override
  Future<PushPermissionStatus> readPermissionStatus() =>
      _delegate.readPermissionStatus();

  @override
  Future<PushPermissionStatus> requestPermission() =>
      _delegate.requestPermission();

  @override
  Future<bool> openDeviceNotificationSettings() =>
      _delegate.openDeviceNotificationSettings();

  @override
  Future<String?> fetchToken() => _delegate.fetchToken();

  @override
  Stream<String> get tokenRefreshes => _delegate.tokenRefreshes;

  @override
  Stream<ReceivedPushMessage> get foregroundMessages =>
      _merge(_delegate.foregroundMessages, _simulatedForegroundMessages.stream);

  @override
  Stream<PushLink> get openedLinks =>
      _merge(_delegate.openedLinks, _simulatedOpenedLinks.stream);

  @override
  Future<PushLink?> takeInitialLink() => _delegate.takeInitialLink();

  /// 실제 스트림 + 흉내 스트림 > 하나 (구독 해제 시 둘 다 해제)
  static Stream<T> _merge<T>(Stream<T> realStream, Stream<T> simulatedStream) =>
      Stream<T>.multi((controller) {
        final subscriptions = [
          for (final stream in [realStream, simulatedStream])
            stream.listen(controller.add, onError: controller.addError),
        ];
        controller.onCancel = () async {
          for (final subscription in subscriptions) {
            await subscription.cancel();
          }
        };
      });
}
