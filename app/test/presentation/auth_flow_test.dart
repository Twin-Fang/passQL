import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/core/network/dio_client.dart';
import 'package:passql_app/core/network/api_providers.dart';
import 'package:passql_app/data/sources/auth_api.dart';
import 'package:passql_app/data/sources/member_api.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/session_reset.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';

/// 소셜 로그인 결과를 정해 둘 수 있는 가짜 구현.
class _FakeSocial implements SocialSignIn {
  _FakeSocial({this.token = 'firebase-id-token', this.error});

  String? token; // null 이면 사용자가 취소한 것
  SocialSignInException? error;
  final requested = <SocialProvider>[];
  int signOuts = 0;

  @override
  Future<String?> fetchIdToken(SocialProvider provider) async {
    requested.add(provider);
    if (error != null) throw error!;
    return token;
  }

  bool revokeGranted = true;
  int revokes = 0;

  @override
  Future<bool> revokeAccessForWithdrawal() async {
    revokes++;
    return revokeGranted;
  }

  @override
  Future<void> signOut() async => signOuts++;
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi({this.loginError}) : super(Dio());

  DioException? loginError;
  String? lastIdToken;
  SocialProvider? lastProvider;
  final loggedOut = <String>[];

  @override
  Future<LoginResult> login({required SocialProvider provider, required String idToken}) async {
    lastProvider = provider;
    lastIdToken = idToken;
    if (loginError != null) throw loginError!;
    return const LoginResult(
      session: AuthSession(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        memberUuid: 'member-1',
        nickname: '새회원',
      ),
      isNewMember: true,
    );
  }

  @override
  Future<void> logout(String refreshToken) async => loggedOut.add(refreshToken);
}

