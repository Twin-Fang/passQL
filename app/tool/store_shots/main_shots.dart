// 스토어 스크린샷 전용 진입점.
//
// 실서버에 로그인하지 않고도 로그인 이후 화면을 같은 렌더링으로 찍기 위해,
// 앱 전체를 그대로 띄우되 Dio 를 가짜 어댑터로 바꿔 canned 응답을 돌려준다.
// 빌드: flutter build ios --simulator -t tool/store_shots/main_shots.dart
// 촬영: echo /stats > /tmp/passql_shot_route.txt && xcrun simctl launch <기기> com.coldredrice.passql
// 운영 코드(lib/)에는 영향이 없고, 빌드 산출물에도 포함되지 않는다.
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/core/network/dio_client.dart';
import 'package:passql_app/main.dart' show PassqlApp;
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/router/app_router.dart';

// 시뮬레이터는 호스트 파일시스템을 그대로 보므로, 이 파일에 적은 경로로 이동한다.
// 같은 빌드로 화면만 바꿔 여러 장을 찍기 위한 장치다.
String _readRoute() {
  try {
    return File('/tmp/passql_shot_route.txt').readAsStringSync().trim();
  } catch (_) {
    return '/home';
  }
}

const _topics = [
  ['80ae3a3d-063a-4bc8-9574-8478ba3065aa', 'data_modeling', '데이터 모델링'],
  ['7a132bb9-7d05-4154-a1a3-31db02188995', 'sql_basic_select', 'SELECT 기본'],
  ['4ec01e62-e187-4c0d-9b87-b7880c5289af', 'sql_ddl_dml_tcl', 'DDL / DML / TCL'],
  ['5d58d20c-1378-40b6-9892-2b63504e24b6', 'sql_function', 'SQL 함수'],
  ['11111111-0000-4000-8000-000000000005', 'sql_join', 'JOIN'],
  ['11111111-0000-4000-8000-000000000006', 'sql_subquery', '서브쿼리'],
  ['11111111-0000-4000-8000-000000000007', 'sql_group', '그룹함수 / 집계'],
  ['11111111-0000-4000-8000-000000000008', 'sql_window', '윈도우 함수'],
];

Map<String, dynamic> _summary(int i, String topic, String stem, int diff) => {
  'questionUuid': '22222222-0000-4000-8000-00000000000$i',
  'topicCode': 'sql_basic_select',
  'topicName': topic,
  'stemPreview': stem,
  'difficulty': diff,
  'executionMode': 'PRACTICE',
  'createdAt': '2026-10-01T09:00:00',
};

final _questions = [
  _summary(1, 'SELECT 기본', 'EMP 테이블에서 급여가 3000 이상인 사원의 이름을 조회하는 SQL로 알맞은 것은?', 1),
  _summary(2, 'JOIN', '두 테이블을 내부 조인할 때 결과 행 수가 가장 적은 조인 방식은?', 2),
  _summary(3, '그룹함수 / 집계', 'GROUP BY 절과 HAVING 절의 차이로 올바른 설명은?', 2),
  _summary(4, '윈도우 함수', 'RANK() OVER 와 DENSE_RANK() OVER 의 결과 차이는?', 3),
];

