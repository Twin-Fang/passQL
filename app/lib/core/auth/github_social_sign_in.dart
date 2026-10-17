import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'auth_session.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 인증 브라우저 열기 > 콜백 URL 반환 (테스트에서 가짜로 교체)
typedef OpenAuthenticationBrowser =
    Future<String> Function({
      required String url,
      required String callbackUrlScheme,
    });

/// GitHub 로그인: 인가 화면(인증 브라우저) > 콜백 state 대조 > 서버 교환용 인가 코드
/// client secret 은 서버만 보관 (앱은 공개 client ID 만 사용)
class GithubSocialSignIn {
  GithubSocialSignIn({
    OpenAuthenticationBrowser? openAuthenticationBrowser,
    String Function()? createState,
  }) : _openAuthenticationBrowser =
           openAuthenticationBrowser ?? _openWithFlutterWebAuth,
       _createState = createState ?? createRandomState;

  final OpenAuthenticationBrowser _openAuthenticationBrowser;
  final String Function() _createState;

  // GitHub OAuth App 공개 client ID (서버 /auth/social-config 의 GITHUB clientId 와 같은 값)
  static const String clientId = 'Ov23liFJLvi4ZizNqLfi';
  // 앱 콜백 주소: 서버 redirect 허용 목록·GitHub OAuth App 콜백과 같아야 함
  static const String redirectUri = 'passql://auth/callback/github';
  // iOS CFBundleURLTypes·Android CallbackActivity intent-filter 에 등록한 스킴
  static const String callbackUrlScheme = 'passql';
  // 회원 식별에 필요한 공개 프로필만 요청
  static const String scope = 'read:user';
  // 플랫폼 공통 사용자 취소 코드 (flutter_web_auth_2)
  static const String _cancelledErrorCode = 'CANCELED';
  // GitHub 인가 화면에서 사용자가 거부한 경우 error 값
  static const String _accessDeniedError = 'access_denied';

  /// 사용자가 취소·거부하면 null, state 불일치·코드 누락이면 [SocialSignInException]
  Future<SocialAuthorizationCodeCredential?> fetchCredential() async {
    final state = _createState();
    final String callbackUrl;
    try {
      callbackUrl = await _openAuthenticationBrowser(
        url: buildAuthorizeUri(state: state).toString(),
        callbackUrlScheme: callbackUrlScheme,
      );
    } on PlatformException catch (exception) {
      if (exception.code == _cancelledErrorCode) return null;
      throw const SocialSignInException(_failureMessage);
    }

    final code = readAuthorizationCode(
      Uri.parse(callbackUrl),
      expectedState: state,
    );
    if (code == null) return null;
    return SocialAuthorizationCodeCredential(
      provider: SocialProvider.github,
      code: code,
      redirectUri: redirectUri,
      state: state,
    );
  }

  /// GitHub 인가 주소 (client_id, redirect_uri, state, scope)
  static Uri buildAuthorizeUri({required String state}) =>
      Uri.https('github.com', '/login/oauth/authorize', {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'state': state,
        'scope': scope,
      });

  /// 콜백 URL > 인가 코드. 사용자 거부면 null
  /// state 불일치(위조 콜백)·코드 누락은 [SocialSignInException]
  static String? readAuthorizationCode(
    Uri callbackUri, {
    required String expectedState,
  }) {
    final parameters = callbackUri.queryParameters;
    // state 대조 먼저 (거부 응답도 위조일 수 있음)
    if (parameters['state'] != expectedState) {
      throw const SocialSignInException(_failureMessage);
    }
    if (parameters['error'] == _accessDeniedError) return null;
    final code = parameters['code'];
    if (code == null || code.isEmpty) {
      throw const SocialSignInException(_failureMessage);
    }
    return code;
  }

  /// CSRF 방지용 일회용 값 (URL 안전 문자 32자)
  static String createRandomState() {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(
      32,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static Future<String> _openWithFlutterWebAuth({
    required String url,
    required String callbackUrlScheme,
  }) => FlutterWebAuth2.authenticate(
    url: url,
    callbackUrlScheme: callbackUrlScheme,
  );

  static const String _failureMessage = 'GitHub 로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
}
