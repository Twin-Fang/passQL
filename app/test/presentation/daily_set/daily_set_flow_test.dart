import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/core/error/app_exception.dart';
import 'package:passql_app/core/error/error_code.dart';
import 'package:passql_app/core/network/api_providers.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/data/models/home/question_summary.dart';
import 'package:passql_app/data/models/question/question_list_response.dart';
import 'package:passql_app/data/sources/daily_set_api.dart';
import 'package:passql_app/data/sources/question_api.dart';
import 'package:passql_app/presentation/flows/daily_set_flow.dart';
import 'package:passql_app/presentation/flows/question_flow.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';

import '../../helpers/pump_app.dart';

class _FakeDailySetApi implements DailySetApiClient {
  _FakeDailySetApi({
    this.today = const DailySetTodayResponse(),
    this.completeError,
    this.completeResult = const DailySetCompleteResponse(
      correctCount: 0,
      rank: 3,
      totalParticipants: 10,
    ),
  });

  DailySetTodayResponse today;
  DioException? completeError;
  DailySetCompleteResponse completeResult;
  final completeRequests = <DailySetCompleteRequest>[];

  @override
  Future<DailySetTodayResponse> getToday() async => today;

  @override
  Future<DailySetCompleteResponse> complete(DailySetCompleteRequest body) async {
    completeRequests.add(body);
    if (completeError != null) throw completeError!;
    return completeResult;
  }

  @override
  Future<LeaderboardResponse> getLeaderboard() async => const LeaderboardResponse();
}

class _FakeQuestionApi implements QuestionApiClient {
  String? requestedTopic;

  @override
  Future<QuestionListResponse> getQuestions(
    int page,
    int size, {
    String? topic,
    int? difficulty,
  }) async {
    requestedTopic = topic;
    return QuestionListResponse(
      content: [
        const QuestionSummary(questionUuid: 'a'),
        const QuestionSummary(questionUuid: 'b'),
      ],
      totalElements: 2,
      totalPages: 1,
      number: 0,
      last: true,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

DioException _serverError(int status, String code, String message) {
  final opts = RequestOptions(path: '/x');
  return DioException(
    requestOptions: opts,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: opts,
      statusCode: status,
      data: {'errorCode': code, 'message': message},
    ),
  );
}

const _summary = ChapterSummary(
  topicName: '오늘의 세트',
  totalDurationMs: 3000,
  results: [
    ChapterResult(questionUuid: 'a', isCorrect: true, durationMs: 1000),
    ChapterResult(questionUuid: 'b', isCorrect: false, durationMs: 1000),
    ChapterResult(questionUuid: 'c', isCorrect: true, durationMs: 1000),
  ],
);

/// 흐름의 완료 처리를 실행하고, 이동한 곳에 전달된 값을 돌려준다.
Future<Object?> _complete(WidgetTester tester, QuestionFlow flow, ProviderContainer container, {String sessionUuid = 'sess-1'}) async {
  Object? received;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Consumer(
          builder: (context, ref, _) => TextButton(
            onPressed: () => flow.onCompleted(context, ref, _summary, sessionUuid),
            child: const Text('끝내기'),
          ),
        ),
      ),
      GoRoute(
        path: '/daily-set/result',
        builder: (_, state) {
          received = state.extra;
          return const Text('결과 화면');
        },
      ),
      GoRoute(
        path: '/practice/:id/result',
        builder: (_, state) {
          received = state.extra;
          return const Text('연습 결과');
        },
      ),
    ],
  );
  await pumpApp(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.tap(find.text('끝내기'));
  await tester.pumpAndSettle();
  return received;
}