Map<String, dynamic> _detail() => {
  'questionUuid': '22222222-0000-4000-8000-000000000001',
  'topicName': 'SELECT 기본',
  'subtopicName': 'WHERE 조건',
  'difficulty': 1,
  'executionMode': 'PRACTICE',
  'stem': 'EMP 테이블에서 급여(SAL)가 3000 이상인 사원의 이름(ENAME)을 조회하려고 한다. 알맞은 SQL은?',
  'schemaDisplay': 'EMP(EMPNO, ENAME, JOB, SAL, DEPTNO)',
  'schemaDdl': 'CREATE TABLE EMP (EMPNO NUMBER, ENAME VARCHAR2(20), JOB VARCHAR2(20), SAL NUMBER, DEPTNO NUMBER);',
  'schemaSampleData': "INSERT INTO EMP VALUES (7788, 'SCOTT', 'ANALYST', 3000, 20);",
  'hint': 'WHERE 절에서 비교 연산자를 사용합니다.',
  'choiceSets': [
    {
      'choiceSetUuid': '33333333-0000-4000-8000-000000000001',
      'source': 'ADMIN',
      'status': 'APPROVED',
      'sandboxValidationPassed': true,
      'items': [
        {'key': 'A', 'kind': 'SQL', 'body': 'SELECT ENAME FROM EMP WHERE SAL >= 3000;', 'sortOrder': 1},
        {'key': 'B', 'kind': 'SQL', 'body': 'SELECT ENAME FROM EMP HAVING SAL >= 3000;', 'sortOrder': 2},
        {'key': 'C', 'kind': 'SQL', 'body': 'SELECT ENAME FROM EMP GROUP BY SAL >= 3000;', 'sortOrder': 3},
        {'key': 'D', 'kind': 'SQL', 'body': 'SELECT ENAME FROM EMP ORDER BY SAL >= 3000;', 'sortOrder': 4},
      ],
    },
  ],
};

Object? _respond(RequestOptions o) {
  final p = o.path;
  if (p.endsWith('/home/greeting')) {
    return {'nickname': '새찬', 'message': '오늘도 한 문제씩, 합격에 가까워지고 있어요', 'messageType': 'ENCOURAGE'};
  }
  if (p.endsWith('/progress/heatmap')) {
    final today = DateTime(2026, 10, 7);
    return {
      'entries': [
        for (var i = 0; i < 70; i++)
          if (i % 3 != 2)
            {
              'date': today.subtract(Duration(days: i)).toIso8601String().substring(0, 10),
              'solvedCount': 2 + (i * 7) % 9,
              'correctCount': 1 + (i * 5) % 6,
            },
      ],
    };
  }
  if (p.endsWith('/progress/ai-comment')) {
    return {'comment': 'JOIN 과 서브쿼리 영역의 정답률이 좋아요. 윈도우 함수를 조금만 더 연습하면 합격권이에요!', 'generatedAt': '2026-10-07T09:00:00'};
  }
  if (p.endsWith('/progress/topic-analysis')) {
    return {
      'topicStats': [
        for (var i = 0; i < _topics.length; i++)
          {
            'topicUuid': _topics[i][0],
            'displayName': _topics[i][2],
            'totalQuestionCount': 40 + i * 6,
            'correctRate': 0.92 - i * 0.07,
            'solvedCount': 30 - i * 2,
          },
      ],
    };
  }
  if (p.endsWith('/progress/wrong-questions')) {
    return {
      'totalCount': 3,
      'items': [
        for (final q in _questions.take(3))
          {'questionUuid': q['questionUuid'], 'stemPreview': q['stemPreview'], 'topicName': q['topicName'], 'lastWrongAt': '2026-10-06T21:10:00'},
      ],
    };
  }
  if (p.endsWith('/progress')) {
    return {
      'solvedCount': 128,
      'correctRate': 0.78,
      'streakDays': 12,
      'readiness': {
        'score': 0.72, 'accuracy': 0.78, 'coverage': 0.65, 'recency': 0.9,
        'lastStudiedAt': '2026-10-07T08:00:00', 'recentAttemptCount': 34,
        'coveredTopicCount': 7, 'activeTopicCount': 9, 'daysUntilExam': 38, 'toneKey': 'GOOD',
      },
    };
  }
  if (p.endsWith('/daily-set/today')) {
    return {'questions': _questions.take(3).toList(), 'alreadyCompleted': false};
  }
  if (p.endsWith('/daily-set/leaderboard')) {
    return {
      'date': '2026-10-07',
      'entries': [
        {'rank': 1, 'nickname': '쿼리장인', 'correctCount': 3},
        {'rank': 2, 'nickname': '조인마스터', 'correctCount': 3},
        {'rank': 3, 'nickname': '새찬', 'correctCount': 2},
        {'rank': 4, 'nickname': '셀렉트냥', 'correctCount': 2},
        {'rank': 5, 'nickname': '인덱스요정', 'correctCount': 1},
      ],
      'myEntry': {'rank': 3, 'nickname': '새찬', 'correctCount': 2},
    };
  }
  if (p.endsWith('/exam-schedules/selected')) {
    return {'examScheduleUuid': '44444444-0000-4000-8000-000000000001', 'certType': 'SQLD', 'round': 58, 'examDate': '2026-11-14', 'isSelected': true};
  }
  if (p.endsWith('/questions/recommendations')) {
    return {'questions': _questions.take(3).toList()};
  }
  if (p.endsWith('/meta/topics')) {
    return [
      for (var i = 0; i < _topics.length; i++)
        {'topicUuid': _topics[i][0], 'code': _topics[i][1], 'displayName': _topics[i][2], 'sortOrder': i + 1, 'isActive': true, 'subtopics': [for (var j = 1; j <= 3 + i % 2; j++) {'code': '${_topics[i][1]}_$j', 'displayName': '세부 주제 $j', 'sortOrder': j, 'isActive': true}]},
    ];
  }
  if (p.endsWith('/members/me')) {
    return {'memberUuid': '55555555-0000-4000-8000-000000000001', 'nickname': '새찬', 'choiceGenerationMode': 'PRACTICE'};
  }
  if (RegExp(r'/questions/[^/]+/report/status$').hasMatch(p)) return {'reported': false};
  if (RegExp(r'/questions/[^/]+$').hasMatch(p) && o.method == 'GET') return _detail();
  if (p.endsWith('/questions')) {
    return {'content': _questions, 'totalElements': 4, 'totalPages': 1, 'number': 0, 'last': true};
  }
  return null;
}

