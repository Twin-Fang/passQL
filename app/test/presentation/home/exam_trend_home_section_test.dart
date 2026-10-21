import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/exam_trend/exam_trend_report_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/widgets/exam_trend/exam_trend_pattern_card.dart';
import 'package:passql_app/presentation/widgets/home/exam_trend_home_section.dart';

/// 홈 출제 경향 섹션: 요약·캡션·가로 유형 카드, '전체' 이동, 빈 유형 안전
const _report = ExamTrendReportResponse(
  title: '2026 SQLD 출제 경향',
  basisDescription: '제58~62회 시험 유형 분석',
  updatedDate: '2026-10-18',
  summary: '결과 추적형이 늘었어요.',
  risingPatterns: [
    ExamTrendPattern(
      title: '결과 비교형 보기',
      description: '행 수가 가장 많은 것 고르기',
      examRoundsText: '58회부터 증가',
      topicCode: 'sql_join',
      topicName: '조인',
      latestTrendQuestionCount: 3,
    ),
    ExamTrendPattern(
      title: '서브쿼리 추적형',
      description: '중첩 결과 따라가기',
      examRoundsText: '60회부터 증가',
      topicCode: 'sql_subquery',
      topicName: '서브쿼리',
      latestTrendQuestionCount: 2,
    ),
  ],
);

Future<void> _pumpSection(
  WidgetTester tester,
  ExamTrendReportResponse report, {
  ThemeData? theme,
  VoidCallback? onViewAll,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? PassqlTheme.light,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(PassqlSpacing.md),
          child: ExamTrendHomeSection(
            report: report,
            onSolveTopic: (_, _) {},
            onViewAll: onViewAll ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('제목·요약·캡션·유형 카드 제목을 보여 준다', (tester) async {
    await _pumpSection(tester, _report);

    expect(find.text(ExamTrendHomeSection.title), findsOneWidget);
    expect(find.text('결과 추적형이 늘었어요.'), findsOneWidget);
    expect(find.text('제58~62회 시험 유형 분석 · 2026-10-18 갱신'), findsOneWidget);
    expect(find.text('결과 비교형 보기'), findsOneWidget);
    expect(find.byType(ExamTrendPatternCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('390pt 폭에서도 제목이 말줄임 없이 거의 원래 크기로 보인다', (tester) async {
    await _pumpSection(tester, _report);

    final titleFinder = find.text(ExamTrendHomeSection.title);
    final titleParagraph = tester.renderObject<RenderParagraph>(titleFinder);
    expect(titleParagraph.didExceedMaxLines, isFalse);

    // 줄어든 비율 (보이는 너비 / 원래 너비) 90% 이상
    final visibleWidth = tester
        .getSize(
          find.ancestor(of: titleFinder, matching: find.byType(FittedBox)),
        )
        .width;
    expect(visibleWidth / titleParagraph.size.width, greaterThanOrEqualTo(0.9));
  });

  testWidgets("'전체'를 누르면 onViewAll 이 1회 호출된다", (tester) async {
    var viewAllCount = 0;
    await _pumpSection(tester, _report, onViewAll: () => viewAllCount++);

    await tester.tap(find.text('전체'));
    expect(viewAllCount, 1);
  });

  testWidgets("'전체' 버튼은 스크린리더에 '이번 시험 출제 경향 전체 보기'로 읽힌다", (tester) async {
    await _pumpSection(tester, _report);

    expect(find.bySemanticsLabel('이번 시험 출제 경향 전체 보기'), findsOneWidget);
  });

  testWidgets('늘어난 유형이 비어도 카드 없이 예외 없이 그려진다', (tester) async {
    await _pumpSection(tester, _report.copyWith(risingPatterns: const []));

    expect(find.byType(ExamTrendPatternCard), findsNothing);
    expect(find.text('결과 추적형이 늘었어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('다크 테마에서도 예외 없이 그려진다', (tester) async {
    await _pumpSection(tester, _report, theme: PassqlTheme.dark);

    expect(find.text(ExamTrendHomeSection.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