ProviderContainer _container({_FakeDailySetApi? daily, _FakeQuestionApi? question}) {
  final c = ProviderContainer(
    overrides: [
      dailySetApiProvider.overrideWithValue(daily ?? _FakeDailySetApi()),
      if (question != null) questionApiProvider.overrideWithValue(question),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('데일리 세트 흐름: 문제 목록', () {
    // 흐름 코드는 WidgetRef.read 만 쓰므로, Provider 안에서 어댑터로 감싸 호출한다.
    Future<List<String>> load(ProviderContainer c) {
      final p = FutureProvider<List<String>>(
        (ref) => const DailySetFlow().loadQuestionUuids(_RefAdapter(ref)),
      );
      return c.read(p.future);
    }

    test('오늘의 문제 UUID 를 순서대로 돌려준다', () async {
      final c = _container(
        daily: _FakeDailySetApi(
          today: const DailySetTodayResponse(
            questions: [QuestionSummary(questionUuid: 'q1'), QuestionSummary(questionUuid: 'q2')],
          ),
        ),
      );
      expect(await load(c), ['q1', 'q2']);
    });

    test('이미 완료했으면 완료 안내 예외를 던진다', () async {
      final c = _container(
        daily: _FakeDailySetApi(
          today: const DailySetTodayResponse(
            questions: [QuestionSummary(questionUuid: 'q1')],
            alreadyCompleted: true,
          ),
        ),
      );
      await expectLater(
        load(c),
        throwsA(isA<AppException>().having((e) => e.code, 'code', ErrorCode.dailySetAlreadyCompleted)),
      );
    });

    test('세트가 아직 없으면 준비 중 예외를 던진다', () async {
      final c = _container(daily: _FakeDailySetApi());
      await expectLater(
        load(c),
        throwsA(isA<AppException>().having((e) => e.code, 'code', ErrorCode.dailySetNotFound)),
      );
    });
  });

  group('데일리 세트 흐름: 완료 처리', () {
    testWidgets('정답 수와 세션을 서버에 보내고, 순위와 함께 결과 화면으로 이동한다', (tester) async {
      final api = _FakeDailySetApi(
        completeResult: const DailySetCompleteResponse(correctCount: 2, rank: 5, totalParticipants: 40),
      );
      final received = await _complete(tester, const DailySetFlow(), _container(daily: api));

      expect(api.completeRequests.single.correctCount, 2); // 3문제 중 2개 정답
      expect(api.completeRequests.single.sessionUuid, 'sess-1');
      expect(find.text('결과 화면'), findsOneWidget);
      final outcome = received as DailySetOutcome;
      expect(outcome.correctCount, 2);
      expect(outcome.completed?.rank, 5);
      expect(outcome.saveError, isNull);
      expect(outcome.results, hasLength(3));
    });

    testWidgets('이미 등록된 점수(409)는 오류로 보지 않고 결과를 보여준다', (tester) async {
      final api = _FakeDailySetApi(
        completeError: _serverError(409, 'DAILY_SET_ALREADY_COMPLETED', '오늘의 데일리 세트를 이미 완료했습니다.'),
      );
      final outcome =
          await _complete(tester, const DailySetFlow(), _container(daily: api)) as DailySetOutcome;

      expect(outcome.saveError, isNull);
      expect(outcome.completed, isNull);
      expect(find.text('결과 화면'), findsOneWidget);
    });

    testWidgets('점수 등록에 실패해도 결과 화면으로 이동하고 사유를 함께 넘긴다', (tester) async {
      final api = _FakeDailySetApi(
        completeError: DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );
      final outcome =
          await _complete(tester, const DailySetFlow(), _container(daily: api)) as DailySetOutcome;

      expect(outcome.saveError, '네트워크 연결을 확인해 주세요.');
      expect(outcome.correctCount, 2); // 풀이 결과는 잃지 않는다
      expect(find.text('결과 화면'), findsOneWidget);
    });
  });

  group('토픽 흐름', () {
    test('흐름 키가 토픽별로 다르고 세션을 추적하지 않는다', () {
      const a = TopicFlow(topicCode: 'SQL_BASIC', topicName: '기본');
      const b = TopicFlow(topicCode: 'JOIN', topicName: '조인');
      expect(a.id, isNot(b.id));
      expect(a.tracksSession, isFalse);
      expect(const DailySetFlow().tracksSession, isTrue);
    });

    testWidgets('해당 토픽의 문제를 불러오고, 끝나면 연습 결과 화면으로 요약을 넘긴다', (tester) async {
      final question = _FakeQuestionApi();
      final c = _container(question: question);
      const flow = TopicFlow(topicCode: 'JOIN', topicName: '조인');

      final received = await _complete(tester, flow, c);

      expect(received, isA<ChapterSummary>());
      expect((received as ChapterSummary).topicName, '오늘의 세트');
      expect(find.text('연습 결과'), findsOneWidget);
    });
  });

  group('ChapterNotifier.load', () {
    test('불러오기에 성공하면 목록을 담는다', () async {
      final n = ChapterNotifier();
      await n.load(() async => ['a', 'b']);
      expect(n.state.questionUuids, ['a', 'b']);
      expect(n.state.isLoadingList, isFalse);
      expect(n.state.listError, isNull);
    });

    test('흐름이 던진 사용자용 문구를 그대로 오류로 담는다', () async {
      final n = ChapterNotifier();
      await n.load(
        () => throw const AppException(
          code: ErrorCode.dailySetAlreadyCompleted,
          message: '오늘의 세트를 이미 완료했어요.',
        ),
      );
      expect(n.state.listError, '오늘의 세트를 이미 완료했어요.');
      expect(n.state.isLoadingList, isFalse);
    });

    test('네트워크 오류는 사용자용 문구로 바꿔 담는다', () async {
      final n = ChapterNotifier();
      await n.load(
        () => throw DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      expect(n.state.listError, contains('응답이 늦어지고 있어요'));
    });
  });
}

/// Provider 의 Ref 를 WidgetRef 처럼 쓰기 위한 어댑터(흐름 코드가 read 만 쓴다).
class _RefAdapter implements WidgetRef {
  _RefAdapter(this._ref);

  final dynamic _ref;

  @override
  T read<T>(ProviderListenable<T> provider) => _ref.read(provider) as T;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
