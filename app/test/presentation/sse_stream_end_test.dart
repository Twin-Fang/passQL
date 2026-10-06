import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/sse_event.dart';
import 'package:passql_app/data/sources/question_api.dart';
import 'package:passql_app/data/sources/sse_question_client.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';

/// 이벤트 목록을 내보내고 끝나는 가짜 SSE 클라이언트.
class _FakeSse extends SseQuestionClient {
  _FakeSse(this.events) : super(Dio());

  final List<SseEvent> events;

  @override
  Stream<SseEvent> generateChoices({required String questionUuid}) =>
      Stream.fromIterable(events);
}

class _NoApi implements QuestionApiClient {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

QuestionInteractionNotifier _notifier(List<SseEvent> events) =>
    QuestionInteractionNotifier(
      questionUuid: 'q-1',
      questionApi: _NoApi(),
      sseClient: _FakeSse(events),
    );

void main() {
  test('complete/error 없이 스트림이 끝나면 무한 로딩 대신 재시도 가능한 오류로 바꾼다', () async {
    final n = _notifier([SseStatusEvent('생성 중')]);

    await n.startSseGeneration();
    await Future<void>.delayed(Duration.zero);

    expect(n.state.isGeneratingChoices, isFalse);
    expect(n.state.sseError?.retryable, isTrue);
    expect(n.state.sseError?.code, 'STREAM_CLOSED');
  });

  test('complete 이벤트로 정상 종료되면 오류로 바꾸지 않는다', () async {
    final n = _notifier([SseCompleteEvent(const [], 'cs-1')]);

    await n.startSseGeneration();
    await Future<void>.delayed(Duration.zero);

    expect(n.state.sseError, isNull);
    expect(n.state.activeChoiceSetId, 'cs-1');
  });
}
