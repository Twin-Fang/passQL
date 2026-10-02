import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session.dart';

/// 소셜 로그인 실패. 화면에 그대로 보여줄 수 있는 메시지를 담는다.
class SocialSignInException implements Exception {
  const SocialSignInException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 소셜 제공자에서 서버 로그인에 쓸 idToken 을 받아오는 추상화.
///
/// Firebase/Google/Apple SDK 의존을 이 인터페이스 뒤로 숨겨서,
/// 인증 흐름(토큰 저장·재발급·라우팅)을 SDK 설정과 독립적으로 테스트한다.
abstract interface class SocialSignIn {
  /// 사용자가 취소하면 null, 실패하면 [SocialSignInException].
  Future<String?> fetchIdToken(SocialProvider provider);
}

/// Firebase 설정(google-services.json 등)이 들어오기 전까지 쓰는 자리 표시 구현.
class UnconfiguredSocialSignIn implements SocialSignIn {
  const UnconfiguredSocialSignIn();

  @override
  Future<String?> fetchIdToken(SocialProvider provider) {
    throw const SocialSignInException('로그인 설정이 아직 완료되지 않았어요.');
  }
}

final socialSignInProvider = Provider<SocialSignIn>(
  (ref) => const UnconfiguredSocialSignIn(),
);
