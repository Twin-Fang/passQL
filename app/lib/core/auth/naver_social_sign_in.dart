import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

import 'auth_session.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 네이버 로그인: 네이버 SDK 로그인 > 액세스 토큰
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
      final result = await _logIn();
      // 취소 > null (Android SDK 는 커스텀 탭 복귀 실패도 user_cancel 로 보고해 구분 불가, 로그만 남김)
      if (isCancelledResult(result)) {
        debugPrint('[naver login] cancelled : status ${result.status.name}');
        return null;
      }
      if (result.status != NaverLoginStatus.loggedIn) {
        debugPrint(
          '[naver login] failed : status ${result.status.name}, '
          'error ${sanitizeForLog(result.errorMessage)}',
        );
        throw const SocialSignInException(_failureMessage);
      }
      // iOS 는 로그인 결과에 토큰 포함, Android 는 로그인 후 따로 조회
      final accessToken =
          result.accessToken?.accessToken ??
          (await FlutterNaverLogin.getCurrentAccessToken()).accessToken;
      if (accessToken.isEmpty) {
        debugPrint('[naver login] failed : empty access token');
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
      debugPrint(
        '[naver login] failed : platform ${sanitizeForLog(error.code)}',
      );
      throw const SocialSignInException(_failureMessage);
    }
  }

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
