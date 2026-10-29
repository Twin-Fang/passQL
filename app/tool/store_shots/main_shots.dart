// 스토어 스크린샷 전용 진입점.
//
// 실서버에 로그인하지 않고도 로그인 이후 화면을 같은 렌더링으로 찍기 위해,
// 앱 전체를 그대로 띄우되 Dio 를 가짜 어댑터로 바꿔 canned 응답을 돌려준다.
// 빌드: flutter build ios --simulator -t tool/store_shots/main_shots.dart
// 촬영: echo /stats > /tmp/passql_shot_route.txt && xcrun simctl launch <기기> com.coldredrice.passql
// 연출(경로 대신 적음): execute-ok(SQL 실행 성공 표), execute-fail(SQL 실행 실패 카드), chapter-result(문제 목록 > 챕터 > 챕터 결과), ai-sheet(오답 AI 해설 시트),
//   onboarding-1~4(온보딩 n장), onboarding-celebration(온보딩 첫 문제 축하), onboarding-tour(4장 넘김 > 축하 영상),
//   withdraw-confirm(설정 > 회원 탈퇴 확인창 > 확인 문구 입력 영상),
//   nickname-sheet(내 프로필 > 닉네임 변경 시트), nickname-toast(내 프로필 + 닉네임 변경 토스트),
//   nickname-edit(내 프로필 > 시트 > 입력 > 닫고 토스트 영상)
// 로그인 중 화면: echo /login-signing-in > /tmp/passql_shot_route.txt (카카오 버튼을 눌러 응답 대기에서 멈춘 상태)
// 로그인 전환 영상: echo /login-transition > /tmp/passql_shot_route.txt (로그인 화면 > 4초 뒤 홈 > 9초 뒤 로그인 화면, xcrun simctl io <기기> recordVideo 로 녹화)
// 앱 시작 설정 상황: echo maintenance > /tmp/passql_shot_app_config.txt
//   (force_update | recommended_update | maintenance | notice, 없거나 그 외는 정상)
// 알림함 상황: echo empty > /tmp/passql_shot_notifications.txt (없거나 그 외는 알림 4건·공지 3건, 안 읽은 일부)
// 알림 권한 안내 시트: echo show > /tmp/passql_shot_permission.txt (없으면 "나중에"를 고른 상태로 시작해 시트를 띄우지 않음)
// Android 에뮬레이터(호스트 /tmp 못 읽음): --dart-define=SHOT_ROUTE=/stats 로 경로·연출 지정
// 개념 전수 점검 (#577): echo concept-sweep > /tmp/passql_shot_route.txt (export_shot_concepts.py --all 데이터로 빌드, 결과 /tmp/passql_sweep)
// 개념 학습 (#577): SHOT_ROUTE=/concepts (개념 탭), /concept-study/44444444-0000-4000-8000-000000000014 (관계형 DB와 SQL), 대표 개념 3개는 shot_concept_data.dart
// 등급 상황 (#576): --dart-define=SHOT_PLAN=off|free|pro (결제 꺼짐 | 무료·결제 켜짐 | 프로·결제 켜짐, 없으면 off)
//   연출 result: 오답 제출 결과 화면 (무료면 실행 결과·해설 잠금)
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
import 'package:passql_app/core/billing/pro_purchase_port.dart';
import 'package:passql_app/core/auth/social_credential.dart';
import 'package:passql_app/core/auth/social_sign_in.dart';
import 'package:passql_app/presentation/pages/login/social_login_button.dart';
import 'package:passql_app/core/auth/token_store.dart';
import 'package:passql_app/data/sources/api_providers.dart';
import 'package:passql_app/core/push/firebase_push_messaging_client.dart';
import 'package:passql_app/core/push/push_permission_prompt_store.dart';
import 'package:passql_app/main.dart' show PassqlApp;
import 'package:passql_app/presentation/providers/ad_providers.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/question_providers.dart';
import 'package:passql_app/presentation/providers/push_notification_providers.dart';
import 'package:passql_app/presentation/providers/theme_mode_provider.dart';
import 'package:passql_app/presentation/design/design.dart' show PassqlPressable, PassqlSemanticButton;
import 'package:passql_app/presentation/widgets/community/community_compose_bar.dart';
import 'package:passql_app/presentation/widgets/common/app_toast.dart';
import 'package:passql_app/presentation/widgets/question/ai_explain_sheet.dart';
import 'package:passql_app/presentation/widgets/settings/settings_group.dart';
import 'package:passql_app/router/app_launch_gate_routing.dart';
import 'package:passql_app/router/app_router.dart';
import 'package:passql_app/router/app_routes.dart';
import 'package:passql_app/router/result_route_arguments.dart';
import 'package:passql_app/data/models/question/submit_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shot_concept_responses.dart';
import 'shot_concept_sweep.dart';
import 'shot_plan_responses.dart';

// 시뮬레이터는 호스트 파일시스템을 그대로 보므로, 이 파일에 적은 경로로 이동한다.
// 같은 빌드로 화면만 바꿔 여러 장을 찍기 위한 장치다.
String _readRoute() {
  const shotRouteDefine = String.fromEnvironment('SHOT_ROUTE');
  if (shotRouteDefine.isNotEmpty) return shotRouteDefine;
  try {
    return File('/tmp/passql_shot_route.txt').readAsStringSync().trim();
  } catch (_) {
    return '/home';
  }
}

