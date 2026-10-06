import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/home/question_summary.dart';
import 'package:passql_app/presentation/flows/daily_set_flow.dart';
import 'package:passql_app/presentation/pages/daily_set/daily_set_result_page.dart';
import 'package:passql_app/presentation/pages/daily_set/leaderboard_page.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';
import 'package:passql_app/presentation/widgets/home/daily_set_card.dart';

import '../../helpers/pump_app.dart';

const _entries = [
  LeaderboardEntry(rank: 1, nickname: '민트', correctCount: 5),
  LeaderboardEntry(rank: 2, nickname: '라임', correctCount: 4),
  LeaderboardEntry(rank: 3, nickname: '체리', correctCount: 4),
  LeaderboardEntry(rank: 4, nickname: '나', correctCount: 3),
];

LeaderboardResponse _board({LeaderboardEntry? mine}) =>
    LeaderboardResponse(date: '2026-10-02', entries: _entries, myEntry: mine);

Override _boardOverride(LeaderboardResponse res) =>
    leaderboardProvider.overrideWith((ref) async => res);

Future<void> _pageOf(WidgetTester tester, Widget page, List<Override> overrides) async {
  await pumpApp(
    tester,
    ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(path: '/', builder: (_, _) => page),
            GoRoute(path: '/leaderboard', builder: (_, _) => const Text('전체 순위 화면')),
            GoRoute(path: '/home', builder: (_, _) => const Text('홈 화면')),
            GoRoute(path: '/daily-set', builder: (_, _) => const Text('풀이 화면')),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('홈 카드', () {
    Future<void> card(WidgetTester tester, DailySetTodayResponse? data, {List<String>? taps}) async {
      await pumpApp(
        tester,
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: DailySetCard(
                dailySet: data,
                onStart: () => taps?.add('start'),
                onViewResult: () => taps?.add('result'),
                onBrowse: () => taps?.add('browse'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('풀 수 있으면 문제 수를 보여주고 누르면 풀이를 시작한다', (tester) async {
      final taps = <String>[];
      await card(
        tester,
        DailySetTodayResponse(
          questions: List.generate(5, (i) => QuestionSummary(questionUuid: 'q$i')),
        ),
        taps: taps,
      );

      expect(find.text('오늘의 5문제'), findsOneWidget);
      expect(find.text('완료'), findsNothing);
      await tester.tap(find.byType(DailySetCard));
      expect(taps, ['start']);
    });

    testWidgets('이미 완료했으면 정답 수를 보여주고 누르면 결과를 연다', (tester) async {
      final taps = <String>[];
      await card(
        tester,
        DailySetTodayResponse(
          questions: List.generate(5, (i) => QuestionSummary(questionUuid: 'q$i')),
          alreadyCompleted: true,
          correctCount: 4,
        ),
        taps: taps,
      );

      expect(find.text('완료'), findsOneWidget);
      expect(find.text('4 / 5 정답'), findsOneWidget);
      await tester.tap(find.byType(DailySetCard));
      expect(taps, ['result']);
    });

    testWidgets('세트가 없거나 불러오지 못하면 준비 중으로 보이고 문제 목록으로 안내한다', (tester) async {
      for (final data in [null, const DailySetTodayResponse()]) {
        final taps = <String>[];
        await card(tester, data, taps: taps);

        expect(find.textContaining('준비 중'), findsOneWidget);
        await tester.tap(find.byType(DailySetCard));
        expect(taps, ['browse']);
      }
    });
  });

  group('결과 화면', () {
    const results = [
      ChapterResult(questionUuid: 'a', isCorrect: true, durationMs: 1),
      ChapterResult(questionUuid: 'b', isCorrect: false, durationMs: 1),
      ChapterResult(questionUuid: 'c', isCorrect: true, durationMs: 1),
    ];

    testWidgets('풀이 직후에는 점수, 문제별 결과, 상위 3명과 내 순위를 보여준다', (tester) async {
      await _pageOf(
        tester,
        const DailySetResultPage(
          extra: DailySetOutcome(results: results, correctCount: 2),
        ),
        [_boardOverride(_board(mine: _entries.last))],
      );

      // 점수는 한 문장(TextSpan)으로 이어 그려지므로 rich text 까지 검색한다.
      expect(find.textContaining('2 / 3', findRichText: true), findsOneWidget);
      expect(find.text('문제별 결과'), findsOneWidget);
      expect(find.text('정답'), findsNWidgets(3)); // 라벨 1 + 정답 행 2
      expect(find.text('오답'), findsOneWidget);
      expect(find.text('민트'), findsOneWidget);
      expect(find.text('체리'), findsOneWidget);
      expect(find.text('나'), findsNothing); // 상위 3명만 보여준다
      expect(find.text('내 순위 4위'), findsOneWidget);
    });

    testWidgets('점수 등록에 실패했으면 순위에 반영되지 않았음을 알린다', (tester) async {
      await _pageOf(
        tester,
        const DailySetResultPage(
          extra: DailySetOutcome(
            results: results,
            correctCount: 2,
            saveError: '네트워크 연결을 확인해 주세요.',
          ),
        ),
        [_boardOverride(_board())],
      );

      expect(find.textContaining('순위에 반영하지 못했어요'), findsOneWidget);
      expect(find.textContaining('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    });

    testWidgets('전체 순위 보기와 홈으로 가기가 동작한다', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pageOf(
        tester,
        const DailySetResultPage(extra: DailySetOutcome(results: results, correctCount: 2)),
        [_boardOverride(_board())],
      );

      await tester.tap(find.text('전체 순위 보기'));
      await tester.pumpAndSettle();
      expect(find.text('전체 순위 화면'), findsOneWidget);
    });

    testWidgets('풀이 직후가 아니면 서버 기록으로 완료 결과를 보여준다', (tester) async {
      await _pageOf(
        tester,
        const DailySetResultPage(),
        [
          dailySetTodayProvider.overrideWith(
            (ref) async => DailySetTodayResponse(
              questions: List.generate(5, (i) => QuestionSummary(questionUuid: 'q$i')),
              alreadyCompleted: true,
              correctCount: 4,
            ),
          ),
          _boardOverride(_board()),
        ],
      );

      expect(find.textContaining('4 / 5', findRichText: true), findsOneWidget);
      expect(find.text('문제별 결과'), findsNothing); // 기록에는 문제별 정오답이 없다
    });

    testWidgets('아직 풀지 않았다면 풀어보기로 안내한다', (tester) async {
      await _pageOf(
        tester,
        const DailySetResultPage(),
        [
          dailySetTodayProvider.overrideWith(
            (ref) async => const DailySetTodayResponse(
              questions: [QuestionSummary(questionUuid: 'q')],
            ),
          ),
          _boardOverride(_board()),
        ],
      );

      expect(find.text('아직 오늘의 세트를 풀지 않았어요'), findsOneWidget);
      await tester.tap(find.text('풀어보기'));
      await tester.pumpAndSettle();
      expect(find.text('풀이 화면'), findsOneWidget);
    });
  });

  group('리더보드', () {
    testWidgets('날짜와 순위를 보여주고, 내 기록은 위에 따로 표시한다', (tester) async {
      await _pageOf(
        tester,
        const LeaderboardPage(),
        [_boardOverride(_board(mine: _entries.last))],
      );

      expect(find.text('2026-10-02'), findsOneWidget);
      expect(find.text('내 순위'), findsOneWidget);
      expect(find.text('민트'), findsOneWidget);
      // 내 기록은 맨 위 강조 줄과 목록에서 모두 보인다.
      expect(find.text('나'), findsNWidgets(2));
    });

    testWidgets('내가 아직 완료하지 않았다면 내 순위 줄이 없다', (tester) async {
      await _pageOf(tester, const LeaderboardPage(), [_boardOverride(_board())]);
      expect(find.text('내 순위'), findsNothing);
    });

    testWidgets('아무도 완료하지 않았으면 안내 문구를 보여준다', (tester) async {
      await _pageOf(
        tester,
        const LeaderboardPage(),
        [_boardOverride(const LeaderboardResponse(date: '2026-10-02'))],
      );
      expect(find.text('아직 완료한 사람이 없어요'), findsOneWidget);
    });

    testWidgets('불러오기에 실패하면 사유와 다시 시도를 보여준다', (tester) async {
      var attempts = 0;
      await _pageOf(tester, const LeaderboardPage(), [
        leaderboardProvider.overrideWith((ref) async {
          attempts++;
          if (attempts == 1) {
            throw DioException(
              requestOptions: RequestOptions(path: '/x'),
              type: DioExceptionType.connectionError,
            );
          }
          return _board();
        }),
      ]);
      expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();
      expect(find.text('민트'), findsOneWidget);
    });
  });
}
