import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/question/choice_item.dart';
import '../models/question/sse_event.dart';

/// POST /questions/{questionUuid}/generate-choices SSE 스트리밍 클라이언트.
///
/// Retrofit은 SSE를 지원하지 않으므로 Dio ResponseType.stream으로 직접 처리.
class SseQuestionClient {
  final Dio _dio;

  SseQuestionClient(this._dio);

  /// SSE 스트림 반환. 이벤트: SseStatusEvent, SseCompleteEvent, SseErrorEvent.
  /// 에러 발생 시 스트림에 SseErrorEvent yield 후 종료.
  Stream<SseEvent> generateChoices({required String questionUuid}) async* {
    Response<ResponseBody> response;
    try {
      response = await _dio.post<ResponseBody>(
        '/questions/$questionUuid/generate-choices',
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );
    } catch (e) {
      yield SseErrorEvent('CONNECT_FAILED', true);
      return;
    }

    // SSE 프로토콜: "event: <type>" 줄로 이벤트 타입을 지정하고,
    // "data: <json>" 줄에 페이로드, 빈 줄로 이벤트 경계를 구분.
    final lineStream = response.data!.stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    // 줄 단위 스트림을 SSE 규격대로 이벤트로 바꾼다. (파싱 규칙은 [parseSseLines] 참고)
    await for (final data in parseSseLines(lineStream)) {
      final event = _parse(data.event, data.data);
      if (event != null) yield event;
    }
  }

  /// SSE [eventType]과 raw JSON 문자열로 이벤트 객체 생성.
  /// eventType이 없으면 json['type'] 필드로 폴백.
  SseEvent? _parse(String eventType, String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      // event: 필드 우선, 없으면 json body의 type 필드 폴백
      final type = eventType.isNotEmpty ? eventType : json['type'] as String?;
      switch (type) {
        case 'status':
          return SseStatusEvent(json['message'] as String? ?? '처리 중...');
        case 'complete':
          final rawChoices = json['choices'] as List<dynamic>? ?? [];
          final choices = rawChoices
              .map((e) => ChoiceItem.fromJson(e as Map<String, dynamic>))
              .toList();
          return SseCompleteEvent(
            choices,
            json['choiceSetId'] as String? ?? '',
          );
        case 'error':
          return SseErrorEvent(
            json['code'] as String? ?? 'UNKNOWN',
            json['retryable'] as bool? ?? false,
          );
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}

/// SSE 이벤트 한 건(원문). [event] 가 비어 있으면 이벤트 이름이 없는 것이다.
class SseRawEvent {
  const SseRawEvent(this.event, this.data);

  final String event;
  final String data;
}

/// 줄 단위 입력을 SSE 규격(RFC)대로 해석한다.
///
/// - `event:name` 과 `event: name` 을 모두 받는다. Spring `SseEmitter` 는 콜론 뒤에 공백을 넣지 않고,
///   브라우저 표준은 공백이 있어도 되므로 한 칸만 제거한다. (공백을 강제하면 이벤트를 하나도 못 읽는다)
/// - 여러 줄의 `data:` 는 줄바꿈으로 이어 붙인다.
/// - `:` 로 시작하는 줄(주석, keep-alive)과 모르는 필드는 무시한다.
/// - 빈 줄이 이벤트 경계다. 스트림이 빈 줄 없이 끝나도 남은 data 를 내보낸다.
Stream<SseRawEvent> parseSseLines(Stream<String> lines) async* {
  var event = '';
  final data = <String>[];

  await for (final raw in lines) {
    // CRLF 로 온 경우를 대비해 끝의 \r 을 제거한다.
    final line = raw.endsWith('\r') ? raw.substring(0, raw.length - 1) : raw;

    if (line.isEmpty) {
      if (data.isNotEmpty) yield SseRawEvent(event, data.join('\n'));
      event = '';
      data.clear();
      continue;
    }
    if (line.startsWith(':')) continue;

    final colon = line.indexOf(':');
    final field = colon == -1 ? line : line.substring(0, colon);
    var value = colon == -1 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);

    switch (field) {
      case 'event':
        event = value.trim();
      case 'data':
        data.add(value);
    }
  }
  if (data.isNotEmpty) yield SseRawEvent(event, data.join('\n'));
}