// 의견 보내기 전송 결과 연출 (limit 이면 하루 한도 거절)
String _readFeedbackScenario() {
  try {
    return File('/tmp/passql_shot_feedback.txt').readAsStringSync().trim();
  } catch (_) {
    return '';
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
    item('general-3-read', 'DAILY_SET_REMINDER', '오늘의 세트가 준비됐어요', '5문제로 실력을 확인해 보세요.', const Duration(days: 1), linkTarget: 'DAILY_SET'),
    item('general-4-read', 'ADMIN_MESSAGE', '시험 D-30', 'SQLD 63회까지 30일 남았어요.', const Duration(days: 2), linkTarget: 'HOME'),
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
      '제63회 SQLD 대비 문제 업데이트 안내',
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
    notice('notice-4-old', '오늘의 세트 리더보드 오픈', '매일 5문제를 풀고 친구들과 순위를 겨뤄 보세요.', const Duration(days: 21), isVisible: false),
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
    'isAndroidBillingEnabled': isShotBillingEnabled,
    'maintenance': {
      'isUnderMaintenance': _appConfigScenario == 'maintenance',
      'message': '서버 안정화 작업으로 10월 16일 02:00 ~ 04:00 동안 점검해요.\n이용에 불편을 드려 죄송해요.',
    },
    'notices': [
      if (_appConfigScenario == 'notice')
        {
          'noticeUuid': '66666666-0000-4000-8000-000000000001',
          'title': '제63회 SQLD 시험 대비 문제 업데이트 안내',
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
  ['11111111-0000-4000-8000-000000000007', 'sql_group_aggregate', '그룹함수 / 집계'],
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
  {
    'topicCode': 'sql_basic_select',
    'topicName': 'SELECT 기본',
    'latestTrendQuestionCount': 5,
  },
  {
    'topicCode': 'sql_subquery',
    'topicName': '서브쿼리',
    'latestTrendQuestionCount': 4,
  },
  {
    'topicCode': 'sql_ddl_dml_tcl',
    'topicName': 'DDL / DML / TCL',
    'latestTrendQuestionCount': 6,
  },
  {
    'topicCode': 'sql_group_aggregate',
    'topicName': '그룹함수 / 집계',
    'latestTrendQuestionCount': 4,
  },
  {
    'topicCode': 'sql_window',
    'topicName': '윈도우 함수',
    'latestTrendQuestionCount': 2,
  },
  {
    'topicCode': 'sql_function',
    'topicName': 'SQL 함수',
    'latestTrendQuestionCount': 3,
  },
];

// 토픽 코드 > 토픽 이름·최신 경향 문제 수 (목록에 없으면 이름 null, 0개 = 탭 불가 상태)
Map<String, dynamic> _trendTopicFields(String topicCode) {
  final topic = _latestTrendTopics
      .where((t) => t['topicCode'] == topicCode)
      .firstOrNull;
  return {
    'topicCode': topicCode,
    'topicName': topic?['topicName'],
    'latestTrendQuestionCount': topic?['latestTrendQuestionCount'] ?? 0,
  };
}

// 최신 경향 문제 수 합계 (토픽별 합)
final _latestTrendQuestionTotal = _latestTrendTopics.fold<int>(
  0,
  (sum, t) => sum + (t['latestTrendQuestionCount'] as int),
);

Map<String, dynamic> _examTrendReport() => {
  'title': '2026 SQLD 출제 경향',
  'basisDescription': '제58~62회 복원 기출과 수험생 후기·오픈채팅 분석',
  'updatedDate': '2026-10-20',
  'summary':
      '짧은 쿼리에 NULL 함정을 숨기고 결과를 따라가게 하는 문제가 중심이에요. 62회는 쉬웠다는 말이 많았지만 합격률은 낮았어요.',
  'latestTrendQuestionCount': _latestTrendQuestionTotal,
  'subjectShares': [
    {
      'subjectName': '1과목 데이터 모델링의 이해',
      'questionCount': 10,
      'percent': 20,
      'description': '정의 암기보다 참여도·상호배타·다중값 속성을 지문 상황에 적용하는 문제가 늘었어요.',
    },
    {
      'subjectName': '2과목 SQL 기본과 활용',
      'questionCount': 40,
      'percent': 80,
      'description': '대부분이 결과 행 수·값·오류 여부를 직접 계산하는 추적형이에요.',
    },
  ],
  'risingPatterns': [
    {
      'title': '결과 비교형 보기',
      'description': '보기마다 SQL을 주고 결과 행 수가 가장 많은 것, 결과가 다른 것을 고르는 문제예요.',
      'examRoundsText': '61·62회 각 4문항',
      ..._trendTopicFields('sql_join'),
    },
    {
      'title': '짧은 쿼리 속 NULL 함정',
      'description':
          '쿼리는 짧은데 NOT IN, 빈 결과 집계, NULL 비교, NULL 치환 함수를 섞어 결과를 바꿔요.',
      'examRoundsText': '62회 9문항',
      ..._trendTopicFields('sql_group_aggregate'),
    },
    {
      'title': '오류 나는 SQL 고르기',
      'description': '인라인 뷰 별칭을 바깥에서 쓰거나 스칼라 서브쿼리가 여러 행을 돌려주는 SQL을 찾아요.',
      'examRoundsText': '58·61·62회 각 3문항',
      ..._trendTopicFields('sql_subquery'),
    },
    {
      'title': '제약조건 아래 DML 성공 판정',
      'description': 'PK·UNIQUE·CHECK·NOT NULL이 걸린 테이블에 어떤 INSERT가 성공하는지 따져요.',
      'examRoundsText': '60회 4문항, 62회 1문항',
      ..._trendTopicFields('sql_ddl_dml_tcl'),
    },
    {
      'title': '관리 구문 최종 상태 추적',
      'description':
          'MERGE의 DELETE 절, INSERT FIRST, COMMIT 뒤 SAVEPOINT, 중첩 ROLE 회수 후 결과를 물어요.',
      'examRoundsText': '62회 관리 구문 9문항',
      ..._trendTopicFields('sql_ddl_dml_tcl'),
    },
    {
      'title': 'ROWNUM 실행 순서',
      'description': 'ROWNUM이 ORDER BY보다 먼저 붙는 점과 부등 조건에서 행이 탈락하는 점을 노려요.',
      'examRoundsText': '61회 3문항, 62회 2문항',
      ..._trendTopicFields('sql_basic_select'),
    },
    {
      'title': 'GROUP BY 키 조합과 HAVING',
      'description': '그룹 키에 어떤 컬럼이 들어가는지, HAVING 조건을 WHERE로 옮길 수 있는지 판단해요.',
      'examRoundsText': '60·62회 각 2문항',
      ..._trendTopicFields('sql_group_aggregate'),
    },
    {
      'title': '1과목 상황 판단형',
      'description': '관계선 기호로 참여도를 읽고, 상호배타 관계와 트랜잭션의 역할을 상황에 맞게 골라요.',
      'examRoundsText': '62회 오답이 많았던 영역',
      ..._trendTopicFields('data_modeling'),
    },
  ],
  'frequentConcepts': [
    {
      'rank': 1,
      'name': '관리 구문·제약조건',
      'description':
          'MERGE, INSERT FIRST, SAVEPOINT, ROLE, CTAS, 제약조건 아래 INSERT',
      'frequencyText': '5회 합계 26문항',
      ..._trendTopicFields('sql_ddl_dml_tcl'),
    },
    {
      'rank': 2,
      'name': '조인',
      'description': '외부조인 ON과 WHERE 조건 위치, NATURAL·USING 규칙, 결과 행 수',
      'frequencyText': '5회 합계 20문항',
      ..._trendTopicFields('sql_join'),
    },
    {
      'rank': 3,
      'name': '서브쿼리',
      'description': 'ANY·ALL, 다중 컬럼 IN, 상관 조건 없는 EXISTS, NOT IN과 NULL',
      'frequencyText': '5회 합계 19문항',
      ..._trendTopicFields('sql_subquery'),
    },
    {
      'rank': 4,
      'name': '집계 함수와 NULL',
      'description': 'COUNT(*)와 COUNT(컬럼), 빈 결과에서 0·NULL·결과 없음 구분',
      'frequencyText': '5회 합계 16문항',
      ..._trendTopicFields('sql_group_aggregate'),
    },
    {
      'rank': 5,
      'name': '계층형 질의·PIVOT',
      'description': 'PRIOR 위치와 전개 방향, LEVEL, UNPIVOT IN 절',
      'frequencyText': '5회 합계 15문항',
      ..._trendTopicFields('sql_hierarchy_pivot'),
    },
    {
      'rank': 6,
      'name': 'GROUP BY 확장·HAVING',
      'description': 'ROLLUP·CUBE·GROUPING SETS 결과 행, 괄호 묶음, HAVING 조건',
      'frequencyText': '5회 합계 14문항',
      ..._trendTopicFields('sql_group_aggregate'),
    },
    {
      'rank': 7,
      'name': '윈도우 함수',
      'description': 'RANK·DENSE_RANK·ROW_NUMBER, 기본 프레임 누적합, LAG',
      'frequencyText': '5회 합계 14문항 (62회 0문항)',
      ..._trendTopicFields('sql_window'),
    },
    {
      'rank': 8,
      'name': 'NULL 치환·단일행 함수',
      'description': 'NVL·NVL2·COALESCE·NULLIF, SUBSTR·ROUND, 묵시적 형변환',
      'frequencyText': '5회 합계 13문항',
      ..._trendTopicFields('sql_function'),
    },
    {
      'rank': 9,
      'name': '페이징·정렬',
      'description': 'ROWNUM, FETCH FIRST WITH TIES, NULL 정렬 위치',
      'frequencyText': '5회 합계 9문항',
      ..._trendTopicFields('sql_basic_select'),
    },
    {
      'rank': 10,
      'name': '3값 논리·연산자 우선순위',
      'description': 'NULL 비교와 UNKNOWN, NOT BETWEEN, NOT·AND·OR 순서',
      'frequencyText': '5회 합계 8문항',
      ..._trendTopicFields('sql_basic_select'),
    },
  ],
  'studyTips': [
    '쉬웠다는 체감과 달리 합격률은 낮았어요. 짧은 쿼리일수록 NULL 함정을 의심하세요.',
    '조건에 맞는 행이 없을 때 결과가 0인지, NULL인지, 행이 아예 없는지 구분하세요. GROUP BY가 붙으면 결과 행이 사라져요.',
    'ROWNUM은 ORDER BY보다 먼저 붙어요. 중간 번호를 건너뛰는 조건을 쓰면 그 뒤 행도 모두 떨어져요.',
    '관리 구문은 개념보다 최종 상태를 물어요. COMMIT 뒤에는 SAVEPOINT가 사라지고, INSERT FIRST는 처음 참인 분기에만 넣어요.',
    '62회엔 윈도우 함수가 없었지만 58~61회엔 매 회 2~4문항이 나왔어요. 빼놓지 말고 정리해 두세요.',
    '복원 기출 점수는 실제보다 높게 나오는 편이에요. 기출 모의고사에서 80점 이상을 목표로 잡으세요.',
    '1과목은 10문항 중 4문항 미만이면 과락이에요. 상호배타 관계, 다중값 속성, 참여도 읽기를 상황 문제로 연습해 두세요.',
  ],
  'latestTrendTopics': _latestTrendTopics,
};

final _questions = [
  _summary(1, 'SELECT 기본', 'EMP 테이블에서 급여가 3000 이상인 사원의 이름을 조회하는 SQL로 알맞은 것은?', 1),
  _summary(2, 'JOIN', '두 테이블을 내부 조인할 때 결과 행 수가 가장 적은 조인 방식은?', 2),
  _summary(3, '그룹함수 / 집계', 'GROUP BY 절과 HAVING 절의 차이로 올바른 설명은?', 2),
  _summary(4, '윈도우 함수', 'RANK() OVER 와 DENSE_RANK() OVER 의 결과 차이는?', 3),
];

// 오늘의 세트: 운영과 같은 5문제 (AdminDailyChallengeService.MAX_QUESTIONS_PER_DAY, #644)
const _dailySetQuestionCount = 5;

List<Map<String, dynamic>> _dailySetQuestions() => [
  for (var i = 0; i < _dailySetQuestionCount; i++)
    {..._questions[i % _questions.length], 'questionUuid': 'dddddddd-0000-4000-8000-${(i + 1).toString().padLeft(12, '0')}'},
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
  // 개념 학습 (#577)
  final conceptResponse = conceptShotResponse(o);
  if (conceptResponse != null || p.contains('/concepts/')) return conceptResponse;
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
    return {'questions': _dailySetQuestions(), 'alreadyCompleted': false};
  }
  if (p.endsWith('/daily-set/leaderboard')) {
    return {
      'date': '2026-10-07',
      'entries': [
        {'rank': 1, 'nickname': '쿼리장인', 'correctCount': 5},
        {'rank': 2, 'nickname': '조인마스터', 'correctCount': 5},
        {'rank': 3, 'nickname': '새찬', 'correctCount': 4},
        {'rank': 4, 'nickname': '셀렉트냥', 'correctCount': 4},
        {'rank': 5, 'nickname': '인덱스요정', 'correctCount': 3},
      ],
      'myEntry': {'rank': 3, 'nickname': '새찬', 'correctCount': 4},
    };
  }
  if (p.endsWith('/exam-schedules/selected')) {
    return {'examScheduleUuid': '44444444-0000-4000-8000-000000000001', 'certType': 'SQLD', 'round': 63, 'examDate': '2026-11-14', 'isSelected': true};
  }
  // 토론 탭 (#741): 피드 문제 줄, 문제별 의견 목록
  if (p.endsWith('/community/feed')) {
    final source = o.queryParameters['source'];
    // 최신 경향 보기는 빈 목록 (빈 화면 가운데 정렬 확인용)
    if (source == 'trend') return {'items': <Object>[], 'nextCursor': null};
    return {'items': _communityFeedItems(isMine: source == 'mine'), 'nextCursor': null};
  }
  if (RegExp(r'/community/questions/[^/]+/posts$').hasMatch(p) && o.method == 'GET') {
    final isLikesSort = o.queryParameters['sort'] == 'likes';
    final posts = _communityPosts();
    if (isLikesSort) posts.sort((a, b) => (b['likeCount'] as int).compareTo(a['likeCount'] as int));
    return {'items': posts, 'nextCursor': null};
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
  if (p.endsWith('/members/me/plan')) return memberPlanShotResponse();
  if (p.endsWith('/ai/choice-explanation')) return choiceExplanationShotResponse();
  if (p.endsWith('/questions/random')) return _questions;
  if (p.endsWith('/submit') && o.method == 'POST') return submitShotResponse(correctSql: _executableChoiceSql);
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

// 토론 탭 (#741): 안 푼 문제(잠금) uuid. 이 문제의 의견 목록은 COMMUNITY_SOLVE_REQUIRED 로 거절
const _communityLockedQuestionUuid = '55555555-0000-4000-8000-000000000003';

List<Map<String, dynamic>> _communityFeedItems({required bool isMine}) {
  const rows = [
    ('55555555-0000-4000-8000-000000000001', 'sql_window', '윈도우 함수', '다음 중 RANK와 DENSE_RANK의 결과가 달라지는 행은?', 12, '2026-10-07T08:57:00', true),
    ('55555555-0000-4000-8000-000000000002', 'sql_function', 'SQL 함수 (문자/숫자/날짜/NULL)', 'EMP 테이블에서 COUNT(*)와 COUNT(COMM)의 결과가 다른 이유로 옳은 것은? (COMM 컬럼에는 NULL 값이 포함되어 있다)', 8, '2026-10-07T08:48:00', true),
    (_communityLockedQuestionUuid, 'sql_hierarchy_pivot', '계층 쿼리 / PIVOT', '다음 SQL에서 START WITH … CONNECT BY PRIOR의 방향을 바꾸면 출력 순서는 어떻게 되는가?', 5, '2026-10-07T08:20:00', false),
    ('55555555-0000-4000-8000-000000000004', 'sql_join', '조인 (JOIN)', 'LEFT OUTER JOIN에서 오른쪽 테이블 조건을 ON절과 WHERE절에 둘 때 결과 행 수의 차이는?', 4, '2026-10-07T08:00:00', true),
    ('55555555-0000-4000-8000-000000000005', 'sql_group_aggregate', '그룹함수 / 집계', 'GROUP BY ROLLUP(DEPTNO, JOB)의 결과 행 수로 옳은 것은?', 3, '2026-10-07T07:00:00', true),
  ];
  return [
    for (final (uuid, code, name, stem, count, at, isSolved) in rows)
      if (!isMine || isSolved)
        {
          'questionUuid': uuid,
          'stemPreview': stem,
          'topicCode': code,
          'topicName': name,
          'postCount': count,
          'lastActivityAt': at,
          'isSolvedByMe': isSolved,
          'myPostCount': isMine ? 2 : null,
          'receivedLikeCount': isMine ? 5 : null,
        },
  ];
}

// 최신순(기본) 순서. 첫 글은 3줄 넘는 본문(더 보기), 마지막은 내 글
List<Map<String, dynamic>> _communityPosts() => [
  {
    'postUuid': '66666666-0000-4000-8000-000000000001',
    'authorNickname': '합격가즈아',
    'content': 'NULL 행이 COUNT(컬럼)에서 빠진다는 건 알았는데 보기 3번에 NVL이 끼어 있어서 또 틀렸어요. NVL(COMM, 0)으로 감싸면 NULL이 0이 돼서 COUNT에 잡히는 거였네요. 시험장에서 이런 거 나오면 바로 헷갈릴 것 같아요.',
    'isMine': false,
    'likeCount': 12,
    'isLikedByMe': true,
    'solveSnapshot': {'isCorrect': false, 'attemptCount': 3},
    'createdAt': '2026-10-07T08:48:00',
    'images': <Map<String, dynamic>>[],
  },
  {
    'postUuid': '66666666-0000-4000-8000-000000000002',
    'authorNickname': '코딩고래',
    'content': '집계 함수는 NULL을 건너뛰는데 COUNT(*)만 행 자체를 세요.',
    'isMine': false,
    'likeCount': 9,
    'isLikedByMe': false,
    'solveSnapshot': {'isCorrect': true, 'attemptCount': 1},
    'createdAt': '2026-10-07T08:20:00',
    'images': <Map<String, dynamic>>[],
  },
  {
    'postUuid': '66666666-0000-4000-8000-000000000003',
    'authorNickname': 'sqld합격',
    'content': 'AVG(COMM)도 NULL 행을 빼고 나누니까 SUM(COMM)/COUNT(*)와 값이 달라져요.',
    'isMine': true,
    'likeCount': 0,
    'isLikedByMe': false,
    'solveSnapshot': null,
    'createdAt': '2026-10-07T08:00:00',
    'images': <Map<String, dynamic>>[],
  },
];

/// 실행형(EXECUTABLE) 문제: execute-fail 연출용, 실행 API 는 SANDBOX_TIMEOUT 으로 실패
const _executableQuestionUuid = '22222222-0000-4000-8000-000000000005';
const _executableChoiceSql = 'SELECT ENAME FROM EMP WHERE SAL >= 3000;';

// 연출 execute-ok 일 때만 실행 API 성공 (그 외 SANDBOX_TIMEOUT)
var _isExecuteSuccessScene = false;
const _executeSuccessResult = {
  'status': 'SUCCESS',
  'columns': ['ENAME'],
  'rows': [['KING'], ['FORD'], ['SCOTT']],
  'rowCount': 3,
  'elapsedMs': 12,
  'errorCode': null,
  'errorMessage': null,
};

// 실습 실행 연출 (#727): SQL 에 4000 이 있으면 KING 1행, 아니면 3행
Map<String, dynamic> _executeShotResultOf(Object? requestData) {
  final isRaisedThreshold = jsonEncode(requestData).contains('4000');
  if (!isRaisedThreshold) return _executeSuccessResult;
  return {
    ..._executeSuccessResult,
    'rows': [['KING']],
    'rowCount': 1,
    'elapsedMs': 9,
  };
}

Map<String, dynamic> _executableDetail() {
  final detail = _detail();
  final choiceSet = Map<String, dynamic>.from((detail['choiceSets'] as List).first as Map);
  return {
    ...detail,
    'questionUuid': _executableQuestionUuid,
    'executionMode': 'EXECUTABLE',
    // 실습 입력 보조 3줄째(표·열 이름) 연출 (#727)
    'schemaTables': [
      {
        'tableName': 'EMP',
        'columns': [
          {'name': 'EMPNO', 'type': 'NUMBER'},
          {'name': 'ENAME', 'type': 'VARCHAR2(20)'},
          {'name': 'JOB', 'type': 'VARCHAR2(20)'},
          {'name': 'SAL', 'type': 'NUMBER'},
          {'name': 'DEPTNO', 'type': 'NUMBER'},
        ],
        'sampleRows': [
          [7839, 'KING', 'PRESIDENT', 5000, 10],
          [7788, 'SCOTT', 'ANALYST', 3000, 20],
          [7902, 'FORD', 'ANALYST', 3000, 20],
          [7566, 'JONES', 'MANAGER', 2975, 20],
        ],
      },
    ],
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
    if (isProRequiredShotPath(options.path)) {
      return ResponseBody.fromString(
        jsonEncode({'errorCode': 'PRO_REQUIRED', 'message': 'pro required'}),
        403,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }
    if (options.path.endsWith('/generate-choices')) {
      // ...0004 문제는 실행 결과형(RESULT_MATCH)으로 응답한다.
      final rm = options.path.contains('000000000004');
      return ResponseBody.fromString(_sse(resultMatch: rm), 200, headers: {Headers.contentTypeHeader: ['text/event-stream']});
    }
    // 토론 탭 잠금 연출 (#741): 안 푼 문제의 의견 목록은 서버처럼 풀이 필요로 거절
    if (options.path.endsWith('/community/questions/$_communityLockedQuestionUuid/posts')) {
      return ResponseBody.fromString(
        jsonEncode({'errorCode': 'COMMUNITY_SOLVE_REQUIRED', 'message': '문제를 풀고 나서 의견을 볼 수 있어요.'}),
        403,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }
    if (options.path.endsWith('/execute') && _isExecuteSuccessScene) {
      return ResponseBody.fromString(jsonEncode(_executeShotResultOf(options.data)), 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
    }
    if (options.path.endsWith('/execute')) {
      return ResponseBody.fromString(
        jsonEncode({'errorCode': 'SANDBOX_TIMEOUT', 'message': 'sandbox timeout'}),
        500,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );
    }
    // 의견 보내기 (#708): 기본 성공, /tmp/passql_shot_feedback.txt 가 limit 이면 하루 한도 거절
    if (options.method == 'POST' && options.path.endsWith('/feedback')) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final isLimit = _readFeedbackScenario() == 'limit';
      return ResponseBody.fromString(
        isLimit ? jsonEncode({'errorCode': 'FEEDBACK_DAILY_LIMIT_EXCEEDED', 'message': '오늘은 의견을 더 보낼 수 없어요. 내일 다시 보내 주세요.'}) : '',
        isLimit ? 429 : 204,
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
  // 전환 시나리오는 홈에 데이터가 보이도록 세션은 두고, 라우터만 비로그인으로 시작한다.
  if (loggedOut && route != _transitionRoute) {
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
    // 스토어 캡처에 테스트 광고·AdMob 검사 팝업이 찍히지 않게 광고 끔
    adsEnabledProvider.overrideWithValue(false),
    dioProvider.overrideWith((ref) => Dio(BaseOptions(baseUrl: 'http://shots.local/api'))..httpClientAdapter = _FakeAdapter()),
    if (route == _signingInRoute) socialSignInProvider.overrideWithValue(_PendingSocialSignIn()),
    // 시뮬레이터에는 스토어 가격이 없어 할인·권유 줄이 안 보이므로 가짜 가격을 준다 (#749 촬영)
    proPurchasePortProvider.overrideWithValue(const _ShotPurchasePort()),
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

  // 개념 전수 점검은 앱 전체를 캡처 경계로 감싸 화면을 직접 저장
  final isConceptSweep = route == conceptSweepRoute;
  runApp(UncontrolledProviderScope(
    container: container,
    child: isConceptSweep
        ? RepaintBoundary(key: conceptSweepBoundaryKey, child: const PassqlApp())
        : const PassqlApp(),
  ));
  if (isConceptSweep) {
    Timer(const Duration(milliseconds: 3000), () => runConceptSweep(container));
    return;
  }
  startPushNotificationSync(container, AppRouter.router);
  // 첫 프레임 이후 지정한 화면으로 이동한다.
  if (!loggedOut) {
    Timer(const Duration(milliseconds: 2000), () => _openRoute(route, container));
  }
  if (route == _signingInRoute) {
    Timer(const Duration(milliseconds: 2000), _tapFirstSocialLoginButton);
  }
  // 로그인 화면 > 홈 > 로그인 화면 전환을 영상으로 남기기 위해 로그인 상태를 시간차로 바꾼다.
  if (route == _transitionRoute) {
    Timer(const Duration(seconds: 4), () => AppRouter.authenticated.value = true);
    Timer(const Duration(seconds: 9), () => AppRouter.authenticated.value = false);
  }
}

const _transitionRoute = '/login-transition';

const _signingInRoute = '/login-signing-in';

/// 소셜 로그인 응답이 오지 않는 상태: 로그인 중 버튼 모양을 고정해 찍는다
class _PendingSocialSignIn implements SocialSignIn {
  @override
  Future<SocialCredential?> fetchCredential(SocialProvider provider) => Completer<SocialCredential?>().future;

  @override
  Future<bool> revokeAccessForWithdrawal(SocialProvider? provider, {String? providerUserId}) async => true;

  @override
  Future<void> disconnectAfterWithdrawal(SocialProvider? provider) async {}

  @override
  Future<void> signOut() async {}
}

/// 시뮬레이터는 탭을 보낼 수 없으므로 첫 소셜 버튼(카카오)의 탭 콜백을 직접 부른다
void _tapFirstSocialLoginButton() {
  VoidCallback? onPressed;
  void visit(Element element) {
    final widget = element.widget;
    if (onPressed == null && widget is SocialLoginButton) onPressed = widget.onPressed;
    if (onPressed == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onPressed?.call();
}

/// 경로 이동 또는 연출 5종(execute-ok, execute-fail, chapter-result, ai-sheet, result)
Future<void> _openRoute(String route, ProviderContainer container) async {
  const settleDelay = Duration(milliseconds: 1500);
  switch (route) {
    case 'execute-ok':
      // 실행형 문제 > 선택지 A 선택·실행 > 실행 성공 결과 표
      _isExecuteSuccessScene = true;
      AppRouter.router.go(AppRoutes.questionDetail(_executableQuestionUuid));
      await Future<void>.delayed(settleDelay);
      container
          .read(questionInteractionProvider(_executableQuestionUuid).notifier)
          .selectChoice('A');
      await container
          .read(questionInteractionProvider(_executableQuestionUuid).notifier)
          .runChoice(choiceKey: 'A', sql: _executableChoiceSql);
    case 'execute-fail':
      // 실행형 문제 > 선택지 A 선택·실행 > 실행 API 실패
      AppRouter.router.go(AppRoutes.questionDetail(_executableQuestionUuid));
      await Future<void>.delayed(settleDelay);
      container
          .read(questionInteractionProvider(_executableQuestionUuid).notifier)
          .selectChoice('A');
      await container
          .read(questionInteractionProvider(_executableQuestionUuid).notifier)
          .runChoice(choiceKey: 'A', sql: _executableChoiceSql);
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
    case 'result':
      // 오답 제출 결과 (무료면 실행 결과·해설 잠금), 실습 칸 실행은 성공 (#727)
      _isExecuteSuccessScene = true;
      AppRouter.router.go(AppRoutes.questionDetail(_executableQuestionUuid));
      await Future<void>.delayed(settleDelay);
      AppRouter.router.push(
        AppRoutes.questionResult(_executableQuestionUuid),
        extra: QuestionResultArguments(
          // JSON 왕복: 실제 응답처럼 중첩 맵 타입을 맞춤
          result: SubmitResult.fromJson(jsonDecode(jsonEncode(submitShotResponse(correctSql: _executableChoiceSql))) as Map<String, dynamic>)
              .copyWith(choiceSetUuid: '33333333-0000-4000-8000-000000000001'),
          correctDisplayLabel: 'A',
          selectedChoiceKey: 'B',
          displayLabelByChoiceKey: const {'A': 'A', 'B': 'B', 'C': 'C', 'D': 'D'},
        ),
      );
    case 'onboarding-celebration':
      // 온보딩 첫 문제 뒤 축하 화면 (이어서 풀기)
      AppRouter.router.push(AppRoutes.onboardingCelebration, extra: false);
    case 'onboarding-tour':
      // 온보딩 4장을 차례로 넘긴 뒤 축하 화면까지 (리포트 영상용, 스와이프 대신 페이지 애니메이션)
      AppRouter.router.go(AppRoutes.onboarding);
      for (var pageIndex = 1; pageIndex < 4; pageIndex++) {
        await Future<void>.delayed(const Duration(milliseconds: 2500));
        await _animateFirstPageView(pageIndex);
      }
      await Future<void>.delayed(const Duration(milliseconds: 3000));
      AppRouter.router.push(AppRoutes.onboardingCelebration, extra: false);
    case 'withdraw-confirm':
      // 설정 > 회원 탈퇴 확인창 > 확인 문구 한 글자씩 입력 (리포트 영상용, 입력칸이 없으면 창만 띄움)
      AppRouter.router.go(AppRoutes.settings);
      await Future<void>.delayed(const Duration(milliseconds: 2000));
      // 탈퇴 행은 화면 아래라 스크롤해야 그려진다
      await _scrollFirstScrollableToEnd();
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _tapSettingsRow('회원 탈퇴');
      await Future<void>.delayed(const Duration(milliseconds: 2000));
      for (final typed in const ['탈', '탈퇴', '탈퇴하', '탈퇴하기']) {
        _typeIntoFirstTextField(typed);
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    case 'feedback':
      // 설정 > 의견 보내기 (직전 경로가 설정으로 진단 정보에 담김)
      AppRouter.router.go(AppRoutes.settings);
      await Future<void>.delayed(settleDelay);
      unawaited(AppRouter.router.push(AppRoutes.feedback));
    case 'community-menu':
      // 의견 화면 > 첫 의견 ··· 메뉴 시트 (#741 손잡이 확인)
      AppRouter.router.go(AppRoutes.communityQuestion('55555555-0000-4000-8000-000000000002'));
      await Future<void>.delayed(settleDelay);
      _tapSemanticButton('글 메뉴');
    case 'community-compose':
      // 의견 화면 > 하단 입력줄 > 의견 작성 시트 (#741 손잡이 확인)
      AppRouter.router.go(AppRoutes.communityQuestion('55555555-0000-4000-8000-000000000002'));
      await Future<void>.delayed(settleDelay);
      _tapComposeBar();
    case 'stats-scroll':
      // 내 프로필 > 아래까지 천천히 내렸다 올림 (#749 리포트 영상, 시뮬레이터는 스와이프를 못 보내 직접 스크롤)
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(const Duration(milliseconds: 3000));
      await _scrollFirstVertical(toEnd: true);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      await _scrollFirstVertical(toEnd: false);
    case 'pass-sheet':
      // 내 프로필 > 탑승권 누름 > 무료는 구매 시트, 프로는 접힌 줄 펼침 > 탑승권 > 정보 시트 (#749)
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      if (_tapPressableContaining('펼치기')) {
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
      _tapPressableContaining('passQL');
    case 'pass-sheet-1m':
      // 구매 시트에서 1개월을 골라 3개월 권유 줄이 나오는 장면
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      _tapPressableContaining('passQL');
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      _tapSemanticButtonStarting('1개월');
    case 'nickname-sheet':
      // 내 프로필 > 닉네임 변경 시트 (프로필 카드 편집 콜백을 직접 부름, 전후 버전 모두 동작)
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(settleDelay);
      _tapProfileCard();
    case 'nickname-toast':
      // 내 프로필 + 닉네임 변경 완료 토스트. 토스트가 2초면 사라져 촬영 시점과 어긋나므로 몇 번 다시 띄운다
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(settleDelay);
      for (var i = 0; i < 10; i++) {
        _showShotToast('닉네임이 변경됐어요');
        await Future<void>.delayed(const Duration(milliseconds: 1500));
      }
    case 'nickname-edit':
      // 내 프로필 > 시트 > 새 닉네임 입력 > 시트 닫고 토스트 (리포트 영상용, 저장 API 없이 흐름만 재현)
      AppRouter.router.go(AppRoutes.stats);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      _tapProfileCard();
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      for (final typed in const ['새', '새찬', '새찬이', '새찬이다']) {
        _typeIntoFirstTextField(typed);
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      AppRouter.router.routerDelegate.navigatorKey.currentState?.pop();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      _showShotToast('닉네임이 변경됐어요');
    default:
      // 온보딩 n장: onboarding-2 ~ onboarding-4 (시뮬레이터는 스와이프를 못 보내 페이지를 직접 넘김)
      final onboardingPage = RegExp(r'^onboarding-([1-4])$').firstMatch(route);
      if (onboardingPage == null) {
        AppRouter.router.go(route);
        return;
      }
      AppRouter.router.go(AppRoutes.onboarding);
      await Future<void>.delayed(settleDelay);
      _jumpFirstPageView(int.parse(onboardingPage.group(1)!) - 1);
  }
}

/// 시뮬레이터는 탭을 보낼 수 없으므로 프로필 카드의 편집 콜백을 직접 부른다
/// 시뮬레이터는 탭을 보낼 수 없으므로 라벨이 같은 첫 시맨틱 버튼의 탭 콜백을 직접 부른다
void _tapSemanticButton(String label) {
  VoidCallback? onTap;
  void visit(Element element) {
    final widget = element.widget;
    if (onTap == null && widget is PassqlSemanticButton && widget.label == label) onTap = widget.onTap;
    if (onTap == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onTap?.call();
}

/// 의견 화면 하단 입력줄 탭 콜백을 직접 부른다
void _tapComposeBar() {
  VoidCallback? onTap;
  void visit(Element element) {
    final widget = element.widget;
    if (onTap == null && widget is CommunityComposeBar) onTap = widget.onTap;
    if (onTap == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onTap?.call();
}

/// 시맨틱 라벨에 [text] 가 들어간 첫 PassqlPressable 의 탭 콜백을 부른다 (찾으면 true)
bool _tapPressableContaining(String text) {
  VoidCallback? onTap;
  void visit(Element element) {
    final widget = element.widget;
    if (onTap == null && widget is PassqlPressable && (widget.semanticLabel?.contains(text) ?? false)) {
      onTap = widget.onTap;
    }
    if (onTap == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onTap?.call();
  return onTap != null;
}

/// 라벨이 [prefix] 로 시작하는 첫 시맨틱 버튼의 탭 콜백을 부른다 (이용권 칸 고르기)
void _tapSemanticButtonStarting(String prefix) {
  VoidCallback? onTap;
  void visit(Element element) {
    final widget = element.widget;
    if (onTap == null && widget is PassqlSemanticButton && widget.label.startsWith(prefix)) onTap = widget.onTap;
    if (onTap == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onTap?.call();
}

/// 화면의 가장 긴 세로 스크롤을 끝(또는 처음)까지 천천히 움직인다
Future<void> _scrollFirstVertical({required bool toEnd}) async {
  ScrollPosition? longest;
  void visit(Element element) {
    if (element is StatefulElement && element.state is ScrollableState) {
      final position = (element.state as ScrollableState).position;
      if (position.axis == Axis.vertical && (longest == null || position.maxScrollExtent > longest!.maxScrollExtent)) {
        longest = position;
      }
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  final position = longest;
  if (position == null) return;
  await position.animateTo(
    toEnd ? position.maxScrollExtent : 0,
    duration: const Duration(milliseconds: 3500),
    curve: Curves.easeInOut,
  );
}

void _tapProfileCard() {
  VoidCallback? onEdit;
  void visit(Element element) {
    final widget = element.widget;
    // 닉네임 편집은 내 프로필 맨 위 이름 줄 (#749, 이전 프로필 카드 대신)
    if (onEdit == null && widget is PassqlPressable && (widget.semanticLabel?.startsWith('닉네임 ') ?? false)) {
      onEdit = widget.onTap;
    }
    if (onEdit == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onEdit?.call();
}

/// 앱 공통 토스트를 현재 화면에 띄운다
void _showShotToast(String message) {
  final context = AppRouter.router.routerDelegate.navigatorKey.currentContext;
  if (context != null && context.mounted) showAppToast(context, message);
}

/// 시뮬레이터는 탭을 보낼 수 없으므로 제목이 같은 설정 행의 탭 콜백을 직접 부른다
void _tapSettingsRow(String title) {
  VoidCallback? onTap;
  void visit(Element element) {
    final widget = element.widget;
    if (onTap == null && widget is SettingsRow && widget.title == title) onTap = widget.onTap;
    if (onTap == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  onTap?.call();
}

/// 화면의 첫 스크롤 영역을 끝까지 내린다 (아래쪽 행 촬영용)
Future<void> _scrollFirstScrollableToEnd() async {
  ScrollableState? scrollable;
  void visit(Element element) {
    if (scrollable == null && element is StatefulElement && element.state is ScrollableState) {
      scrollable = element.state as ScrollableState;
    }
    if (scrollable == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  final position = scrollable?.position;
  if (position == null) return;
  await position.animateTo(position.maxScrollExtent, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
}

/// 키보드 입력처럼 첫 입력칸 값을 바꾼다 (onChanged 까지 불림)
void _typeIntoFirstTextField(String text) {
  EditableTextState? field;
  void visit(Element element) {
    if (field == null && element is StatefulElement && element.state is EditableTextState) {
      field = element.state as EditableTextState;
    }
    if (field == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  field?.updateEditingValue(
    TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length)),
  );
}

/// 화면의 첫 PageView 를 지정한 페이지로 넘긴다 (온보딩 촬영용)
void _jumpFirstPageView(int pageIndex) {
  PageController? controller;
  void visit(Element element) {
    final widget = element.widget;
    if (controller == null && widget is PageView) controller = widget.controller;
    if (controller == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  controller?.jumpToPage(pageIndex);
}

/// 화면의 첫 PageView 를 손으로 넘긴 것처럼 미끄러뜨려 넘긴다 (온보딩 영상용)
Future<void> _animateFirstPageView(int pageIndex) async {
  PageController? controller;
  void visit(Element element) {
    final widget = element.widget;
    if (controller == null && widget is PageView) controller = widget.controller;
    if (controller == null) element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  await controller?.animateToPage(
    pageIndex,
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeOutCubic,
  );
}

/// 촬영용 결제 포트: 가격만 돌려주고 결제·복원은 하지 않는다 (앱 코드 주석의 예시 가격과 같은 값)
class _ShotPurchasePort implements ProPurchasePort {
  const _ShotPurchasePort();

  @override
  Future<Map<String, PassPrice>> loadPassPrices(List<String> productIds) async => const {
    'pro_pass_3m': PassPrice(displayPrice: '9,900원', rawPrice: 9900),
    'pro_pass_1m': PassPrice(displayPrice: '4,400원', rawPrice: 4400),
  };

  @override
  Future<ProPurchaseOutcome> purchasePass(String productId) async => ProPurchaseOutcome.cancelled;

  @override
  Future<ProPurchaseOutcome> restorePurchases() async => ProPurchaseOutcome.nothingToRestore;
}
