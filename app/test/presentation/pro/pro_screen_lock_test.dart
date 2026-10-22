import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/member/member_plan_response.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/exam_trend/exam_trend_page.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/presentation/pages/settings/settings_page.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/ad_providers.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/widgets/pro/locked_preview_samples.dart';
import 'package:passql_app/presentation/widgets/pro/pro_settings_card.dart';
import 'package:passql_app/presentation/widgets/settings/settings_group.dart';

import '../../helpers/fakes/fake_http_client_adapter.dart';
import '../../helpers/fakes/fake_pro_plan.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/text_finders.dart';

// 프로(결제 켜짐) 등급
final _proPlan = MemberPlanResponse(
  isBillingEnabled: true,
  plan: MemberPlanType.pro,
  proExpiresAt: DateTime(2026, 11, 22, 23, 59, 59),
  dailyFreeLimit: 10,
);

// 화면별 잠긴 기능 경로: 결제 꺼짐이면 그대로 부르고, 무료면 아예 요청하지 않아야 함 (서버 403)
const _lockedPathsByScreen = {
  '홈': ['/questions/recommendations'],
  '문제': ['/exam-trends/latest/topics'],
  '통계': ['/progress/topic-analysis', '/progress/ai-comment'],
  '출제 경향': ['/exam-trends/latest'],
  '설정': ['/progress/wrong-questions'],
};
final _lockedPaths = {
  for (final paths in _lockedPathsByScreen.values) ...paths,
};

/// 요청 경로를 기록하는 가짜 서버 (목록 응답이 필요한 경로만 채움)
class _RecordingServer {
  late final adapter = FakeHttpClientAdapter(_respond);

  List<String> get requestedPaths =>
      adapter.requests.map((request) => request.path).toList();

  List<String> get requestedLockedPaths =>
      requestedPaths.where(_lockedPaths.contains).toList();

  static ResponseBody _respond(RequestOptions options) {
    switch (options.path) {
      case '/meta/topics':
        return jsonListResponseBody(200, [
          {
            'topicUuid': 't1',
            'code': 'sql_join',
            'displayName': 'JOIN',
            'isActive': true,
            'sortOrder': 1,
          },
        ]);
      case '/exam-trends/latest/topics':
        return jsonListResponseBody(200, const []);
      case '/progress':
        return jsonResponseBody(200, {
          'solvedCount': 12,
          'correctRate': 0.6,
          'streakDays': 3,
        });
      default:
        return jsonResponseBody(200, const {});
    }
  }
}

/// 화면 1개를 등급·가짜 서버와 함께 띄움 (광고 꺼짐)
Future<_RecordingServer> _pumpPage(
  WidgetTester tester,
  Widget page,
  MemberPlanResponse plan, {
  List<Override> extraOverrides = const [],
}) async {
  final server = _RecordingServer();
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // 등급 조회 중에 화면이 열리고 첫 프레임 뒤 등급 도착 (그 사이 잠긴 요청이 새지 않아야 함)
  final planArrival = Completer<void>();
  final container = await signedInPlanContainer(
    adapter: server.adapter,
    plan: plan,
    planArrival: planArrival.future,
    extraOverrides: [
      adsEnabledProvider.overrideWithValue(false),
      ...extraOverrides,
    ],
  );
  await pumpApp(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: PassqlTheme.light,
        routerConfig: GoRouter(
          routes: [GoRoute(path: '/', builder: (_, _) => page)],
        ),
      ),
    ),
  );
  await tester.pump();
  planArrival.complete();
  await tester.pump();
  await pumpUntilMotionDone(tester);
  return server;
}

// 설정 화면: 회원 정보·앱 버전은 고정값 (오답 개수는 실제 Provider 로 요청 여부 확인)
final _settingsOverrides = <Override>[
  settingsDataProvider.overrideWith(
    (ref) async => const SettingsData(
      memberUuid: 'm-1',
      nickname: '새찬',
      choiceMode: ChoiceGenerationMode.practice,
    ),
  ),
  currentAppVersionProvider.overrideWith((ref) async => '1.0.0'),
];

// 홈: 진행 현황·오늘의 세트·히트맵은 비움 (잠금과 무관한 묶음)
final _homeOverrides = <Override>[
  homeLearningStatusProvider.overrideWith(
    (ref) async => const HomeLearningStatus(),
  ),
];

