import 'auth_session.dart';

/// 토큰 재발급 포트: AuthInterceptor 의 401 재발급에 사용
/// 구현은 data 계층(AuthApi) > core 는 data 를 모름
abstract interface class TokenReissueClient {
  /// refreshToken > 새 access/refresh 토큰 (거부되면 DioException)
  Future<ReissueResult> reissue(String refreshToken);
}
