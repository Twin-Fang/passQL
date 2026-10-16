import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_placement.dart';
import 'package:passql_app/core/ads/interstitial_ad_controller.dart';
import 'package:passql_app/core/ads/interstitial_ad_loader.dart';
import 'package:passql_app/core/ads/interstitial_frequency_cap.dart';

import '../../helpers/fakes/fake_interstitial_show_history_store.dart';

/// 가짜 전면 광고: 표시 요청 시 바로 뜨고, [close] 로 닫음
class _FakeInterstitial {
  _FakeInterstitial(this.loadedAt);

  final DateTime loadedAt;
  int showCount = 0;
  bool isDisposed = false;
  VoidCallback? _onClosed;

  LoadedInterstitial toLoaded() => LoadedInterstitial(
    loadedAt: loadedAt,
    show: ({required onShown, required onClosed}) {
      showCount++;
      _onClosed = onClosed;
      onShown();
    },
    dispose: () => isDisposed = true,
  );

  void close() => _onClosed?.call();
}

/// 부를 때마다 새 가짜 광고를 돌려주는 로더 (null 이면 실패)
class _FakeLoader implements InterstitialAdLoader {
  _FakeLoader(this.now);

  final DateTime Function() now;
  final loadedAds = <_FakeInterstitial>[];
  bool shouldFail = false;

  @override
  Future<LoadedInterstitial?> load(AdPlacement placement) async {
    if (shouldFail) return null;
    final fakeAd = _FakeInterstitial(now());
    loadedAds.add(fakeAd);
    return fakeAd.toLoaded();
  }
}

void main() {
  late DateTime currentTime;
  late _FakeLoader loader;
  late MemoryInterstitialShowHistoryStore store;
  late InterstitialAdController controller;

  setUp(() {
    currentTime = DateTime(2026, 10, 16, 9);
    loader = _FakeLoader(() => currentTime);
    store = MemoryInterstitialShowHistoryStore();
    controller = InterstitialAdController(
      loader: loader,
      frequencyCap: InterstitialFrequencyCap(store),
      now: () => currentTime,
    );
  });

  test('준비 안 됐으면 보이지 않고(화면 진행) 다음을 미리 불러 둔다', () async {
    expect(await controller.showIfAllowed(), isFalse);
    await pumpEventQueue();
    expect(loader.loadedAds, hasLength(1));
    expect(controller.hasReadyAd, isTrue);
  });

  test('미리 불러 둔 광고를 보여 주고 노출을 기록한다', () async {
    await controller.preload();
    expect(await controller.showIfAllowed(), isTrue);
    await pumpEventQueue();
    expect(loader.loadedAds.single.showCount, 1);
    expect(store.history.shownCountOfDay, 1);
  });

  test('닫힌 뒤 다음 광고를 미리 불러 오지만 3분 안에는 보이지 않는다', () async {
    await controller.preload();
    await controller.showIfAllowed();
    loader.loadedAds.single.close();
    await pumpEventQueue();
    expect(loader.loadedAds, hasLength(2));

    currentTime = currentTime.add(const Duration(minutes: 1));
    expect(await controller.showIfAllowed(), isFalse);
    currentTime = currentTime.add(const Duration(minutes: 2));
    expect(await controller.showIfAllowed(), isTrue);
  });

  test('하루 3회를 채우면 더 보이지 않고 더 불러 오지도 않는다', () async {
    for (var showIndex = 0; showIndex < 3; showIndex++) {
      await controller.preload();
      expect(await controller.showIfAllowed(), isTrue);
      loader.loadedAds.last.close();
      await pumpEventQueue();
      currentTime = currentTime.add(const Duration(minutes: 5));
    }
    final loadCountAfterCap = loader.loadedAds.length;
    expect(await controller.showIfAllowed(), isFalse);
    await controller.preload();
    await pumpEventQueue();
    // 3번째 닫힘 뒤에는 오늘 남은 횟수가 없어 새로 불러오지 않음
    expect(loader.loadedAds.length, loadCountAfterCap);
    expect(store.history.shownCountOfDay, 3);
  });

  test('불러온 지 55분이 지난 광고는 해제하고 보이지 않는다', () async {
    await controller.preload();
    final staleAd = loader.loadedAds.single;
    currentTime = currentTime.add(const Duration(minutes: 56));
    expect(await controller.showIfAllowed(), isFalse);
    expect(staleAd.isDisposed, isTrue);
    expect(staleAd.showCount, 0);
  });

  test('보이는 중에는 다른 결과 화면이 또 보이지 않는다', () async {
    await controller.preload();
    expect(await controller.showIfAllowed(), isTrue);
    currentTime = currentTime.add(const Duration(minutes: 10));
    expect(await controller.showIfAllowed(), isFalse);
  });

  test('로드 실패해도 예외 없이 보이지 않는다', () async {
    loader.shouldFail = true;
    await controller.preload();
    expect(controller.hasReadyAd, isFalse);
    expect(await controller.showIfAllowed(), isFalse);
  });
}
