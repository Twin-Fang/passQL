import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/app_exception.dart';
import '../../core/push/push_link.dart';
import '../../core/push/push_messaging_client.dart';
import '../models/member/push_token_models.dart';
import '../sources/api_providers.dart';
import '../sources/push_token_api.dart';

/// 알림 수신 동의를 바꿀 수 없는 이유 (화면에 [message] 그대로 표시)
class PushSettingException implements Exception {
  const PushSettingException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 이미 거부돼 앱에서 다시 물을 수 없는 알림 권한 (기기 설정으로 안내해야 함)
class PushPermissionDeniedException extends PushSettingException {
  const PushPermissionDeniedException()
    : super('기기 설정에서 passQL 알림을 허용해 주세요');
}

/// 푸시 공통 지점: 권한 확인(요청은 사용자가 고른 뒤에만), 토큰 서버 등록·갱신 재등록, 수신 동의 변경, 로그아웃 삭제, 수신·탭 스트림
/// SDK 는 [PushMessagingClient] 로만 다룸 (테스트는 가짜 클라이언트)
class PushNotificationService {
  PushNotificationService({
    required PushMessagingClient messagingClient,
    required PushTokenApiClient pushTokenApi,
  }) : _messagingClient = messagingClient,
       _pushTokenApi = pushTokenApi;

  final PushMessagingClient _messagingClient;
  final PushTokenApiClient _pushTokenApi;

  // 서버에 등록한 이 기기 토큰 (로그아웃 삭제·수신 동의 변경에 사용)
  String? _registeredToken;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Stream<ReceivedPushMessage> get foregroundMessages =>
      _messagingClient.foregroundMessages;

  Stream<PushLink> get openedLinks => _messagingClient.openedLinks;

  Future<PushLink?> takeInitialLink() => _messagingClient.takeInitialLink();

  /// 묻지 않고 현재 알림 권한만 읽음
  Future<PushPermissionStatus> readPermissionStatus() =>
      _messagingClient.readPermissionStatus();

  /// 기기 설정 앱의 알림 화면 열기 (열 수 없는 플랫폼 > false)
  Future<bool> openDeviceNotificationSettings() =>
      _messagingClient.openDeviceNotificationSettings();

  /// 로그인 회원 기기 등록: 권한 읽기(시스템 창은 띄우지 않음) > 토큰 > 서버 등록 > 토큰 갱신 구독
  /// 결과: 이 기기 수신 동의 (권한 없음·토큰 없음·서버 실패 > null)
  Future<bool?> registerDeviceForSignedInMember() async {
    final permissionStatus = await _messagingClient.readPermissionStatus();
    if (permissionStatus != PushPermissionStatus.granted) return null;
    final token = await _messagingClient.fetchToken();
    if (token == null) return null;
    _listenTokenRefreshes();
    try {
      return (await _registerToken(token)).isPushEnabled;
    } on DioException {
      // 다음 실행·토큰 갱신 때 다시 등록
      return null;
    }
  }

  /// 켜기·끄기: 켤 때 권한 요청(사용자가 안내 시트·토글로 고른 뒤에만 호출) > 토큰 > 서버 저장 > 저장된 값
  /// 실패: [PushPermissionDeniedException] (권한 거부) / [PushSettingException] (토큰 없음) / [AppException] (서버)
  Future<bool> updatePushEnabled(bool isEnabled) async {
    if (isEnabled &&
        await _messagingClient.requestPermission() !=
            PushPermissionStatus.granted) {
      throw const PushPermissionDeniedException();
    }
    final token = _registeredToken ?? await _messagingClient.fetchToken();
    if (token == null) {
      throw const PushSettingException('이 기기에서는 알림을 받을 수 없어요');
    }
    _listenTokenRefreshes();
    try {
      return (await _registerToken(
        token,
        isPushEnabled: isEnabled,
      )).isPushEnabled;
    } on DioException catch (exception) {
      throw exception.asAppException;
    }
  }

  /// 로그아웃 직전 서버 토큰 삭제 (실패해도 로그아웃은 진행) > 갱신 구독 해제
  Future<void> unregisterDevice() async {
    final token = _registeredToken;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _registeredToken = null;
    if (token == null) return;
    try {
      await _pushTokenApi.deletePushToken(token);
    } on DioException {
      // 다음 로그인 회원이 같은 토큰을 등록하면 서버가 소유자를 옮김
    }
  }

  Future<PushTokenResponse> _registerToken(
    String token, {
    bool? isPushEnabled,
  }) async {
    final response = await _pushTokenApi.registerPushToken(
      PushTokenRegisterRequest(
        token: token,
        platform: _messagingClient.platformName,
        isPushEnabled: isPushEnabled,
      ),
    );
    _registeredToken = token;
    return response;
  }

  /// 토큰이 바뀌면 서버 재등록 (수신 동의는 서버 값 유지)
  void _listenTokenRefreshes() {
    _tokenRefreshSubscription ??= _messagingClient.tokenRefreshes.listen((
      token,
    ) async {
      try {
        await _registerToken(token);
      } on DioException {
        // 다음 실행 때 다시 등록
      }
    });
  }
}

/// 앱 전역 푸시 서비스 (테스트는 messagingClient·API 를 가짜로 override)
final pushNotificationServiceProvider = Provider<PushNotificationService>(
  (ref) => PushNotificationService(
    messagingClient: PushMessagingClient.current,
    pushTokenApi: ref.watch(pushTokenApiProvider),
  ),
);
