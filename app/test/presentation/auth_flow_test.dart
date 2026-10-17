import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/firebase_social_sign_in.dart';
import 'package:passql_app/core/auth/member_suspension_signal.dart';
import 'package:passql_app/core/auth/session_expiry_signal.dart';
import 'package:passql_app/core/auth/social_credential.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/sources/auth_api.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';

import '../helpers/fakes/fake_member_api.dart';
import '../helpers/fakes/fake_push.dart';

/// 소셜 로그인 결과를 정해 둘 수 있는 가짜 구현.
class _FakeSocial implements SocialSignIn {
  _FakeSocial({
    this.token = 'firebase-id-token',
    this.error,
    this.codeCredential,
  });

  String? token; // null 이면 사용자가 취소한 것
  SocialSignInException? error;
  // 있으면 토큰 대신 인가 코드 재료 반환 (GitHub)
  SocialAuthorizationCodeCredential? codeCredential;
  final requested = <SocialProvider>[];
  int signOuts = 0;

  @override
  Future<SocialCredential?> fetchCredential(SocialProvider provider) async {
    requested.add(provider);
    if (error != null) throw error!;
    if (codeCredential != null) return codeCredential;
    final currentToken = token;
    if (currentToken == null) return null;
    return SocialTokenCredential(provider: provider, token: currentToken);
  }

  bool revokeGranted = true;
  int revokes = 0;
  // 탈퇴 회수·연결 해제 요청 제공자 기록 (순서대로)
  final revokedProviders = <SocialProvider?>[];
  final revokedProviderUserIds = <String?>[];
  final disconnectedProviders = <SocialProvider?>[];
  // 있으면 탈퇴 확인에서 던짐 (재인증 계정 불일치 등)
  SocialSignInException? revokeError;

  @override
  Future<bool> revokeAccessForWithdrawal(
    SocialProvider? provider, {
    String? providerUserId,
  }) async {
    revokes++;
    revokedProviders.add(provider);
    revokedProviderUserIds.add(providerUserId);
    if (revokeError != null) throw revokeError!;
    return revokeGranted;
  }

