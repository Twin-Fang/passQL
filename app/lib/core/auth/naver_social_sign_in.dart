import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

import '../config/app_build_flavor.dart';
import '../logging/app_logger.dart';
import 'auth_session.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 네이버 로그인: 네이버 SDK 로그인 > 액세스 토큰
/// iOS 는 flutter_naver_login, Android 는 SDK 5.12 직접 채널 (플러그인 2.1.1 은 SDK 5.10 전용, 폴더블에서 실패, #942)
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _fetchAndroidCredential();
    }
    try {
      final result = await _logIn();
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

  /// Android: 네이버 앱 우선 로그인 > 실패(취소 아님)면 Chrome 로그인 화면으로 1회 재시도 > 액세스 토큰
  Future<SocialTokenCredential?> _fetchAndroidCredential() async {
    try {
      final accessToken =
          await _logInAndroid(_defaultBehavior) ??
          await _logInAndroid(_customTabsBehavior);
      if (accessToken == null || accessToken.isEmpty) {
        AppLogger.warn('naver login', 'failed : empty access token');
        throw const SocialSignInException(_failureMessage);
      }
      return SocialTokenCredential(
        provider: SocialProvider.naver,
        token: accessToken,
      );
    } on _NaverLoginCancelled {
      AppLogger.info('naver login', 'cancelled');
      return null;
    }
  }

  /// SDK 로그인 1회: 성공 > 토큰, 재시도할 실패 > null, 취소 > [_NaverLoginCancelled], 마지막 방식 실패 > 예외
  Future<String?> _logInAndroid(String behavior) async {
    try {
      final reply = await _androidLoginChannel.invokeMapMethod<String, dynamic>(
        'login',
        // 개발·테스트 빌드만 네이버 SDK 내부 로그(logcat) 켬
        {'behavior': behavior, 'isDeveloperLog': AppBuildFlavor.canUseDevTools},
      );
      AppLogger.info(
        'naver login',
        'success : ${describeDiagnostics(reply?['diagnostics'])}',
      );
      return reply?['accessToken'] as String?;
    } on PlatformException catch (error) {
      final details = error.details is Map ? error.details as Map : const {};
      final errorCode = details['errorCode']?.toString();
      AppLogger.warn(
        'naver login',
        'failed : behavior $behavior, platform ${sanitizeForLog(error.code)}, '
            'error ${sanitizeForLog(errorCode)}, '
            'desc ${sanitizeForLog(details['errorDescription']?.toString())}, '
            '${describeDiagnostics(details['diagnostics'])}',
      );
      if (isCancelledErrorCode(errorCode)) throw const _NaverLoginCancelled();
      if (behavior == _defaultBehavior) return null;
      throw const SocialSignInException(_failureMessage);
    } on MissingPluginException {
      throw SocialSignInException.preparing();
    }
  }

  /// 네이티브 진단 정보 > 로그 한 줄 (SDK 버전, 방식, 네이버 앱 설치, 걸린 시간, 시작 창, 로그인 중 화면 변경, 멀티 윈도우)
  static String describeDiagnostics(Object? diagnostics) {
    if (diagnostics is! Map) return 'diag none';
    String read(String key) => sanitizeForLog(diagnostics[key]?.toString());
    return 'sdk ${read('sdkVersion')}, naverApp ${read('isNaverAppInstalled')}, '
        '${read('elapsedMs')}ms, window ${read('startWindow')}, '
        'changes ${read('configChanges')}, multiWindow ${read('isInMultiWindow')}';
  }

  /// SDK 취소 코드 판정 (사용자 취소 > 조용히 로그인 화면 유지)
  static bool isCancelledErrorCode(String? errorCode) =>
      errorCode != null && errorCode.toLowerCase().contains('cancel');

  // MainActivity 의 네이버 로그인 채널과 이름·값을 맞춤
  static const MethodChannel _androidLoginChannel = MethodChannel(
    'passql/naver_login',
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
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _androidLoginChannel.invokeMethod<void>('logout');
      } else {
        await FlutterNaverLogin.logOut();
      }
    } catch (_) {}
  }

  /// 탈퇴 후 네이버 토큰 삭제(연동 해제) (설정 없는 빌드는 생략, 실패해도 진행: 서버도 해제)
  Future<void> deleteToken() async {
    if (_readClientId().isEmpty) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _androidLoginChannel.invokeMethod<void>('deleteToken');
      } else {
        await FlutterNaverLogin.logOutAndDeleteToken();
      }
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

/// Android 로그인 사용자 취소 (호출부에서 null 로 바꿈)
class _NaverLoginCancelled implements Exception {
  const _NaverLoginCancelled();
}
