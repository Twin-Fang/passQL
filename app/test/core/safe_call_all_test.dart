import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/network/safe_call.dart';

Future<Object?> _fail() => Future.error(
  DioException(
    requestOptions: RequestOptions(path: '/x'),
    type: DioExceptionType.connectionError,
  ),
);

void main() {
  test('일부만 실패하면 실패한 자리만 null 로 채운다', () async {
    final r = await safeCallAll([Future.value(1), _fail(), Future.value('a')]);
    expect(r, [1, null, 'a']);
  });

  test('전부 실패하면(서버 장애) 오류를 던져 오류 화면이 보이게 한다', () async {
    expect(() => safeCallAll([_fail(), _fail()]), throwsA(isA<AppException>()));
  });

  test('핵심 호출이 실패하면 나머지가 성공해도 오류를 던진다', () async {
    expect(
      () => safeCallAll([_fail(), Future.value(1)], required: {0}),
      throwsA(isA<AppException>()),
    );
  });
}
