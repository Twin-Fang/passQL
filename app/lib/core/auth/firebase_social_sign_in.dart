import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'auth_session.dart';
import 'social_sign_in.dart';

/// Firebase Auth 로 Google/Apple 로그인을 하고, 서버 로그인에 쓸 Firebase ID 토큰을 돌려준다.
///
/// 서버는 Firebase Admin SDK 로 이 토큰을 검증한 뒤 자체 JWT 를 발급한다.
/// (웹도 같은 Firebase 프로젝트의 ID 토큰을 보낸다.)
/// 제공자 묶음(`MultiProviderSocialSignIn`)이 Google·Apple 요청만 넘긴다.
class FirebaseSocialSignIn {
  FirebaseSocialSignIn({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  bool _isGoogleInitialized = false;

  Future<String?> fetchIdToken(SocialProvider provider) async {
    try {
      final credential = switch (provider) {
        SocialProvider.google => await _googleCredential(),
        SocialProvider.apple => await _appleCredential(),
        _ => throw ArgumentError.value(provider, 'provider', 'Firebase 로그인은 Google·Apple 만'),
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
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) return null;
      throw SocialSignInException(_failure('Google'));
    } on SignInWithAppleAuthorizationException catch (exception) {
      if (exception.code == AuthorizationErrorCode.canceled) return null;
      throw SocialSignInException(_failure('Apple'));
    } on FirebaseAuthException catch (exception) {
      throw SocialSignInException(_firebaseMessage(exception));
    }
  }

  /// 탈퇴 재인증 계정이 가입 계정과 다를 때 안내 (revoke·disconnect 없이 탈퇴 중단)
  static const String accountMismatchMessage = '가입한 계정으로 다시 인증해 주세요.';
  static const String _appleFailureMessage = 'Apple 인증에 실패했어요. 잠시 후 다시 시도해 주세요.';

  /// 제공자 모르는 세션용: 기기의 Firebase 로그인이 Apple 일 때만 revoke
  Future<bool> revokeAppleAccessIfSignedInWithApple({required String? expectedUid}) async {
    final isApple = _auth.currentUser?.providerData.any((p) => p.providerId == 'apple.com') ?? false;
    if (!isApple) return true;
    return revokeAppleAccess(expectedUid: expectedUid);
  }

  /// Apple 탈퇴 필수 revoke: Apple 재인증 > 가입 계정 대조(Firebase uid <-> [expectedUid]) > 인가 코드로 토큰 revoke
  /// 취소 > false, 실패·다른 계정 > [SocialSignInException] (모두 탈퇴 중단)
  Future<bool> revokeAppleAccess({required String? expectedUid}) async {
    if (!Platform.isIOS) {
      throw const SocialSignInException('Apple 계정 탈퇴는 iOS 기기에서 진행해 주세요.');
    }
    try {
      final rawNonce = _randomNonce();
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: const [],
        nonce: sha256.convert(utf8.encode(rawNonce)).toString(),
      );
      final idToken = apple.identityToken;
      if (idToken == null) throw const SocialSignInException(_appleFailureMessage);
      await confirmSignedUpAccount(
        OAuthProvider('apple.com').credential(idToken: idToken, rawNonce: rawNonce),
        expectedUid,
      );
      await _auth.revokeTokenWithAuthorizationCode(apple.authorizationCode);
      return true;
    } on SocialSignInException {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (exception) {
      if (exception.code == AuthorizationErrorCode.canceled) return false;
      throw const SocialSignInException(_appleFailureMessage);
    } on FirebaseAuthException catch (exception) {
      throw SocialSignInException(_firebaseMessage(exception));
    }
  }

  /// Google 탈퇴 계정 대조: Firebase 세션 uid 가 [expectedUid] 면 통과, 아니면 Google 재인증 > 새 Firebase 로그인 후 대조
  /// 취소 > false, 실패·다른 계정 > [SocialSignInException] (모두 탈퇴 중단, disconnect 안 함)
  Future<bool> confirmGoogleAccount({required String? expectedUid}) async {
    if (expectedUid != null && _auth.currentUser?.uid == expectedUid) return true;
    try {
      final credential = await _googleCredential();
      if (credential == null) return false;
      await confirmSignedUpAccount(credential, expectedUid);
      return true;
    } on SocialSignInException {
      rethrow;
    } on GoogleSignInException catch (exception) {
      if (exception.code == GoogleSignInExceptionCode.canceled) return false;
      throw SocialSignInException(_failure('Google'));
    } on FirebaseAuthException catch (exception) {
      throw SocialSignInException(_firebaseMessage(exception));
    }
  }

  /// 재인증 자격 > 가입 계정 대조 (uid <-> [expectedUid])
  /// 같은 계정 Firebase 세션 > 재인증, 그 외 > 세션 정리 후 새 로그인 > uid 비교 (다르면 새로 생긴 Firebase 회원 삭제)
  @visibleForTesting
  Future<void> confirmSignedUpAccount(AuthCredential credential, String? expectedUid) async {
    if (expectedUid == null) throw const SocialSignInException(accountMismatchMessage);
    final currentUser = _auth.currentUser;
    if (currentUser?.uid == expectedUid) {
      await currentUser!.reauthenticateWithCredential(credential);
      return;
    }
    // 다른 계정 Firebase 세션 정리 (재인증 대상이 가입 계정이어야 함)
    if (currentUser != null) await _auth.signOut();
    final signedIn = await _auth.signInWithCredential(credential);
    if (signedIn.user?.uid == expectedUid) return;
    // 다른 계정으로 새로 만들어진 Firebase 회원 정리 (실패해도 탈퇴 중단은 그대로)
    try {
      if (signedIn.additionalUserInfo?.isNewUser ?? false) await signedIn.user?.delete();
      await _auth.signOut();
    } catch (_) {}
    throw const SocialSignInException(accountMismatchMessage);
  }

  /// Google 앱 권한 해제 (최선, 실패 무시). 이 실행에서 Google 로그인한 적 없으면 SDK 가 무시할 수 있음
  Future<void> disconnectGoogle() async {
    try {
      await _initializeGoogleOnce();
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }

  Future<void> signOut() async {
    // 한쪽이 실패해도 다른 쪽은 정리한다. 기기에서 로그아웃되는 것이 우선이다.
    try {
      await _auth.signOut();
    } catch (_) {}
    try {
      if (_isGoogleInitialized) await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  Future<AuthCredential?> _googleCredential() async {
    await _initializeGoogleOnce();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const SocialSignInException('Google 로그인 정보를 확인하지 못했어요.');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  Future<void> _initializeGoogleOnce() async {
    if (_isGoogleInitialized) return;
    // Android 는 google-services.json 의 웹 클라이언트, iOS 는 Info.plist 의 GIDClientID 를 쓴다.
    await GoogleSignIn.instance.initialize();
    _isGoogleInitialized = true;
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

  static String _firebaseMessage(FirebaseAuthException exception) => switch (exception.code) {
    'network-request-failed' => '네트워크 연결을 확인해 주세요.',
    'user-disabled' => '이용이 제한된 계정이에요.',
    'account-exists-with-different-credential' => '이미 다른 방법으로 가입된 계정이에요.',
    _ => '로그인에 실패했어요. 잠시 후 다시 시도해 주세요.',
  };
}
