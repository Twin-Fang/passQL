import 'push_link.dart';

/// 알림 권한 상태 3종 (provisional 은 granted 로 봄)
enum PushPermissionStatus { granted, denied, notDetermined }

/// 푸시 SDK 저수준 포트: 권한, 기기 토큰, 수신·탭 스트림
/// 기본값은 아무것도 하지 않는 구현 > main 에서 Firebase 구현으로 교체 (테스트는 가짜 구현)
abstract class PushMessagingClient {
  const PushMessagingClient();

  /// 앱 전역 클라이언트. provider 기본값으로 쓰임
  static PushMessagingClient current = const NoopPushMessagingClient();

  /// 서버 등록용 플랫폼 이름: IOS, ANDROID
  String get platformName;

  /// 묻지 않고 현재 권한만 읽음
  Future<PushPermissionStatus> readPermissionStatus();

  /// 시스템 권한 요청 (이미 정해졌으면 묻지 않고 현재 값)
  Future<PushPermissionStatus> requestPermission();

  /// 이 기기 FCM 토큰 (발급 불가 > null: iOS APNs 미설정·시뮬레이터 등)
  Future<String?> fetchToken();

  Stream<String> get tokenRefreshes;

  /// 앱 사용 중(포그라운드) 받은 알림
  Stream<ReceivedPushMessage> get foregroundMessages;

  /// 백그라운드 상태에서 알림을 탭해 앱으로 돌아온 경우의 이동 정보
  Stream<PushLink> get openedLinks;

  /// 종료 상태에서 알림을 탭해 앱이 켜진 경우의 이동 정보 (최초 1회만 값)
  Future<PushLink?> takeInitialLink();
}

/// 아무것도 하지 않는 구현 (테스트·Firebase 초기화 전)
class NoopPushMessagingClient extends PushMessagingClient {
  const NoopPushMessagingClient();

  @override
  String get platformName => 'ANDROID';

  @override
  Future<PushPermissionStatus> readPermissionStatus() async =>
      PushPermissionStatus.notDetermined;

  @override
  Future<PushPermissionStatus> requestPermission() async =>
      PushPermissionStatus.notDetermined;

  @override
  Future<String?> fetchToken() async => null;

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Stream<ReceivedPushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushLink> get openedLinks => const Stream.empty();

  @override
  Future<PushLink?> takeInitialLink() async => null;
}
