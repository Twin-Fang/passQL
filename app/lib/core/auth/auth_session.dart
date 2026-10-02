/// 소셜 로그인 제공자. 서버 `authProvider` 값과 1:1 대응.
enum SocialProvider {
  google('GOOGLE'),
  apple('APPLE');

  const SocialProvider(this.serverValue);

  /// 서버 LoginRequest.authProvider 에 그대로 전달하는 값.
  final String serverValue;
}

/// 로그인된 회원 세션.
///
/// 토큰 두 개와 서버가 내려준 회원 식별 정보를 한 묶음으로 다룬다.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.memberUuid,
    required this.nickname,
  });

  final String accessToken;
  final String refreshToken;
  final String memberUuid;
  final String nickname;

  /// 재발급 시에는 토큰만 바뀌므로 나머지 정보는 유지한다.
  AuthSession withTokens({
    required String accessToken,
    required String refreshToken,
  }) => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    memberUuid: memberUuid,
    nickname: nickname,
  );
}

/// `POST /auth/login` 응답.
class LoginResult {
  const LoginResult({required this.session, required this.isNewMember});

  final AuthSession session;
  final bool isNewMember;

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
    session: AuthSession(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      memberUuid: json['memberUuid'] as String,
      nickname: json['nickname'] as String,
    ),
    isNewMember: json['isNewMember'] as bool? ?? false,
  );
}

/// `POST /auth/reissue` 응답. 재발급 시 refreshToken 도 함께 회전한다.
class ReissueResult {
  const ReissueResult({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory ReissueResult.fromJson(Map<String, dynamic> json) => ReissueResult(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}
