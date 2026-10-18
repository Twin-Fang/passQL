// 스토어 스크린샷 전용 진입점.
//
// 실서버에 로그인하지 않고도 로그인 이후 화면을 같은 렌더링으로 찍기 위해,
// 앱 전체를 그대로 띄우되 Dio 를 가짜 어댑터로 바꿔 canned 응답을 돌려준다.
// 빌드: flutter build ios --simulator -t tool/store_shots/main_shots.dart
// 촬영: echo /stats > /tmp/passql_shot_route.txt && xcrun simctl launch <기기> com.coldredrice.passql
// 연출 3종(경로 대신 적음): execute-fail(SQL 실행 실패 카드), chapter-result(문제 목록 > 챕터 > 챕터 결과), ai-sheet(오답 AI 해설 시트)
// 앱 시작 설정 상황: echo maintenance > /tmp/passql_shot_app_config.txt
//   (force_update | recommended_update | maintenance | notice, 없거나 그 외는 정상)
// 알림함 상황: echo empty > /tmp/passql_shot_notifications.txt (없거나 그 외는 알림 4건·공지 3건, 안 읽은 일부)
// 알림 권한 안내 시트: echo show > /tmp/passql_shot_permission.txt (없으면 "나중에"를 고른 상태로 시작해 시트를 띄우지 않음)
// 운영 코드(lib/)에는 영향이 없고, 빌드 산출물에도 포함되지 않는다.
import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passql_app/core/auth/auth_session.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/core/push/firebase_push_messaging_client.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:passql_app/main.dart' show PassqlApp;
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/providers/push_notification_providers.dart';
import 'package:passql_app/presentation/providers/theme_mode_provider.dart';
import 'package:passql_app/presentation/widgets/question/ai_explain_sheet.dart';
import 'package:passql_app/router/app_launch_gate_routing.dart';
import 'package:passql_app/router/app_router.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 시뮬레이터는 호스트 파일시스템을 그대로 보므로, 이 파일에 적은 경로로 이동한다.
// 같은 빌드로 화면만 바꿔 여러 장을 찍기 위한 장치다.
String _readRoute() {
  try {
    return File('/tmp/passql_shot_route.txt').readAsStringSync().trim();
  } catch (_) {
    return '/home';
  }
}

// 앱 시작 설정 상황 (/meta/app-config 가짜 응답 선택)
String _readAppConfigScenario() {
  try {
    return File('/tmp/passql_shot_app_config.txt').readAsStringSync().trim();
  } catch (_) {
    return '';
  }
}

final _appConfigScenario = _readAppConfigScenario();

// 알림함 상황 (알림·공지 가짜 응답 선택)
String _readNotificationScenario() {
  try {
    return File('/tmp/passql_shot_notifications.txt').readAsStringSync().trim();
  } catch (_) {
    return '';
  }
}

// 알림 권한 안내 시트를 띄울지 (show 일 때만)
bool _readShouldShowPermissionPrompt() {
  try {
    return File('/tmp/passql_shot_permission.txt').readAsStringSync().trim() == 'show';
  } catch (_) {
    return false;
  }
}

final _notificationScenario = _readNotificationScenario();

// 읽음 처리된 알림·공지 id (읽음 API 호출 > 개수·목록에 반영)
final _readNotificationIds = <String>{};

