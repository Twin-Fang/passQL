import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/execute_result.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/chapter/chapter_feedback_bar.dart';
import 'package:passql_app/presentation/widgets/question/execute_result_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PqTheme.light,
  home: Scaffold(bottomNavigationBar: child),
);

void main() {
  testWidgets('오답이면 정답 키와 AI 해설을 보여 주고, 마지막 문제면 결과 보기', (tester) async {
    var next = 0;
    await tester.pumpWidget(_wrap(ChapterFeedbackBar(
      result: const SubmitResult(isCorrect: false, correctKey: 'C'),
      questionUuid: 'q',
      selectedChoiceKey: 'A',
      isLastQuestion: true,
      onNext: () => next++,
    )));
    expect(find.text('오답이에요 · 정답 C'), findsOneWidget);
    expect(find.text('AI 해설'), findsOneWidget);
    await tester.tap(find.text('결과 보기'));
    expect(next, 1);
  });

  testWidgets('EXECUTABLE 정답이면 AI 해설을 숨기고 다음 버튼을 보여 준다', (tester) async {
    await tester.pumpWidget(_wrap(ChapterFeedbackBar(
      result: const SubmitResult(isCorrect: true, correctKey: 'A', correctSql: 'SELECT 1'),
      questionUuid: 'q',
      selectedChoiceKey: 'A',
      isLastQuestion: false,
      onNext: () {},
    )));
    expect(find.text('정답이에요'), findsOneWidget);
    expect(find.text('AI 해설'), findsNothing);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('실행 결과 카드는 성공/오류를 라벨로 구분한다', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PqTheme.light,
      home: Scaffold(
        body: Column(children: [
          ExecuteResultCard(result: ExecuteResult(columns: ['n'], rows: [[1]], rowCount: 1)),
          ExecuteResultCard(
            result: ExecuteResult(errorCode: 'ORA-00923', errorMessage: 'FROM 키워드가 없어요'),
            onAiExplainTap: () {},
          ),
        ]),
      ),
    ));
    expect(find.text('실행 성공'), findsOneWidget);
    expect(find.text('실행 오류'), findsOneWidget);
    expect(find.text('AI에게 물어보기'), findsOneWidget);
  });
}
