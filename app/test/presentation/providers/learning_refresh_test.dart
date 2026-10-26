import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passql_app/data/models/home/recommendations_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/presentation/providers/home_providers.dart';
import 'package:passql_app/presentation/providers/learning_refresh.dart';
import 'package:passql_app/presentation/providers/stats_providers.dart';

void main() {
  late int overviewLoads;
  late int learningStatusLoads;
  late int statsLoads;
  late int aiCommentLoads;
  late ProviderContainer container;

  setUp(() {
    overviewLoads = 0;
    learningStatusLoads = 0;
    statsLoads = 0;
    aiCommentLoads = 0;
    container = ProviderContainer(
      overrides: [
        homeOverviewProvider.overrideWith((ref) async {
          overviewLoads++;
          return const HomeOverview();
        }),
        homeLearningStatusProvider.overrideWith((ref) async {
          learningStatusLoads++;
          return const HomeLearningStatus();
        }),
        statsDataProvider.overrideWith((ref) async {
          statsLoads++;
          return const StatsData();
        }),
        statsAiCommentProvider.overrideWith((ref) async {
          aiCommentLoads++;
          return null;
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  /// 홈(합친 값)·통계·AI 코멘트 한 번씩 조회
  Future<void> readAll() async {
    await container.read(homeDataProvider.future);
    await container.read(statsDataProvider.future);
    await container.read(statsAiCommentProvider.future);
  }

  test('갱신 전에는 한 번 불러온 값을 계속 캐시로 쓴다 (풀이 후에도 예전 값이 보이던 원인)', () async {
    await readAll();
    await readAll();

    expect(overviewLoads, 1);
    expect(learningStatusLoads, 1);
    expect(statsLoads, 1);
  });

  test('풀이 후 갱신은 학습 현황·통계·통계 AI 코멘트를 다시 받고 인사말·추천·일정은 캐시 유지 (#567)', () async {
    await readAll();

    refreshLearningData(container.invalidate);
    await readAll();

    expect(learningStatusLoads, 2);
    expect(statsLoads, 2);
    expect(overviewLoads, 1);
    expect(aiCommentLoads, 2);
  });

  test('날짜가 바뀌면 홈 전체를 다시 받는다', () async {
    await readAll();

    refreshDateDependentData(container.invalidate);
    await readAll();

    expect(overviewLoads, 2);
    expect(learningStatusLoads, 2);
    expect(statsLoads, 2);
  });

  test('아직 한 번도 불러오지 않았다면 갱신해도 불필요한 호출을 만들지 않는다', () async {
    refreshLearningData(container.invalidate);
    expect(learningStatusLoads, 0);
    expect(statsLoads, 0);
  });

  group('homeDataProvider 합치기', () {
    ProviderContainer containerWith({
      required Future<HomeOverview> Function() loadOverview,
      required Future<HomeLearningStatus> Function() loadLearningStatus,
    }) {
      final mergeContainer = ProviderContainer(
        overrides: [
          homeOverviewProvider.overrideWith((ref) => loadOverview()),
          homeLearningStatusProvider.overrideWith(
            (ref) => loadLearningStatus(),
          ),
        ],
      );
      addTearDown(mergeContainer.dispose);
      return mergeContainer;
    }

    test('한 묶음만 실패하면 나머지 묶음으로 화면을 채운다', () async {
      final mergeContainer = containerWith(
        loadOverview: () async => throw Exception('overview down'),
        loadLearningStatus: () async => const HomeLearningStatus(),
      );
      final homeData = await mergeContainer.read(homeDataProvider.future);
      expect(homeData.greeting, isNull);
    });

    test('두 묶음 모두 실패하면 오류로 본다 (#375)', () async {
      final mergeContainer = containerWith(
        loadOverview: () async => throw Exception('overview down'),
        loadLearningStatus: () async => throw Exception('learning down'),
      );
      await expectLater(
        mergeContainer.read(homeDataProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    test('추천 문제가 늦어도 홈은 기다리지 않는다 (#676)', () async {
      final mergeContainer = ProviderContainer(
        overrides: [
          homeOverviewProvider.overrideWith(
            (ref) async => const HomeOverview(),
          ),
          homeLearningStatusProvider.overrideWith(
            (ref) async => const HomeLearningStatus(),
          ),
          // 끝나지 않는 추천 (등급 확인 > 추천 직렬 대기 흉내)
          homeRecommendationsProvider.overrideWith(
            (ref) => Completer<RecommendationsResponse?>().future,
          ),
        ],
      );
      addTearDown(mergeContainer.dispose);
      await expectLater(
        mergeContainer
            .read(homeDataProvider.future)
            .timeout(const Duration(seconds: 1)),
        completes,
      );
    });
  });
}
