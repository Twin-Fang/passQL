import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/exam_trend/exam_trend_report_response.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/router/questions_tab_view.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/presentation/providers/exam_trend_providers.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';
import 'package:passql_app/presentation/widgets/exam_trend/concept_ranking_tab_view.dart';

import '../../helpers/fakes/fake_member_api.dart';
import '../../helpers/pump_app.dart';

const _topics = [
  TopicTree(topicUuid: 't1', code: 'sql_join', displayName: 'JOIN'),
];

final _report = ExamTrendReportResponse(
  title: '2026 SQLD 출제 경향',
  basisDescription: '제58~62회 시험 유형 분석',
  updatedDate: '2026-10-18',
  summary: '결과 추적형이 늘었어요.',
  latestTrendQuestionCount: 3,
  risingPatterns: const [
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
    for (var rank = 1; rank <= 6; rank++)
      ExamTrendConcept(
        rank: rank,
        name: '개념$rank',
        description: '설명$rank',
        frequencyText: '$rank문항',
        topicCode: 'sql_join',
      ),
  ],
  studyTips: const ['결과 표를 직접 그려 보세요.'],
);

/// 문제 탭을 [view] 보기로 그린다 (세그먼트 이동 확인용 GoRouter 포함)
Future<GoRouter> _pumpQuestionsTab(
  WidgetTester tester,
  QuestionsTabView view, {
  bool isReportFailing = false,
  List<Override> extraOverrides = const [],
  FakeMemberApi? memberApi,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => TopicListPage(view: view),
      ),
      GoRoute(
        path: '/questions',
        builder: (_, state) => TopicListPage(
          view: QuestionsTabView.fromQueryValue(
            state.uri.queryParameters['view'],
          ),
        ),
      ),
    ],
  );
  await pumpApp(
    tester,
    ProviderScope(
      overrides: [
        topicsProvider.overrideWith((ref) async => _topics),
        wrongQuestionTotalCountProvider.overrideWith((ref) async => 7),
        // 풀이 모드 행·설정 타일이 읽는 같은 원본 (기본 연습)
        memberApiProvider.overrideWithValue(memberApi ?? FakeMemberApi()),
        settingsDataProvider.overrideWith(
          (ref) async => const SettingsData(
            memberUuid: 'm',
            nickname: 'n',
            choiceMode: ChoiceGenerationMode.practice,
          ),
        ),
        latestTrendQuestionCountByTopicProvider.overrideWith(
          (ref) async => <String, int>{},
        ),
        examTrendReportProvider.overrideWith(
          (ref) async => isReportFailing ? throw Exception('boom') : _report,
        ),
        ...extraOverrides,
      ],
      child: MaterialApp.router(theme: PassqlTheme.light, routerConfig: router),
    ),
  );
  await pumpUntilMotionDone(tester);
  return router;
}

void main() {
  testWidgets('주제별: 오답 노트 행·토픽·세그먼트 라벨 3개', (tester) async {
    await _pumpQuestionsTab(tester, QuestionsTabView.byTopic);
    expect(find.text('오답 노트'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('JOIN'), findsOneWidget);
    for (final view in QuestionsTabView.values) {
      expect(find.text(view.label), findsOneWidget);
    }
  });

  testWidgets('공통 영역: 3개 보기 모두에서 오답 노트와 풀이 모드 행이 보인다', (tester) async {
    for (final view in QuestionsTabView.values) {
      await _pumpQuestionsTab(tester, view);
      expect(find.text('오답 노트'), findsOneWidget, reason: view.label);
      expect(find.text('풀이 모드'), findsOneWidget, reason: view.label);
      expect(find.text('연습'), findsOneWidget, reason: view.label);
    }
  });

  testWidgets('풀이 모드 행을 누르면 설정이 읽는 같은 Provider 가 실전으로 바뀐다', (tester) async {
    final memberApi = FakeMemberApi();
    await _pumpQuestionsTab(
      tester,
      QuestionsTabView.latestTrend,
      memberApi: memberApi,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TopicListPage)),
    );
    expect(
      container.read(choiceModeProvider).valueOrNull,
      ChoiceGenerationMode.practice,
    );

    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pumpAndSettle();

    expect(find.text('실전'), findsOneWidget);
    expect(find.text('매번 AI가 새 선택지를 만들어요'), findsOneWidget);
    expect(
      container.read(choiceModeProvider).valueOrNull,
      ChoiceGenerationMode.real,
    );
    expect(memberApi.calls, ['mode:REAL']);
  });

  testWidgets('오답 노트 행은 개수만 조회하고 목록(진입 분석 기록)은 불러오지 않는다', (tester) async {
    var wrongListLoads = 0;
    await _pumpQuestionsTab(
      tester,
      QuestionsTabView.byTopic,
      extraOverrides: [
        wrongQuestionsProvider.overrideWith((ref) async {
          wrongListLoads++;
          throw StateError('questions tab must not load the wrong-notes list');
        }),
      ],
    );
    expect(find.text('7'), findsOneWidget);
    expect(wrongListLoads, 0);
  });

  testWidgets('최신 경향: 총 문제 수·유형·공부 팁, 토픽 목록 없음', (tester) async {
    await _pumpQuestionsTab(tester, QuestionsTabView.latestTrend);
    expect(find.text('최신 경향 문제 총 3개'), findsOneWidget);
    expect(find.text('결과 비교형 보기'), findsOneWidget);
    expect(find.text('결과 표를 직접 그려 보세요.'), findsOneWidget);
    expect(find.text('학습할 토픽을 선택하세요'), findsNothing);
  });

  testWidgets('개념 TOP 10: 1위와 6위 이름, 머리글 개수 하나', (tester) async {
    await _pumpQuestionsTab(tester, QuestionsTabView.conceptRanking);
    expect(find.text('자주 나오는 개념 TOP 6'), findsOneWidget);
    expect(find.text('개념1'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('개념6'), 200);
    expect(find.text('개념6'), findsOneWidget);
  });

  testWidgets('출제 경향 실패: 오류 문구', (tester) async {
    await _pumpQuestionsTab(
      tester,
      QuestionsTabView.latestTrend,
      isReportFailing: true,
    );
    expect(find.text('출제 경향을 불러올 수 없어요'), findsOneWidget);
  });

  testWidgets('세그먼트 최신 경향 탭: 해당 보기 경로로 이동', (tester) async {
    final router = await _pumpQuestionsTab(tester, QuestionsTabView.byTopic);
    await tester.tap(find.text(QuestionsTabView.latestTrend.label));
    await pumpUntilMotionDone(tester);
    expect(
      router.routeInformationProvider.value.uri.toString(),
      QuestionsTabView.latestTrend.location,
    );
    expect(find.text('최신 경향 문제 총 3개'), findsOneWidget);
  });

  testWidgets('개념 TOP 10 광고 자리: 5위 뒤에 꽂히고 머리글·안내 문구는 한 번씩', (tester) async {
    await pumpApp(
      tester,
      MaterialApp(
        theme: PassqlTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: ConceptRankingTabView(
              concepts: _report.frequentConcepts,
              onSolveTopic: (_, _) {},
              adSlot: const Text('광고 자리'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('자주 나오는 개념 TOP 6'), findsOneWidget);
    expect(find.textContaining('합산 출제 문항 수 기준'), findsOneWidget);
    final adTop = tester.getTopLeft(find.text('광고 자리')).dy;
    expect(tester.getTopLeft(find.text('개념5')).dy, lessThan(adTop));
    expect(tester.getTopLeft(find.text('개념6')).dy, greaterThan(adTop));
  });
}
