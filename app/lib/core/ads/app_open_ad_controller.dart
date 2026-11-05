import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_placement.dart';
import '../utils/app_clock.dart';
import 'app_open_ad_loader.dart';
import 'app_open_frequency_cap.dart';
import 'full_screen_ad_guard.dart';
import 'loaded_full_screen_ad.dart';

/// 앱 오프닝 광고: 미리 불러오기, 백그라운드 복귀 판정, 표시 (#787)
/// 제외 4개: 첫 실행(백그라운드 기록 없음), 30초 미만 복귀, 광고 때문에 나갔다 온 복귀, 다른 전체 화면 광고 표시 중
class AppOpenAdController {
  AppOpenAdController({
    required AppOpenAdLoader loader,
    required AppOpenFrequencyCap frequencyCap,
    DateTime Function()? now,
  }) : _loader = loader,
       _frequencyCap = frequencyCap,
       _now = now ?? AppClock.now;

  /// 이보다 짧게 나갔다 오면 광고 없음 (권한 창·공유·로그인 같은 짧은 전환, 30초)
  static const minimumBackgroundDuration = Duration(seconds: 30);

  /// 불러 둔 광고 유효 시간 (AdMob 앱 오프닝 광고는 4시간 뒤 만료 > 여유 5분)
  static const loadedAdValidDuration = Duration(hours: 3, minutes: 55);

  static const _placement = AdPlacement.appOpenResume;

  final AppOpenAdLoader _loader;
  final AppOpenFrequencyCap _frequencyCap;
  final DateTime Function() _now;

  LoadedFullScreenAd? _readyAd;
  Future<void>? _inFlightLoad;
  DateTime? _backgroundedAt;
  bool _isBackgroundCausedByAd = false;

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

  /// 백그라운드 진입 기록 (나간 시각 + 광고 때문에 나갔는지)
  void recordBackgrounded() {
    final now = _now();
    _backgroundedAt = now;
    _isBackgroundCausedByAd = FullScreenAdGuard.isBackgroundCausedByAdAt(now);
  }

  /// 포그라운드 복귀 시 1회: 제외 조건 통과 + 준비됨 + 빈도 제한 통과 > 표시 후 true
  Future<bool> showIfAllowedOnResume() async {
    final backgroundedAt = _backgroundedAt;
    final isBackgroundCausedByAd = _isBackgroundCausedByAd;
    // 복귀 1회에 판정 1회 (다음 복귀는 새 백그라운드 기록 필요)
    _backgroundedAt = null;
    _isBackgroundCausedByAd = false;

    if (!_isEligibleResume(backgroundedAt, isBackgroundCausedByAd)) {
      return false;
    }
    _discardExpiredAd();
    final readyAd = _readyAd;
    if (readyAd == null) {
      unawaited(preload());
      return false;
    }
    if (!await _frequencyCap.canShowAt(_now())) return false;
    // 기다리는 사이 다른 호출이 가져갔거나 전면 광고가 떴으면 중단
    if (!identical(_readyAd, readyAd) ||
        FullScreenAdGuard.isFullScreenAdShowing) {
      return false;
    }

    _readyAd = null;
    FullScreenAdGuard.markFullScreenAdShowing();
    readyAd.show(
      onShown: () => unawaited(_frequencyCap.recordShownAt(_now())),
      onClosed: () {
        FullScreenAdGuard.markFullScreenAdClosed();
        // 닫힌 뒤 다음 복귀용으로 미리 불러옴 (오늘 남은 횟수 있을 때만)
        unawaited(preload());
      },
    );
    return true;
  }

  // 복귀 제외 조건 4개 (첫 실행, 짧은 전환, 광고 이탈, 전체 화면 광고 표시 중)
  bool _isEligibleResume(DateTime? backgroundedAt, bool isCausedByAd) {
    if (backgroundedAt == null) return false;
    if (isCausedByAd) return false;
    if (FullScreenAdGuard.isFullScreenAdShowing) return false;
    // 기기 시각을 되돌린 경우(음수)도 짧은 전환으로 봄
    return _now().difference(backgroundedAt) >= minimumBackgroundDuration;
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

/// 앱 전체에서 하나 (복귀 판정 상태·준비 광고 공유)
final appOpenAdControllerProvider = Provider<AppOpenAdController>(
  (ref) => AppOpenAdController(
    loader: ref.watch(appOpenAdLoaderProvider),
    frequencyCap: AppOpenFrequencyCap(
      SharedPreferencesAppOpenShowHistoryStore(),
    ),
  ),
);
