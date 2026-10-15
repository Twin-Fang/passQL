import 'package:dio/dio.dart';

import '../error/app_exception.dart';
import '../error/error_code.dart';

/// 이용 제한(403 MEMBER_SUSPENDED) 응답 감지 > [onMemberSuspended] 로 안내 문구 전달
/// 오류 자체는 그대로 다음으로 넘겨 호출 측 처리(토스트·오류 화면)는 유지
class MemberSuspensionInterceptor extends Interceptor {
  MemberSuspensionInterceptor({required this.onMemberSuspended});

  final void Function(String noticeMessage) onMemberSuspended;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final error = err.asAppException;
    if (error.code == ErrorCode.memberSuspended) {
      onMemberSuspended(error.message);
    }
    handler.next(err);
  }
}
