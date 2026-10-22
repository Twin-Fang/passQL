import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/error_code.dart';

/// 프로 접근 거부(403 PRO_REQUIRED·FREE_DAILY_LIMIT_REACHED) 응답 감지 > [onProAccessDenied]
/// 공정 사용 한도(429)는 프로 사용자 몫이라 제외, 오류 자체는 그대로 넘겨 호출 측 처리 유지
class ProAccessDeniedInterceptor extends Interceptor {
  ProAccessDeniedInterceptor({required this.onProAccessDenied});

  final void Function() onProAccessDenied;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final errorCode = err.asAppException.code;
    if (errorCode == ErrorCode.proRequired ||
        errorCode == ErrorCode.freeDailyLimitReached) {
      onProAccessDenied();
    }
    handler.next(err);
  }
}