String _sse() {
  final choices = [
    for (final c in (_detail()['choiceSets'] as List).first['items'] as List)
      {...c as Map<String, dynamic>, 'isCorrect': c['key'] == 'A', 'rationale': c['key'] == 'A' ? 'WHERE 절로 행을 먼저 거릅니다.' : '이 절은 이 상황에 맞지 않습니다.'},
  ];
  final complete = jsonEncode({'choices': choices, 'choiceSetId': '33333333-0000-4000-8000-000000000009'});
  return 'event:status\ndata:{"message":"선택지를 준비하고 있어요"}\n\nevent:complete\ndata:$complete\n\n';
}

/// 실서버 대신 canned JSON 을 돌려주는 어댑터.
class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (options.path.endsWith('/generate-choices')) {
      return ResponseBody.fromString(_sse(), 200, headers: {Headers.contentTypeHeader: ['text/event-stream']});
    }
    final body = _respond(options);
    return ResponseBody.fromString(
      jsonEncode(body ?? <String, dynamic>{}),
      body == null ? 404 : 200,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // 로그인 화면을 찍을 때는 세션을 지워 비로그인 상태로 시작하고, 그 외에는 로그인된 상태로 시작한다.
  final route = _readRoute();
  final loggedOut = route.startsWith('/login');
  final store = TokenStore();
  if (loggedOut) {
    await store.clear();
  } else {
    await store.save(const AuthSession(
      accessToken: 'shots-access',
      refreshToken: 'shots-refresh',
      memberUuid: '55555555-0000-4000-8000-000000000001',
      nickname: '새찬',
    ));
  }

  final container = ProviderContainer(overrides: [
    dioProvider.overrideWith((ref) => Dio(BaseOptions(baseUrl: 'http://shots.local/api'))..httpClientAdapter = _FakeAdapter()),
  ]);
  await container.read(authProvider.future);
  AppRouter.authenticated.value = !loggedOut;

  runApp(UncontrolledProviderScope(container: container, child: const PassqlApp()));
  // 첫 프레임 이후 지정한 화면으로 이동한다.
  if (!loggedOut) {
    Timer(const Duration(milliseconds: 2000), () => AppRouter.router.go(route));
  }
}
