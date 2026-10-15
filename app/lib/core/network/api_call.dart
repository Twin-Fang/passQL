import 'package:dio/dio.dart';

import '../error/app_exception.dart';

/// API 호출 1건 대기: Dio 오류 > [AppException] 변환 후 던짐 (그 외 오류는 그대로)
/// 실패를 화면 문구로 보여 줘야 하는 호출(제출·변경·탈퇴 등)이 공통으로 사용
Future<T> callApiThrowingAppException<T>(Future<T> apiCall) async {
  try {
    return await apiCall;
  } on DioException catch (exception) {
    throw exception.asAppException;
  }
}
