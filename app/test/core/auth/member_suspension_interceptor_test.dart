import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/member_suspension_interceptor.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';

/// [statusCode]·[body] 로 응답하는 Dio 에 인터셉터를 붙이고, 알림받은 안내 문구를 모은다
Future<List<String>> _requestAndCollectNotices(
  int statusCode,
  Map<String, dynamic> body,
) async {
  final notices = <String>[];
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'))
    ..httpClientAdapter = FakeHttpClientAdapter(
      (_) => jsonResponseBody(statusCode, body),
    )
    ..interceptors.add(
      MemberSuspensionInterceptor(onMemberSuspended: notices.add),
    );
  // 오류는 호출 측으로 그대로 전달
  await expectLater(
    dio.get<dynamic>('/members/me'),
    throwsA(isA<DioException>()),
  );
  return notices;
}

void main() {
  test('403 MEMBER_SUSPENDED 면 서버 안내 문구로 이용 제한을 알린다', () async {
    final notices = await _requestAndCollectNotices(403, {
      'errorCode': 'MEMBER_SUSPENDED',
      'message': '운영 정책 위반으로 이용이 제한되었어요.',
    });

    expect(notices, ['운영 정책 위반으로 이용이 제한되었어요.']);
  });

  test('다른 403(ACCESS_DENIED)은 이용 제한으로 보지 않는다', () async {
    final notices = await _requestAndCollectNotices(403, {
      'errorCode': 'ACCESS_DENIED',
      'message': '접근 권한이 없어요.',
    });

    expect(notices, isEmpty);
  });
}
