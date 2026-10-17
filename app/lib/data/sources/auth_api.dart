import 'package:dio/dio.dart';

import '../../core/auth/auth_session.dart';
import '../../core/auth/token_reissue_client.dart';

/// 인증 엔드포인트(`/auth/*`) 호출 전용 클라이언트.
///
/// 인증 인터셉터가 붙지 않은 Dio 를 받아야 한다.
/// 재발급 요청이 다시 인터셉터를 타면 401 → 재발급이 무한 반복되기 때문이다.
class AuthApi implements TokenReissueClient {
  AuthApi(this._dio);

  final Dio _dio;

  /// 소셜 idToken 으로 로그인. 신규 회원이면 서버가 자동 가입시킨다.
  Future<LoginResult> login({
    required SocialProvider provider,
    required String idToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'authProvider': provider.serverValue, 'idToken': idToken},
    );
    return LoginResult.fromJson(response.data!);
  }

  /// 인가 코드로 로그인 (GitHub). 서버가 client secret 으로 코드 교환 > 신규 회원이면 자동 가입
  Future<LoginResult> loginWithAuthorizationCode({
    required SocialProvider provider,
    required String code,
    required String redirectUri,
    required String state,
    required String codeVerifier,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login/code',
      data: {
        'authProvider': provider.serverValue,
        'code': code,
        'redirectUri': redirectUri,
        'state': state,
        // PKCE 원문: 서버가 토큰 교환 요청의 code_verifier 로 전달
        'codeVerifier': codeVerifier,
      },
    );
    return LoginResult.fromJson(response.data!);
  }

  /// refreshToken 으로 토큰 재발급.
  @override
  Future<ReissueResult> reissue(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/reissue',
      data: {'refreshToken': refreshToken},
    );
    return ReissueResult.fromJson(response.data!);
  }

  /// 서버 측 refreshToken 폐기.
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
