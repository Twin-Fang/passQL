import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'app_analytics.dart';

/// Firebase Analytics 로 보내는 [AnalyticsBackend] 구현
class FirebaseAnalyticsBackend extends AnalyticsBackend {
  const FirebaseAnalyticsBackend(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String eventName, Map<String, Object> parameters) =>
      _analytics.logEvent(
        name: eventName,
        parameters: parameters.isEmpty ? null : parameters,
      );

  @override
  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> setMemberIdentifier(String? memberUuid) =>
      _analytics.setUserId(id: memberUuid);
}

/// 분석 수집 시작 (Firebase.initializeApp 뒤 1회): 디버그 빌드 수집 끔 > 전역 분석기 교체
Future<void> startFirebaseAnalytics() async {
  final analytics = FirebaseAnalytics.instance;
  await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
  AppAnalytics.current = AppAnalytics(FirebaseAnalyticsBackend(analytics));
}
