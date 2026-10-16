import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_placement.dart';
import 'interstitial_ad_loader.dart';
import 'interstitial_frequency_cap.dart';

/// 결과 화면 전면 광고: 미리 불러오기, 빈도 제한 확인, 표시
/// 준비 안 됐으면 보여 주지 않고 다음을 불러 둠 (화면 이동을 기다리게 하지 않음)
class InterstitialAdController {
  InterstitialAdController({
    required InterstitialAdLoader loader,
    required InterstitialFrequencyCap frequencyCap,
    DateTime Function()? now,
  }) : _loader = loader,
       _frequencyCap = frequencyCap,
       _now = now ?? DateTime.now;

  /// 불러 둔 광고 유효 시간 (AdMob 전면 광고는 1시간 뒤 만료 > 여유 5분)
  static const loadedAdValidDuration = Duration(minutes: 55);

  static const _placement = AdPlacement.interstitialResult;

  final InterstitialAdLoader _loader;
  final InterstitialFrequencyCap _frequencyCap;
  final DateTime Function() _now;

  LoadedInterstitial? _readyAd;
  Future<void>? _inFlightLoad;
  bool _isShowing = false;

  /// 표시할 광고가 준비돼 있는지 (테스트·진단용)
  bool get hasReadyAd => _readyAd != null;

  /// 미리 불러오기: 오늘 남은 횟수 있을 때만, 이미 준비·진행 중이면 그대로 (중복 요청 방지)
  Future<void> preload() {
    _discardExpiredAd();
    if (_readyAd != null) return Future.value();
    return _inFlightLoad ??= _loadIfRemaining().whenComplete(() {
      _inFlightLoad = null;
    });
  }

  /// 결과 화면 진입 시 1회: 준비됨 + 빈도 제한 통과 > 표시 후 true, 아니면 false
  Future<bool> showIfAllowed() async {
    if (_isShowing) return false;
    _discardExpiredAd();
    final readyAd = _readyAd;
    if (readyAd == null) {
      unawaited(preload());
      return false;
    }
    if (!await _frequencyCap.canShowAt(_now())) return false;
    // 기다리는 사이 다른 호출이 가져갔으면 중단
    if (!identical(_readyAd, readyAd) || _isShowing) return false;

    _readyAd = null;
    _isShowing = true;
    readyAd.show(
      onShown: () => unawaited(_frequencyCap.recordShownAt(_now())),
      onClosed: () {
        _isShowing = false;
        // 닫힌 뒤 다음 결과 화면용으로 미리 불러옴 (오늘 남은 횟수 있을 때만)
        unawaited(preload());
      },
    );
    return true;
  }

  Future<void> _loadIfRemaining() async {
    if (!await _frequencyCap.hasRemainingShowsOn(_now())) return;
    final loadedAd = await _loader.load(_placement);
    if (loadedAd == null) return;
    _readyAd?.dispose();
    _readyAd = loadedAd;
  }

  // 만료 임박 광고는 해제 (만료 광고를 보이면 표시 실패·무효 노출)
  void _discardExpiredAd() {
    final readyAd = _readyAd;
    if (readyAd == null) return;
    if (_now().difference(readyAd.loadedAt) < loadedAdValidDuration) return;
    readyAd.dispose();
    _readyAd = null;
  }
}

/// 앱 전체에서 하나 (결과 화면 2곳이 같은 빈도 제한·준비 광고를 공유)
final interstitialAdControllerProvider = Provider<InterstitialAdController>(
  (ref) => InterstitialAdController(
    loader: ref.watch(interstitialAdLoaderProvider),
    frequencyCap: InterstitialFrequencyCap(
      SharedPreferencesInterstitialShowHistoryStore(),
    ),
  ),
);
