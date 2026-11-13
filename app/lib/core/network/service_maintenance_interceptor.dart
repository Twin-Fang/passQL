import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/error_code.dart';

/// 점검 중(SERVICE_UNDER_MAINTENANCE) 응답 감지 > [onServiceUnderMaintenance] 호출
/// 오류 자체는 그대로 다음으로 넘겨 호출 측 처리(토스트·오류 화면)는 유지
class ServiceMaintenanceInterceptor extends Interceptor {
  ServiceMaintenanceInterceptor({required this.onServiceUnderMaintenance});

  final void Function() onServiceUnderMaintenance;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.asAppException.code == ErrorCode.serviceUnderMaintenance) {
      onServiceUnderMaintenance();
    }
    handler.next(err);
  }
}
