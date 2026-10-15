import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/widgets/question/question_sections.dart';

/// 선택지 상태 1개로 QuestionChoices 그리기
Future<void> _pumpChoices(
  WidgetTester tester,
  QuestionInteractionState interaction,
) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.listen(questionInteractionProvider('q-1'), (_, _) {});
  await tester.pumpWidget(
    MaterialApp(
      theme: PassqlTheme.light,
      home: Scaffold(
        body: QuestionChoices(
          interaction: interaction,
          notifier: container.read(questionInteractionProvider('q-1').notifier),
          isExecutable: false,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('준비된 세트의 선택지가 비어 있으면 안내와 다시 시도를 보여준다', (tester) async {
    await _pumpChoices(
      tester,
      const QuestionInteractionState(activeChoiceSetId: 'cs-1'),
    );
    expect(find.text('이 문제의 선택지가 비어 있어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('세트 준비 전에는 아무것도 그리지 않는다', (tester) async {
    await _pumpChoices(tester, const QuestionInteractionState());
    expect(find.byType(PassqlStatusView), findsNothing);
  });
}