  @override
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider) async =>
      disconnectedProviders.add(provider);

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

  // 인가 코드 로그인 요청 기록 (provider, code, redirectUri, state, codeVerifier)
  final authorizationCodeLogins = <List<String>>[];

  @override
  Future<LoginResult> loginWithAuthorizationCode({
    required SocialProvider provider,
    required String code,
    required String redirectUri,
    required String state,
    required String codeVerifier,
  }) async {
    authorizationCodeLogins.add([
      provider.serverValue,
      code,
      redirectUri,
      state,
      codeVerifier,
    ]);
    if (loginError != null) throw loginError!;
    return const LoginResult(
      session: AuthSession(
        accessToken: 'access-code',
        refreshToken: 'refresh-code',
        memberUuid: 'member-github',
        nickname: '깃허브회원',
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

    test('카카오 액세스 토큰은 토큰 로그인(/auth/login)으로 보낸다', () async {
      final api = _FakeAuthApi();
      final container = _container(
        _FakeSocial(token: 'kakao-access-token'),
        api,
        store,
      );
      await container.read(authProvider.future);

      await container.read(authProvider.notifier).signIn(SocialProvider.kakao);

      expect(api.lastProvider, SocialProvider.kakao);
      expect(api.lastIdToken, 'kakao-access-token');
      expect(api.authorizationCodeLogins, isEmpty);
    });

    test('GitHub 인가 코드는 코드 로그인(/auth/login/code)으로 보내고 세션을 저장한다', () async {
      final api = _FakeAuthApi();
      final social = _FakeSocial(
        codeCredential: const SocialAuthorizationCodeCredential(
          provider: SocialProvider.github,
          code: 'github-code',
          redirectUri: 'passql://auth/callback/github',
          state: 'state-1',
          codeVerifier: 'verifier-1',
        ),
      );
      final container = _container(social, api, store);
      await container.read(authProvider.future);

      final ok = await container
          .read(authProvider.notifier)
          .signIn(SocialProvider.github);

      expect(ok, isTrue);
      expect(api.lastIdToken, isNull);
      expect(api.authorizationCodeLogins, [
        [
          'GITHUB',
          'github-code',
          'passql://auth/callback/github',
          'state-1',
          'verifier-1',
        ],
      ]);
      expect((await store.read())?.memberUuid, 'member-github');
      expect((await store.read())?.authProvider, SocialProvider.github);
    });

    test('서버에 설정 없는 제공자(503 SOCIAL_LOGIN_UNAVAILABLE)는 준비 중 안내를 던진다', () async {
      final api = _FakeAuthApi(
        loginError: DioException(
          requestOptions: RequestOptions(path: '/auth/login/code'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login/code'),
            statusCode: 503,
            data: {
              'errorCode': 'SOCIAL_LOGIN_UNAVAILABLE',
              'message': '이 소셜 로그인은 아직 준비 중입니다.',
            },
          ),
        ),
      );
      final social = _FakeSocial(
        codeCredential: const SocialAuthorizationCodeCredential(
          provider: SocialProvider.github,
          code: 'github-code',
          redirectUri: 'passql://auth/callback/github',
          state: 'state-1',
          codeVerifier: 'verifier-1',
        ),
      );
      final container = _container(social, api, store);
      await container.read(authProvider.future);

      await expectLater(
        container.read(authProvider.notifier).signIn(SocialProvider.github),
        throwsA(
          isA<SocialSignInException>().having(
            (e) => e.message,
            'message',
            SocialSignInException.preparing().message,
          ),
        ),
      );
      expect(await store.read(), isNull);
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

    test(
      '소셜 토큰 검증 실패(401 INVALID_SOCIAL_TOKEN 등)는 세션 만료가 아닌 로그인 실패 문구 (#516)',
      () async {
        for (final serverCode in [
          'INVALID_SOCIAL_TOKEN',
          'INVALID_FIREBASE_TOKEN',
          'EXPIRED_FIREBASE_TOKEN',
        ]) {
          final api = _FakeAuthApi(
            loginError: DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 401,
                data: {'errorCode': serverCode, 'message': '유효하지 않은 토큰입니다.'},
              ),
            ),
          );
          final container = _container(_FakeSocial(), api, store);
          await container.read(authProvider.future);

          await expectLater(
            container.read(authProvider.notifier).signIn(SocialProvider.kakao),
            throwsA(
              isA<SocialSignInException>().having(
                (exception) => exception.message,
                'message',
                '로그인에 실패했어요. 다시 시도해 주세요.',
              ),
            ),
          );
          expect(await store.read(), isNull);
        }
      },
    );

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
      FakeMemberApi member, {
      SocialProvider provider = SocialProvider.google,
    }) async {
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
      await container.read(authProvider.notifier).signIn(provider);
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

    test('카카오·네이버·GitHub 세션은 /members/me 조회 없이 저장된 제공자로 분기한다 (#516)', () async {
      for (final provider in [
        SocialProvider.kakao,
        SocialProvider.naver,
        SocialProvider.github,
      ]) {
        final social = _FakeSocial();
        final member = FakeMemberApi();
        final container = await signedIn(social, member, provider: provider);

        await container.read(authProvider.notifier).withdraw();

        expect(social.revokedProviders, [provider]);
        expect(social.disconnectedProviders, [provider]);
        expect(member.getMeCalls, 0);
      }
    });

    test(
      'Apple·Google 세션은 /members/me 의 providerUserId 로 재인증 계정을 대조한다 (#516)',
      () async {
        for (final provider in [SocialProvider.apple, SocialProvider.google]) {
          final social = _FakeSocial();
          final member = FakeMemberApi(meProviderUserId: 'firebase-uid-1');
          final container = await signedIn(social, member, provider: provider);

          await container.read(authProvider.notifier).withdraw();

          expect(member.getMeCalls, 1);
          expect(social.revokedProviders, [provider]);
          expect(social.revokedProviderUserIds, ['firebase-uid-1']);
          expect(member.withdrawCalls, 1);
        }
      },
    );

    test('재인증 계정이 가입 계정과 다르면 서버 탈퇴·연결 해제 없이 안내를 던진다 (#516)', () async {
      final social = _FakeSocial()
        ..revokeError = const SocialSignInException(
          FirebaseSocialSignIn.accountMismatchMessage,
        );
      final member = FakeMemberApi(meProviderUserId: 'firebase-uid-1');
      final container = await signedIn(
        social,
        member,
        provider: SocialProvider.apple,
      );

      await expectLater(
        container.read(authProvider.notifier).withdraw(),
        throwsA(
          isA<SocialSignInException>().having(
            (exception) => exception.message,
            'message',
            '가입한 계정으로 다시 인증해 주세요.',
          ),
        ),
      );
      expect(member.withdrawCalls, 0);
      expect(social.disconnectedProviders, isEmpty);
      expect(container.read(authProvider).value, isNotNull);
    });

    test('제공자 없는 이전 세션은 /members/me 의 authProvider 로 분기한다 (#516)', () async {
      await store.save(
        const AuthSession(
          accessToken: 'access-old',
          refreshToken: 'refresh-old',
          memberUuid: 'member-old',
          nickname: '이전회원',
        ),
      );
      final social = _FakeSocial();
      final member = FakeMemberApi(meAuthProvider: 'NAVER');
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

      await container.read(authProvider.notifier).withdraw();

      expect(member.getMeCalls, 1);
      expect(social.revokedProviders, [SocialProvider.naver]);
      expect(social.disconnectedProviders, [SocialProvider.naver]);
      expect(member.withdrawCalls, 1);
    });

    test('서버 탈퇴가 실패하면 제공자 연결을 끊지 않는다', () async {
      final social = _FakeSocial();
      final member = FakeMemberApi(
        withdrawError: DioException(
          requestOptions: RequestOptions(path: '/members/me'),
          type: DioExceptionType.connectionError,
        ),
      );
      final container = await signedIn(
        social,
        member,
        provider: SocialProvider.kakao,
      );

      await expectLater(
        container.read(authProvider.notifier).withdraw(),
        throwsA(isA<Exception>()),
      );
      expect(social.disconnectedProviders, isEmpty);
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
}
