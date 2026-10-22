import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/data/models/question/sse_event.dart';
import 'package:passql_app/data/sources/sse_question_client.dart';

import '../helpers/fakes/fake_http_client_adapter.dart';

/// 가짜 어댑터를 붙인 SSE 클라이언트로 선택지 생성 첫 이벤트 받기
Future<SseEvent> _firstChoiceEvent(FakeHttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'))
    ..httpClientAdapter = adapter;
  return SseQuestionClient(dio).generateChoices(questionUuid: 'q-1').first;
}

void main() {
  test('연결 단계 서버 거부(403 JSON) > 서버 errorCode, 재시도 불가, 공통 변환 결과 전달', () async {
    final adapter = FakeHttpClientAdapter(
      (_) => jsonResponseBody(403, {
        'errorCode': 'FREE_DAILY_LIMIT_REACHED',
        'message': '오늘 무료 10문제를 다 풀었어요',
      }),
    );

    final event = await _firstChoiceEvent(adapter) as SseErrorEvent;

    expect(event.code, 'FREE_DAILY_LIMIT_REACHED');
    expect(event.isRetryable, isFalse);
    expect(event.connectFailure?.code, ErrorCode.freeDailyLimitReached);
    // JSON 을 받겠다고 해야 서버가 오류 본문을 실어 보냄 (event-stream 만이면 500)
    expect(adapter.lastRequest.headers['Accept'], contains('application/json'));
  });

  test('서버 응답 없는 연결 실패 > CONNECT_FAILED 재시도 가능', () async {
    final adapter = FakeHttpClientAdapter(
      (options) => throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      ),
    );

    final event = await _firstChoiceEvent(adapter) as SseErrorEvent;

    expect(event.code, connectFailedCode);
    expect(event.isRetryable, isTrue);
  });
}
