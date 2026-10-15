import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/monitoring/analytics_event_names.dart';
import 'package:passql_app/core/monitoring/app_analytics.dart';

import '../../helpers/fakes/fake_analytics_backend.dart';

void main() {
  late FakeAnalyticsBackend backend;
  late AppAnalytics analytics;

  setUp(() {
    backend = FakeAnalyticsBackend();
    analytics = AppAnalytics(backend);
  });

  test('답안 제출은 정답 여부를 숫자로, 토픽은 알 때만 보낸다', () async {
    await analytics.logAnswerSubmitted(isCorrect: true, topicName: 'JOIN');
    await analytics.logAnswerSubmitted(isCorrect: false);

    expect(
      backend.loggedEvents.map((event) => event.$1),
      everyElement(AnalyticsEventNames.answerSubmitted),
    );
    expect(backend.loggedEvents.map((event) => event.$2).toList(), [
      {
        AnalyticsParameterNames.isCorrect: 1,
        AnalyticsParameterNames.topicName: 'JOIN',
      },
      {AnalyticsParameterNames.isCorrect: 0},
    ]);
  });

  test('파라미터 값은 Firebase 가 받는 문자열·숫자뿐이다', () async {
    await analytics.logLoginCompleted('google');
    await analytics.logChapterCompleted(
      topicCode: 'sql_join',
      correctCount: 7,
      questionCount: 10,
    );
    await analytics.logAiExplanationRequested(isErrorExplanation: true);

    final parameterValues = backend.loggedEvents.expand(
      (event) => event.$2.values,
    );
    expect(
      parameterValues.every((value) => value is String || value is num),
      isTrue,
    );
  });
}
