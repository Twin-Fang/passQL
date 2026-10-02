import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/home/recommendations_request.dart';
import 'package:passql_app/data/models/question/submit_request.dart';
import 'package:passql_app/data/sources/member_api.dart';
import 'package:passql_app/data/sources/progress_api.dart';
import 'package:passql_app/data/sources/question_api.dart';

/// 서버 계약(요청 형태)을 고정하는 테스트.
/// 응답 파싱이 아니라 "어떤 요청이 나가는가"만 본다.
class _Capture implements HttpClientAdapter {
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode({}),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Capture capture;
  late Dio dio;

  setUp(() {
    capture = _Capture();
    dio = Dio(BaseOptions(baseUrl: 'https://test'))..httpClientAdapter = capture;
  });

  // 응답 모델 파싱 실패는 이 테스트의 관심사가 아니다.
  Future<void> ignoreParse(Future<dynamic> call) async {
    try {
      await call;
    } catch (_) {}
  }

  test('추천 문제는 POST 본문으로 size 와 제외 목록을 보낸다', () async {
    await ignoreParse(
      QuestionApiClient(dio).getRecommendations(
        const RecommendationsRequest(size: 3, excludeQuestionUuids: ['a', 'b']),
      ),
    );

    expect(capture.last!.method, 'POST');
    expect(capture.last!.path, '/questions/recommendations');
    expect(capture.last!.data, {
      'size': 3,
      'excludeQuestionUuids': ['a', 'b'],
    });
    // 제외 목록이 쿼리스트링으로 쌓이면 헤더 한도(8KB)를 넘는다.
    expect(capture.last!.queryParameters, isEmpty);
  });

  test('답안 제출은 회원 헤더 없이 sessionUuid 를 본문에 싣는다', () async {
    await ignoreParse(
      QuestionApiClient(dio).submitAnswer(
        'q-1',
        const SubmitRequest(choiceSetId: 'cs', selectedChoiceKey: 'A', sessionUuid: 's-1'),
      ),
    );

    expect(capture.last!.path, '/questions/q-1/submit');
    expect(capture.last!.headers.keys, isNot(contains('X-Member-UUID')));
    // 실제 전송 형태(JSON)로 확인한다.
    final wire = jsonDecode(jsonEncode(capture.last!.data)) as Map;
    expect(wire['sessionUuid'], 's-1');
    expect(wire['selectedChoiceKey'], 'A');
    expect(wire['choiceSetId'], 'cs');
  });

  test('회원 식별용 memberUuid 를 쿼리로 보내지 않는다', () async {
    await ignoreParse(ProgressApiClient(dio).getProgress());
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);

    await ignoreParse(ProgressApiClient(dio).getHeatmap(null, null));
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);

    await ignoreParse(MemberApiClient(dio).getMe());
    expect(capture.last!.queryParameters.containsKey('memberUuid'), isFalse);
  });

  test('AI 코멘트는 연습 세션 단위로 조회할 수 있다', () async {
    await ignoreParse(ProgressApiClient(dio).getAiComment(sessionUuid: 's-9'));
    expect(capture.last!.path, '/progress/ai-comment');
    expect(capture.last!.queryParameters['sessionUuid'], 's-9');
  });
}
