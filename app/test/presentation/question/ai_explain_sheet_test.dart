import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/models/ai/ai_result.dart';
import 'package:passql_app/data/models/ai/choice_explanation_response.dart';
import 'package:passql_app/data/models/ai/similar_question.dart';
import 'package:passql_app/data/sources/ai_api.dart';
import 'package:passql_app/presentation/widgets/question/ai_explain_sheet.dart';

/// 서버 대신 응답을 정해 주는 가짜 API. 어떤 엔드포인트가 불렸는지도 기록한다.
class _FakeAiApi implements AiApiClient {
  _FakeAiApi({this.reply, this.failure});

  final Completer<AiResult>? reply;
  final Object? failure;
  final calls = <String>[];
  Map<String, dynamic>? lastBody;

  Future<AiResult> _answer(String name, Map<String, dynamic> body) {
    calls.add(name);
    lastBody = body;
    if (failure != null) return Future.error(failure!);
    return reply!.future;
  }

  @override
  Future<AiResult> diffExplain(Map<String, dynamic> body) =>
      _answer('diff-explain', body);

  @override
  Future<AiResult> explainError(Map<String, dynamic> body) =>
      _answer('explain-error', body);

  @override
  Future<ChoiceExplanationResponse> getChoiceExplanation(
    String questionUuid, {
    String? choiceSetUuid,
    String? selectedChoiceKey,
  }) => throw UnimplementedError();

  @override
  Future<List<SimilarQuestion>> getSimilar(String questionUuid, int k) =>
      throw UnimplementedError();
}

/// 실제 호출부와 같이 AiExplainSheet.show 로 공용 시트를 연다.
Future<void> _open(
  WidgetTester tester,
  _FakeAiApi api, {
  required bool isErrorExplain,
  Map<String, dynamic>? payload,
  String? initialExplanation,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [aiApiProvider.overrideWithValue(api)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => AiExplainSheet.show(
                context,
                payload:
                    payload ??
                    const {'questionUuid': 'q-1', 'selectedChoiceKey': 'D'},
                isErrorExplain: isErrorExplain,
                initialExplanation: initialExplanation,
              ),
              child: const Text('열기'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('열기'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('오답 해설: 로딩 후 서버가 준 해설 본문을 보여 주고 diff-explain 을 부른다 (#354)', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    final api = _FakeAiApi(reply: Completer<AiResult>());
    await _open(tester, api, isErrorExplain: false);

    expect(find.text('AI 해설'), findsOneWidget);
    expect(find.text('AI가 해설을 쓰고 있어요'), findsOneWidget);

    api.reply!.complete(
      const AiResult(text: '## 왜 틀렸나\nRANK는 동점이면 순위를 건너뜁니다.', promptVersion: 2),
    );
    await tester.pumpAndSettle();

    expect(find.text('AI가 해설을 쓰고 있어요'), findsNothing);
    // 단어 순차 등장 배치라 한 줄 전체는 스크린리더 라벨로 확인한다
    expect(
      find.bySemanticsLabel(RegExp('RANK는 동점이면 순위를 건너뜁니다.')),
      findsOneWidget,
    );
    expect(find.textContaining('불러올 수 없어요'), findsNothing);
    expect(api.calls, ['diff-explain']);
    expect(api.lastBody, {'questionUuid': 'q-1', 'selectedChoiceKey': 'D'});
    semanticsHandle.dispose();
  });

  testWidgets('SQL 오류 해설: explain-error 로 SQL 과 오류 메시지를 보낸다', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    final api = _FakeAiApi(reply: Completer<AiResult>());
    await _open(
      tester,
      api,
      isErrorExplain: true,
      payload: const {
        'questionUuid': 'q-1',
        'sql': 'SELEC 1',
        'errorMessage': 'syntax error',
      },
    );

    api.reply!.complete(const AiResult(text: 'SELECT 철자를 확인하세요.'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('SELECT 철자를 확인하세요.')), findsOneWidget);
    expect(api.calls, ['explain-error']);
    expect(api.lastBody!['sql'], 'SELEC 1');
    semanticsHandle.dispose();
  });

  testWidgets('서버 실패(AI 사용 불가 등)는 빈 화면 대신 안내 문구를 보여 준다', (tester) async {
    final api = _FakeAiApi(failure: Exception('503'));
    await _open(tester, api, isErrorExplain: false);
    await tester.pumpAndSettle();

    expect(find.text('AI 해설을 불러올 수 없어요'), findsOneWidget);
    expect(find.text('AI가 해설을 쓰고 있어요'), findsNothing);
  });

  testWidgets('미리 생성된 해설이 있으면 서버를 부르지 않고 바로 보여 준다 (#496)', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    final api = _FakeAiApi(reply: Completer<AiResult>());
    await _open(
      tester,
      api,
      isErrorExplain: false,
      initialExplanation: 'GROUP BY 없이 HAVING 을 썼어요.',
    );
    await tester.pumpAndSettle();

    expect(find.text('AI가 해설을 쓰고 있어요'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('GROUP BY 없이 HAVING 을 썼어요.')),
      findsOneWidget,
    );
    expect(api.calls, isEmpty);
    semanticsHandle.dispose();
  });
}
