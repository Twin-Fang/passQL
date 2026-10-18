import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 전면 광고 노출 기록 4개: 마지막 노출 시각, 기록한 날짜, 그날 노출 횟수, 결과 화면 진입 누적 횟수
class InterstitialShowHistory {
  const InterstitialShowHistory({
    this.lastShownAtEpochMilliseconds,
    this.shownDayKey,
    this.shownCountOfDay = 0,
    this.resultEntryCount = 0,
  });

  final int? lastShownAtEpochMilliseconds;

  /// 기기 현지 날짜 yyyy-MM-dd
  final String? shownDayKey;
  final int shownCountOfDay;

  /// 풀이를 마친 결과 화면 진입 누적 횟수 (설치 후 첫 결과 유예 판단용)
  final int resultEntryCount;

  InterstitialShowHistory copyWith({
    int? lastShownAtEpochMilliseconds,
    String? shownDayKey,
    int? shownCountOfDay,
    int? resultEntryCount,
  }) => InterstitialShowHistory(
    lastShownAtEpochMilliseconds:
        lastShownAtEpochMilliseconds ?? this.lastShownAtEpochMilliseconds,
    shownDayKey: shownDayKey ?? this.shownDayKey,
    shownCountOfDay: shownCountOfDay ?? this.shownCountOfDay,
    resultEntryCount: resultEntryCount ?? this.resultEntryCount,
  );
}

/// 노출 기록 저장소 포트. 테스트는 메모리 저장소로 바꿈
abstract interface class InterstitialShowHistoryStore {
  Future<InterstitialShowHistory> read();
  Future<void> write(InterstitialShowHistory history);
}

/// SharedPreferences 저장소 (계정과 무관한 기기 단위 기록)
class SharedPreferencesInterstitialShowHistoryStore
    implements InterstitialShowHistoryStore {
  @override
  Future<InterstitialShowHistory> read() async => InterstitialShowHistory(
    lastShownAtEpochMilliseconds: await DevicePreferences.readInt(
      StorageKeys.interstitialLastShownAt,
    ),
    shownDayKey: await DevicePreferences.readString(
      StorageKeys.interstitialShownDay,
    ),
    shownCountOfDay:
        await DevicePreferences.readInt(StorageKeys.interstitialShownCount) ??
        0,
    resultEntryCount:
        await DevicePreferences.readInt(
          StorageKeys.interstitialResultEntryCount,
        ) ??
        0,
  );

  @override
  Future<void> write(InterstitialShowHistory history) async {
    final lastShownAt = history.lastShownAtEpochMilliseconds;
    final shownDay = history.shownDayKey;
    if (lastShownAt != null) {
      await DevicePreferences.writeInt(
        StorageKeys.interstitialLastShownAt,
        lastShownAt,
      );
    }
    if (shownDay != null) {
      await DevicePreferences.writeString(
        StorageKeys.interstitialShownDay,
        shownDay,
      );
    }
    await DevicePreferences.writeInt(
      StorageKeys.interstitialShownCount,
      history.shownCountOfDay,
    );
    await DevicePreferences.writeInt(
      StorageKeys.interstitialResultEntryCount,
      history.resultEntryCount,
    );
  }
}

/// 전면 광고 빈도 제한 3개: 설치 후 첫 결과 2회는 광고 없음, 노출 간격 5분 이상, 하루 최대 3회 (기기 현지 날짜 기준)
class InterstitialFrequencyCap {
  InterstitialFrequencyCap(this._store);

  /// 연속 노출 최소 간격 (5분)
  static const minimumIntervalBetweenShows = Duration(minutes: 5);

  /// 하루 최대 노출 횟수
  static const maximumShowsPerDay = 3;

  /// 광고 없이 넘기는 첫 결과 화면 진입 횟수 (첫 학습 경험 보호)
  static const freeResultEntryCount = 2;

  final InterstitialShowHistoryStore _store;

  /// 지금 보여도 되는지 (첫 결과 유예 지남 + 오늘 남은 횟수 + 마지막 노출 뒤 5분 경과)
  Future<bool> canShowAt(DateTime now) async {
    final history = await _store.read();
    if (history.resultEntryCount <= freeResultEntryCount) return false;
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
      history.copyWith(
        lastShownAtEpochMilliseconds: now.millisecondsSinceEpoch,
        shownDayKey: dayKeyOf(now),
        shownCountOfDay: _shownCountOn(history, now) + 1,
      ),
    );
  }

  /// 결과 화면 진입 1회 기록 (광고 표시 여부와 무관, canShowAt 보다 먼저)
  Future<void> recordResultEntry() async {
    final history = await _store.read();
    await _store.write(
      history.copyWith(resultEntryCount: history.resultEntryCount + 1),
    );
  }

  /// 시각 > 현지 날짜 키 (yyyy-MM-dd)
  static String dayKeyOf(DateTime time) {
    final local = time.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  // 기록 날짜가 오늘이 아니면 0회
  static int _shownCountOn(InterstitialShowHistory history, DateTime now) =>
      history.shownDayKey == dayKeyOf(now) ? history.shownCountOfDay : 0;
}