// 알림함 가짜 항목: 알림 4건(안 읽음 2) + 공지 3건(안 읽음 1, 중요)
List<Map<String, dynamic>> _notificationItems(String category) {
  if (_notificationScenario == 'empty') return const [];
  final now = DateTime.now();
  Map<String, dynamic> item(
    String id,
    String type,
    String title,
    String body,
    Duration ago, {
    String? linkTarget,
    String? linkQuestionUuid,
    bool isImportant = false,
  }) => {
    'id': id,
    'category': category,
    'type': type,
    'title': title,
    'body': body,
    'linkTarget': linkTarget,
    'linkQuestionUuid': linkQuestionUuid,
    'isRead': _readNotificationIds.contains(id) || id.endsWith('-read'),
    'createdAt': now.subtract(ago).toIso8601String(),
    'isImportant': isImportant,
  };
  if (category == 'NOTICE') {
    // 노출 중 공지만 (지난 공지는 /meta/notices 목록에만)
    return [
      for (final notice in _fakeNotices().where((notice) => notice['isVisible'] == true))
        item(notice['noticeUuid'] as String, 'NOTICE', notice['title'] as String, notice['body'] as String,
            now.difference(DateTime.parse(notice['publishedAt'] as String)), isImportant: notice['isImportant'] as bool),
    ];
  }
  return [
    item('general-1', 'REPORT_RESOLVED', '신고하신 문제를 확인했어요', '"JOIN 결과 행 수" 문제의 정답을 수정했어요. 알려 주셔서 고마워요.', const Duration(minutes: 3), linkTarget: 'QUESTION_DETAIL', linkQuestionUuid: '22222222-0000-4000-8000-000000000002'),
    item('general-2', 'ADMIN_MESSAGE', '이번 주 학습 리포트', '통계에서 약한 토픽을 확인해 보세요.', const Duration(hours: 2), linkTarget: 'STATS'),
    item('general-3-read', 'DAILY_SET_REMINDER', '오늘의 세트가 준비됐어요', '3문제로 실력을 확인해 보세요.', const Duration(days: 1), linkTarget: 'DAILY_SET'),
    item('general-4-read', 'ADMIN_MESSAGE', '시험 D-30', 'SQLD 58회까지 30일 남았어요.', const Duration(days: 2), linkTarget: 'HOME'),
  ];
}

// 가짜 공지 (#529): 노출 중 3건(중요 1) + 노출 끝난 지난 공지 2건, 본문은 마크다운 일부
// 순서 = 서버 정렬(노출 중 중요 먼저 > 게시 최신 순)
List<Map<String, dynamic>> _fakeNotices() {
  final now = DateTime.now();
  Map<String, dynamic> notice(String uuid, String title, String body, Duration ago,
          {bool isImportant = false, bool isVisible = true}) =>
      {
        'noticeUuid': uuid,
        'title': title,
        'body': body,
        'startsAt': null,
        'endsAt': null,
        'isActive': true,
        'isImportant': isImportant,
        'publishedAt': now.subtract(ago).toIso8601String(),
        'isVisible': isVisible,
      };
  return [
    notice(
      'notice-1',
      '제58회 SQLD 대비 문제 업데이트 안내',
      '시험이 한 달 앞으로 다가왔어요. **윈도우 함수·계층형 질의 문제 40개**를 새로 추가했어요.\n\n'
          '이번 업데이트에서 달라진 점\n'
          '- 윈도우 함수 20문제: `ROW_NUMBER`, `RANK`, `LAG` 위주\n'
          '- 계층형 질의 20문제: `START WITH`, `CONNECT BY`\n'
          '- 모든 문제에 AI 해설 제공\n\n'
          '문제 탭에서 바로 풀어 보세요. 자세한 출제 범위는 [시험 안내 페이지](https://www.dataq.or.kr)에서 확인할 수 있어요.',
      const Duration(days: 1),
      isImportant: true,
    ),
    notice('notice-2-read', '10월 16일 새벽 서버 점검', '**02:00 ~ 04:00** 동안 서버를 점검해요.\n\n점검 중에는 풀이 기록이 저장되지 않아요.', const Duration(days: 3)),
    notice('notice-3-read', '개인정보처리방침 개정 안내', '10월 20일부터 개정된 개인정보처리방침이 적용돼요.\n\n- 수집 항목 정리\n- 보관 기간 명시', const Duration(days: 6)),
    notice('notice-4-old', '오늘의 세트 리더보드 오픈', '매일 3문제를 풀고 친구들과 순위를 겨뤄 보세요.', const Duration(days: 21), isVisible: false),
    notice('notice-5-old', 'passQL 정식 출시 안내', 'SQLD·SQLP 문제 풀이 앱 passQL 이 정식 출시됐어요. **피드백**은 설정 > 건의사항으로 보내 주세요.', const Duration(days: 40), isVisible: false),
  ];
}

