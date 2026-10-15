import 'dart:async';

import 'package:dio/dio.dart';
import 'package:passql_app/core/push/push_link.dart';
import 'package:passql_app/core/push/push_messaging_client.dart';
import 'package:passql_app/data/models/member/push_token_models.dart';
import 'package:passql_app/data/sources/push_token_api.dart';

/// 권한·토큰을 정해 둘 수 있는 푸시 SDK. 권한 요청 횟수를 남긴다
class FakePushMessagingClient extends PushMessagingClient {
  FakePushMessagingClient({
    this.permissionAfterRequest = PushPermissionStatus.granted,
    this.currentPermission = PushPermissionStatus.notDetermined,
    this.token = 'device-token',
  });

  PushPermissionStatus permissionAfterRequest;
  PushPermissionStatus currentPermission;
  String? token;
  int permissionRequestCount = 0;
  final tokenRefreshController = StreamController<String>.broadcast();

  @override
  String get platformName => 'IOS';

  @override
  Future<PushPermissionStatus> readPermissionStatus() async =>
      currentPermission;

  @override
  Future<PushPermissionStatus> requestPermission() async {
    permissionRequestCount++;
    currentPermission = permissionAfterRequest;
    return currentPermission;
  }

  @override
  Future<String?> fetchToken() async => token;

  @override
  Stream<String> get tokenRefreshes => tokenRefreshController.stream;

  @override
  Stream<ReceivedPushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushLink> get openedLinks => const Stream.empty();

  @override
  Future<PushLink?> takeInitialLink() async => null;
}

/// 서버 대신 등록·삭제 요청을 남기는 토큰 API (수신 동의는 마지막 요청값, 생략 시 유지)
class FakePushTokenApi implements PushTokenApiClient {
  final registeredRequests = <PushTokenRegisterRequest>[];
  final deletedTokens = <String>[];
  bool serverPushEnabled = true;
  DioException? registerError;

  @override
  Future<PushTokenResponse> registerPushToken(
    PushTokenRegisterRequest body,
  ) async {
    if (registerError != null) throw registerError!;
    registeredRequests.add(body);
    serverPushEnabled = body.isPushEnabled ?? serverPushEnabled;
    return PushTokenResponse(isPushEnabled: serverPushEnabled);
  }

  @override
  Future<void> deletePushToken(String token) async => deletedTokens.add(token);
}
