import 'package:passql_app/core/ads/interstitial_frequency_cap.dart';

/// 메모리 전면 광고 노출 기록 저장소 (SharedPreferences 대신)
class MemoryInterstitialShowHistoryStore
    implements InterstitialShowHistoryStore {
  InterstitialShowHistory history = const InterstitialShowHistory();

  @override
  Future<InterstitialShowHistory> read() async => history;

  @override
  Future<void> write(InterstitialShowHistory newHistory) async {
    history = newHistory;
  }
}
