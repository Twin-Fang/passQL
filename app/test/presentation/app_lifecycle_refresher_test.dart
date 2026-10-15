import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/widgets/common/app_lifecycle_refresher.dart';

/// 홈 데이터 조회 횟수를 세는 화면
class _HomeDataWatcher extends ConsumerWidget {
  const _HomeDataWatcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeDataProvider);
    return const SizedBox();
  }
}

void main() {
  /// 복귀 시각을 바꿔 가며 resumed 를 보내고 홈 데이터 조회 횟수 반환
  Future<int> countHomeFetchesAfterResume(
    WidgetTester tester, {
    required DateTime resumedAt,
  }) async {
    var currentTime = DateTime(2026, 10, 15, 23, 50);
    var homeFetchCount = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeDataProvider.overrideWith((ref) async {
            homeFetchCount++;
            return const HomeData();
          }),
        ],
        child: AppLifecycleRefresher(
          readCurrentTime: () => currentTime,
          child: const _HomeDataWatcher(),
        ),
      ),
    );
    await tester.pump();
    currentTime = resumedAt;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    return homeFetchCount;
  }

  testWidgets('다음 날 복귀하면 홈 데이터를 다시 조회한다', (tester) async {
    final fetchCount = await countHomeFetchesAfterResume(
      tester,
      resumedAt: DateTime(2026, 10, 16, 0, 5),
    );
    expect(fetchCount, 2);
  });

  testWidgets('같은 날 복귀하면 다시 조회하지 않는다', (tester) async {
    final fetchCount = await countHomeFetchesAfterResume(
      tester,
      resumedAt: DateTime(2026, 10, 15, 23, 55),
    );
    expect(fetchCount, 1);
  });
}
