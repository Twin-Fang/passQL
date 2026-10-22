import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 디버그 요청·응답 로그: 민감 경로는 요청 본문 제외, 그 외 전체 본문
/// 요청 헤더는 항상 제외 (Bearer 토큰)
class DebugLogInterceptor extends Interceptor {
  DebugLogInterceptor({void Function(Object object) logPrint = _printDioLog})
    : _fullLogInterceptor = _buildLogInterceptor(
        isRequestBodyLogged: true,
        logPrint: logPrint,
      ),
      _requestBodyHiddenLogInterceptor = _buildLogInterceptor(
        isRequestBodyLogged: false,
        logPrint: logPrint,
      );

  // 요청 본문을 로그에 남기지 않는 경로 (결제 확인 본문 = Play 구매 토큰)
  static const List<String> _requestBodyHiddenPathSegments = ['/billing/'];

  final LogInterceptor _fullLogInterceptor;
  final LogInterceptor _requestBodyHiddenLogInterceptor;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) =>
      _logInterceptorFor(options).onRequest(options, handler);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) =>
      _logInterceptorFor(response.requestOptions).onResponse(response, handler);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) =>
      _logInterceptorFor(err.requestOptions).onError(err, handler);

  LogInterceptor _logInterceptorFor(RequestOptions options) =>
      _isRequestBodyHidden(options)
      ? _requestBodyHiddenLogInterceptor
      : _fullLogInterceptor;

  static bool _isRequestBodyHidden(RequestOptions options) {
    final path = options.uri.path;
    return _requestBodyHiddenPathSegments.any(path.contains);
  }

  static LogInterceptor _buildLogInterceptor({
    required bool isRequestBodyLogged,
    required void Function(Object object) logPrint,
  }) => LogInterceptor(
    requestHeader: false,
    requestBody: isRequestBodyLogged,
    responseHeader: false,
    responseBody: true,
    error: true,
    logPrint: logPrint,
  );

  static void _printDioLog(Object object) => debugPrint('[DIO] $object');
}
