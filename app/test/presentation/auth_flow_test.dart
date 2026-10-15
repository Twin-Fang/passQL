import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/member_suspension_signal.dart';
import 'package:passql_app/core/auth/session_expiry_signal.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/core/network/dio_client.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/sources/auth_api.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/session_reset.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';

import '../helpers/fakes/fake_member_api.dart';
import '../helpers/fakes/fake_push.dart';

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
  Future<LoginResult> login({
    required SocialProvider provider,
    required String idToken,
  }) async {
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

ProviderContainer _container(
  _FakeSocial social,
  _FakeAuthApi api,
  TokenStore store,
) {
  final container = ProviderContainer(
    overrides: [
      socialSignInProvider.overrideWithValue(social),
      authApiProvider.overrideWithValue(api),
      pushTokenApiProvider.overrideWithValue(FakePushTokenApi()),
      tokenStoreProvider.overrideWithValue(store),
    ],
  );
  addTearDown(container.dispose);
  return container;
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
      final container = _container(social, api, store);
      await container.read(authProvider.future);

      final ok = await container
          .read(authProvider.notifier)
          .signIn(SocialProvider.google);

      expect(ok, isTrue);
      expect(api.lastProvider, SocialProvider.google);
      expect(api.lastIdToken, 'firebase-id-token');
      expect(container.read(authProvider).value?.memberUuid, 'member-1');
      expect((await store.read())?.accessToken, 'access-1');
    });

    test('사용자가 소셜 로그인을 취소하면 서버를 호출하지 않고 로그인 상태도 바꾸지 않는다', () async {
      final api = _FakeAuthApi();
      final container = _container(_FakeSocial(token: null), api, store);
      await container.read(authProvider.future);

      final ok = await container
          .read(authProvider.notifier)
          .signIn(SocialProvider.apple);

      expect(ok, isFalse);
      expect(api.lastIdToken, isNull);
      expect(container.read(authProvider).value, isNull);
    });

    test('소셜 로그인 실패 문구는 그대로 전달한다', () async {
      final container = _container(
        _FakeSocial(error: const SocialSignInException('Google 로그인에 실패했어요.')),
        _FakeAuthApi(),
        store,
      );
      await container.read(authProvider.future);

      await expectLater(
        container.read(authProvider.notifier).signIn(SocialProvider.google),
        throwsA(
          isA<SocialSignInException>().having(
            (e) => e.message,
            'message',
            'Google 로그인에 실패했어요.',
          ),
        ),
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
      final container = _container(_FakeSocial(), api, store);
      await container.read(authProvider.future);

      await expectLater(
        container.read(authProvider.notifier).signIn(SocialProvider.google),
        throwsA(
          isA<SocialSignInException>().having(
            (e) => e.message,
            'message',
            '네트워크 연결을 확인해 주세요.',
          ),
        ),
      );
      expect(await store.read(), isNull);
    });
  });

  group('로그아웃', () {
    Future<ProviderContainer> signedIn(
      _FakeSocial social,
      _FakeAuthApi api,
    ) async {
      final container = _container(social, api, store);
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).signIn(SocialProvider.google);
      return container;
    }

    test('서버에 refresh 토큰을 폐기하고, 저장된 세션과 소셜 로그인 상태를 모두 지운다', () async {
      final social = _FakeSocial();
      final api = _FakeAuthApi();
      final container = await signedIn(social, api);

      await container.read(authProvider.notifier).signOut();

      expect(api.loggedOut, ['refresh-1']);
      expect(social.signOuts, 1);
      expect(await store.read(), isNull);
      expect(container.read(authProvider).value, isNull);
    });

    test('네트워크 계층의 세션 만료 신호를 받으면 로그아웃 상태가 된다', () async {
      final container = await signedIn(_FakeSocial(), _FakeAuthApi());

      container.read(sessionExpirySignalProvider).announceExpired();
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider).value, isNull);
    });

    test('이용 제한 신호를 받으면 안내 문구를 남기고 세션·소셜 로그인을 지운 뒤 로그아웃한다 (#484)', () async {
      final social = _FakeSocial();
      final container = await signedIn(social, _FakeAuthApi());

      container
          .read(memberSuspensionSignalProvider)
          .announceSuspended('이용이 제한된 계정이에요.');
      await Future<void>.delayed(Duration.zero);

      expect(container.read(authProvider).value, isNull);
      expect(container.read(loginNoticeProvider), '이용이 제한된 계정이에요.');
      expect(await store.read(), isNull);
      expect(social.signOuts, 1);
    });

    test('다시 시작해도 로그아웃 상태가 유지된다 (저장소에서 세션을 읽지 못한다)', () async {
      final container = await signedIn(_FakeSocial(), _FakeAuthApi());
      await container.read(authProvider.notifier).signOut();

      final restarted = _container(_FakeSocial(), _FakeAuthApi(), TokenStore());
      expect(await restarted.read(authProvider.future), isNull);
    });
  });

  group('회원 탈퇴', () {
    Future<ProviderContainer> signedIn(
      _FakeSocial social,
      FakeMemberApi member,
    ) async {
      final container = ProviderContainer(
        overrides: [
          socialSignInProvider.overrideWithValue(social),
          authApiProvider.overrideWithValue(_FakeAuthApi()),
          pushTokenApiProvider.overrideWithValue(FakePushTokenApi()),
          memberApiProvider.overrideWithValue(member),
          tokenStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      await container.read(authProvider.future);
      await container.read(authProvider.notifier).signIn(SocialProvider.google);
      return container;
    }

    test('서버가 계정을 지우면 기기 세션과 소셜 로그인 상태를 모두 지운다', () async {
      final social = _FakeSocial();
      final member = FakeMemberApi();
      final container = await signedIn(social, member);

      await container.read(authProvider.notifier).withdraw();

      expect(member.withdrawCalls, 1);
      expect(social.signOuts, 1);
      expect(await store.read(), isNull);
      expect(container.read(authProvider).value, isNull);
    });

    test('Apple 재인증을 취소하면 서버에 탈퇴를 요청하지 않고 계정을 그대로 둔다', () async {
      final social = _FakeSocial()..revokeGranted = false;
      final member = FakeMemberApi();
      final container = await signedIn(social, member);

      await container.read(authProvider.notifier).withdraw();

      expect(social.revokes, 1);
      expect(member.withdrawCalls, 0);
      expect(container.read(authProvider).value, isNotNull);
    });

    test('탈퇴 전에 소셜 접근 권한을 먼저 회수한다', () async {
      final social = _FakeSocial();
      final container = await signedIn(social, FakeMemberApi());

      await container.read(authProvider.notifier).withdraw();

      expect(social.revokes, 1);
    });

    test(
      '서버 요청이 실패하면 세션을 그대로 두고 사유를 알린다 (지워지지 않은 계정을 로그아웃만 시키지 않는다)',
      () async {
        final member = FakeMemberApi(
          withdrawError: DioException(
            requestOptions: RequestOptions(path: '/members/me'),
            type: DioExceptionType.connectionError,
          ),
        );
        final container = await signedIn(_FakeSocial(), member);

        await expectLater(
          container.read(authProvider.notifier).withdraw(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('네트워크'),
            ),
          ),
        );
        expect((await store.read())?.memberUuid, 'member-1');
        expect(container.read(authProvider).value, isNotNull);
      },
    );
  });

  group('계정 전환 시 캐시 초기화', () {
    test('회원별 데이터(홈, 통계, 설정, 순위 등)를 모두 다음 조회 때 다시 불러온다', () async {
      var loads = <String, int>{};
      int bump(String k) => loads[k] = (loads[k] ?? 0) + 1;
      final container = ProviderContainer(
        overrides: [
          homeDataProvider.overrideWith((ref) async {
            bump('home');
            return const HomeData();
          }),
          statsDataProvider.overrideWith((ref) async {
            bump('stats');
            return const StatsData();
          }),
          dailySetTodayProvider.overrideWith((ref) async {
            bump('daily');
            throw StateError('x');
          }),
        ],
      );
      addTearDown(container.dispose);
      await container.read(homeDataProvider.future);
      await container.read(statsDataProvider.future);

      resetUserScopedProviders(container.invalidate);
      await container.read(homeDataProvider.future);
      await container.read(statsDataProvider.future);

      expect(loads['home'], 2);
      expect(loads['stats'], 2);
    });
  });
}
