import 'dart:convert';

import 'package:dio/dio.dart';

/// 실제 서버 대신 요청을 기록하고 [respond] 가 정한 응답을 돌려주는 Dio 어댑터
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this.respond);

  /// 기본: 모든 요청에 200 + 빈 JSON (요청 형태만 볼 때)
  FakeHttpClientAdapter.emptyJson() : respond = _emptyJsonResponse;

  final ResponseBody Function(RequestOptions options) respond;

  /// 들어온 요청 순서대로
  final List<RequestOptions> requests = [];

  RequestOptions get lastRequest => requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody _emptyJsonResponse(RequestOptions _) =>
      jsonResponseBody(200, const {});
}

/// JSON 본문 응답 (Content-Type: application/json)
ResponseBody jsonResponseBody(int statusCode, Map<String, dynamic> body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
