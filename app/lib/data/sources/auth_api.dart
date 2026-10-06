import 'package:dio/dio.dart';

import '../../core/auth/auth_session.dart';

/// 인증 엔드포인트(`/auth/*`) 호출 전용 클라이언트.
///
/// 인증 인터셉터가 붙지 않은 Dio 를 받아야 한다.
/// 재발급 요청이 다시 인터셉터를 타면 401 → 재발급이 무한 반복되기 때문이다.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  /// 소셜 idToken 으로 로그인. 신규 회원이면 서버가 자동 가입시킨다.
  Future<LoginResult> login({
    required SocialProvider provider,
    required String idToken,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'authProvider': provider.serverValue, 'idToken': idToken},
    );
    return LoginResult.fromJson(res.data!);
  }

  /// refreshToken 으로 토큰 재발급.
  Future<ReissueResult> reissue(String refreshToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/reissue',
      data: {'refreshToken': refreshToken},
    );
    return ReissueResult.fromJson(res.data!);
  }

  /// 서버 측 refreshToken 폐기.
  Future<void> logout(String refreshToken) async {
    await _dio.post<void>('/auth/logout', data: {'refreshToken': refreshToken});
  }
}
