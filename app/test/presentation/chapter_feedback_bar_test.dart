import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/question/execute_result.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/question/result_rows_table.dart';
import 'package:passql_app/presentation/widgets/chapter/chapter_feedback_bar.dart';
import 'package:passql_app/presentation/widgets/question/execute_result_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: PassqlTheme.light,
  home: Scaffold(bottomNavigationBar: child),
);

void main() {
  testWidgets('오답이면 정답 키를 보여 주고, 해설 항목이 없으면 미리보기 없이 결과 보기', (tester) async {
    var next = 0;
    await tester.pumpWidget(
      _wrap(
        ChapterFeedbackBar(
          result: const SubmitResult(isCorrect: false, correctKey: 'C'),
          questionUuid: 'q',
          isLastQuestion: true,
          onNext: () => next++,
        ),
      ),
    );
    expect(find.text('오답이에요 · 정답\u00A0C'), findsOneWidget);
    expect(find.text('AI 해설'), findsNothing);
    await tester.tap(find.text('결과 보기'));
    expect(next, 1);
  });

  testWidgets('정답이면 정답 표시와 다음 버튼을 보여 준다', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ChapterFeedbackBar(
          result: const SubmitResult(
            isCorrect: true,
            correctKey: 'A',
            correctSql: 'SELECT 1',
          ),
          questionUuid: 'q',
          isLastQuestion: false,
          onNext: () {},
        ),
      ),
    );
    expect(find.text('정답이에요'), findsOneWidget);
    expect(find.text('AI 해설'), findsNothing);
    expect(find.text('다음'), findsOneWidget);
  });

  testWidgets('실행 결과 카드는 성공/오류를 라벨로 구분한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              ExecuteResultCard(
                result: ExecuteResult(
                  columns: ['n'],
                  rows: [
                    [1],
                  ],
                  rowCount: 1,
                ),
              ),
              ExecuteResultCard(
                result: ExecuteResult(
                  errorCode: 'ORA-00923',
                  errorMessage: 'FROM 키워드가 없어요',
                ),
                onAiExplainTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('실행 성공'), findsOneWidget);
    expect(find.text('실행 오류'), findsOneWidget);
    expect(find.text('AI에게 물어보기'), findsOneWidget);
  });

  testWidgets('피드백 바는 부모가 rebuild되거나 형제가 추가돼도 햅틱을 1회만 울린다', (tester) async {
    var haptics = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics++;
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    final extra = ValueNotifier(false);
    Widget bar() => ChapterFeedbackBar(
      key: const ValueKey('q'),
      result: const SubmitResult(isCorrect: false, correctKey: 'C'),
      questionUuid: 'q',
      isLastQuestion: true,
      onNext: () {},
    );
    // ChapterPage 와 같은 모양: 항상 Stack, 완료 중일 때만 형제가 추가된다.
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: ValueListenableBuilder<bool>(
          valueListenable: extra,
          builder: (_, completing, _) => Stack(
            children: [
              Scaffold(bottomNavigationBar: bar()),
              if (completing) const ModalBarrier(dismissible: false),
            ],
          ),
        ),
      ),
    );
    expect(haptics, 1);
    extra.value = true;
    await tester.pump();
    extra.value = false;
    await tester.pump();
    expect(haptics, 1);
  });

  testWidgets('실행 결과 표는 이름이 같은 열의 값을 모두 보여 준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: const Scaffold(
          body: ResultRowsTable.positional(
            columns: ['deptno', 'deptno'],
            rows: [
              [10, 20],
            ],
          ),
        ),
      ),
    );
    expect(find.text('deptno'), findsNWidgets(2));
    expect(find.text('10'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('행이 0개여도 열 이름 헤더는 보여 준다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: ExecuteResultCard(
            result: ExecuteResult(
              columns: ['ename', 'sal'],
              rows: [],
              rowCount: 0,
            ),
          ),
        ),
      ),
    );
    expect(find.text('ename'), findsOneWidget);
    expect(find.text('sal'), findsOneWidget);
    expect(find.text('(결과 없음)'), findsNothing);
  });

  testWidgets('채점 뒤 탭은 onGradedTap 이 있을 때만 동작하고 시각 상태는 그대로다', (tester) async {
    var normal = 0, graded = 0;
    Widget card({VoidCallback? onGradedTap}) => MaterialApp(
      theme: PassqlTheme.light,
      home: Scaffold(
        body: PassqlChoiceCard(
          keyLabel: 'B',
          state: PassqlChoiceState.dimmed,
          onTap: () => normal++,
          onGradedTap: onGradedTap,
          child: const Text('선택지 본문'),
        ),
      ),
    );
    await tester.pumpWidget(card());
    await tester.tap(find.text('선택지 본문'));
    expect(normal + graded, 0);
    await tester.pumpWidget(card(onGradedTap: () => graded++));
    await tester.tap(find.text('선택지 본문'));
    expect(graded, 1);
    expect(normal, 0);
  });
}
