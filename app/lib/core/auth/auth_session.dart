/// 소셜 로그인 제공자. 서버 `authProvider` 값과 1:1 대응.
enum SocialProvider {
  google('GOOGLE'),
  apple('APPLE'),
  // 카카오·네이버: SDK 액세스 토큰을 idToken 자리로 전달, GitHub: 인가 코드 교환 (#509)
  kakao('KAKAO'),
  naver('NAVER'),
  github('GITHUB');

  const SocialProvider(this.serverValue);

  /// 서버 LoginRequest.authProvider 에 그대로 전달하는 값.
  final String serverValue;

  /// 서버 authProvider 값 > 제공자 (모르는 값·null > null)
  static SocialProvider? fromServerValue(String? serverValue) => values
      .where((provider) => provider.serverValue == serverValue)
      .firstOrNull;
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
    this.authProvider,
  });

  final String accessToken;
  final String refreshToken;
  final String memberUuid;
  final String nickname;

  /// 로그인한 제공자 (탈퇴 시 연결 해제 분기 기준). 이전 버전에서 저장한 세션은 null
  final SocialProvider? authProvider;

  /// 닉네임만 바뀌는 경우(변경, 재생성)에는 나머지 정보는 유지한다.
  AuthSession withNickname(String nickname) => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    memberUuid: memberUuid,
    nickname: nickname,
    authProvider: authProvider,
  );

  /// 로그인 요청에 쓴 제공자 기록 (로그인 응답에는 제공자가 없음)
  AuthSession withAuthProvider(SocialProvider authProvider) => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    memberUuid: memberUuid,
    nickname: nickname,
    authProvider: authProvider,
  );

  /// 재발급 시에는 토큰만 바뀌므로 나머지 정보는 유지한다.
  AuthSession withTokens({
    required String accessToken,
    required String refreshToken,
  }) => AuthSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    memberUuid: memberUuid,
    nickname: nickname,
    authProvider: authProvider,
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
