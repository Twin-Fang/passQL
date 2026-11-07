import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../storage/storage_keys.dart';
import 'auth_session.dart';

/// 인증 세션을 보안 저장소(Keychain/Keystore)에 보관한다.
///
/// 토큰은 SharedPreferences 같은 평문 저장소에 두면 안 되므로 secure storage 만 쓴다.
/// 요청마다 읽히므로 메모리에 캐시해 매 요청 디스크 접근을 피한다.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  // iOS 쓰기: 재시동 뒤 첫 잠금 해제 이후 읽기 허용 (잠긴 화면에서 푸시로 깨어난 백그라운드 실행도 읽음)
  static const IOSOptions _writeIosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );
  // iOS 삭제: 접근 등급 조건 없이 (예전 기본 등급 unlocked 로 저장된 값까지 지움)
  static const IOSOptions _anyAccessibilityIosOptions = IOSOptions(
    accessibility: null,
  );

  // Android 복호화 키 소실 표식 (기기 이전·백업 복원 > 저장분을 다시 읽을 수 없음)
  static const List<String> _unrecoverableAndroidErrorMarkers = [
    'BadPaddingException',
    'AEADBadTagException',
    'IllegalBlockSizeException',
    'InvalidKeyException',
    'UnrecoverableKeyException',
    'KeyPermanentlyInvalidatedException',
  ];

  // 세션 키 5개 (삭제 대상)
  static const List<String> _sessionKeys = [
    StorageKeys.sessionAccessToken,
    StorageKeys.sessionRefreshToken,
    StorageKeys.sessionMemberUuid,
    StorageKeys.sessionNickname,
    StorageKeys.sessionAuthProvider,
  ];

  AuthSession? _cache;
  bool _isLoaded = false;

  /// 저장된 세션 조회. 없거나 읽기 실패면 null (일시 오류는 캐시하지 않아 다음 호출에서 다시 읽음)
  Future<AuthSession?> read() async {
    if (_isLoaded) return _cache;

    String? access, refresh, uuid, nickname, authProvider;
    try {
      // 키 5개 동시 읽기 (시작 시 세션 복원 대기 단축)
      final storedValues = await Future.wait([
        _storage.read(key: StorageKeys.sessionAccessToken),
        _storage.read(key: StorageKeys.sessionRefreshToken),
        _storage.read(key: StorageKeys.sessionMemberUuid),
        _storage.read(key: StorageKeys.sessionNickname),
        _storage.read(key: StorageKeys.sessionAuthProvider),
      ]);
      [access, refresh, uuid, nickname, authProvider] = storedValues;
    } catch (error) {
      // 이번 실행은 로그인 안 된 것으로 (앱이 켜지지 않는 것보다 로그인 화면이 나음)
      // 복호화 키 소실만 저장분 삭제, 그 외(기기 잠김 등 일시 오류)는 보존 > 다음 읽기에서 다시 시도
      if (!_isUnrecoverableReadError(error)) return null;
      try {
        await _storage.deleteAll(iOptions: _anyAccessibilityIosOptions);
      } catch (_) {}
      _cache = null;
      _isLoaded = true;
      return null;
    }

    // 일부만 남은 깨진 상태는 로그인 안 된 것으로 취급한다.
    if (access == null || refresh == null || uuid == null) {
      _cache = null;
    } else {
      _cache = AuthSession(
        accessToken: access,
        refreshToken: refresh,
        memberUuid: uuid,
        nickname: nickname ?? '',
        authProvider: SocialProvider.fromServerValue(authProvider),
      );
    }
    _isLoaded = true;
    return _cache;
  }

  /// 로그인 직후 전체 세션 저장.
  Future<void> save(AuthSession session) async {
    await _storage.write(
      key: StorageKeys.sessionAccessToken,
      value: session.accessToken,
      iOptions: _writeIosOptions,
    );
    await _storage.write(
      key: StorageKeys.sessionRefreshToken,
      value: session.refreshToken,
      iOptions: _writeIosOptions,
    );
    await _storage.write(
      key: StorageKeys.sessionMemberUuid,
      value: session.memberUuid,
      iOptions: _writeIosOptions,
    );
    await _storage.write(
      key: StorageKeys.sessionNickname,
      value: session.nickname,
      iOptions: _writeIosOptions,
    );
    final authProviderValue = session.authProvider?.serverValue;
    if (authProviderValue == null) {
      // 제공자 없는 세션은 이전 계정 값이 남지 않게 삭제
      await _storage.delete(
        key: StorageKeys.sessionAuthProvider,
        iOptions: _anyAccessibilityIosOptions,
      );
    } else {
      await _storage.write(
        key: StorageKeys.sessionAuthProvider,
        value: authProviderValue,
        iOptions: _writeIosOptions,
      );
    }
    _cache = session;
    _isLoaded = true;
  }

  /// 재발급 결과 반영. 세션이 없으면 아무것도 하지 않는다.
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final current = await read();
    if (current == null) return;
    await save(
      current.withTokens(accessToken: accessToken, refreshToken: refreshToken),
    );
  }

  /// 닉네임이 바뀌었을 때 저장된 세션에 반영한다. 세션이 없으면 아무것도 하지 않는다.
  Future<void> updateNickname(String nickname) async {
    final current = await read();
    if (current == null) return;
    await save(current.withNickname(nickname));
  }

  /// 로그아웃 또는 세션 만료 시 전체 삭제.
  Future<void> clear() async {
    for (final key in _sessionKeys) {
      await _storage.delete(key: key, iOptions: _anyAccessibilityIosOptions);
    }
    _cache = null;
    _isLoaded = true;
  }

  /// 다시 읽어도 소용없는 오류인가: Android 복호화 키 소실만 (iOS 키체인 오류는 잠김 등 일시 오류)
  static bool _isUnrecoverableReadError(Object error) {
    if (error is! PlatformException) return false;
    final errorText = '${error.message} ${error.details}';
    return _unrecoverableAndroidErrorMarkers.any(errorText.contains);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
