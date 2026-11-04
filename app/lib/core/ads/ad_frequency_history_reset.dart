import '../storage/device_preferences.dart';
import '../storage/storage_keys.dart';

/// 광고 빈도 기록 초기화 (개발자 도구 전용, #809): 전면 4개 + 앱 오프닝 3개 저장 키 삭제
/// 다음 결과 화면·앱 복귀에서 하루 횟수·간격·첫 유예 제한 없이 바로 확인
abstract final class AdFrequencyHistoryReset {
  static const List<String> _historyKeys = [
    StorageKeys.interstitialLastShownAt,
    StorageKeys.interstitialShownDay,
    StorageKeys.interstitialShownCount,
    StorageKeys.interstitialResultEntryCount,
    StorageKeys.appOpenAdLastShownAt,
    StorageKeys.appOpenAdShownDay,
    StorageKeys.appOpenAdShownCount,
  ];

  /// 기록 7개 삭제
  static Future<void> resetAll() async {
    for (final historyKey in _historyKeys) {
      await DevicePreferences.remove(historyKey);
    }
  }
}
