import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/progress/ai_comment_response.dart';
import 'package:passql_app/presentation/widgets/stats/ai_analysis_card.dart';
import 'package:passql_app/presentation/widgets/stats/summary_stats_section.dart';

Widget _host(Widget child) => ScreenUtilInit(
  designSize: const Size(390, 844),
  builder: (_, _) => MaterialApp(home: Scaffold(body: child)),
);

void main() {
  testWidgets('요약 카드: 정답률 값은 "정답률" 라벨로 표시한다', (tester) async {
    await tester.pumpWidget(_host(const SummaryStatsSection(progress: null)));
    expect(find.text('정답률'), findsOneWidget);
    expect(find.text('합격 준비도'), findsNothing);
  });

  testWidgets('AI 영역 분석: 백틱 기호를 숨긴다', (tester) async {
    await tester.pumpWidget(
      _host(
        const AiAnalysisCard(
          aiComment: AiCommentResponse(comment: '`JOIN` 토픽은 정답률 50%입니다.'),
        ),
      ),
    );
    expect(find.textContaining('`', findRichText: true), findsNothing);
    expect(
      find.textContaining('JOIN 토픽은 정답률 50%입니다.', findRichText: true),
      findsOneWidget,
    );
  });
}
