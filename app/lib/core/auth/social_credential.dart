import 'auth_session.dart';

/// 소셜 제공자에서 받은 서버 로그인 재료 2종: 토큰(`/auth/login`), 인가 코드(`/auth/login/code`)
sealed class SocialCredential {
  const SocialCredential(this.provider);

  final SocialProvider provider;
}

/// 토큰 로그인 재료. Google·Apple: Firebase ID 토큰, 카카오·네이버: SDK 액세스 토큰
class SocialTokenCredential extends SocialCredential {
  const SocialTokenCredential({
    required SocialProvider provider,
    required this.token,
  }) : super(provider);

  /// 서버 LoginRequest.idToken 에 그대로 전달하는 값
  final String token;
}

/// 인가 코드 로그인 재료 (GitHub). 서버가 client secret 으로 코드 교환
class SocialAuthorizationCodeCredential extends SocialCredential {
  const SocialAuthorizationCodeCredential({
    required SocialProvider provider,
    required this.code,
    required this.redirectUri,
    required this.state,
    required this.codeVerifier,
  }) : super(provider);

  final String code;

  /// 인가 요청에 쓴 콜백 주소 (서버 허용 목록과 같아야 교환 성공)
  final String redirectUri;

  /// 인가 요청에 실어 보낸 일회용 값 (앱에서 콜백과 대조 완료)
  final String state;

  /// PKCE 원문 (인가 요청에는 S256 해시만 전송, 서버가 코드 교환 때 원문 전달)
  final String codeVerifier;
}