void main() {
  final keyScreens = <String, (Widget, List<Override>)>{
    '홈': (const HomePage(), _homeOverrides),
    '문제': (const TopicListPage(), const []),
    '통계': (const StatsPage(), const []),
    '출제 경향': (const ExamTrendPage(), const []),
    '설정': (const SettingsPage(), _settingsOverrides),
  };

  for (final screen in keyScreens.entries) {
    testWidgets('billingDisabled_noChipNoBlur: ${screen.key}', (tester) async {
      final server = await _pumpPage(
        tester,
        screen.value.$1,
        billingOffPlan,
        extraOverrides: screen.value.$2,
      );

      // 결제 꺼짐 = 지금처럼 잠긴 기능 API 도 그대로 부름
      expect(
        server.requestedPaths,
        containsAll(_lockedPathsByScreen[screen.key]!),
      );
      expect(find.byType(PassqlPlanChip), findsNothing);
      expect(find.byType(PassqlLockedPreview), findsNothing);
      expect(
        findTextContainingIgnoringWordJoiners('책 없이 폰 하나로 SQLD 합격'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  group('무료 강제 (결제 켜짐)', () {
    testWidgets('홈: FREE 칩, 오늘 랜덤 n / 10, 추천 요청 없음', (tester) async {
      final server = await _pumpPage(
        tester,
        const HomePage(),
        freePlan,
        extraOverrides: _homeOverrides,
      );

      expect(find.byType(PassqlPlanChip), findsOneWidget);
      expect(find.text(PassqlPlanChip.freeLabel), findsOneWidget);
      expect(
        findTextContainingIgnoringWordJoiners('오늘 랜덤 3 / 10'),
        findsOneWidget,
      );
      expect(server.requestedLockedPaths, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('문제: 랜덤 풀기 선명, 토픽·실전·추천 묶음 블러, 최신 경향 요청 없음', (tester) async {
      final server = await _pumpPage(tester, const TopicListPage(), freePlan);

      expect(find.byType(PassqlPlanChip), findsOneWidget);
      expect(find.text('랜덤 풀기'), findsOneWidget);
      expect(find.byType(PassqlLockedPreview), findsOneWidget);
      expect(
        findTextContainingIgnoringWordJoiners(
          LockedPreviewCaptions.practiceModes,
        ),
        findsOneWidget,
      );
      // 진짜 토픽 행은 블러 아래에도 그리지 않음
      expect(find.text('JOIN'), findsNothing);
      expect(server.requestedLockedPaths, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('통계: 기본 수치 선명, 약점·AI 코멘트 블러, 잠긴 통계 요청 없음', (tester) async {
      final server = await _pumpPage(tester, const StatsPage(), freePlan);

      expect(find.byType(PassqlPlanChip), findsOneWidget);
      expect(
        findTextContainingIgnoringWordJoiners(LockedPreviewCaptions.stats),
        findsOneWidget,
      );
      expect(server.requestedPaths, contains('/progress'));
      expect(server.requestedLockedPaths, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('출제 경향: 제목 선명, 본문 블러, 출제 경향 요청 없음', (tester) async {
      final server = await _pumpPage(tester, const ExamTrendPage(), freePlan);

      expect(find.text(ExamTrendPage.pageTitle), findsOneWidget);
      expect(
        findTextContainingIgnoringWordJoiners(LockedPreviewCaptions.examTrend),
        findsOneWidget,
      );
      expect(server.requestedLockedPaths, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('설정: 무료 카드, 오답 개수 요청 없음, 실전 모드 켜기는 PATCH 없이 시트', (
      tester,
    ) async {
      final server = await _pumpPage(
        tester,
        const SettingsPage(),
        freePlan,
        extraOverrides: _settingsOverrides,
      );

      expect(
        findTextContainingIgnoringWordJoiners('책 없이 폰 하나로 SQLD 합격'),
        findsOneWidget,
      );
      expect(
        findTextContainingIgnoringWordJoiners('오늘 3/10문제 사용'),
        findsOneWidget,
      );
      expect(find.text(ProSettingsCard.passLabel), findsOneWidget);
      expect(server.requestedLockedPaths, isEmpty);

      // 실전 모드 행의 스위치 (알림 행에도 스위치가 있음)
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(SettingsRow, '실전 모드'),
          matching: find.byType(CupertinoSwitch),
        ),
      );
      await tester.pump();
      await pumpUntilMotionDone(tester);

      expect(
        server.adapter.requests.where((request) => request.method == 'PATCH'),
        isEmpty,
      );
      expect(find.text('이미 구매했나요? 복원하기'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('설정 프로: 한 줄 회차 패스 · 만료일까지 · PRO', (tester) async {
    await _pumpPage(
      tester,
      const SettingsPage(),
      _proPlan,
      extraOverrides: _settingsOverrides,
    );

    expect(
      findTextContainingIgnoringWordJoiners('회차 패스 · 2026.11.22까지'),
      findsOneWidget,
    );
    expect(
      findTextContainingIgnoringWordJoiners('책 없이 폰 하나로 SQLD 합격'),
      findsNothing,
    );
    expect(find.byType(PassqlLockedPreview), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
