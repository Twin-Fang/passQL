import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/models/question/choice_set_summary.dart';
import 'package:passql_app/data/models/question/question_detail.dart';
import 'package:passql_app/data/models/question/sse_event.dart';
import 'package:passql_app/data/sources/api_providers.dart';
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

/// 가짜 SSE 를 붙인 컨테이너에서 문제 1건의 상호작용 notifier 를 꺼낸다(autoDispose 유지용 구독 포함).
QuestionInteractionNotifier _notifierFor(List<SseEvent> events) {
  final container = ProviderContainer(
    overrides: [
      sseQuestionClientProvider.overrideWithValue(_FakeSse(events)),
      questionApiProvider.overrideWithValue(_NoApi()),
    ],
  );
  addTearDown(container.dispose);
  container.listen(questionInteractionProvider('q-1'), (_, _) {});
  return container.read(questionInteractionProvider('q-1').notifier);
}

void main() {
  test('complete/error 없이 스트림이 끝나면 무한 로딩 대신 재시도 가능한 오류로 바꾼다', () async {
    final notifier = _notifierFor([SseStatusEvent('생성 중')]);

    await notifier.startSseGeneration();
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.isGeneratingChoices, isFalse);
    expect(notifier.state.sseError?.isRetryable, isTrue);
    expect(notifier.state.sseError?.code, 'STREAM_CLOSED');
  });

  test('complete 이벤트로 정상 종료되면 오류로 바꾸지 않는다', () async {
    final notifier = _notifierFor([SseCompleteEvent(const [], 'cs-1')]);

    await notifier.startSseGeneration();
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state.sseError, isNull);
    expect(notifier.state.activeChoiceSetId, 'cs-1');
  });

  test('바로 쓸 수 있는(OK) 선택지 세트가 있으면 SSE 생성 없이 재사용한다', () async {
    final notifier = _notifierFor([SseStatusEvent('생성되면 안 됨')]);

    notifier.initializeChoices(
      const QuestionDetail(
        questionUuid: 'q-1',
        stem: '지문',
        choiceSets: [
          ChoiceSetSummary(
            choiceSetUuid: 'cs-fail',
            source: 'AI',
            status: 'FAILED',
          ),
          ChoiceSetSummary(
            choiceSetUuid: 'cs-ok',
            source: 'AI',
            status: 'OK',
            items: [ChoiceItem(key: 'A', kind: 'TEXT', body: '보기')],
          ),
        ],
      ),
    );

    expect(notifier.state.activeChoiceSetId, 'cs-ok');
    expect(notifier.state.isGeneratingChoices, isFalse);
  });
}
