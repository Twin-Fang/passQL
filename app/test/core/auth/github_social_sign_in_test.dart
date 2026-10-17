import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/github_social_sign_in.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';

/// 인증 브라우저 가짜: 받은 인가 주소 기록 > 정해 둔 콜백 반환 또는 예외
GithubSocialSignIn _signInReturning(
  String Function(Uri authorizeUri) respond, {
  List<Uri>? openedUris,
  String state = 'fixed-state',
  String codeVerifier = _rfcCodeVerifier,
}) => GithubSocialSignIn(
  createState: () => state,
  createCodeVerifier: () => codeVerifier,
  openAuthenticationBrowser:
      ({required String url, required String callbackUrlScheme}) async {
        expect(callbackUrlScheme, 'passql');
        final authorizeUri = Uri.parse(url);
        openedUris?.add(authorizeUri);
        return respond(authorizeUri);
      },
);

// RFC 7636 부록 B 예시 (verifier > S256 challenge)
const _rfcCodeVerifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
const _rfcCodeChallenge = 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM';

void main() {
  group('인가 주소', () {
    test(
      'client_id, 앱 콜백 주소, state, read:user 범위, PKCE S256 challenge 를 싣는다',
      () {
        final uri = GithubSocialSignIn.buildAuthorizeUri(
          state: 'state-1',
          codeChallenge: 'challenge-1',
        );

        expect(uri.origin, 'https://github.com');
        expect(uri.path, '/login/oauth/authorize');
        expect(uri.queryParameters, {
          'client_id': 'Ov23liFJLvi4ZizNqLfi',
          'redirect_uri': 'passql://auth/callback/github',
          'state': 'state-1',
          'scope': 'read:user',
          'code_challenge': 'challenge-1',
          'code_challenge_method': 'S256',
        });
      },
    );

    test(
      'code_challenge 는 verifier 의 SHA-256 base64url(패딩 없음)이다 (RFC 7636 예시)',
      () {
        expect(
          GithubSocialSignIn.buildCodeChallenge(_rfcCodeVerifier),
          _rfcCodeChallenge,
        );
      },
    );

    test('code_verifier 는 매번 새로 만든 RFC 7636 비예약 문자 64자다', () {
      final first = GithubSocialSignIn.createRandomCodeVerifier();
      final second = GithubSocialSignIn.createRandomCodeVerifier();

      expect(first, hasLength(64));
      expect(first, matches(RegExp(r'^[0-9A-Za-z\-._~]+$')));
      expect(first, isNot(second));
    });

    test('state 는 매번 새로 만든 URL 안전 문자 32자다', () {
      final first = GithubSocialSignIn.createRandomState();
      final second = GithubSocialSignIn.createRandomState();

      expect(first, hasLength(32));
      expect(first, matches(RegExp(r'^[0-9A-Za-z]+$')));
      expect(first, isNot(second));
    });
  });

  group('콜백 검증', () {
    test('state 가 같으면 인가 코드를 돌려준다', () {
      final code = GithubSocialSignIn.readAuthorizationCode(
        Uri.parse('passql://auth/callback/github?code=abc&state=s1'),
        expectedState: 's1',
      );

      expect(code, 'abc');
    });

    test('state 가 다르면(위조 콜백) 코드가 있어도 실패로 막는다', () {
      expect(
        () => GithubSocialSignIn.readAuthorizationCode(
          Uri.parse('passql://auth/callback/github?code=abc&state=other'),
          expectedState: 's1',
        ),
        throwsA(isA<SocialSignInException>()),
      );
    });

    test('사용자가 GitHub 화면에서 거부하면 취소(null)로 본다', () {
      final code = GithubSocialSignIn.readAuthorizationCode(
        Uri.parse('passql://auth/callback/github?error=access_denied&state=s1'),
        expectedState: 's1',
      );

      expect(code, isNull);
    });

    test('코드가 없으면 실패로 본다', () {
      expect(
        () => GithubSocialSignIn.readAuthorizationCode(
          Uri.parse('passql://auth/callback/github?state=s1'),
          expectedState: 's1',
        ),
        throwsA(isA<SocialSignInException>()),
      );
    });
  });

  group('로그인 흐름', () {
    test('인가 화면에 보낸 state 로 콜백을 대조하고 서버 교환 재료를 만든다', () async {
      final openedUris = <Uri>[];
      final signIn = _signInReturning(
        (authorizeUri) =>
            'passql://auth/callback/github?code=code-1&state=${authorizeUri.queryParameters['state']}',
        openedUris: openedUris,
      );

      final credential = await signIn.fetchCredential();

      expect(openedUris.single.queryParameters['state'], 'fixed-state');
      expect(credential?.provider, SocialProvider.github);
      expect(credential?.code, 'code-1');
      expect(credential?.state, 'fixed-state');
      expect(credential?.redirectUri, 'passql://auth/callback/github');
      // 인가 요청에는 해시만, 서버 교환 재료에는 원문
      expect(
        openedUris.single.queryParameters['code_challenge'],
        _rfcCodeChallenge,
      );
      expect(credential?.codeVerifier, _rfcCodeVerifier);
    });

    test('사용자가 인증 브라우저를 닫으면 오류 없이 null', () async {
      final signIn = _signInReturning(
        (_) => throw PlatformException(code: 'CANCELED'),
      );

      expect(await signIn.fetchCredential(), isNull);
    });

    test('브라우저 오류는 사용자용 실패 문구로 바꾼다', () async {
      final signIn = _signInReturning(
        (_) => throw PlatformException(code: 'EUNKNOWN'),
      );

      await expectLater(
        signIn.fetchCredential(),
        throwsA(isA<SocialSignInException>()),
      );
    });
  });
}
