import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/install_guard.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _session = AuthSession(
  accessToken: 'a',
  refreshToken: 'r',
  memberUuid: 'm-1',
  nickname: '닉',
);

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('재설치처럼 키체인에 토큰이 남아 있는데 설치 표식이 없으면 이전 로그인을 지운다', () async {
    final store = TokenStore();
    await store.save(_session); // 앱을 지워도 남은 키체인 값

    await resetSecureStorageOnFreshInstall(store);

    expect(await TokenStore().read(), isNull);
  });

  test('설치 표식이 이미 있으면(평소 실행) 로그인을 건드리지 않는다', () async {
    SharedPreferences.setMockInitialValues({'install_initialized': true});
    final store = TokenStore();
    await store.save(_session);

    await resetSecureStorageOnFreshInstall(store);

    expect((await TokenStore().read())?.memberUuid, 'm-1');
  });

  test('첫 실행 처리 뒤에는 표식이 남아 다음 실행에서 로그인을 지우지 않는다', () async {
    await resetSecureStorageOnFreshInstall(TokenStore());
    final store = TokenStore();
    await store.save(_session);

    await resetSecureStorageOnFreshInstall(store); // 두 번째 실행

    expect((await TokenStore().read())?.memberUuid, 'm-1');
  });
}