// 공지 목록·상세 가짜 응답 (공지 0건 상황은 알림함 empty 와 같이)
Object? _respondNotices(RequestOptions o) {
  final notices = _notificationScenario == 'empty' ? const <Map<String, dynamic>>[] : _fakeNotices();
  final detailPrefix = '/meta/notices/';
  final detailIndex = o.path.indexOf(detailPrefix);
  if (detailIndex >= 0) {
    final noticeUuid = o.path.substring(detailIndex + detailPrefix.length);
    return notices.firstWhere((notice) => notice['noticeUuid'] == noticeUuid, orElse: () => notices.first);
  }
  return {'notices': notices, 'page': 0, 'hasNextPage': false};
}

// 알림함 가짜 응답: 목록(탭별), 안 읽은 개수
Object? _respondNotifications(RequestOptions o) {
  if (o.path.endsWith('/notifications/unread-count')) {
    int unreadOf(String category) =>
        _notificationItems(category).where((item) => item['isRead'] != true).length;
    final general = unreadOf('GENERAL');
    final notice = unreadOf('NOTICE');
    return {'general': general, 'notice': notice, 'total': general + notice};
  }
  final category = o.queryParameters['category'] as String? ?? 'GENERAL';
  return {'items': _notificationItems(category), 'nextCursor': null};
}

// 상황별 /meta/app-config 응답: 강제 업데이트·권장 업데이트·점검·공지
Map<String, dynamic> _appConfig() {
  final minimumVersion = _appConfigScenario == 'force_update' ? '99.0.0' : '0.0.0';
  final recommendedVersion = _appConfigScenario == 'recommended_update' ? '99.0.0' : '0.0.0';
  Map<String, dynamic> platform(String storeUrl) => {
    'minimumVersion': minimumVersion,
    'recommendedVersion': recommendedVersion,
    'storeUrl': storeUrl,
  };
  return {
    'ios': platform('https://apps.apple.com/kr/app/passql/id0000000000'),
    'android': platform('https://play.google.com/store/apps/details?id=com.coldredrice.passql'),
    'maintenance': {
      'isUnderMaintenance': _appConfigScenario == 'maintenance',
      'message': '서버 안정화 작업으로 10월 16일 02:00 ~ 04:00 동안 점검해요.\n이용에 불편을 드려 죄송해요.',
    },
    'notices': [
      if (_appConfigScenario == 'notice')
        {
          'noticeUuid': '66666666-0000-4000-8000-000000000001',
          'title': '제58회 SQLD 시험 대비 문제 업데이트 안내',
          'body': '시험이 한 달 앞으로 다가왔어요.\n\n윈도우 함수·계층형 질의 문제 40개를 새로 추가했어요. 문제 탭에서 바로 풀어 보세요.',
          'startsAt': null,
          'endsAt': null,
          'isActive': true,
          'isImportant': true,
          'publishedAt': DateTime.now().toIso8601String(),
        },
    ],
  };
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
  'isLatestTrend': diff >= 2,
};

const _latestTrendTopics = [
  {'topicCode': 'sql_join', 'topicName': 'JOIN', 'latestTrendQuestionCount': 3},
  {'topicCode': 'sql_basic_select', 'topicName': 'SELECT 기본', 'latestTrendQuestionCount': 5},
];

