import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/ad_native_loader.dart';
import 'package:passql_app/core/ads/ad_native_strip_loader.dart';
import 'package:passql_app/core/ads/ad_placement.dart';
import 'package:passql_app/core/ads/loaded_ad_view.dart';
import 'package:passql_app/presentation/design/design.dart';
import 'package:passql_app/presentation/providers/ad_providers.dart';
import 'package:passql_app/presentation/widgets/ads/ad_native_slot.dart';
import 'package:passql_app/presentation/widgets/ads/ad_native_strip_slot.dart';

/// 호출 순서대로 정한 결과를 돌려주는 가짜 띠 로더 (null = 실패)
class _FakeStripLoader implements AdNativeStripLoader {
  _FakeStripLoader(this.results);

  final List<LoadedAdView?> results;
  int callCount = 0;
  NativeAdStripStyle? lastStyle;

  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    double heightDp,
    NativeAdStripStyle style,
  ) async {
    lastStyle = style;
    final result = callCount < results.length ? results[callCount] : null;
    callCount++;
    return result;
  }
}

class _ThrowingStripLoader implements AdNativeStripLoader {
  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    double heightDp,
    NativeAdStripStyle style,
  ) => Future.error(StateError('sdk'));
}

// 띠 슬롯이 감싸는 탭 바 자리
const _fakeTabBar = SizedBox(key: Key('fake-tab-bar'), height: 44);
const _stripSlot = AdNativeStripSlot(tabBar: _fakeTabBar);

class _FakeNativeLoader implements AdNativeLoader {
  _FakeNativeLoader(this.result);

  final LoadedAdView? result;
  NativeAdPalette? lastPalette;

  @override
  Future<LoadedAdView?> load(
    AdPlacement placement,
    int widthDp,
    NativeAdPalette palette,
  ) async {
    lastPalette = palette;
    return result;
  }
}

LoadedAdView _fakeAdView({VoidCallback? onDispose}) => LoadedAdView(
  height: 50,
  view: const SizedBox(key: Key('fake-ad'), height: 50),
  dispose: onDispose ?? () {},
);

Widget _host({
  required List<Override> overrides,
  required Widget slot,
  bool isAdsEnabled = true,
}) => ProviderScope(
  overrides: [adsEnabledProvider.overrideWithValue(isAdsEnabled), ...overrides],
  child: MaterialApp(
    theme: PassqlTheme.light,
    home: Scaffold(
      body: Column(children: [const Text('앞'), slot, const Text('뒤')]),
    ),
  ),
);

double _slotGap(WidgetTester tester) =>
    tester.getTopLeft(find.text('뒤')).dy -
    tester.getBottomLeft(find.text('앞')).dy;

void main() {
  group('하단 한 줄 띠', () {
    testWidgets('실패하면 탭 바만 남고 30초·60초 뒤 한 번씩만 다시 시도한다', (tester) async {
      final loader = _FakeStripLoader([null]);
      await tester.pumpWidget(
        _host(
          overrides: [adNativeStripLoaderProvider.overrideWithValue(loader)],
          slot: _stripSlot,
        ),
      );
      await tester.pump();
      expect(loader.callCount, 1);
      expect(_slotGap(tester), 44);

      await tester.pump(const Duration(seconds: 30));
      expect(loader.callCount, 2);
      await tester.pump(const Duration(seconds: 60));
      expect(loader.callCount, 3);
      await tester.pump(const Duration(minutes: 10));
      expect(loader.callCount, 3);
    });

    testWidgets('성공하면 탭 바 아래 띠 높이만큼 자리를 차지하고 화면을 떠나면 해제한다', (tester) async {
      var isDisposed = false;
      final loader = _FakeStripLoader([
        _fakeAdView(onDispose: () => isDisposed = true),
      ]);
      await tester.pumpWidget(
        _host(
          overrides: [adNativeStripLoaderProvider.overrideWithValue(loader)],
          slot: _stripSlot,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('fake-ad')), findsOneWidget);
      // 순서: 탭 바 > 띠
      expect(
        tester.getTopLeft(find.byKey(const Key('fake-ad'))).dy,
        greaterThan(
          tester.getTopLeft(find.byKey(const Key('fake-tab-bar'))).dy,
        ),
      );
      expect(
        _slotGap(tester),
        44 + PassqlSize.bottomStrip + PassqlSize.hairline + PassqlSpacing.xs,
      );
      expect(loader.lastStyle?.background, PassqlColors.light.card);
      expect(loader.lastStyle?.badgeLabel, AdNativeStripSlot.badgeLabel);

      await tester.pumpWidget(const SizedBox());
      expect(isDisposed, isTrue);
    });

    testWidgets('로더가 예외를 던져도 탭 바는 살아 있다', (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            adNativeStripLoaderProvider.overrideWithValue(
              _ThrowingStripLoader(),
            ),
          ],
          slot: _stripSlot,
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('fake-tab-bar')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('광고가 꺼져 있으면 로더를 부르지 않고 탭 바만 그린다', (tester) async {
      final loader = _FakeStripLoader([_fakeAdView()]);
      await tester.pumpWidget(
        _host(
          isAdsEnabled: false,
          overrides: [adNativeStripLoaderProvider.overrideWithValue(loader)],
          slot: _stripSlot,
        ),
      );
      await tester.pump();
      expect(loader.callCount, 0);
      expect(_slotGap(tester), 44);
    });
  });

  group('네이티브', () {
    testWidgets('실패하면 항목 자체가 없다 (라벨·여백 없음)', (tester) async {
      await tester.pumpWidget(
        _host(
          overrides: [
            adNativeLoaderProvider.overrideWithValue(_FakeNativeLoader(null)),
          ],
          slot: const AdNativeSlot(
            placement: AdPlacement.nativeQuestions,
            padding: EdgeInsets.only(top: PassqlSpacing.md),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(AdNativeSlot.adLabel), findsNothing);
      expect(_slotGap(tester), 0);
    });

    testWidgets('성공하면 광고 라벨과 틀을 붙이고 테마 색을 템플릿에 넘긴다', (tester) async {
      final loader = _FakeNativeLoader(_fakeAdView());
      await tester.pumpWidget(
        _host(
          overrides: [adNativeLoaderProvider.overrideWithValue(loader)],
          slot: const AdNativeSlot(placement: AdPlacement.nativeQuestions),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(AdNativeSlot.adLabel), findsOneWidget);
      expect(find.byKey(AdNativeSlot.frameKey), findsOneWidget);
      expect(loader.lastPalette?.background, PassqlColors.light.card);
    });
  });
}
