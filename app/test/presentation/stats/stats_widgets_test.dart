import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/progress/ai_comment_response.dart';
import 'package:passql_app/presentation/widgets/stats/ai_analysis_card.dart';
import 'package:passql_app/presentation/widgets/stats/summary_stats_section.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('요약 카드: 정답률 값은 "정답률" 라벨로 표시한다', (tester) async {
    await tester.pumpWidget(_host(const SummaryStatsSection(progress: null)));
    expect(find.text('정답률'), findsOneWidget);
    expect(find.text('합격 준비도'), findsNothing);
  });

  testWidgets('AI 영역 분석: 백틱 기호를 숨긴다', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const AiAnalysisCard(
          aiComment: AiCommentResponse(comment: '`JOIN` 토픽은 정답률 50%입니다.'),
        ),
      ),
    );
    // 단어 순차 등장이 끝나면 정적인 글자로 바뀐다
    await tester.pumpAndSettle();
    expect(find.textContaining('`', findRichText: true), findsNothing);
    expect(find.text('JOIN'), findsOneWidget);
    // 단어 순차 등장 배치라 문장 전체는 스크린리더 라벨로 확인한다
    expect(find.bySemanticsLabel('JOIN 토픽은 정답률 50%입니다.'), findsOneWidget);
    semanticsHandle.dispose();
  });
}
