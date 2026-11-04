import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';
import 'interstitial_frequency_cap.dart';

/// 앱 오프닝 광고 노출 기록 3개: 마지막 노출 시각, 기록한 날짜, 그날 노출 횟수
class AppOpenShowHistory {
  const AppOpenShowHistory({
    this.lastShownAtEpochMilliseconds,
    this.shownDayKey,
    this.shownCountOfDay = 0,
  });

  final int? lastShownAtEpochMilliseconds;

  /// 기기 현지 날짜 yyyy-MM-dd
  final String? shownDayKey;
  final int shownCountOfDay;
}

/// 노출 기록 저장소 포트. 테스트는 메모리 저장소로 바꿈
abstract interface class AppOpenShowHistoryStore {
  Future<AppOpenShowHistory> read();
  Future<void> write(AppOpenShowHistory history);
}

/// SharedPreferences 저장소 (계정과 무관한 기기 단위 기록)
class SharedPreferencesAppOpenShowHistoryStore
    implements AppOpenShowHistoryStore {
  @override
  Future<AppOpenShowHistory> read() async => AppOpenShowHistory(
    lastShownAtEpochMilliseconds: await DevicePreferences.readInt(
      StorageKeys.appOpenAdLastShownAt,
    ),
    shownDayKey: await DevicePreferences.readString(
      StorageKeys.appOpenAdShownDay,
    ),
    shownCountOfDay:
        await DevicePreferences.readInt(StorageKeys.appOpenAdShownCount) ?? 0,
  );

  @override
  Future<void> write(AppOpenShowHistory history) async {
    final lastShownAt = history.lastShownAtEpochMilliseconds;
    if (lastShownAt != null) {
      await DevicePreferences.writeInt(
        StorageKeys.appOpenAdLastShownAt,
        lastShownAt,
      );
    }
    final shownDayKey = history.shownDayKey;
    if (shownDayKey != null) {
      await DevicePreferences.writeString(
        StorageKeys.appOpenAdShownDay,
        shownDayKey,
      );
    }
    await DevicePreferences.writeInt(
      StorageKeys.appOpenAdShownCount,
      history.shownCountOfDay,
    );
  }
}

/// 앱 오프닝 광고 빈도 제한 2개: 노출 간격 1시간 이상, 하루 최대 3회 (기기 현지 날짜 기준, #787)
class AppOpenFrequencyCap {
  AppOpenFrequencyCap(this._store);

  /// 연속 노출 최소 간격 (1시간)
  static const minimumIntervalBetweenShows = Duration(hours: 1);

  /// 하루 최대 노출 횟수
  static const maximumShowsPerDay = 3;

  final AppOpenShowHistoryStore _store;

  /// 지금 보여도 되는지 (오늘 남은 횟수 + 마지막 노출 뒤 1시간 경과)
  Future<bool> canShowAt(DateTime now) async {
    final history = await _store.read();
    if (_shownCountOn(history, now) >= maximumShowsPerDay) return false;
    final lastShownAt = history.lastShownAtEpochMilliseconds;
    if (lastShownAt == null) return true;
    final elapsed = now.difference(
      DateTime.fromMillisecondsSinceEpoch(lastShownAt),
    );
    // 기기 시각을 되돌린 경우(음수)도 간격 미달로 봄
    return elapsed >= minimumIntervalBetweenShows;
  }

  /// 오늘 더 보여 줄 수 있는지 (미리 불러오기 여부 판단용, 간격은 보지 않음)
  Future<bool> hasRemainingShowsOn(DateTime now) async {
    final history = await _store.read();
    return _shownCountOn(history, now) < maximumShowsPerDay;
  }

  /// 노출 1회 기록 (날짜가 바뀌었으면 1부터)
  Future<void> recordShownAt(DateTime now) async {
    final history = await _store.read();
    await _store.write(
      AppOpenShowHistory(
        lastShownAtEpochMilliseconds: now.millisecondsSinceEpoch,
        shownDayKey: InterstitialFrequencyCap.dayKeyOf(now),
        shownCountOfDay: _shownCountOn(history, now) + 1,
      ),
    );
  }

  // 기록 날짜가 오늘이 아니면 0회
  static int _shownCountOn(AppOpenShowHistory history, DateTime now) =>
      history.shownDayKey == InterstitialFrequencyCap.dayKeyOf(now)
      ? history.shownCountOfDay
      : 0;
}
