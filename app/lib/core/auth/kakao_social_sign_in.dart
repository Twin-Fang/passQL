import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'auth_session.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 카카오 로그인: SDK 초기화(최초 1회) > 카카오톡 앱 로그인(설치 시) 또는 카카오계정 로그인 > 액세스 토큰
/// 서버가 액세스 토큰으로 카카오 사용자 정보 API 를 불러 회원 식별
class KakaoSocialSignIn {
  KakaoSocialSignIn({String Function()? readNativeAppKey})
    : _readNativeAppKey = readNativeAppKey ?? _readNativeAppKeyFromEnv;

  final String Function() _readNativeAppKey;
  bool _isSdkInitialized = false;

  // app/.env: 카카오 네이티브 앱 키 (공개 앱 식별자, 네이티브 URL 스킴 kakao{키} 와 같은 원본)
  static const String nativeAppKeyEnvKey = 'KAKAO_NATIVE_APP_KEY';
  // SDK 네이티브 계층의 사용자 취소 코드 (카카오톡·카카오계정 공통)
  static const String _cancelledErrorCode = 'CANCELED';

  /// 사용자가 취소하면 null, 실패하면 [SocialSignInException]
  Future<SocialTokenCredential?> fetchCredential() async {
    await _initializeSdkOnce();
    try {
      final token = await isKakaoTalkInstalled()
          ? await _loginWithKakaoTalkFallingBackToAccount()
          : await UserApi.instance.loginWithKakaoAccount();
      return SocialTokenCredential(
        provider: SocialProvider.kakao,
        token: token.accessToken,
      );
    } on PlatformException catch (exception) {
      if (exception.code == _cancelledErrorCode) return null;
      throw const SocialSignInException(_failureMessage);
    } on KakaoAuthException catch (exception) {
      // 동의 화면에서 취소 = 사용자 취소
      if (exception.error == AuthErrorCause.accessDenied) return null;
      throw const SocialSignInException(_failureMessage);
    } on KakaoClientException catch (exception) {
      if (exception.reason == ClientErrorCause.cancelled) return null;
      throw const SocialSignInException(_failureMessage);
    } on KakaoException {
      throw const SocialSignInException(_failureMessage);
    }
  }

  /// 기기의 카카오 토큰 정리 (설정 없는 빌드는 생략, 실패해도 진행)
  Future<void> signOut() async {
    if (_readNativeAppKey().isEmpty) return;
    try {
      await _initializeSdkOnce();
      await UserApi.instance.logout();
    } catch (_) {}
  }

  /// 카카오톡 로그인 실패 시 카카오계정 로그인으로 재시도 (톡 미연결 계정 등). 사용자 취소는 그대로 전달
  Future<OAuthToken> _loginWithKakaoTalkFallingBackToAccount() async {
    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (exception) {
      if (exception.code == _cancelledErrorCode) rethrow;
      return UserApi.instance.loginWithKakaoAccount();
    }
  }

  Future<void> _initializeSdkOnce() async {
    if (_isSdkInitialized) return;
    final nativeAppKey = _readNativeAppKey();
    // 키 없는 빌드(CI .env 누락 등) > SDK 오류 대신 준비 중 안내
    if (nativeAppKey.isEmpty) {
      throw SocialSignInException.preparing();
    }
    await KakaoSdk.init(nativeAppKey: nativeAppKey);
    _isSdkInitialized = true;
  }

  // .env 미로드(테스트 등)도 키 없음으로 처리
  static String _readNativeAppKeyFromEnv() {
    try {
      return dotenv.maybeGet(nativeAppKeyEnvKey)?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static const String _failureMessage = '카카오 로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
}
