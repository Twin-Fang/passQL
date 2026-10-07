import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/data/models/daily_set/daily_set_models.dart';
import 'package:passql_app/presentation/pages/daily_set/leaderboard_page.dart';
import 'package:passql_app/presentation/providers/daily_set_providers.dart';

void main() {
  testWidgets('전체 목록 위에 "전체 순위 · N명" 제목을 보여 내 순위와 구분한다', (tester) async {
    const me = LeaderboardEntry(rank: 1, nickname: '당당한다이아몬드', correctCount: 2);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leaderboardProvider.overrideWith(
            (ref) async => const LeaderboardResponse(
              date: '2026-10-07',
              entries: [me],
              myEntry: me,
            ),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, _) => const MaterialApp(home: LeaderboardPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('내 순위'), findsOneWidget);
    expect(find.text('전체 순위 · 1명'), findsOneWidget);
  });
}
