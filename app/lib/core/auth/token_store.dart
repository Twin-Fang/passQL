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

  AuthSession? _cache;
  bool _isLoaded = false;

  /// 저장된 세션 조회. 없으면 null.
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
    } catch (_) {
      // 기기 이전이나 백업 복원으로 암호화 키가 사라지면 읽기가 예외를 던진다.
      // 앱이 켜지지 않는 것보다 로그인 화면으로 가는 것이 낫다. 읽을 수 없는 저장분은 지운다.
      try {
        await _storage.deleteAll();
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
    );
    await _storage.write(
      key: StorageKeys.sessionRefreshToken,
      value: session.refreshToken,
    );
    await _storage.write(
      key: StorageKeys.sessionMemberUuid,
      value: session.memberUuid,
    );
    await _storage.write(
      key: StorageKeys.sessionNickname,
      value: session.nickname,
    );
    // 제공자 없는 세션은 이전 계정 값이 남지 않게 삭제
    await _storage.write(
      key: StorageKeys.sessionAuthProvider,
      value: session.authProvider?.serverValue,
    );
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
    await _storage.delete(key: StorageKeys.sessionAccessToken);
    await _storage.delete(key: StorageKeys.sessionRefreshToken);
    await _storage.delete(key: StorageKeys.sessionMemberUuid);
    await _storage.delete(key: StorageKeys.sessionNickname);
    await _storage.delete(key: StorageKeys.sessionAuthProvider);
    _cache = null;
    _isLoaded = true;
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
