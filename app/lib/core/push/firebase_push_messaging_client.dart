import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_link.dart';
import 'push_messaging_client.dart';

/// Firebase Cloud Messaging 으로 동작하는 [PushMessagingClient] 구현
class FirebasePushMessagingClient extends PushMessagingClient {
  const FirebasePushMessagingClient(this._messaging);

  final FirebaseMessaging _messaging;

  // iOS APNs 토큰 대기 (FCM 토큰은 APNs 토큰 이후 발급): 최대 3회, 1초 간격
  static const int _apnsTokenWaitAttemptCount = 3;
  static const Duration _apnsTokenWaitInterval = Duration(seconds: 1);

  @override
  String get platformName => Platform.isIOS ? 'IOS' : 'ANDROID';

  @override
  Future<PushPermissionStatus> readPermissionStatus() async =>
      _toPermissionStatus(
        (await _messaging.getNotificationSettings()).authorizationStatus,
      );

  @override
  Future<PushPermissionStatus> requestPermission() async => _toPermissionStatus(
    (await _messaging.requestPermission()).authorizationStatus,
  );

  @override
  Future<String?> fetchToken() async {
    try {
      if (Platform.isIOS && !await _hasApnsToken()) return null;
      return await _messaging.getToken();
    } catch (error) {
      // 시뮬레이터·APNs 미설정(aps-environment 없음)은 정상 상황이라 수집하지 않음
      debugPrint('[push] token unavailable : $error');
      return null;
    }
  }

  @override
  Stream<String> get tokenRefreshes => _messaging.onTokenRefresh;

  @override
  Stream<ReceivedPushMessage> get foregroundMessages =>
      FirebaseMessaging.onMessage.map(
        (message) => ReceivedPushMessage(
          title: message.notification?.title,
          body: message.notification?.body,
          link: PushLink.fromData(message.data),
        ),
      );

  @override
  Stream<PushLink> get openedLinks => FirebaseMessaging.onMessageOpenedApp
      .map((message) => PushLink.fromData(message.data))
      .where((link) => link != null)
      .cast<PushLink>();

  @override
  Future<PushLink?> takeInitialLink() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : PushLink.fromData(message.data);
  }

  Future<bool> _hasApnsToken() async {
    for (var attempt = 0; attempt < _apnsTokenWaitAttemptCount; attempt++) {
      if (await _messaging.getAPNSToken() != null) return true;
      await Future<void>.delayed(_apnsTokenWaitInterval);
    }
    return false;
  }

  static PushPermissionStatus _toPermissionStatus(AuthorizationStatus status) =>
      switch (status) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => PushPermissionStatus.granted,
        AuthorizationStatus.denied ||
        AuthorizationStatus.deniedPermanently => PushPermissionStatus.denied,
        AuthorizationStatus.notDetermined => PushPermissionStatus.notDetermined,
      };
}

/// 푸시 수신 준비 (Firebase.initializeApp 뒤 1회)
/// iOS 포그라운드 시스템 배너 끔(앱 내 토스트로 대신) > 전역 클라이언트 교체
Future<void> startFirebasePushMessaging() async {
  final messaging = FirebaseMessaging.instance;
  await messaging.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: true,
    sound: false,
  );
  PushMessagingClient.current = FirebasePushMessagingClient(messaging);
}
