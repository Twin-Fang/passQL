import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

import '../ads/full_screen_ad_guard.dart';
import '../monitoring/app_analytics.dart';
import '../utils/app_clock.dart';
import 'store_review_prompt_history.dart';
import 'store_review_prompt_rule.dart';

/// 평가 요청을 일으킨 학습 2종 (분석 이벤트 값)
enum StoreReviewTrigger {
  dailySet('daily_set'),
  mockExam('mock_exam');

  const StoreReviewTrigger(this.analyticsValue);

  final String analyticsValue;
}

/// 시스템 평가 창 포트 (in_app_review 는 여기서만 import), 테스트는 가짜로 교체
abstract interface class StoreReviewRequester {
  /// 이 기기에서 시스템 평가 창을 쓸 수 있는지 (Android 는 Play 스토어 앱 필요)
  Future<bool> isAvailable();

  /// 시스템 평가 창 요청 (표시 여부·횟수는 OS 가 정함, 결과를 돌려주지 않음)
  Future<void> requestReview();
}

/// in_app_review 어댑터: iOS SKStoreReviewController, Android Play In-App Review
/// 스토어 페이지 열기(openStoreListing)는 자동으로 쓰지 않음
class InAppReviewStoreReviewRequester implements StoreReviewRequester {
  const InAppReviewStoreReviewRequester();

  @override
  Future<bool> isAvailable() => InAppReview.instance.isAvailable();

  @override
  Future<void> requestReview() => InAppReview.instance.requestReview();
}

/// 학습 결과 화면의 스토어 평가 요청 (#864)
/// 완료 기록 > 판정 > 결과 감상 대기 > 전면 광고 닫힘 대기 > 화면 확인 > 시스템 창 > 요청 기록
class StoreReviewPrompter {
  StoreReviewPrompter({
    required StoreReviewPromptHistoryStore historyStore,
    required StoreReviewRequester requester,
    required Future<String> Function() readAppVersion,
    required AppAnalytics analytics,
    DateTime Function()? now,
  }) : _historyStore = historyStore,
       _requester = requester,
       _readAppVersion = readAppVersion,
       _analytics = analytics,
       _now = now ?? AppClock.now;

  /// 결과 화면이 보인 뒤 시스템 창까지 기다리는 시간 (점수 고리 연출 1초 + 점수를 읽을 시간)
  static const Duration resultViewingDelay = Duration(milliseconds: 2500);

  /// 전면 광고 닫힘을 기다리는 최대 시간 (닫힘 콜백 유실 시 대기 상태가 남지 않게)
  static const Duration fullScreenAdMaximumWait = Duration(minutes: 2);

  final StoreReviewPromptHistoryStore _historyStore;
  final StoreReviewRequester _requester;
  final Future<String> Function() _readAppVersion;
  final AppAnalytics _analytics;
  final DateTime Function() _now;

  // 대기 중인 요청이 있으면 다음 결과 화면은 판정만 건너뜀 (완료 기록은 남김)
  bool _isRequestPending = false;

  /// 결과 화면 진입 1회: 완료 기록 후 조건을 채우면 잠시 뒤 시스템 평가 창 요청
  /// [isResultStillVisible]: 대기 뒤 결과 화면이 아직 앞에 있는지 (떠났으면 요청하지 않음)
  Future<void> recordStudyCompletedAndRequestIfEligible({
    required StoreReviewTrigger trigger,
    required bool isGoodResult,
    required bool Function() isResultStillVisible,
  }) async {
    try {
      final history = await _recordStudyCompleted();
      if (_isRequestPending) return;
      final appVersion = await _readAppVersion();
      final decision = StoreReviewPromptRule.decide(
        history: history,
        now: _now(),
        appVersion: appVersion,
        isGoodResult: isGoodResult,
      );
      if (decision != StoreReviewPromptDecision.eligible) {
        debugPrint('[store review] skipped : ${decision.name}');
        return;
      }
      _isRequestPending = true;
      try {
        await _requestAfterResultViewed(
          trigger: trigger,
          appVersion: appVersion,
          isResultStillVisible: isResultStillVisible,
        );
      } finally {
        _isRequestPending = false;
      }
    } catch (error) {
      // 평가 요청 실패는 학습 흐름에 영향 없음 > 기록만
      debugPrint('[store review] request failed : $error');
    }
  }

  /// 대기 > 화면·기기 확인 > 시스템 창 > 요청 기록·분석 이벤트
  Future<void> _requestAfterResultViewed({
    required StoreReviewTrigger trigger,
    required String appVersion,
    required bool Function() isResultStillVisible,
  }) async {
    await _waitUntilResultViewed();
    if (FullScreenAdGuard.isFullScreenAdShowing || !isResultStillVisible()) {
      debugPrint('[store review] skipped : result screen left or ad showing');
      return;
    }
    if (!await _requester.isAvailable()) {
      debugPrint('[store review] skipped : review not available');
      return;
    }
    await _requester.requestReview();
    await _recordRequested(appVersion);
    unawaited(_analytics.logStoreReviewRequested(trigger.analyticsValue));
  }

  Future<StoreReviewPromptHistory> _recordStudyCompleted() async {
    final history = (await _historyStore.read()).recordStudyCompletedAt(_now());
    await _historyStore.write(history);
    return history;
  }

  // 결과를 읽을 시간 > 전면 광고가 떠 있으면 닫힐 때까지 + 닫힌 뒤 다시 읽을 시간
  Future<void> _waitUntilResultViewed() async {
    await Future<void>.delayed(resultViewingDelay);
    if (!FullScreenAdGuard.isFullScreenAdShowing) return;
    await FullScreenAdGuard.waitUntilFullScreenAdClosed().timeout(
      fullScreenAdMaximumWait,
      onTimeout: () {},
    );
    await Future<void>.delayed(resultViewingDelay);
  }

  Future<void> _recordRequested(String appVersion) async {
    final history = await _historyStore.read();
    await _historyStore.write(history.recordRequestedAt(_now(), appVersion));
  }
}
