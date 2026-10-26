import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/sources/question_api.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/widgets/question/execute_failure_card.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';

const _sql = 'SELECT 1 FROM DUAL';

/// [respond] 로 응답을 정하는 가짜 서버를 붙여 문제 1건의 notifier 를 꺼낸다 (autoDispose 유지용 구독 포함)
QuestionInteractionNotifier _notifierWith(
  ResponseBody Function(RequestOptions options) respond,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'))
    ..httpClientAdapter = FakeHttpClientAdapter(respond);
  final container = ProviderContainer(
    overrides: [questionApiProvider.overrideWithValue(QuestionApiClient(dio))],
  );
  addTearDown(container.dispose);
  container.listen(questionInteractionProvider('q-1'), (_, _) {});
  return container.read(questionInteractionProvider('q-1').notifier)
    ..useExistingChoiceSet('cs-1', const [
      ChoiceItem(key: 'A', kind: 'SQL', body: _sql),
    ]);
}

void main() {
  group('SQL 실행 실패 (#482)', () {
    test('SANDBOX_TIMEOUT 이면 로딩을 끝내고 매핑된 문구로 실패를 담는다', () async {
      final notifier = _notifierWith(
        (_) => jsonResponseBody(500, {'errorCode': 'SANDBOX_TIMEOUT'}),
      );

      await notifier.selectChoice(
        choiceKey: 'A',
        sql: _sql,
        isExecutable: true,
      );

      expect(notifier.state.isExecuting, isFalse);
      expect(notifier.state.currentExecuteResult, isNull);
      expect(notifier.state.executeFailure?.code, ErrorCode.sandboxTimeout);
      expect(notifier.state.executeFailure?.message, '쿼리 실행 시간이 초과되었어요.');
    });

    test('다시 시도가 성공하면 실패를 지우고 결과를 담는다', () async {
      var isServerDown = true;
      final notifier = _notifierWith(
        (_) => isServerDown
            ? jsonResponseBody(503, const {})
            : jsonResponseBody(200, {
                'columns': ['X'],
                'rows': [
                  [1],
                ],
                'rowCount': 1,
              }),
      );
      await notifier.selectChoice(
        choiceKey: 'A',
        sql: _sql,
        isExecutable: true,
      );
      expect(notifier.state.executeFailure?.code, ErrorCode.serverError);

      isServerDown = false;
      await notifier.retryExecution();

      expect(notifier.state.executeFailure, isNull);
      expect(notifier.state.currentExecuteResult?.rowCount, 1);
    });
  });

  test('제출 실패는 원인별 문구가 담긴 AppException 으로 전달된다 (#482)', () async {
    final notifier = _notifierWith(
      (_) => jsonResponseBody(400, {
        'errorCode': 'INVALID_REQUEST',
        'message': '선택지 세트가 만료되었어요.',
      }),
    );
    await notifier.selectChoice(choiceKey: 'A', sql: null, isExecutable: false);

    await expectLater(
      notifier.submit(),
      throwsA(
        isA<AppException>().having(
          (exception) => exception.message,
          'message',
          '선택지 세트가 만료되었어요.',
        ),
      ),
    );
    expect(notifier.state.isSubmitting, isFalse);
  });

  testWidgets('실행 실패 카드는 사유와 다시 시도를 보여준다', (tester) async {
    var retryCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: ExecuteFailureCard(
            message: '네트워크 연결을 확인해 주세요.',
            onRetry: () => retryCount++,
          ),
        ),
      ),
    );

    expect(find.text('실행하지 못했어요'), findsOneWidget);
    expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    expect(retryCount, 1);
  });
}
