import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_placement.dart';
import 'package:passql_app/core/ads/interstitial_ad_controller.dart';
import 'package:passql_app/core/ads/interstitial_ad_loader.dart';
import 'package:passql_app/core/ads/interstitial_frequency_cap.dart';
import 'package:passql_app/presentation/providers/ad_providers.dart';
import 'package:passql_app/presentation/widgets/ads/interstitial_ad_on_enter.dart';
import 'package:passql_app/presentation/widgets/ads/interstitial_ad_preloader.dart';

import '../../helpers/fakes/fake_interstitial_show_history_store.dart';

class _NeverLoadingLoader implements InterstitialAdLoader {
  @override
  Future<LoadedInterstitial?> load(AdPlacement placement) async => null;
}

/// 호출 횟수만 세는 컨트롤러
class _CountingController extends InterstitialAdController {
  _CountingController()
    : super(
        loader: _NeverLoadingLoader(),
        frequencyCap: InterstitialFrequencyCap(
          MemoryInterstitialShowHistoryStore(),
        ),
      );

  int showRequestCount = 0;
  int preloadCount = 0;

  @override
  Future<bool> showIfAllowed() async {
    showRequestCount++;
    return false;
  }

  @override
  Future<void> preload() async => preloadCount++;
}

Widget _host(_CountingController controller, {required bool isAdsEnabled}) =>
    ProviderScope(
      overrides: [
        adsEnabledProvider.overrideWithValue(isAdsEnabled),
        interstitialAdControllerProvider.overrideWithValue(controller),
      ],
      child: const MaterialApp(
        home: InterstitialAdPreloader(
          child: InterstitialAdOnEnter(child: Text('결과')),
        ),
      ),
    );

void main() {
  testWidgets('결과 화면을 먼저 그리고 첫 프레임 뒤 전면 광고를 1회만 시도한다', (tester) async {
    final controller = _CountingController();
    await tester.pumpWidget(_host(controller, isAdsEnabled: true));
    expect(find.text('결과'), findsOneWidget);
    await tester.pump();
    await tester.pump();
    expect(controller.showRequestCount, 1);
    expect(controller.preloadCount, 1);
  });

  testWidgets('광고가 꺼져 있으면 시도하지도 불러 오지도 않는다', (tester) async {
    final controller = _CountingController();
    await tester.pumpWidget(_host(controller, isAdsEnabled: false));
    await tester.pump();
    expect(find.text('결과'), findsOneWidget);
    expect(controller.showRequestCount, 0);
    expect(controller.preloadCount, 0);
  });
}