Map<String, dynamic> _examTrendReport() => {
  'title': '2026 SQLD 출제 경향',
  'basisDescription': '제58~62회(2025년 8월~2026년 8월) 시험 유형 분석',
  'updatedDate': '2026-10-18',
  'summary': 'SQL과 데이터를 주고 실행 결과를 따라가는 문제가 크게 늘었어요. 새 개념보다 이미 아는 개념 2~3개를 한 문제에 섞는 방식이 기본이 됐어요.',
  'latestTrendQuestionCount': 8,
  'subjectShares': [
    {'subjectName': '1과목 데이터 모델링의 이해', 'questionCount': 10, 'percent': 20, 'description': '정의 암기보다 관계를 읽고 참여·식별 여부를 판정하는 상황형이 늘었어요.'},
    {'subjectName': '2과목 SQL 기본과 활용', 'questionCount': 40, 'percent': 80, 'description': '대부분이 결과 행 수·값·오류 여부를 직접 계산하는 추적형이에요.'},
  ],
  'risingPatterns': [
    {'title': '결과 비교형 보기', 'description': '보기마다 SQL을 주고 결과 행 수가 가장 많은 것, 결과가 다른 것, 오류가 나는 것을 고르는 문제예요.', 'examRoundsText': '58회부터 크게 증가', 'topicCode': 'sql_join', 'topicName': 'JOIN', 'latestTrendQuestionCount': 3},
    {'title': 'ROWNUM·Top-N 실행 순서', 'description': 'ROWNUM 조건이 ORDER BY보다 먼저 적용되는 점을 노린 보기 고르기가 자주 나와요.', 'examRoundsText': '62회 3문항 안팎', 'topicCode': 'sql_basic_select', 'topicName': 'SELECT 기본', 'latestTrendQuestionCount': 5},
  ],
  'frequentConcepts': [
    {'rank': 1, 'name': 'NULL 함정', 'description': 'NOT IN과 NULL, 집계 함수의 NULL 무시, 3값 논리', 'frequencyText': '15문항 이상', 'topicCode': 'sql_subquery', 'topicName': null, 'latestTrendQuestionCount': 0},
    {'rank': 2, 'name': '조인', 'description': '외부조인 ON과 WHERE 조건 위치, 결과 행 수 계산', 'frequencyText': '15문항 이상', 'topicCode': 'sql_join', 'topicName': 'JOIN', 'latestTrendQuestionCount': 3},
  ],
  'studyTips': [
    'SQL을 읽고 결과 표를 직접 그려 보세요. 암기보다 실행 순서와 결과 추적이 점수를 가려요.',
    'ROWNUM은 ORDER BY보다 먼저 적용돼요. 정렬한 뒤 자르려면 인라인 뷰로 감싸야 해요.',
  ],
  'latestTrendTopics': _latestTrendTopics,
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
  'isLatestTrend': true,
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
  if (p.endsWith('/ai/diff-explain') || p.endsWith('/ai/explain-error')) {
    return {
      'text': '**HAVING** 은 그룹으로 묶은 뒤의 결과를 거르는 조건이에요.\n\n'
          '- 고른 답 B 는 `GROUP BY` 없이 `HAVING` 을 써서 행 단위 조건으로 동작하지 않아요.\n'
          '- 정답 A 는 `WHERE SAL >= 3000` 으로 행마다 급여를 비교해요.\n\n'
          '기억할 포인트: 행 조건은 WHERE, 그룹 조건은 HAVING.',
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
  if (p.endsWith('/members/me/notifications') || p.endsWith('/members/me/notifications/unread-count')) {
    return _respondNotifications(o);
  }
  if (p.endsWith('/meta/app-config')) return _appConfig();
  if (p.endsWith('/meta/notices') || p.contains('/meta/notices/')) return _respondNotices(o);
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
  if (p.endsWith('/questions/$_executableQuestionUuid') && o.method == 'GET') return _executableDetail();
  if (p.endsWith('/questions/22222222-0000-4000-8000-000000000004') && o.method == 'GET') {
    return {
      ..._detail(),
      'questionUuid': '22222222-0000-4000-8000-000000000004',
      'topicName': '윈도우 함수',
      'difficulty': 3,
      'stem': '다음 SQL의 실행 결과로 올바른 것은?\n\nSELECT NAME, SAL, DENSE_RANK() OVER (ORDER BY SAL DESC) DRNK, RANK() OVER (ORDER BY SAL DESC) RNK FROM EMP;',
      'choiceSets': [],
    };
  }
  // 출제 경향 화면·토픽 목록 최신 경향 표시 (#523)
  if (p.endsWith('/exam-trends/latest/topics')) return _latestTrendTopics;
  if (p.endsWith('/exam-trends/latest')) return _examTrendReport();
  if (RegExp(r'/questions/[^/]+$').hasMatch(p) && o.method == 'GET') return _detail();
  if (p.endsWith('/questions')) {
    return {'content': _questions, 'totalElements': 4, 'totalPages': 1, 'number': 0, 'last': true};
  }
  return null;
}

/// 실행형(EXECUTABLE) 문제: execute-fail 연출용, 실행 API 는 SANDBOX_TIMEOUT 으로 실패
const _executableQuestionUuid = '22222222-0000-4000-8000-000000000005';
const _executableChoiceSql = 'SELECT ENAME FROM EMP WHERE SAL >= 3000;';

Map<String, dynamic> _executableDetail() {
  final detail = _detail();
  final choiceSet = Map<String, dynamic>.from((detail['choiceSets'] as List).first as Map);
  return {
    ...detail,
    'questionUuid': _executableQuestionUuid,
    'executionMode': 'EXECUTABLE',
    'choiceSets': [
      {...choiceSet, 'status': 'OK'},
    ],
  };
}

/// 실행 결과형(RESULT_MATCH) 문제: 선택지 본문이 결과 표 JSON 이다.
List<Map<String, dynamic>> _resultMatchChoices() {
  String rows(List<List<Object>> r) => jsonEncode([
        for (final x in r) {'NAME': x[0], 'SAL': x[1], 'DRNK': x[2], 'RNK': x[3]},
      ]);
  return [
    {'key': 'A', 'kind': 'TEXT', 'body': rows([['홍길동', 5000, 1, 1], ['김영희', 5000, 1, 1], ['이철수', 3000, 2, 3]]), 'isCorrect': true, 'sortOrder': 1},
    {'key': 'B', 'kind': 'TEXT', 'body': rows([['홍길동', 5000, 1, 1], ['김영희', 5000, 1, 1], ['이철수', 3000, 2, 2]]), 'isCorrect': false, 'sortOrder': 2},
    {'key': 'C', 'kind': 'TEXT', 'body': rows([['홍길동', 5000, 1, 1], ['김영희', 5000, 2, 2], ['이철수', 3000, 3, 3]]), 'isCorrect': false, 'sortOrder': 3},
    {'key': 'D', 'kind': 'TEXT', 'body': rows([['홍길동', 5000, 1, 1], ['김영희', 5000, 1, 2], ['이철수', 3000, 3, 3]]), 'isCorrect': false, 'sortOrder': 4},
  ];
}

String _sse({bool resultMatch = false}) {
  if (resultMatch) {
    final complete = jsonEncode({'choices': _resultMatchChoices(), 'choiceSetId': '33333333-0000-4000-8000-000000000010'});
    return 'event:status\ndata:{"message":"선택지를 준비하고 있어요"}\n\nevent:complete\ndata:$complete\n\n';
  }
  final choices = [
    for (final c in (_detail()['choiceSets'] as List).first['items'] as List)
      {...c as Map<String, dynamic>, 'isCorrect': c['key'] == 'A', 'rationale': c['key'] == 'A' ? 'WHERE 절로 행을 먼저 거릅니다.' : '이 절은 이 상황에 맞지 않습니다.'},
  ];
  final complete = jsonEncode({'choices': choices, 'choiceSetId': '33333333-0000-4000-8000-000000000009'});
  return 'event:status\ndata:{"message":"선택지를 준비하고 있어요"}\n\nevent:complete\ndata:$complete\n\n';
}

// 읽음 요청 반영: 1건(id) 또는 탭 전체(read-all)
void _markNotificationsRead(RequestOptions options) {
  if (options.path.endsWith('/read-all')) {
    final category = options.queryParameters['category'] as String? ?? 'GENERAL';
    for (final item in _notificationItems(category)) {
      _readNotificationIds.add(item['id'] as String);
    }
    return;
  }
  final segments = options.path.split('/');
  _readNotificationIds.add(segments[segments.length - 2]);
}

/// 실서버 대신 canned JSON 을 돌려주는 어댑터.
class _FakeAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    // AI 응답은 실제처럼 늦게 와서 기다리는 화면도 찍히게 한다
    if (options.path.contains('/ai/') || options.path.endsWith('/progress/ai-comment')) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }
    if (options.path.endsWith('/generate-choices')) {
      // ...0004 문제는 실행 결과형(RESULT_MATCH)으로 응답한다.
      final rm = options.path.contains('000000000004');
      return ResponseBody.fromString(_sse(resultMatch: rm), 200, headers: {Headers.contentTypeHeader: ['text/event-stream']});
    }
    if (options.path.endsWith('/execute')) {
      return ResponseBody.fromString(
        jsonEncode({'errorCode': 'SANDBOX_TIMEOUT', 'message': 'sandbox timeout'}),
        500,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }
    // 읽음 처리(POST .../notifications/{id}/read, .../read-all) > 기록 후 204
    if (options.method == 'POST' && options.path.contains('/members/me/notifications/')) {
      _markNotificationsRead(options);
      return ResponseBody.fromString('', 204);
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
  // 푸시 알림 탭 이동·포그라운드 토스트 확인용 (xcrun simctl push)
  await Firebase.initializeApp();
  await startFirebasePushMessaging();

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
    initialThemeModeProvider.overrideWithValue(await loadSavedThemeMode()),
    dioProvider.overrideWith((ref) => Dio(BaseOptions(baseUrl: 'http://shots.local/api'))..httpClientAdapter = _FakeAdapter()),
  ]);
  await container.read(authProvider.future);
  AppRouter.authenticated.value = !loggedOut;
  // 권장 업데이트·공지는 한 번 닫으면 기록돼 다시 안 뜸 > 촬영마다 기록 초기화
  if (_appConfigScenario == 'recommended_update' || _appConfigScenario == 'notice') {
    await (await SharedPreferences.getInstance()).clear();
  }
  // 알림 권한 안내 시트: show 일 때만 띄우고, 아니면 "나중에"를 고른 상태로 시작해 다른 화면 촬영을 가리지 않음
  final shouldShowPermissionPrompt = _readShouldShowPermissionPrompt();
  if (shouldShowPermissionPrompt) {
    await (await SharedPreferences.getInstance()).clear();
  } else {
    await const PushPermissionPromptStore().deferPrompt();
  }
  await AppLaunchGateRouting.bindAndLoad(container);

  runApp(UncontrolledProviderScope(container: container, child: const PassqlApp()));
  startPushNotificationSync(container, AppRouter.router);
  // 첫 프레임 이후 지정한 화면으로 이동한다.
  if (!loggedOut) {
    Timer(const Duration(milliseconds: 2000), () => _openRoute(route, container));
  }
}