ProviderContainer _container(_FakeSocial social, _FakeAuthApi api, TokenStore store) {
  final c = ProviderContainer(
    overrides: [
      socialSignInProvider.overrideWithValue(social),
      authApiProvider.overrideWithValue(api),
      tokenStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

class _FakeMemberApi implements MemberApiClient {
  _FakeMemberApi({this.error});
  DioException? error;
  int withdrawCalls = 0;

  @override
  Future<void> withdraw() async {
    withdrawCalls++;
    if (error != null) throw error!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late TokenStore store;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    store = TokenStore();
  });

  group('로그인', () {
    test('소셜 토큰으로 서버에 로그인하고 세션을 안전하게 저장한다', () async {
      final social = _FakeSocial();
      final api = _FakeAuthApi();
      final c = _container(social, api, store);
      await c.read(authProvider.future);

      final ok = await c.read(authProvider.notifier).signIn(SocialProvider.google);

      expect(ok, isTrue);
      expect(api.lastProvider, SocialProvider.google);
      expect(api.lastIdToken, 'firebase-id-token');
      expect(c.read(authProvider).value?.memberUuid, 'member-1');
      expect((await store.read())?.accessToken, 'access-1');
    });

    test('사용자가 소셜 로그인을 취소하면 서버를 호출하지 않고 로그인 상태도 바꾸지 않는다', () async {
      final api = _FakeAuthApi();
      final c = _container(_FakeSocial(token: null), api, store);
      await c.read(authProvider.future);

      final ok = await c.read(authProvider.notifier).signIn(SocialProvider.apple);

      expect(ok, isFalse);
      expect(api.lastIdToken, isNull);
      expect(c.read(authProvider).value, isNull);
    });

    test('소셜 로그인 실패 문구는 그대로 전달한다', () async {
      final c = _container(
        _FakeSocial(error: const SocialSignInException('Google 로그인에 실패했어요.')),
        _FakeAuthApi(),
        store,
      );
      await c.read(authProvider.future);

      await expectLater(
        c.read(authProvider.notifier).signIn(SocialProvider.google),
        throwsA(isA<SocialSignInException>().having((e) => e.message, 'message', 'Google 로그인에 실패했어요.')),
      );
      expect(await store.read(), isNull);
    });

    test('서버 로그인이 네트워크로 실패하면 사용자용 문구를 던지고 세션을 남기지 않는다', () async {
      final api = _FakeAuthApi(
        loginError: DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          type: DioExceptionType.connectionError,
        ),
      );
      final c = _container(_FakeSocial(), api, store);
      await c.read(authProvider.future);

      await expectLater(
        c.read(authProvider.notifier).signIn(SocialProvider.google),
        throwsA(isA<SocialSignInException>().having((e) => e.message, 'message', '네트워크 연결을 확인해 주세요.')),
      );
      expect(await store.read(), isNull);
    });
  });

  group('로그아웃', () {
    Future<ProviderContainer> signedIn(_FakeSocial social, _FakeAuthApi api) async {
      final c = _container(social, api, store);
      await c.read(authProvider.future);
      await c.read(authProvider.notifier).signIn(SocialProvider.google);
      return c;
    }

    test('서버에 refresh 토큰을 폐기하고, 저장된 세션과 소셜 로그인 상태를 모두 지운다', () async {
      final social = _FakeSocial();
      final api = _FakeAuthApi();
      final c = await signedIn(social, api);

      await c.read(authProvider.notifier).signOut();

      expect(api.loggedOut, ['refresh-1']);
      expect(social.signOuts, 1);
      expect(await store.read(), isNull);
      expect(c.read(authProvider).value, isNull);
    });

    test('다시 시작해도 로그아웃 상태가 유지된다 (저장소에서 세션을 읽지 못한다)', () async {
      final c = await signedIn(_FakeSocial(), _FakeAuthApi());
      await c.read(authProvider.notifier).signOut();

      final restarted = _container(_FakeSocial(), _FakeAuthApi(), TokenStore());
      expect(await restarted.read(authProvider.future), isNull);
    });
  });

  group('회원 탈퇴', () {
    Future<ProviderContainer> signedIn(_FakeSocial social, _FakeMemberApi member) async {
      final c = ProviderContainer(
        overrides: [
          socialSignInProvider.overrideWithValue(social),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
          memberApiProvider.overrideWithValue(member),
          tokenStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(c.dispose);
      await c.read(authProvider.future);
      await c.read(authProvider.notifier).signIn(SocialProvider.google);
      return c;
    }

    test('서버가 계정을 지우면 기기 세션과 소셜 로그인 상태를 모두 지운다', () async {
      final social = _FakeSocial();
      final member = _FakeMemberApi();
      final c = await signedIn(social, member);

      await c.read(authProvider.notifier).withdraw();

      expect(member.withdrawCalls, 1);
      expect(social.signOuts, 1);
      expect(await store.read(), isNull);
      expect(c.read(authProvider).value, isNull);
    });

    test('Apple 재인증을 취소하면 서버에 탈퇴를 요청하지 않고 계정을 그대로 둔다', () async {
      final social = _FakeSocial()..revokeGranted = false;
      final member = _FakeMemberApi();
      final c = await signedIn(social, member);

      await c.read(authProvider.notifier).withdraw();

      expect(social.revokes, 1);
      expect(member.withdrawCalls, 0);
      expect(c.read(authProvider).value, isNotNull);
    });

    test('탈퇴 전에 소셜 접근 권한을 먼저 회수한다', () async {
      final social = _FakeSocial();
      final c = await signedIn(social, _FakeMemberApi());

      await c.read(authProvider.notifier).withdraw();

      expect(social.revokes, 1);
    });

    test('서버 요청이 실패하면 세션을 그대로 두고 사유를 알린다 (지워지지 않은 계정을 로그아웃만 시키지 않는다)', () async {
      final member = _FakeMemberApi(
        error: DioException(
          requestOptions: RequestOptions(path: '/members/me'),
          type: DioExceptionType.connectionError,
        ),
      );
      final c = await signedIn(_FakeSocial(), member);

      await expectLater(
        c.read(authProvider.notifier).withdraw(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('네트워크'))),
      );
      expect((await store.read())?.memberUuid, 'member-1');
      expect(c.read(authProvider).value, isNotNull);
    });
  });

  group('계정 전환 시 캐시 초기화', () {
    test('회원별 데이터(홈, 통계, 설정, 순위 등)를 모두 다음 조회 때 다시 불러온다', () async {
      var loads = <String, int>{};
      int bump(String k) => loads[k] = (loads[k] ?? 0) + 1;
      final c = ProviderContainer(
        overrides: [
          homeDataProvider.overrideWith((ref) async { bump('home'); return const HomeData(); }),
          statsDataProvider.overrideWith((ref) async { bump('stats'); return const StatsData(); }),
          dailySetTodayProvider.overrideWith((ref) async { bump('daily'); throw StateError('x'); }),
        ],
      );
      addTearDown(c.dispose);
      await c.read(homeDataProvider.future);
      await c.read(statsDataProvider.future);

      resetUserScopedProviders(c.invalidate);
      await c.read(homeDataProvider.future);
      await c.read(statsDataProvider.future);

      expect(loads['home'], 2);
      expect(loads['stats'], 2);
    });
  });
}
