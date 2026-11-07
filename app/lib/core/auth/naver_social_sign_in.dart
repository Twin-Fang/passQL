import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

import '../logging/app_logger.dart';
import 'auth_session.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 네이버 로그인: 네이버 SDK 로그인 > (Android 실패 시 Chrome 로그인 화면으로 1회 재시도) > 액세스 토큰
/// SDK 설정(client id·secret·이름)은 네이티브 빌드 타임 주입 (Android 매니페스트, iOS Info.plist ← app/.env)
class NaverSocialSignIn {
  NaverSocialSignIn({String Function()? readClientId})
    : _readClientId = readClientId ?? _readClientIdFromEnv;

  final String Function() _readClientId;

  // app/.env: 네이버 client ID (설정 여부 판단용, 네이티브 설정과 같은 원본)
  static const String clientIdEnvKey = 'NAVER_CLIENT_ID';

  /// 사용자가 취소하면 null, 실패하면 [SocialSignInException]
  Future<SocialTokenCredential?> fetchCredential() async {
    // 키 없는 빌드(CI .env 누락 등) > SDK 오류 대신 준비 중 안내
    if (_readClientId().isEmpty) throw SocialSignInException.preparing();
    try {
      final result = await _logInWithCustomTabsFallback();
      // 취소 > null (Android SDK 는 커스텀 탭 복귀 실패도 user_cancel 로 보고해 구분 불가, 로그만 남김)
      if (isCancelledResult(result)) {
        AppLogger.info(
          'naver login',
          'cancelled : status ${result.status.name}',
        );
        return null;
      }
      if (result.status != NaverLoginStatus.loggedIn) {
        AppLogger.warn(
          'naver login',
          'failed : status ${result.status.name}, '
              'error ${sanitizeForLog(result.errorMessage)}',
        );
        throw const SocialSignInException(_failureMessage);
      }
      // iOS 는 로그인 결과에 토큰 포함, Android 는 로그인 후 따로 조회
      final accessToken =
          result.accessToken?.accessToken ??
          (await FlutterNaverLogin.getCurrentAccessToken()).accessToken;
      if (accessToken.isEmpty) {
        AppLogger.warn('naver login', 'failed : empty access token');
        throw const SocialSignInException(_failureMessage);
      }
      return SocialTokenCredential(
        provider: SocialProvider.naver,
        token: accessToken,
      );
    } on MissingPluginException {
      // iOS Info.plist 에 Nid 설정이 없으면 플러그인 미등록
      throw SocialSignInException.preparing();
    } on PlatformException catch (error) {
      AppLogger.warn(
        'naver login',
        'failed : platform ${sanitizeForLog(error.code)}',
      );
      throw const SocialSignInException(_failureMessage);
    }
  }

  /// 로그인 > Android 에서 실패(취소 아님)면 Chrome 로그인 화면으로 1회 재시도 (#942)
  /// 네이버 앱이 깔린 일부 기기에서 앱 간 로그인이 no_catagorized_error 로 실패, Chrome 경로는 정상
  Future<NaverLoginResult> _logInWithCustomTabsFallback() async {
    final result = await _logIn();
    if (!shouldRetryWithCustomTabs(result, defaultTargetPlatform)) {
      return result;
    }
    AppLogger.warn(
      'naver login',
      'app login failed, retry custom tabs : '
          'error ${sanitizeForLog(result.errorMessage)}',
    );
    await _setLoginBehavior(_customTabsBehavior);
    try {
      return await _logIn();
    } finally {
      // 다음 로그인은 다시 네이버 앱 우선 (되는 기기는 한 번에 로그인)
      await _setLoginBehavior(_defaultBehavior);
    }
  }

  /// Chrome 로그인 화면 재시도 여부: Android + 실패 상태 + 취소 아님
  static bool shouldRetryWithCustomTabs(
    NaverLoginResult result,
    TargetPlatform platform,
  ) {
    return platform == TargetPlatform.android &&
        result.status == NaverLoginStatus.error &&
        !isCancelledResult(result);
  }

  /// 네이티브 로그인 방식 지정 (채널 없는 플랫폼·실패는 무시, 기본 방식으로 진행)
  Future<void> _setLoginBehavior(String behavior) async {
    try {
      await _loginBehaviorChannel.invokeMethod<void>('setBehavior', {
        'behavior': behavior,
      });
    } on MissingPluginException {
      // iOS 등 채널 없음
    } on PlatformException catch (error) {
      AppLogger.warn(
        'naver login',
        'set behavior failed : ${sanitizeForLog(error.code)}',
      );
    }
  }

  // MainActivity 의 로그인 방식 채널과 이름·값을 맞춤
  static const MethodChannel _loginBehaviorChannel = MethodChannel(
    'passql/naver_login_behavior',
  );
  // 로그인 방식 값 2개: default(네이버 앱 우선), customTabs(Chrome 로그인 화면만)
  static const String _defaultBehavior = 'default';
  static const String _customTabsBehavior = 'customTabs';

  /// 플러그인 로그인 호출 (네이티브 응답 null > Map 변환 TypeError, 실패 결과로 변환)
  Future<NaverLoginResult> _logIn() async {
    try {
      return await FlutterNaverLogin.logIn();
    } on TypeError {
      return NaverLoginResult(
        status: NaverLoginStatus.error,
        errorMessage: 'empty native result',
      );
    }
  }

  /// 기기의 네이버 토큰 정리 (설정 없는 빌드는 생략, 실패해도 진행)
  Future<void> signOut() async {
    if (_readClientId().isEmpty) return;
    try {
      await FlutterNaverLogin.logOut();
    } catch (_) {}
  }

  /// 탈퇴 후 네이버 토큰 삭제(연동 해제) (설정 없는 빌드는 생략, 실패해도 진행: 서버도 해제)
  Future<void> deleteToken() async {
    if (_readClientId().isEmpty) return;
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
    } catch (_) {}
  }

  /// 사용자 취소 판정: Android 는 loggedOut 상태, iOS 는 cancel 문구가 담긴 error 상태
  static bool isCancelledResult(NaverLoginResult result) {
    if (result.status == NaverLoginStatus.loggedOut) return true;
    final errorMessage = result.errorMessage?.toLowerCase() ?? '';
    return result.status == NaverLoginStatus.error &&
        errorMessage.contains('cancel');
  }

  /// 로그용 값 정리 (null > none, 제어문자 > 공백, 100자 제한)
  static String sanitizeForLog(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return 'none';
    final singleLine = rawValue.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), ' ');
    return singleLine.length <= _maximumLogValueLength
        ? singleLine
        : singleLine.substring(0, _maximumLogValueLength);
  }

  // 로그 한 값 최대 길이 (문자 수)
  static const int _maximumLogValueLength = 100;

  // .env 미로드(테스트 등)도 키 없음으로 처리
  static String _readClientIdFromEnv() {
    try {
      return dotenv.maybeGet(clientIdEnvKey)?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  static const String _failureMessage = '네이버 로그인에 실패했어요. 잠시 후 다시 시도해 주세요.';
}
