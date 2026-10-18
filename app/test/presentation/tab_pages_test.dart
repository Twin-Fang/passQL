import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/exam/exam_schedule_response.dart';
import 'package:passql_app/data/models/home/greeting_response.dart';
import 'package:passql_app/data/models/home/question_summary.dart';
import 'package:passql_app/data/models/home/recommendations_response.dart';
import 'package:passql_app/data/models/meta/topic_tree.dart';
import 'package:passql_app/data/models/progress/ai_comment_response.dart';
import 'package:passql_app/data/models/progress/heatmap_response.dart';
import 'package:passql_app/data/models/progress/progress_response.dart';
import 'package:passql_app/data/models/progress/readiness_response.dart';
import 'package:passql_app/data/models/progress/topic_analysis_response.dart';
import 'package:passql_app/data/models/progress/topic_stat.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/data/sources/community_api.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/community/community_question_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';

import '../helpers/fakes/fake_http_client_adapter.dart';
import '../helpers/pump_app.dart';
import '../helpers/text_finders.dart';

class _SignedInAuth extends AuthNotifier {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    accessToken: 'a',
    refreshToken: 'r',
    memberUuid: 'm-1',
    nickname: '새찬',
  );
}

/// 커뮤니티 서버 대신 [respond] 로 응답하는 클라이언트 (실제 Retrofit 경로 그대로)
CommunityApiClient _communityApi(
  ResponseBody Function(RequestOptions options) respond,
) => CommunityApiClient(
  Dio(BaseOptions(baseUrl: 'https://test'))
    ..httpClientAdapter = FakeHttpClientAdapter(respond),
);

final homeData = HomeData(
  greeting: const GreetingResponse(
    nickname: '찬',
    message: '{nickname}님,\nSQLD D-12! 지금이 골든타임이에요',
    messageType: 'COUNTDOWN',
  ),
  progress: const ProgressResponse(
    solvedCount: 12,
    correctRate: 0.6,
    streakDays: 3,
    readiness: ReadinessResponse(
      score: 0.4,
      accuracy: 0.6,
      coverage: 0.5,
      recency: 0.7,
      recentAttemptCount: 5,
      coveredTopicCount: 3,
      activeTopicCount: 9,
      toneKey: 'STEADY',
    ),
  ),
  dailySet: const DailySetTodayResponse(),
  recommendations: const RecommendationsResponse(
    questions: [
      QuestionSummary(
        questionUuid: 'q1',
        topicName: 'JOIN',
        stemPreview: '다음 중 옳은 것은?',
        difficulty: 2,
      ),
    ],
  ),
  examSchedule: const ExamScheduleResponse(
    examScheduleUuid: 'e',
    certType: 'SQLD',
    round: 58,
    examDate: '2099-01-01',
    isSelected: true,
  ),
  heatmap: HeatmapResponse(
    entries: [
      HeatmapEntry(
        date: DateTime.now().toIso8601String().substring(0, 10),
        solvedCount: 4,
        correctCount: 2,
      ),
    ],
  ),
);

const statsData = StatsData(
  progress: ProgressResponse(solvedCount: 12, correctRate: 0.6, streakDays: 3),
  topicAnalysis: TopicAnalysisResponse(
    topicStats: [
      TopicStat(
        topicUuid: 'a',
        displayName: 'SQL 기본 / SELECT',
        totalQuestionCount: 10,
        correctRate: 0.5,
      ),
      TopicStat(
        topicUuid: 'b',
        displayName: 'JOIN',
        totalQuestionCount: 6,
        correctRate: 0.8,
      ),
      TopicStat(
        topicUuid: 'c',
        displayName: '서브쿼리',
        totalQuestionCount: 4,
        correctRate: 0.3,
      ),
    ],
  ),
);

const topics = [
  TopicTree(
    topicUuid: 't1',
    code: 'sql_join',
    displayName: 'JOIN',
    subtopics: [SubtopicItem(code: 'a', displayName: 'A', isActive: true)],
  ),
  TopicTree(topicUuid: 't2', code: 'unknown', displayName: '신규'),
];

Future<void> _pump(
  WidgetTester tester,
  Widget page,
  List<Override> overrides, {
  ThemeData? theme,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await pumpApp(
    tester,
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: theme ?? PassqlTheme.light, home: page),
    ),
  );
  await tester.pump();
}

