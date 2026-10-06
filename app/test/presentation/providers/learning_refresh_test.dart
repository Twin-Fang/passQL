import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/learning_refresh.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';

void main() {
  late int homeLoads;
  late int statsLoads;
  late ProviderContainer container;

  setUp(() {
    homeLoads = 0;
    statsLoads = 0;
    container = ProviderContainer(
      overrides: [
        homeDataProvider.overrideWith((ref) async {
          homeLoads++;
          return const HomeData();
        }),
        statsDataProvider.overrideWith((ref) async {
          statsLoads++;
          return const StatsData();
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  test('갱신 전에는 한 번 불러온 값을 계속 캐시로 쓴다 (풀이 후에도 예전 값이 보이던 원인)', () async {
    await container.read(homeDataProvider.future);
    await container.read(homeDataProvider.future);
    await container.read(statsDataProvider.future);
    await container.read(statsDataProvider.future);

    expect(homeLoads, 1);
    expect(statsLoads, 1);
  });

  test('학습 현황을 갱신하면 홈과 통계를 다음 조회 때 다시 불러온다', () async {
    await container.read(homeDataProvider.future);
    await container.read(statsDataProvider.future);

    refreshLearningData(container.invalidate);
    await container.read(homeDataProvider.future);
    await container.read(statsDataProvider.future);

    expect(homeLoads, 2);
    expect(statsLoads, 2);
  });

  test('아직 한 번도 불러오지 않았다면 갱신해도 불필요한 호출을 만들지 않는다', () async {
    refreshLearningData(container.invalidate);
    expect(homeLoads, 0);
    expect(statsLoads, 0);
  });
}
