import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

/// 인증 세션을 보안 저장소(Keychain/Keystore)에 보관한다.
///
/// 토큰은 SharedPreferences 같은 평문 저장소에 두면 안 되므로 secure storage 만 쓴다.
/// 요청마다 읽히므로 메모리에 캐시해 매 요청 디스크 접근을 피한다.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const _kAccess = 'auth_access_token';
  static const _kRefresh = 'auth_refresh_token';
  static const _kMemberUuid = 'auth_member_uuid';
  static const _kNickname = 'auth_nickname';

  final FlutterSecureStorage _storage;

  AuthSession? _cache;
  bool _loaded = false;

  /// 저장된 세션 조회. 없으면 null.
  Future<AuthSession?> read() async {
    if (_loaded) return _cache;

    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    final uuid = await _storage.read(key: _kMemberUuid);
    final nickname = await _storage.read(key: _kNickname);

    // 일부만 남은 깨진 상태는 로그인 안 된 것으로 취급한다.
    if (access == null || refresh == null || uuid == null) {
      _cache = null;
    } else {
      _cache = AuthSession(
        accessToken: access,
        refreshToken: refresh,
        memberUuid: uuid,
        nickname: nickname ?? '',
      );
    }
    _loaded = true;
    return _cache;
  }

  /// 로그인 직후 전체 세션 저장.
  Future<void> save(AuthSession session) async {
    await _storage.write(key: _kAccess, value: session.accessToken);
    await _storage.write(key: _kRefresh, value: session.refreshToken);
    await _storage.write(key: _kMemberUuid, value: session.memberUuid);
    await _storage.write(key: _kNickname, value: session.nickname);
    _cache = session;
    _loaded = true;
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

  /// 로그아웃 또는 세션 만료 시 전체 삭제.
  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kMemberUuid);
    await _storage.delete(key: _kNickname);
    _cache = null;
    _loaded = true;
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