void main() {
  final cases = <String, (Widget, List<Override>)>{
    '홈': (
      const HomePage(),
      [homeDataProvider.overrideWith((ref) async => homeData)],
    ),
    '문제': (
      const TopicListPage(),
      [topicsProvider.overrideWith((ref) async => topics)],
    ),
    '통계': (
      const StatsPage(),
      [
        statsDataProvider.overrideWith((ref) async => statsData),
        statsAiCommentProvider.overrideWith(
          (ref) async => const AiCommentResponse(comment: '`JOIN` 토픽이 강해요.'),
        ),
      ],
    ),
  };

  for (final entry in cases.entries) {
    for (final dark in [false, true]) {
      testWidgets('${entry.key} 화면: 상단 바 1개, ${dark ? '다크' : '라이트'} 예외 없음', (
        tester,
      ) async {
        await _pump(
          tester,
          entry.value.$1,
          entry.value.$2,
          theme: dark ? PassqlTheme.dark : PassqlTheme.light,
        );
        // 홈은 로고 상단 바, 나머지 탭은 큰 제목 바 (#530)
        expect(
          find.byType(
            entry.key == '홈'
                ? PassqlBrandBarScrollView
                : CupertinoSliverNavigationBar,
          ),
          findsOneWidget,
        );
        // 인사 둘째 줄이 잘리지 않고 본문으로 보인다.
        if (entry.key == '홈') {
          expect(findTextContainingIgnoringWordJoiners('D-12'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('홈 상단: 320pt 폭·큰 글자에서 로고·종 같은 줄, 인사 말줄임 없음 (#530)', (
    tester,
  ) async {
    const reportedGreeting = '오늘도 한 문제씩, 합격에 가까워지고 있어요';
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith(
            (ref) async => HomeData(
              greeting: const GreetingResponse(
                nickname: '새찬',
                message: reportedGreeting,
                messageType: 'ENCOURAGE',
              ),
              progress: homeData.progress,
              dailySet: homeData.dailySet,
              examSchedule: homeData.examSchedule,
            ),
          ),
        ],
        child: MaterialApp(
          theme: PassqlTheme.light,
          // 앱과 같은 글자 배율 상한(1.4) 적용
          builder: PassqlTextScaleLimit.wrap,
          home: const HomePage(),
        ),
      ),
    );
    await tester.pump();
    await pumpUntilMotionDone(tester);
    expect(tester.takeException(), isNull);

    // 상단 바: 로고 왼쪽 <-> 종 오른쪽, 같은 줄
    final logoRect = tester.getRect(find.byType(PassqlLogo));
    final bellRect = tester.getRect(find.byType(PassqlNotificationBellButton));
    expect(logoRect.center.dy, closeTo(bellRect.center.dy, 0.5));
    expect(logoRect.right, lessThan(bellRect.left));

    // 인사: 줄 제한·말줄임 없음, 바 아래, 화면 폭 안
    final greeting = findTextContainingIgnoringWordJoiners(reportedGreeting);
    final greetingText = tester.widget<Text>(greeting);
    expect(greetingText.maxLines, isNull);
    expect(greetingText.overflow, isNull);
    final greetingRect = tester.getRect(greeting);
    expect(greetingRect.top, greaterThanOrEqualTo(bellRect.bottom));
    expect(greetingRect.right, lessThanOrEqualTo(320 - PassqlSpacing.md));
  });

  testWidgets('통계 화면은 320pt 폭에서도 예외 없다', (tester) async {
    await _pump(tester, const StatsPage(), [
      statsDataProvider.overrideWith((ref) async => statsData),
      statsAiCommentProvider.overrideWith(
        (ref) async => const AiCommentResponse(comment: '`JOIN` 토픽이 강해요.'),
      ),
    ], size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });

  group('커뮤니티 의견 화면 (#525)', () {
    Future<void> pumpQuestionPage(
      WidgetTester tester,
      CommunityApiClient api,
    ) => _pump(tester, const CommunityQuestionPage(questionUuid: 'q-1'), [
      communityApiProvider.overrideWithValue(api),
      authProvider.overrideWith(_SignedInAuth.new),
    ]);

    testWidgets('풀기 전이면 의견 대신 풀기 안내와 문제 풀기 버튼', (tester) async {
      await pumpQuestionPage(
        tester,
        _communityApi(
          (_) => jsonResponseBody(400, {
            'errorCode': 'COMMUNITY_SOLVE_REQUIRED',
            'message': '문제를 풀고 나서 의견을 볼 수 있어요.',
          }),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('풀고 나서 의견을 볼 수 있어요'), findsOneWidget);
      expect(find.text('문제 풀기'), findsOneWidget);
      expect(find.text('의견 쓰기'), findsNothing);
    });

    testWidgets('의견 목록: 풀이 배지·UGC 안내, 좋아요는 서버 값으로 확정', (tester) async {
      final api = _communityApi((options) {
        if (options.method == 'PUT') {
          return jsonResponseBody(200, {'isLiked': true, 'likeCount': 4});
        }
        return jsonResponseBody(200, {
          'items': [
            {
              'postUuid': 'p-1',
              'authorNickname': '용감한고양이',
              'content': 'LEFT JOIN 조건 위치가 헷갈렸어요',
              'isMine': false,
              'likeCount': 3,
              'isLikedByMe': false,
              'solveSnapshot': {
                'isCorrect': true,
                'attemptCount': 2,
                'solvedAt': '2026-10-01',
                'topicCode': 'sql_join',
                'difficulty': 2,
              },
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            },
          ],
          'nextCursor': null,
        });
      });
      await pumpQuestionPage(tester, api);
      await tester.pumpAndSettle();

      expect(find.text('정답 · 2번째 시도에 해결'), findsOneWidget);
      expect(find.text('운영 정책에 어긋나는 글은 신고해 주세요'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('좋아요 3개'));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsOneWidget);
    });
  });
}
