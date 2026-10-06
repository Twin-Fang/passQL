import 'dart:async';

import 'package:dio/dio.dart';

import '../../data/sources/auth_api.dart';
import 'token_store.dart';

/// 모든 API 요청에 Bearer 토큰을 붙이고, 401 이면 토큰을 재발급해 한 번 재시도한다.
///
/// - `/auth/*` 요청은 토큰 없이 호출되므로 건드리지 않는다.
/// - 동시에 여러 요청이 401 을 받아도 재발급은 한 번만 수행하고 결과를 공유한다.
///   (refreshToken 이 회전되므로 중복 호출하면 두 번째가 실패해 로그아웃될 수 있다.)
/// - 재발급까지 실패하면 세션을 지우고 [onSessionExpired] 로 로그인 화면 전환을 알린다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStore,
    required this.authApi,
    required this.retryDio,
    required this.onSessionExpired,
  });

  final TokenStore tokenStore;
  final AuthApi authApi;

  /// 재시도에 쓰는 Dio. 원본 요청과 같은 인스턴스(인터셉터 포함)를 넘긴다.
  final Dio retryDio;
  final void Function() onSessionExpired;

  static const _kRetried = 'auth_retried';

  /// 진행 중인 재발급. 성공 시 새 accessToken, 실패 시 null.
  Future<String?>? _refreshing;

  bool _isAuthPath(RequestOptions options) =>
      options.path.startsWith('/auth/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options)) {
      final session = await tokenStore.read();
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;

    // 401 이 아니거나, 인증 경로이거나, 이미 한 번 재시도한 요청이면 그대로 전달한다.
    if (!isUnauthorized || _isAuthPath(options) || options.extra[_kRetried] == true) {
      return handler.next(err);
    }

    // 이 요청이 나간 뒤 다른 요청이 이미 토큰을 갱신했다면(보낸 토큰 != 현재 토큰),
    // 재발급을 또 하지 않고 현재 토큰으로 바로 재시도한다. 불필요한 토큰 회전을 막는다.
    final current = await tokenStore.read();
    final sent = options.headers['Authorization'];
    final newAccessToken =
        (current != null && sent != null && sent != 'Bearer ${current.accessToken}')
        ? current.accessToken
        : await _refreshOnce();
    if (newAccessToken == null) {
      return handler.next(err);
    }

    try {
      options.extra[_kRetried] = true;
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await retryDio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// 재발급을 한 번만 수행하고, 동시에 대기 중인 요청들이 같은 결과를 받게 한다.
  Future<String?> _refreshOnce() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final session = await tokenStore.read();
    if (session == null) return null;

    try {
      final result = await authApi.reissue(session.refreshToken);
      await tokenStore.updateTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      return result.accessToken;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 서버가 refreshToken 을 거부했을 때만(401/403) 세션을 지운다 → 다시 로그인해야 한다.
      // 네트워크 끊김, 타임아웃, 5xx 는 일시적일 수 있으므로 로그인을 유지하고 원래 오류만 전달한다.
      if (status == 401 || status == 403) {
        await tokenStore.clear();
        onSessionExpired();
      }
      return null;
    }
  }
}
