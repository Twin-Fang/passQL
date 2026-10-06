import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/sources/sse_question_client.dart';

Future<List<SseRawEvent>> parse(List<String> lines) =>
    parseSseLines(Stream.fromIterable(lines)).toList();

void main() {
  test('Spring SseEmitter 형식(콜론 뒤 공백 없음)을 읽는다 — 운영 서버가 실제로 보내는 형태', () async {
    final events = await parse(['event:status', 'data:{"phase":"generating"}', '']);
    expect(events, hasLength(1));
    expect(events.single.event, 'status');
    expect(events.single.data, '{"phase":"generating"}');
  });

  test('브라우저 표준 형식(콜론 뒤 공백 한 칸)도 읽는다', () async {
    final events = await parse(['event: complete', 'data: {"a":1}', '']);
    expect(events.single.event, 'complete');
    expect(events.single.data, '{"a":1}');
  });

  test('값 앞의 공백은 한 칸만 제거한다', () async {
    final events = await parse(['data:  두 칸', '']);
    expect(events.single.data, ' 두 칸');
  });

  test('이벤트가 여러 개여도 경계마다 나눠 내보낸다', () async {
    final events = await parse([
      'event:status', 'data:{"m":1}', '',
      'event:complete', 'data:{"m":2}', '',
    ]);
    expect(events.map((e) => e.event), ['status', 'complete']);
  });

  test('여러 줄 data 는 줄바꿈으로 이어 붙인다', () async {
    final events = await parse(['data:첫째', 'data:둘째', '']);
    expect(events.single.data, '첫째\n둘째');
  });

  test('주석과 keep-alive(:), 모르는 필드는 무시한다', () async {
    final events = await parse([': keep-alive', 'id:7', 'retry:1000', 'event:status', 'data:x', '']);
    expect(events, hasLength(1));
    expect(events.single.event, 'status');
  });

  test('CRLF 줄바꿈으로 와도 읽는다', () async {
    final events = await parse(['event:status\r', 'data:{"a":1}\r', '\r']);
    expect(events.single.event, 'status');
    expect(events.single.data, '{"a":1}');
  });

  test('빈 줄 없이 스트림이 끝나도 남은 data 를 내보낸다', () async {
    final events = await parse(['event:complete', 'data:{"a":1}']);
    expect(events.single.event, 'complete');
  });

  test('data 없이 이벤트 이름만 있으면 내보내지 않는다', () async {
    expect(await parse(['event:status', '']), isEmpty);
  });
}
