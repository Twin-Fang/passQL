import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/push/push_link.dart';
import 'package:passql_app/core/push/push_messaging_client.dart';
import 'package:passql_app/data/push/push_notification_service.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:passql_app/router/push_link_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes/fake_push.dart';

/// 푸시 공통 지점: 권한은 읽기만(요청은 켜기 때만), 토큰 등록·재등록, 수신 동의 변경, 로그아웃 삭제, 알림 이동 (#467, #491)
void main() {
  late FakePushMessagingClient messagingClient;
  late FakePushTokenApi pushTokenApi;
  late PushNotificationService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // 이미 알림을 허용한 기기 (기본)
    messagingClient = FakePushMessagingClient(
      currentPermission: PushPermissionStatus.granted,
    );
    pushTokenApi = FakePushTokenApi();
    service = PushNotificationService(
      messagingClient: messagingClient,
      pushTokenApi: pushTokenApi,
    );
  });

  test('이미 허용한 기기는 시스템 창 없이 토큰을 서버에 등록한다', () async {
    expect(await service.registerDeviceForSignedInMember(), isTrue);
    expect(messagingClient.permissionRequestCount, 0);
    expect(pushTokenApi.registeredRequests.single.token, 'device-token');
    expect(pushTokenApi.registeredRequests.single.platform, 'IOS');
  });

  test('아직 안 물었거나 거부한 기기는 권한을 요청하지 않고 등록하지 않는다', () async {
    for (final status in [
      PushPermissionStatus.notDetermined,
      PushPermissionStatus.denied,
    ]) {
      messagingClient.currentPermission = status;

      expect(await service.registerDeviceForSignedInMember(), isNull);
    }
    expect(messagingClient.permissionRequestCount, 0);
    expect(pushTokenApi.registeredRequests, isEmpty);
  });

  test('켜기를 고르면 그때 권한을 요청하고, 거부하면 기기 설정 안내 예외', () async {
    messagingClient.currentPermission = PushPermissionStatus.notDetermined;
    expect(await service.updatePushEnabled(true), isTrue);
    expect(messagingClient.permissionRequestCount, 1);

    messagingClient.permissionAfterRequest = PushPermissionStatus.denied;
    expect(
      () => service.updatePushEnabled(true),
      throwsA(isA<PushPermissionDeniedException>()),
    );
  });

  test('토큰이 바뀌면 다시 등록한다', () async {
    await service.registerDeviceForSignedInMember();
    messagingClient.tokenRefreshController.add('refreshed-token');
    await Future<void>.delayed(Duration.zero);

    expect(pushTokenApi.registeredRequests.last.token, 'refreshed-token');
  });

  test('수신 동의를 끄면 서버에 false 를 저장하고, 권한이 없으면 켤 수 없다', () async {
    await service.registerDeviceForSignedInMember();
    expect(await service.updatePushEnabled(false), isFalse);
    expect(pushTokenApi.registeredRequests.last.isPushEnabled, isFalse);

    messagingClient.permissionAfterRequest = PushPermissionStatus.denied;
    expect(
      () => service.updatePushEnabled(true),
      throwsA(isA<PushSettingException>()),
    );
  });

  test('로그아웃하면 등록한 토큰을 서버에서 지우고 갱신 재등록을 멈춘다', () async {
    await service.registerDeviceForSignedInMember();
    await service.unregisterDevice();
    messagingClient.tokenRefreshController.add('after-logout-token');
    await Future<void>.delayed(Duration.zero);

    expect(pushTokenApi.deletedTokens, ['device-token']);
    expect(
      pushTokenApi.registeredRequests.map((request) => request.token),
      isNot(contains('after-logout-token')),
    );
  });

  test('알림 data 는 허용 목록 화면 경로로만 바뀐다', () {
    expect(
      toPushLinkLocation(PushLink.fromData({'linkTarget': 'DAILY_SET'})!),
      AppRoutes.dailySet,
    );
    expect(
      toPushLinkLocation(
        PushLink.fromData({
          'linkTarget': 'QUESTION_DETAIL',
          'questionUuid': 'q-1',
        })!,
      ),
      AppRoutes.questionDetail('q-1'),
    );
    // 문제 UUID 누락, 허용 목록 밖, 경로 문자열 직접 지정 > 이동 없음
    expect(PushLink.fromData({'linkTarget': 'QUESTION_DETAIL'}), isNull);
    expect(PushLink.fromData({'linkTarget': 'ADMIN'}), isNull);
    expect(PushLink.fromData({'linkTarget': '/settings'}), isNull);
  });
}