/// 경로 이동 또는 연출(execute-fail, chapter-result)
Future<void> _openRoute(String route, ProviderContainer container) async {
  const settleDelay = Duration(milliseconds: 1500);
  switch (route) {
    case 'execute-fail':
      // 실행형 문제 > 선택지 A 선택 > 실행 API 실패
      AppRouter.router.go(AppRoutes.questionDetail(_executableQuestionUuid));
      await Future<void>.delayed(settleDelay);
      await container
          .read(questionInteractionProvider(_executableQuestionUuid).notifier)
          .selectChoice(choiceKey: 'A', sql: _executableChoiceSql, isExecutable: true);
    case 'chapter-result':
      // 문제 목록 > 챕터 진입 > 마지막 제출 뒤와 같은 교체 이동(TopicFlow.onCompleted)
      AppRouter.router.go(AppRoutes.questions);
      await Future<void>.delayed(settleDelay);
      AppRouter.router.push(AppRoutes.questionChapterOf(topicCode: 'sql_join', topicName: 'JOIN'));
      await Future<void>.delayed(settleDelay);
      AppRouter.router.pushReplacement(
        AppRoutes.chapterResult,
        extra: ChapterSummary(
          topicName: 'JOIN',
          results: [
            for (var i = 0; i < 10; i++)
              ChapterResult(questionUuid: 'q-$i', isCorrect: i % 4 != 3, durationMs: 8000 + i * 900),
          ],
          totalDurationMs: 124000,
        ),
      );
    case 'ai-sheet':
      // 실행형 문제 > 오답 AI 해설 시트 (스켈레톤 > 반짝이 태그 > 단어 순차 등장)
      AppRouter.router.go(AppRoutes.questionDetail(_executableQuestionUuid));
      await Future<void>.delayed(settleDelay);
      final sheetContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
      if (sheetContext != null && sheetContext.mounted) {
        unawaited(AiExplainSheet.show(
          sheetContext,
          payload: {'questionUuid': _executableQuestionUuid, 'selectedChoiceKey': 'B'},
          isErrorExplain: false,
        ));
      }
    default:
      AppRouter.router.go(route);
  }
}
