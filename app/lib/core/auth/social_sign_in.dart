import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/app_exception.dart';
import '../error/error_code.dart';
import 'auth_session.dart';
import 'firebase_social_sign_in.dart';
import 'github_social_sign_in.dart';
import 'kakao_social_sign_in.dart';
import 'multi_provider_social_sign_in.dart';
import 'naver_social_sign_in.dart';
import 'social_credential.dart';

/// 소셜 로그인 실패. 화면에 그대로 보여줄 수 있는 메시지를 담는다.
class SocialSignInException implements Exception {
  const SocialSignInException(this.message);

  /// 설정 없는 제공자 안내 (앱 키 누락, 서버 503 SOCIAL_LOGIN_UNAVAILABLE 공통 문구)
  SocialSignInException.preparing()
    : message = AppException.defaultMessageFor(
        ErrorCode.socialLoginUnavailable,
      );

  final String message;

  @override
  String toString() => message;
}

/// 소셜 제공자에서 서버 로그인 재료(토큰·인가 코드)를 받아오는 추상화.
///
/// Firebase/Google/Apple/카카오/네이버/GitHub SDK 의존을 이 인터페이스 뒤로 숨겨서,
/// 인증 흐름(토큰 저장·재발급·라우팅)을 SDK 설정과 독립적으로 테스트한다.
abstract interface class SocialSignIn {
  /// 사용자가 취소하면 null, 실패하면 [SocialSignInException].
  Future<SocialCredential?> fetchCredential(SocialProvider provider);

  /// 서버 탈퇴 전 확인: [provider] 가 Apple 이면 재인증 > 계정 대조 > 토큰 revoke (App Store 5.1.1(v)),
  /// Google 이면 계정 대조. 대조 기준 [providerUserId] = 서버 회원 제공자 식별자 (Firebase uid)
  /// 취소 > false (탈퇴 중단), 실패·다른 계정 > [SocialSignInException], 확인 대상 아님 > true
  /// [provider] null(제공자 모름) > 기기의 Firebase 로그인 기준으로 Apple 여부 판단
  Future<bool> revokeAccessForWithdrawal(
    SocialProvider? provider, {
    String? providerUserId,
  });

  /// 서버 탈퇴 성공 후 제공자 연결 해제 (최선, 실패 무시)
  /// Google disconnect, 네이버 토큰 삭제. 카카오·GitHub 는 서버 담당, Apple 은 revoke 완료
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider);

  /// 소셜 쪽 로그인 상태도 함께 정리한다. 실패해도 예외를 던지지 않는다.
  Future<void> signOut();
}

/// 로그인 설정이 없는 환경(테스트 등)에서 쓰는 자리 표시 구현.
class UnconfiguredSocialSignIn implements SocialSignIn {
  const UnconfiguredSocialSignIn();

  @override
  Future<SocialCredential?> fetchCredential(SocialProvider provider) {
    throw const SocialSignInException('로그인 설정이 아직 완료되지 않았어요.');
  }

  @override
  Future<bool> revokeAccessForWithdrawal(
    SocialProvider? provider, {
    String? providerUserId,
  }) async => true;

  @override
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider) async {}

  @override
  Future<void> signOut() async {}
}

/// 운영 기본값: 제공자별 SDK 묶음 (Google·Apple Firebase, 카카오, 네이버, GitHub). 테스트에서는 가짜 구현으로 교체
final socialSignInProvider = Provider<SocialSignIn>(
  (ref) => MultiProviderSocialSignIn(
    firebase: FirebaseSocialSignIn(),
    kakao: KakaoSocialSignIn(),
    naver: NaverSocialSignIn(),
    github: GithubSocialSignIn(),
  ),
);
