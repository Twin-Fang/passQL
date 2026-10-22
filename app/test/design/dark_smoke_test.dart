import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/router/result_route_arguments.dart';
import 'package:passql_app/presentation/pages/daily_set/daily_set_result_page.dart';
import 'package:passql_app/presentation/pages/home/home_page.dart';
import 'package:passql_app/presentation/pages/questions/chapter_result_page.dart';
import 'package:passql_app/presentation/pages/questions/topic_list_page.dart';
import 'package:passql_app/presentation/pages/stats/stats_page.dart';
import 'package:passql_app/presentation/providers/chapter_providers.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';
import 'package:passql_app/presentation/providers/topic_providers.dart';

// 화면별 목업은 기존 레이아웃 테스트의 것을 재사용한다.
import '../presentation/login_layout_test.dart' show pumpLogin;
import '../presentation/result_screens_test.dart' show expectResultScaffold;
import '../presentation/settings_layout_test.dart' show pumpSettings;
import '../presentation/tab_pages_test.dart' show homeData, statsData, topics;

/// 다크에서 Text 가 가질 수 있는 색 허용 목록.
/// - 글자 계열 토큰은 그대로 허용한다(brief Step 2).
/// - 예외(실측으로 확인되면 여기에 사유와 함께 추가): 소셜 로그인 브랜드 버튼 글자(제공자 가이드 고정색, 브랜드 바탕 위).
///   아이콘 타일/로고의 흰색 고정은 Text 가 아니라 Icon 이라 걸리지 않는다.
Set<Color> _allowedTextColors() {
  final colors = PassqlColors.dark;
  return {
    colors.label,
    colors.secondaryLabel,
    colors.tertiaryLabel,
    colors.accent,
    colors.accentText,
    colors.onAccent,
    colors.onSemantic,
    colors.correctText,
    colors.wrongText,
    colors.correct,
    colors.wrong,
    colors.warning,
    colors.warningText,
    colors.background, // 토스트 글자·회색 선택지 키 반전 글자
    // 로그인 화면 카카오 버튼 글자 (#509). 네이버·GitHub 흰 글자는 onAccent 와 같은 값
    PassqlSocialBrandColors.kakaoForeground,
  };
}

/// 화면 안 모든 Text 의 명시 색이 다크 토큰인지(라이트 색 잔존 여부) 확인한다.
void _expectNoLightText(WidgetTester tester) {
  expect(tester.takeException(), isNull);
  final allowed = _allowedTextColors();
  final bad = <String>[];
  for (final t in tester.widgetList<Text>(
    find.byType(Text, skipOffstage: false),
  )) {
    final color = t.style?.color;
    if (color != null && !allowed.contains(color)) {
      bad.add('${t.data ?? t.textSpan?.toPlainText()} -> $color');
    }
  }
  expect(bad, isEmpty, reason: '다크 토큰이 아닌 글자색');
}

Future<void> _pumpTab(
  WidgetTester tester,
  Widget page,
  List<Override> overrides,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: PassqlTheme.dark, home: page),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('홈 다크', (tester) async {
    await _pumpTab(tester, const HomePage(), [
      homeDataProvider.overrideWith((ref) async => homeData),
    ]);
    _expectNoLightText(tester);
  });

  testWidgets('문제 다크', (tester) async {
    await _pumpTab(tester, const TopicListPage(), [
      topicsProvider.overrideWith((ref) async => topics),
    ]);
    _expectNoLightText(tester);
  });

  testWidgets('통계 다크', (tester) async {
    await _pumpTab(tester, const StatsPage(), [
      statsDataProvider.overrideWith((ref) async => statsData),
      statsAiCommentProvider.overrideWith((ref) async => null),
    ]);
    _expectNoLightText(tester);
  });

  testWidgets('설정 다크', (tester) async {
    await pumpSettings(tester, PassqlTheme.dark);
    _expectNoLightText(tester);
  });

  testWidgets('로그인 다크', (tester) async {
    await pumpLogin(tester, PassqlTheme.dark);
    _expectNoLightText(tester);
  });

  testWidgets('챕터 결과 다크', (tester) async {
    await expectResultScaffold(
      tester,
      const ChapterResultPage(
        summary: ChapterSummary(
          topicName: 'JOIN',
          results: [
            ChapterResult(
              questionUuid: 'a',
              isCorrect: true,
              durationMs: 12000,
            ),
            ChapterResult(
              questionUuid: 'b',
              isCorrect: false,
              durationMs: 18000,
            ),
          ],
          totalDurationMs: 30000,
        ),
      ),
      theme: PassqlTheme.dark,
    );
    _expectNoLightText(tester);
  });

  testWidgets('오늘의 세트 결과 다크', (tester) async {
    await expectResultScaffold(
      tester,
      const DailySetResultPage(
        outcome: DailySetOutcome(
          results: [
            ChapterResult(questionUuid: 'a', isCorrect: true, durationMs: 1),
            ChapterResult(questionUuid: 'b', isCorrect: false, durationMs: 1),
          ],
          correctCount: 1,
        ),
      ),
      overrides: [
        leaderboardProvider.overrideWith(
          (ref) async => const LeaderboardResponse(
            date: '2026-10-02',
            entries: [
              LeaderboardEntry(rank: 1, nickname: '민트', correctCount: 5),
            ],
          ),
        ),
      ],
      theme: PassqlTheme.dark,
    );
    _expectNoLightText(tester);
  });
}
