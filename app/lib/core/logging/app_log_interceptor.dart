import 'package:dio/dio.dart';

import 'app_logger.dart';

/// API 호출 로그 (전 빌드): "{METHOD} {path} {status} {elapsedMilliseconds}ms" (실패 시 서버 errorCode 추가)
/// 헤더·본문·쿼리 기록 금지 (토큰·개인정보 방지)
class AppLogInterceptor extends Interceptor {
  // RequestOptions.extra: 요청 시작 시각
  static const String _startedAtExtraKey = 'appLogStartedAt';
  static const String _logTag = 'api';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtExtraKey] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.info(
      _logTag,
      _describe(response.requestOptions, response.statusCode),
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusText = err.response?.statusCode ?? err.type.name;
    final data = err.response?.data;
    final serverErrorCode = data is Map ? data['errorCode'] : null;
    final suffix = serverErrorCode is String ? ' $serverErrorCode' : '';
    AppLogger.warn(
      _logTag,
      '${_describe(err.requestOptions, statusText)}$suffix',
    );
    handler.next(err);
  }

  /// "{METHOD} {path} {status} {elapsed}ms" (path 는 쿼리 제외)
  String _describe(RequestOptions options, Object? status) {
    final startedAt = options.extra[_startedAtExtraKey];
    final elapsedMilliseconds = startedAt is DateTime
        ? DateTime.now().difference(startedAt).inMilliseconds
        : 0;
    return '${options.method} ${options.uri.path} $status ${elapsedMilliseconds}ms';
  }
}
