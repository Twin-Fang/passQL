import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 조회(GET) 요청 연결 실패 시 1회 재시도: 순간 끊김(엘리베이터·망 전환)으로 화면이 오류가 되지 않게
/// 대상 오류 2개: 연결 실패, 연결 시간 초과 (응답 대기 초과는 대기만 두 배가 되어 제외)
/// 그 외 메서드(POST 제출 등)는 중복 실행 위험이 있어 재시도하지 않음
class GetRetryInterceptor extends Interceptor {
  GetRetryInterceptor({
    required this.retryDio,
    this.retryDelay = _defaultRetryDelay,
  });

  /// 재시도에 쓸 Dio (같은 인터셉터를 다시 타서 토큰도 다시 붙음)
  final Dio retryDio;

  /// 재시도 전 대기 (망이 돌아올 틈)
  final Duration retryDelay;

  static const _defaultRetryDelay = Duration(milliseconds: 400);

  // requestOptions.extra: 재시도한 요청 표시 (두 번째 실패는 그대로 전달)
  static const _retriedExtraKey = 'isGetRetried';

  static const _retryableErrorTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
  };

  /// 재시도 대상인지: GET + 연결 계열 오류 + 아직 재시도 안 함
  @visibleForTesting
  static bool isRetryable(DioException error) =>
      error.requestOptions.method.toUpperCase() == 'GET' &&
      _retryableErrorTypes.contains(error.type) &&
      error.requestOptions.extra[_retriedExtraKey] != true;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!isRetryable(err)) return handler.next(err);

    final retryOptions = err.requestOptions..extra[_retriedExtraKey] = true;
    debugPrint(
      '[network retry] GET ${retryOptions.path} after ${err.type.name}',
    );
    await Future<void>.delayed(retryDelay);
    try {
      final response = await retryDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
