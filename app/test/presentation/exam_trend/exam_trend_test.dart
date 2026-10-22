import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/exam_trend/exam_trend_report_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/exam_trend_providers.dart';
import 'package:passql_app/presentation/widgets/exam_trend/exam_trend_pattern_card.dart';
import 'package:passql_app/presentation/widgets/exam_trend/exam_trend_sections.dart';
import 'package:passql_app/presentation/widgets/home/daily_study_tip_card.dart';

import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/question/question_detail.dart';
import 'package:passql_app/presentation/flows/question_flow.dart';
import 'package:passql_app/presentation/widgets/question/question_sections.dart';
import 'package:passql_app/presentation/widgets/question/topic_card.dart';
import 'package:passql_app/router/app_routes.dart';

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

Widget _host(Widget child) => MaterialApp(
  theme: PassqlTheme.light,
  home: Scaffold(body: child),
);

void main() {
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

  test('오늘의 공부 팁은 날짜의 연중 일수로 고르고 목록이 비면 null 이다', () {
    expect(selectDailyStudyTip(const [], DateTime(2026, 10, 21)), isNull);
    const tips = ['a', 'b', 'c'];
    expect(selectDailyStudyTip(tips, DateTime(2026, 1, 1)), 'a');
    expect(selectDailyStudyTip(tips, DateTime(2026, 1, 2)), 'b');
    expect(selectDailyStudyTip(tips, DateTime(2026, 1, 4)), 'a');
  });

  test('홈 유형 카드는 날짜마다 시작 항목만 돌고 순서는 유지한다', () {
    const patterns = ['a', 'b', 'c'];
    expect(rotateToDailyStart(patterns, DateTime(2026, 1, 1)), ['a', 'b', 'c']);
    expect(rotateToDailyStart(patterns, DateTime(2026, 1, 2)), ['b', 'c', 'a']);
    expect(rotateToDailyStart(const <String>[], DateTime(2026, 1, 2)), isEmpty);
  });

  testWidgets('유형 카드는 숫자 없이 풀기 문구를 보여 주고 탭하면 그 토픽을 풀러 간다', (tester) async {
    final solvedTopics = <(String, String)>[];
    await tester.pumpWidget(
      _host(
        ExamTrendPatternCard(
          pattern: _report.risingPatterns.first,
          onSolveTopic: (topicCode, topicName) =>
              solvedTopics.add((topicCode, topicName)),
        ),
      ),
    );
    expect(find.text(ExamTrendPatternCard.solveLabel), findsOneWidget);
    expect(find.text('58회부터 증가'), findsNothing);
    expect(find.text('행 수가 가장 많은 것 고르기'), findsOneWidget);

    await tester.tap(find.text(ExamTrendPatternCard.solveLabel));
    expect(solvedTopics, [('sql_join', '조인')]);
  });

  testWidgets('유형 카드는 긴 제목·설명도 고정 높이 안에 말줄임으로 담는다', (tester) async {
    await tester.pumpWidget(
      _host(
        ExamTrendPatternCard(
          pattern: const ExamTrendPattern(
            title: '관리 구문 최종 상태 추적과 아주 긴 제목이 한 줄을 넘는 경우',
            description:
                'MERGE의 DELETE 절, INSERT FIRST, COMMIT 뒤 SAVEPOINT, 중첩 ROLE 회수 후 결과를 물어요. 설명이 두 줄을 넘는 경우도 말줄임으로 담아요.',
            examRoundsText: '62회 관리 구문 9문항',
            topicCode: 'sql_ddl_dml_tcl',
            topicName: 'DDL / DML / TCL',
            latestTrendQuestionCount: 12,
          ),
          onSolveTopic: (_, _) {},
        ),
      ),
    );
    // 넘침 예외 없이 그려지고 하단 문구가 보임
    expect(tester.takeException(), isNull);
    expect(find.text(ExamTrendPatternCard.solveLabel), findsOneWidget);
  });

  testWidgets('토픽 이름이 없는 유형 카드는 풀기 문구도 탭도 없다', (tester) async {
    var tapCount = 0;
    await tester.pumpWidget(
      _host(
        ExamTrendPatternCard(
          pattern: const ExamTrendPattern(
            title: '결과 비교형 보기',
            description: '행 수가 가장 많은 것 고르기',
            examRoundsText: '58회부터 증가',
            topicCode: 'sql_join',
          ),
          onSolveTopic: (_, _) => tapCount++,
        ),
      ),
    );
    expect(find.text(ExamTrendPatternCard.solveLabel), findsNothing);

    await tester.tap(find.text('결과 비교형 보기'));
    expect(tapCount, 0);
  });

  testWidgets('개념 행은 순위를 큰 숫자로 따로 보여 주고 제목엔 이름만 쓴다', (tester) async {
    await tester.pumpWidget(
      _host(
        ExamTrendConceptSection(
          concepts: _report.frequentConcepts,
          onSolveTopic: (_, _) {},
        ),
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('윈도우 함수'), findsOneWidget);
    expect(find.text('1. 윈도우 함수'), findsNothing);
  });

  testWidgets('오늘의 공부 팁 카드는 제목과 본문을 보여 준다', (tester) async {
    await tester.pumpWidget(
      _host(const DailyStudyTipCard(studyTip: '결과 표를 직접 그려 보세요.')),
    );
    expect(find.text('오늘의 공부 팁'), findsOneWidget);
    expect(find.text('결과 표를 직접 그려 보세요.'), findsOneWidget);
  });
}
