import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/exam_trend/exam_trend_report_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/exam_trend/exam_trend_page.dart';
import 'package:passql_app/presentation/providers/exam_trend_providers.dart';

import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/question/question_detail.dart';
import 'package:passql_app/presentation/flows/question_flow.dart';
import 'package:passql_app/presentation/widgets/home/exam_trend_entry_card.dart';
import 'package:passql_app/presentation/widgets/question/question_sections.dart';
import 'package:passql_app/presentation/widgets/question/topic_card.dart';
import 'package:passql_app/router/app_routes.dart';
import '../../helpers/pump_app.dart';

/// 출제 경향 화면 (#523): 섹션 표시, 최신 경향 문제 있는 항목만 풀기 안내, 실패 시 다시 시도
const _report = ExamTrendReportResponse(
  title: '2026 SQLD 출제 경향',
  basisDescription: '제58~62회 시험 유형 분석',
  updatedDate: '2026-10-18',
  summary: '결과 추적형이 늘었어요.',
  latestTrendQuestionCount: 3,
  subjectShares: [
    ExamTrendSubjectShare(
      subjectName: '1과목',
      questionCount: 10,
      percent: 20,
      description: '상황형 증가',
    ),
    ExamTrendSubjectShare(
      subjectName: '2과목',
      questionCount: 40,
      percent: 80,
      description: '추적형 대부분',
    ),
  ],
  risingPatterns: [
    ExamTrendPattern(
      title: '결과 비교형 보기',
      description: '행 수가 가장 많은 것 고르기',
      examRoundsText: '58회부터 증가',
      topicCode: 'sql_join',
      topicName: '조인',
      latestTrendQuestionCount: 3,
    ),
  ],
  frequentConcepts: [
    ExamTrendConcept(
      rank: 1,
      name: '윈도우 함수',
      description: '순위 함수 3종',
      frequencyText: '10문항',
      topicCode: 'sql_window',
    ),
  ],
  studyTips: ['결과 표를 직접 그려 보세요.'],
);

Future<void> _pumpPage(WidgetTester tester, Override reportOverride) async {
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [reportOverride],
      child: MaterialApp(theme: PassqlTheme.light, home: const ExamTrendPage()),
    ),
  );
  await pumpUntilMotionDone(tester);
}

Widget _host(Widget child) => MaterialApp(
  theme: PassqlTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('요약·과목 비중·늘어난 유형·자주 나오는 개념·공부 팁을 보여 준다', (tester) async {
    await _pumpPage(
      tester,
      examTrendReportProvider.overrideWith((ref) async => _report),
    );

    expect(find.text('2026 SQLD 출제 경향'), findsOneWidget);
    expect(find.text('최신 경향 문제 3개를 풀 수 있어요'), findsOneWidget);
    expect(find.text('10문항 · 20%'), findsOneWidget);
    expect(find.text('결과 비교형 보기'), findsOneWidget);
    expect(find.text('1. 윈도우 함수'), findsOneWidget);
    expect(find.text('결과 표를 직접 그려 보세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('최신 경향 문제가 있는 항목만 풀기 안내를 보여 준다', (tester) async {
    await _pumpPage(
      tester,
      examTrendReportProvider.overrideWith((ref) async => _report),
    );

    expect(find.text('조인 최신 경향 문제 3개 풀기'), findsOneWidget);
    expect(find.textContaining('윈도우 함수 최신 경향'), findsNothing);
  });

  testWidgets('불러오기 실패면 다시 시도 안내를 보여 준다', (tester) async {
    await _pumpPage(
      tester,
      examTrendReportProvider.overrideWith(
        (ref) async => throw Exception('network'),
      ),
    );

    expect(find.text('출제 경향을 불러올 수 없어요'), findsOneWidget);
  });

  testWidgets('최신 경향 문제 머리에만 최신 경향 배지가 보인다', (tester) async {
    await tester.pumpWidget(
      _host(
        const QuestionHeader(
          question: QuestionDetail(
            questionUuid: 'q',
            stem: '지문',
            isLatestTrend: true,
          ),
        ),
      ),
    );
    expect(find.text(PassqlLatestTrendBadge.label), findsOneWidget);

    await tester.pumpWidget(
      _host(
        const QuestionHeader(
          question: QuestionDetail(questionUuid: 'q', stem: '지문'),
        ),
      ),
    );
    expect(find.text(PassqlLatestTrendBadge.label), findsNothing);
  });

  testWidgets('최신 경향 문제가 있는 토픽 행에 배지가 보인다', (tester) async {
    const topic = TopicTree(
      topicUuid: 't',
      code: 'sql_join',
      displayName: '조인',
    );
    await tester.pumpWidget(
      _host(
        TopicCard(topic: topic, onTap: () {}, hasLatestTrendQuestion: true),
      ),
    );
    expect(find.byType(PassqlLatestTrendBadge), findsOneWidget);

    await tester.pumpWidget(_host(TopicCard(topic: topic, onTap: () {})));
    expect(find.byType(PassqlLatestTrendBadge), findsNothing);
  });

  testWidgets('홈 진입 카드는 제목과 최신 경향 배지를 보여 준다', (tester) async {
    await tester.pumpWidget(_host(const ExamTrendEntryCard()));
    expect(find.text(ExamTrendEntryCard.title), findsOneWidget);
    expect(find.byType(PassqlLatestTrendBadge), findsOneWidget);
  });

  test('최신 경향 풀기 경로는 latestTrend 쿼리를 붙이고 흐름은 일반 챕터와 상태를 나눈다', () {
    final route = AppRoutes.questionChapterOf(
      topicCode: 'sql_join',
      topicName: '조인',
      isLatestTrendOnly: true,
    );
    expect(
      Uri.parse(route).queryParameters[AppRoutes.latestTrendQuery],
      AppRoutes.latestTrendQueryValue,
    );
    expect(
      Uri.parse(
        AppRoutes.questionChapterOf(topicCode: 'sql_join', topicName: '조인'),
      ).queryParameters.containsKey(AppRoutes.latestTrendQuery),
      isFalse,
    );

    const latestTrendFlow = TopicFlow(
      topicCode: 'sql_join',
      topicName: '조인',
      isLatestTrendOnly: true,
    );
    const normalFlow = TopicFlow(topicCode: 'sql_join', topicName: '조인');
    expect(latestTrendFlow.id, isNot(normalFlow.id));
    expect(latestTrendFlow.title, '조인 최신 경향');
  });
}
