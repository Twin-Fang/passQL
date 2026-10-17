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

  /// 회수 대상은 Apple 만 (Firebase 담당, 심사 5.1.1(v)). 카카오·네이버·GitHub 는 서버 회원 삭제만
  @override
  Future<bool> revokeAccessForWithdrawal() =>
      _firebase.revokeAccessForWithdrawal();

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
