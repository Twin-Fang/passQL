import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_placement.dart';
import 'package:passql_app/core/ads/app_open_ad_controller.dart';
import 'package:passql_app/core/ads/app_open_ad_loader.dart';
import 'package:passql_app/core/ads/app_open_frequency_cap.dart';
import 'package:passql_app/core/ads/full_screen_ad_guard.dart';
import 'package:passql_app/core/ads/loaded_full_screen_ad.dart';

/// 앱 오프닝 광고 복귀 판정 (#787): 첫 실행·짧은 전환·광고 이탈 제외, 1시간 간격

class _FakeAppOpenAdLoader implements AppOpenAdLoader {
  int shownCount = 0;

  @override
  Future<LoadedFullScreenAd?> load(AdPlacement placement) async =>
      LoadedFullScreenAd(
        loadedAt: DateTime(2026, 11, 2, 9),
        show: ({required onShown, required onClosed}) {
          shownCount++;
          onShown();
          onClosed();
        },
        dispose: () {},
      );
}

class _MemoryAppOpenShowHistoryStore implements AppOpenShowHistoryStore {
  AppOpenShowHistory history = const AppOpenShowHistory();

  @override
  Future<AppOpenShowHistory> read() async => history;

  @override
  Future<void> write(AppOpenShowHistory newHistory) async =>
      history = newHistory;
}

void main() {
  late DateTime now;
  late _FakeAppOpenAdLoader loader;
  late AppOpenAdController controller;

  setUp(() async {
    FullScreenAdGuard.resetForTest();
    now = DateTime(2026, 11, 2, 9);
    loader = _FakeAppOpenAdLoader();
    controller = AppOpenAdController(
      loader: loader,
      frequencyCap: AppOpenFrequencyCap(_MemoryAppOpenShowHistoryStore()),
      now: () => now,
    );
    await controller.preload();
  });

  // 백그라운드에 [duration] 만큼 있다가 복귀
  Future<bool> resumeAfter(Duration duration) async {
    controller.recordBackgrounded();
    now = now.add(duration);
    final isShown = await controller.showIfAllowedOnResume();
    await controller.preload();
    return isShown;
  }

  test('첫 실행(백그라운드 기록 없음)에는 보이지 않는다', () async {
    expect(await controller.showIfAllowedOnResume(), isFalse);
  });

  test('30초 미만 복귀는 제외, 30초 이상이면 보인다', () async {
    expect(await resumeAfter(const Duration(seconds: 10)), isFalse);
    expect(await resumeAfter(const Duration(seconds: 30)), isTrue);
    expect(loader.shownCount, 1);
  });

  test('광고를 눌러 나갔다 온 복귀는 제외한다', () async {
    FullScreenAdGuard.recordAdClicked(now);
    expect(await resumeAfter(const Duration(minutes: 2)), isFalse);
  });

  test('노출 뒤 1시간 안의 복귀는 제외한다', () async {
    expect(await resumeAfter(const Duration(minutes: 1)), isTrue);
    expect(await resumeAfter(const Duration(minutes: 30)), isFalse);
    expect(await resumeAfter(const Duration(minutes: 31)), isTrue);
  });
}
