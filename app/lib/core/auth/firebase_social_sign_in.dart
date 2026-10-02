import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_session.dart';
import 'social_sign_in.dart';

/// Firebase Auth 로 Google/Apple 로그인을 하고, 서버 로그인에 쓸 Firebase ID 토큰을 돌려준다.
///
/// 서버는 Firebase Admin SDK 로 이 토큰을 검증한 뒤 자체 JWT 를 발급한다.
/// (웹도 같은 Firebase 프로젝트의 ID 토큰을 보낸다.)
class FirebaseSocialSignIn implements SocialSignIn {
  FirebaseSocialSignIn({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _googleReady = false;

  @override
  Future<String?> fetchIdToken(SocialProvider provider) async {
    try {
      final credential = switch (provider) {
        SocialProvider.google => await _googleCredential(),
        SocialProvider.apple => await _appleCredential(),
      };
      // 사용자가 중간에 취소했다.
      if (credential == null) return null;

      final user = (await _auth.signInWithCredential(credential)).user;
      final token = await user?.getIdToken();
      if (token == null) {
        throw const SocialSignInException('로그인 정보를 확인하지 못했어요. 다시 시도해 주세요.');
      }
      return token;
    } on SocialSignInException {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw SocialSignInException(_failure('Google'));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      throw SocialSignInException(_failure('Apple'));
    } on FirebaseAuthException catch (e) {
      throw SocialSignInException(_firebaseMessage(e));
    }
  }

  @override
  Future<void> signOut() async {
    // 한쪽이 실패해도 다른 쪽은 정리한다. 기기에서 로그아웃되는 것이 우선이다.
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      if (_googleReady) await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  Future<AuthCredential?> _googleCredential() async {
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      // Android 는 google-services.json 의 웹 클라이언트, iOS 는 Info.plist 의 GIDClientID 를 쓴다.
      await google.initialize();
      _googleReady = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const SocialSignInException('Google 로그인 정보를 확인하지 못했어요.');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<AuthCredential?> _appleCredential() async {
    if (!Platform.isIOS) {
      throw const SocialSignInException('Apple 로그인은 iOS에서만 사용할 수 있어요.');
    }
    // 재전송 공격을 막기 위해 일회용 값(nonce)을 만들어 Apple 에는 해시를, Firebase 에는 원문을 보낸다.
    final rawNonce = _randomNonce();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email],
      nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
    );
    final idToken = apple.identityToken;
    if (idToken == null) {
      throw const SocialSignInException('Apple 로그인 정보를 확인하지 못했어요.');
    }
    return OAuthProvider('apple.com').credential(idToken: idToken, rawNonce: rawNonce);
  }

  static String _randomNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static String _failure(String provider) =>
      '$provider 로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';

  static String _firebaseMessage(FirebaseAuthException e) => switch (e.code) {
    'network-request-failed' => '네트워크 연결을 확인해 주세요.',
    'user-disabled' => '이용이 제한된 계정이에요.',
    'account-exists-with-different-credential' => '이미 다른 방법으로 가입된 계정이에요.',
    _ => '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.',
  };
}
