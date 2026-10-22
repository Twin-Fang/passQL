import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/exam_trend/exam_trend_report_response.dart';
import 'package:passql_app/data/models/member/choice_generation_mode.dart';
import 'package:passql_app/data/models/question/choice_item.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/presentation/pages/settings/settings_page.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/auth_provider.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/app_config_providers.dart';
import 'package:passql_app/presentation/providers/settings_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';
import 'package:passql_app/presentation/providers/wrong_questions_provider.dart';
import 'package:passql_app/presentation/widgets/question/choice_item_card.dart';
import 'package:passql_app/presentation/widgets/home/exam_trend_home_section.dart';
import 'package:passql_app/presentation/widgets/question/questions_tab_segmented_control.dart';
import 'package:passql_app/router/questions_tab_view.dart';

import 'settings_layout_test.dart' show SignedInAuth;
import 'tab_pages_test.dart' show homeData, statsData, topics;
import '../helpers/pump_app.dart';

// 시스템 글자 크기 최대(접근성 큰 글자) 수준 배율
const double _systemMaximumTextScaleFactor = 2.0;

/// 출제 경향 유형 카드: 설명 2줄 + 하단 "이 유형 풀기" (고정 높이 넘침 재현 조합, 감사 C3)
const _examTrendReportWithLongDescriptions = ExamTrendReportResponse(
  title: '2026 SQLD 출제 경향',
  basisDescription: '제58~62회 시험 유형 분석',
  updatedDate: '2026-10-18',
  summary: '결과 추적형이 늘었어요.',
  risingPatterns: [
    ExamTrendPattern(
      title: '결과 비교형 보기',
      description: '여러 SQL 실행 결과를 나란히 두고 행 수가 가장 많은 것을 고르는 유형',
      examRoundsText: '58회부터 증가',
      topicCode: 'sql_join',
      topicName: '조인',
      latestTrendQuestionCount: 12,
    ),
  ],
);

/// 시스템 글자 2배 > 앱 상한(PassqlTextScaleLimit) 적용 상태로 화면 1개 그리기
Future<void> _pumpWithLargeText(
  WidgetTester tester,
  Widget page,
  List<Override> overrides, {
  required ThemeData theme,
  Size viewSize = const Size(390, 844),
}) async {
  tester.view.physicalSize = viewSize;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue =
      _systemMaximumTextScaleFactor;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: theme,
        builder: PassqlTextScaleLimit.wrap,
        home: page,
      ),
    ),
  );
  await tester.pump();
  // 섹션 순차 등장이 끝날 때까지
  await pumpUntilMotionDone(tester);
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
        statsAiCommentProvider.overrideWith((ref) async => null),
      ],
    ),
    '설정': (
      const SettingsPage(),
      [
        authProvider.overrideWith(SignedInAuth.new),
        settingsDataProvider.overrideWith(
          (ref) async => const SettingsData(
            memberUuid: 'm-1',
            nickname: '기존닉네임',
            choiceMode: ChoiceGenerationMode.practice,
          ),
        ),
        currentAppVersionProvider.overrideWith((ref) async => '1.0.0'),
        wrongQuestionTotalCountProvider.overrideWith((ref) async => 3),
      ],
    ),
    '홈 출제 경향 유형 카드': (
      Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(PassqlSpacing.md),
          child: ExamTrendHomeSection(
            patterns: _examTrendReportWithLongDescriptions.risingPatterns,
            onSolveTopic: (_, _) {},
            onViewAll: () {},
          ),
        ),
      ),
      const <Override>[],
    ),
    '문제 탭 세그먼트': (
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(PassqlSpacing.md),
          child: QuestionsTabSegmentedControl(
            selectedView: QuestionsTabView.byTopic,
            onSelected: (_) {},
          ),
        ),
      ),
      const <Override>[],
    ),
    '문제 풀이 선택지': (
      Scaffold(
        body: ListView(
          children: [
            for (final (key, kind, body) in const [
              ('A', 'TEXT', '급여가 3000 이상인 사원의 이름을 조회한다'),
              ('B', 'SQL', 'SELECT ENAME FROM EMP WHERE SAL >= 3000;'),
            ])
              ChoiceItemCard(
                item: ChoiceItem(key: key, kind: kind, body: body),
                displayLabel: key,
                state: PassqlChoiceState.idle,
                onTap: () {},
              ),
          ],
        ),
      ),
      const <Override>[],
    ),
  };

  test('앱 글자 배율 상한은 1.4배', () {
    final limitedScaler = const TextScaler.linear(
      _systemMaximumTextScaleFactor,
    ).clamp(maxScaleFactor: PassqlTextScaleLimit.maximumTextScaleFactor);
    expect(limitedScaler.scale(10), 14);
  });

  for (final entry in cases.entries) {
    for (final isDark in [false, true]) {
      testWidgets(
        '${entry.key}: 시스템 글자 최대에서 넘침 없음 (${isDark ? '다크' : '라이트'})',
        (tester) async {
          await _pumpWithLargeText(
            tester,
            entry.value.$1,
            entry.value.$2,
            theme: isDark ? PassqlTheme.dark : PassqlTheme.light,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('히트맵은 스크린리더 요약 문구를 가진다', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    await _pumpWithLargeText(
      tester,
      const HomePage(),
      [homeDataProvider.overrideWith((ref) async => homeData)],
      theme: PassqlTheme.light,
      viewSize: const Size(390, 2400),
    );
    expect(find.bySemanticsLabel(RegExp(r'최근 \d+일 학습 기록')), findsOneWidget);
    semanticsHandle.dispose();
  });

  testWidgets('레이더 차트는 토픽별 정답률을 스크린리더로 읽는다', (tester) async {
    final semanticsHandle = tester.ensureSemantics();
    await _pumpWithLargeText(
      tester,
      const StatsPage(),
      [
        statsDataProvider.overrideWith((ref) async => statsData),
        statsAiCommentProvider.overrideWith((ref) async => null),
      ],
      theme: PassqlTheme.light,
      viewSize: const Size(390, 2400),
    );
    expect(
      find.bySemanticsLabel(RegExp('영역별 정답률: .*JOIN 80%')),
      findsOneWidget,
    );
    semanticsHandle.dispose();
  });
}
