import 'auth_session.dart';
import 'firebase_social_sign_in.dart';
import 'github_social_sign_in.dart';
import 'kakao_social_sign_in.dart';
import 'naver_social_sign_in.dart';
import 'social_credential.dart';
import 'social_sign_in.dart';

/// 제공자별 SDK 묶음: 로그인 요청을 제공자 담당 구현으로 연결, 로그아웃은 전체 정리
/// 담당 4개: Google·Apple(Firebase), 카카오, 네이버, GitHub
class MultiProviderSocialSignIn implements SocialSignIn {
  MultiProviderSocialSignIn({
    required FirebaseSocialSignIn firebase,
    required KakaoSocialSignIn kakao,
    required NaverSocialSignIn naver,
    required GithubSocialSignIn github,
  }) : _firebase = firebase,
       _kakao = kakao,
       _naver = naver,
       _github = github;

  final FirebaseSocialSignIn _firebase;
  final KakaoSocialSignIn _kakao;
  final NaverSocialSignIn _naver;
  final GithubSocialSignIn _github;

  @override
  Future<SocialCredential?> fetchCredential(SocialProvider provider) async {
    switch (provider) {
      case SocialProvider.google:
      case SocialProvider.apple:
        final idToken = await _firebase.fetchIdToken(provider);
        if (idToken == null) return null;
        return SocialTokenCredential(provider: provider, token: idToken);
      case SocialProvider.kakao:
        return _kakao.fetchCredential();
      case SocialProvider.naver:
        return _naver.fetchCredential();
      case SocialProvider.github:
        return _github.fetchCredential();
    }
  }

  /// 탈퇴 전 확인: Apple 재인증·계정 대조·revoke(필수), Google 계정 대조 (Firebase 담당, 심사 5.1.1(v))
  /// 카카오·네이버·GitHub 는 확인 없음. 제공자 모름 > Firebase 로그인 기준
  @override
  Future<bool> revokeAccessForWithdrawal(
    SocialProvider? provider, {
    String? providerUserId,
  }) => switch (provider) {
    SocialProvider.apple => _firebase.revokeAppleAccess(
      expectedUid: providerUserId,
    ),
    SocialProvider.google => _firebase.confirmGoogleAccount(
      expectedUid: providerUserId,
    ),
    null => _firebase.revokeAppleAccessIfSignedInWithApple(
      expectedUid: providerUserId,
    ),
    _ => Future.value(true),
  };

  /// 제공자별 연결 해제 (각 구현이 실패를 삼킴)
  /// 카카오는 서버가 Admin 키로 unlink (앱 중복 해제 시 한쪽 실패 > 로그아웃만), GitHub 는 서버가 grant 삭제
  @override
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider) async {
    switch (provider) {
      case SocialProvider.google:
        await _firebase.disconnectGoogle();
      case SocialProvider.naver:
        await _naver.deleteToken();
      case SocialProvider.kakao:
      case SocialProvider.apple:
      case SocialProvider.github:
      case null:
        break;
    }
  }

  /// 어느 제공자로 로그인했든 전부 정리 (각 구현이 실패를 삼킴)
  @override
  Future<void> signOut() async {
    await Future.wait<void>([
      _firebase.signOut(),
      _kakao.signOut(),
      _naver.signOut(),
    ]);
  }
}
