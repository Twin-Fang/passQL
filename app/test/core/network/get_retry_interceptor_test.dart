import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/network/get_retry_interceptor.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';

void main() {
  /// 처음 [failureCount] 번은 연결 실패, 그 뒤 200 을 주는 Dio
  (Dio, FakeHttpClientAdapter) buildDio({required int failureCount}) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final adapter = FakeHttpClientAdapter((options) {
      if (failureCount-- > 0) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      return jsonResponseBody(200, const {'ok': true});
    });
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      GetRetryInterceptor(retryDio: dio, retryDelay: Duration.zero),
    );
    return (dio, adapter);
  }

  test('GET 이 연결 실패하면 한 번 다시 보내 성공을 돌려준다', () async {
    final (dio, adapter) = buildDio(failureCount: 1);
    final response = await dio.get<dynamic>('/progress');
    expect(response.statusCode, 200);
    expect(adapter.requests, hasLength(2));
  });

  test('재시도도 실패하면 더 보내지 않고 오류를 전달한다', () async {
    final (dio, adapter) = buildDio(failureCount: 5);
    await expectLater(
      dio.get<dynamic>('/progress'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, hasLength(2));
  });

  test('POST 는 중복 실행 위험이 있어 재시도하지 않는다', () async {
    final (dio, adapter) = buildDio(failureCount: 1);
    await expectLater(
      dio.post<dynamic>('/submit'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests, hasLength(1));
  });
}
