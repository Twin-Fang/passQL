import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/ads/interstitial_frequency_cap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes/fake_interstitial_show_history_store.dart';

/// 전면 광고 빈도 제한: 3분 간격, 하루 3회, 날짜 바뀌면 초기화
void main() {
  final morning = DateTime(2026, 10, 16, 9);

  late MemoryInterstitialShowHistoryStore store;
  late InterstitialFrequencyCap frequencyCap;

  setUp(() {
    store = MemoryInterstitialShowHistoryStore();
    frequencyCap = InterstitialFrequencyCap(store);
  });

  test('처음에는 보여도 된다', () async {
    expect(await frequencyCap.canShowAt(morning), isTrue);
  });

  test('노출 뒤 3분 안에는 막고 3분이 지나면 허용한다', () async {
    await frequencyCap.recordShownAt(morning);
    expect(
      await frequencyCap.canShowAt(
        morning.add(const Duration(minutes: 2, seconds: 59)),
      ),
      isFalse,
    );
    expect(
      await frequencyCap.canShowAt(morning.add(const Duration(minutes: 3))),
      isTrue,
    );
  });

  test('하루 3회를 채우면 그날은 더 보이지 않고 미리 불러오기도 멈춘다', () async {
    for (var showIndex = 0; showIndex < 3; showIndex++) {
      await frequencyCap.recordShownAt(
        morning.add(Duration(minutes: 10 * showIndex)),
      );
    }
    final evening = DateTime(2026, 10, 16, 21);
    expect(await frequencyCap.canShowAt(evening), isFalse);
    expect(await frequencyCap.hasRemainingShowsOn(evening), isFalse);
  });

  test('날짜가 바뀌면 횟수를 다시 센다', () async {
    for (var showIndex = 0; showIndex < 3; showIndex++) {
      await frequencyCap.recordShownAt(
        morning.add(Duration(minutes: 10 * showIndex)),
      );
    }
    final nextDay = DateTime(2026, 10, 17, 9);
    expect(await frequencyCap.canShowAt(nextDay), isTrue);
    await frequencyCap.recordShownAt(nextDay);
    expect(store.history.shownCountOfDay, 1);
    expect(store.history.shownDayKey, '2026-10-17');
  });

  test('기기 시각을 되돌려도 간격 미달로 보고 막는다', () async {
    await frequencyCap.recordShownAt(morning);
    expect(
      await frequencyCap.canShowAt(morning.subtract(const Duration(hours: 1))),
      isFalse,
    );
  });

  test('SharedPreferences 저장소는 기록을 그대로 읽어 온다', () async {
    SharedPreferences.setMockInitialValues({});
    final preferencesStore = SharedPreferencesInterstitialShowHistoryStore();
    final preferencesCap = InterstitialFrequencyCap(preferencesStore);
    await preferencesCap.recordShownAt(morning);

    final history = await preferencesStore.read();
    expect(
      history.lastShownAtEpochMilliseconds,
      morning.millisecondsSinceEpoch,
    );
    expect(history.shownDayKey, '2026-10-16');
    expect(history.shownCountOfDay, 1);
  });
}
