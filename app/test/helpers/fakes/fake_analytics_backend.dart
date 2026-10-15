import 'package:passql_app/core/monitoring/app_analytics.dart';

/// 기록된 이벤트·화면 이름만 모으는 가짜 분석 backend
class FakeAnalyticsBackend extends AnalyticsBackend {
  final List<(String, Map<String, Object>)> loggedEvents = [];
  final List<String> loggedScreenNames = [];

  @override
  Future<void> logEvent(
    String eventName,
    Map<String, Object> parameters,
  ) async => loggedEvents.add((eventName, parameters));

  @override
  Future<void> logScreenView(String screenName) async =>
      loggedScreenNames.add(screenName);

  @override
  Future<void> setMemberIdentifier(String? memberUuid) async {}
}
